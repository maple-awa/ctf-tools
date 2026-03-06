import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:ctf_tools/features/network/utils/target_parser.dart';

class ProtocolRunResult {
  const ProtocolRunResult({
    required this.title,
    required this.requestLog,
    required this.responseLog,
    required this.summary,
    this.curl,
  });

  final String title;
  final String requestLog;
  final String responseLog;
  final List<String> summary;
  final String? curl;

  String format() {
    return [
      title,
      ...summary,
      '',
      'Request:',
      requestLog.isEmpty ? '(empty)' : requestLog,
      '',
      'Response:',
      responseLog.isEmpty ? '(empty)' : responseLog,
      if (curl != null && curl!.isNotEmpty) '',
      if (curl != null && curl!.isNotEmpty) 'cURL:',
      if (curl != null && curl!.isNotEmpty) curl!,
    ].join('\n');
  }
}

class ProtocolClients {
  static const Map<String, List<String>> scriptedTemplates = {
    'SMTP': [
      'EHLO ctf.tools',
      'MAIL FROM:<ctf@example.com>',
      'RCPT TO:<flag@example.com>',
      'DATA',
      'Subject: test',
      '',
      'flag{demo}',
      '.',
      'QUIT',
    ],
    'FTP': [
      'USER anonymous',
      'PASS anonymous@ctf.tools',
      'SYST',
      'PWD',
      'QUIT',
    ],
    'POP3': ['USER demo', 'PASS demo', 'STAT', 'LIST', 'QUIT'],
  };

  static ProtocolRunResult buildHttpRequest({
    required String method,
    required String url,
    required String headersText,
    required String body,
  }) {
    final uri = Uri.parse(url.trim());
    final path = uri.hasQuery
        ? '${uri.path.isEmpty ? '/' : uri.path}?${uri.query}'
        : (uri.path.isEmpty ? '/' : uri.path);
    final headers = _parseHeaders(headersText);
    final requestLines = <String>[
      '$method $path HTTP/1.1',
      'Host: ${uri.host}',
    ];
    requestLines.addAll(
      headers.entries.map((entry) => '${entry.key}: ${entry.value}'),
    );
    if (body.isNotEmpty) {
      requestLines.add('Content-Length: ${utf8.encode(body).length}');
    }
    requestLines.add('');
    if (body.isNotEmpty) {
      requestLines.add(body);
    }

    final curlHeaders = headers.entries
        .map((entry) {
          final escaped = '${entry.key}: ${entry.value}'.replaceAll(
            "'",
            "'\\''",
          );
          return "-H '$escaped'";
        })
        .join(' ');
    final curlBody = body.isEmpty
        ? ''
        : " --data '${body.replaceAll("'", "'\\''")}'";

    return ProtocolRunResult(
      title: 'HTTP Build',
      requestLog: requestLines.join('\n'),
      responseLog: '未发送，仅构造请求。',
      summary: [
        'Target: ${uri.scheme}://${uri.host}${uri.hasPort ? ':${uri.port}' : ''}',
        'Method: $method',
      ],
      curl: "curl -X $method $curlHeaders$curlBody '${uri.toString()}'".trim(),
    );
  }

  static Future<ProtocolRunResult> sendHttp({
    required String method,
    required String url,
    required String headersText,
    required String body,
    Duration timeout = const Duration(seconds: 8),
  }) async {
    final built = buildHttpRequest(
      method: method,
      url: url,
      headersText: headersText,
      body: body,
    );
    final uri = Uri.parse(url.trim());
    final client = HttpClient()..connectionTimeout = timeout;
    try {
      final request = await client.openUrl(method, uri).timeout(timeout);
      final headers = _parseHeaders(headersText);
      headers.forEach(request.headers.set);
      if (body.isNotEmpty) {
        request.write(body);
      }
      final response = await request.close().timeout(timeout);
      final responseBody = await utf8.decodeStream(response).timeout(timeout);
      final responseHeaders = _formatHeaders(response.headers);
      return ProtocolRunResult(
        title: 'HTTP Response',
        requestLog: built.requestLog,
        responseLog:
            'HTTP ${response.statusCode} ${response.reasonPhrase}\n$responseHeaders\n\n$responseBody',
        summary: [
          'Target: ${uri.scheme}://${uri.host}${uri.hasPort ? ':${uri.port}' : ''}',
          'Status: ${response.statusCode}',
          'Body Length: ${responseBody.length}',
        ],
        curl: built.curl,
      );
    } finally {
      client.close(force: true);
    }
  }

  static Future<ProtocolRunResult> tcpRequest({
    required String target,
    required String payload,
    Duration timeout = const Duration(seconds: 6),
  }) async {
    final parsed = NetworkTargetParser.parse(target);
    final port = parsed.port;
    if (port == null) {
      throw const FormatException('TCP 目标必须包含端口');
    }
    final socket = await Socket.connect(parsed.host, port, timeout: timeout);
    try {
      socket.write(payload);
      await socket.flush();
      await socket.close();
      final response = await utf8.decoder
          .bind(socket)
          .join()
          .timeout(timeout, onTimeout: () => '');
      return ProtocolRunResult(
        title: 'TCP Session',
        requestLog: payload,
        responseLog: response,
        summary: [
          'Host: ${parsed.host}',
          'Port: $port',
          'Bytes Sent: ${utf8.encode(payload).length}',
        ],
      );
    } finally {
      socket.destroy();
    }
  }

  static Future<ProtocolRunResult> webSocketRequest({
    required String url,
    required String payload,
    Duration timeout = const Duration(seconds: 8),
  }) async {
    final socket = await WebSocket.connect(url).timeout(timeout);
    final responses = <String>[];
    late final StreamSubscription<dynamic> sub;
    sub = socket.listen((event) {
      responses.add(event.toString());
    });
    try {
      socket.add(payload);
      await Future<void>.delayed(const Duration(milliseconds: 600));
      await socket.close();
      return ProtocolRunResult(
        title: 'WebSocket Session',
        requestLog: payload,
        responseLog: responses.join('\n'),
        summary: ['Target: $url', 'Frames Received: ${responses.length}'],
      );
    } finally {
      await sub.cancel();
    }
  }

  static Future<ProtocolRunResult> runScriptedProtocol({
    required String protocol,
    required String target,
    required String script,
    Duration timeout = const Duration(seconds: 6),
  }) async {
    final parsed = NetworkTargetParser.parse(
      target,
      defaultPort: switch (protocol) {
        'SMTP' => 25,
        'FTP' => 21,
        'POP3' => 110,
        _ => null,
      },
    );
    final port = parsed.port;
    if (port == null) {
      throw const FormatException('协议交互需要端口');
    }
    final socket = await Socket.connect(parsed.host, port, timeout: timeout);
    final lines = <String>[];
    final completer = Completer<void>();
    socket.listen(
      (event) {
        lines.add(utf8.decode(event, allowMalformed: true));
      },
      onDone: () {
        if (!completer.isCompleted) {
          completer.complete();
        }
      },
    );
    try {
      await Future<void>.delayed(const Duration(milliseconds: 300));
      final commands = script.split('\n');
      for (final command in commands) {
        socket.write('$command\r\n');
        await socket.flush();
        await Future<void>.delayed(const Duration(milliseconds: 120));
      }
      await socket.close();
      await completer.future.timeout(timeout, onTimeout: () {});
      return ProtocolRunResult(
        title: '$protocol Session',
        requestLog: commands.join('\n'),
        responseLog: lines.join(''),
        summary: [
          'Host: ${parsed.host}',
          'Port: $port',
          'Commands: ${commands.length}',
        ],
      );
    } finally {
      socket.destroy();
    }
  }

  static Map<String, String> _parseHeaders(String input) {
    final headers = <String, String>{};
    for (final line in input.split('\n')) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) {
        continue;
      }
      final parts = trimmed.split(':');
      if (parts.length < 2) {
        continue;
      }
      headers[parts.first.trim()] = parts.sublist(1).join(':').trim();
    }
    return headers;
  }

  static String _formatHeaders(HttpHeaders headers) {
    final lines = <String>[];
    headers.forEach((name, values) {
      for (final value in values) {
        lines.add('$name: $value');
      }
    });
    return lines.join('\n');
  }
}
