/// 离线 HTTP 报文解析工具。
class HttpMessageParser {
  static HttpMessageParseResult parse(String rawText) {
    final normalized = rawText.replaceAll('\r\n', '\n').trim();
    if (normalized.isEmpty) {
      throw const FormatException('HTTP 报文不能为空');
    }

    final parts = normalized.split('\n\n');
    final head = parts.first;
    final body = parts.length > 1 ? parts.sublist(1).join('\n\n') : '';
    final lines = head.split('\n');
    final startLine = lines.first.trim();
    final headers = <HttpHeader>[];

    for (final line in lines.skip(1)) {
      final index = line.indexOf(':');
      if (index <= 0) continue;
      headers.add(
        HttpHeader(
          name: line.substring(0, index).trim(),
          value: line.substring(index + 1).trim(),
        ),
      );
    }

    if (startLine.startsWith('HTTP/')) {
      final tokens = startLine.split(' ');
      if (tokens.length < 2) {
        throw const FormatException('响应行格式非法');
      }
      return HttpMessageParseResult(
        messageType: 'HTTP Response',
        summary: [
          'Version: ${tokens[0]}',
          'Status: ${tokens.length > 1 ? tokens[1] : ''}',
          if (tokens.length > 2) 'Reason: ${tokens.sublist(2).join(' ')}',
          'Header Count: ${headers.length}',
          'Body Length: ${body.length}',
        ],
        headers: headers,
        bodyPreview: body,
      );
    }

    final tokens = startLine.split(' ');
    if (tokens.length < 3) {
      throw const FormatException('请求行格式非法');
    }
    return HttpMessageParseResult(
      messageType: 'HTTP Request',
      summary: [
        'Method: ${tokens[0]}',
        'Path: ${tokens[1]}',
        'Version: ${tokens[2]}',
        'Header Count: ${headers.length}',
        'Body Length: ${body.length}',
      ],
      headers: headers,
      bodyPreview: body,
    );
  }
}

class HttpMessageParseResult {
  const HttpMessageParseResult({
    required this.messageType,
    required this.summary,
    required this.headers,
    required this.bodyPreview,
  });

  final String messageType;
  final List<String> summary;
  final List<HttpHeader> headers;
  final String bodyPreview;
}

class HttpHeader {
  const HttpHeader({
    required this.name,
    required this.value,
  });

  final String name;
  final String value;
}
