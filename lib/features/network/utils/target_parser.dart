class ParsedNetworkTarget {
  const ParsedNetworkTarget({
    required this.raw,
    required this.host,
    this.port,
    this.uri,
    this.path = '/',
  });

  final String raw;
  final String host;
  final int? port;
  final Uri? uri;
  final String path;
}

class NetworkTargetParser {
  static ParsedNetworkTarget parse(String input, {int? defaultPort}) {
    final raw = input.trim();
    if (raw.isEmpty) {
      throw const FormatException('目标不能为空');
    }

    final withScheme = raw.contains('://') ? raw : 'tcp://$raw';
    final uri = Uri.tryParse(withScheme);
    if (uri != null && uri.host.isNotEmpty) {
      return ParsedNetworkTarget(
        raw: raw,
        host: uri.host,
        port: uri.hasPort ? uri.port : defaultPort,
        uri: raw.contains('://') ? uri : null,
        path: uri.path.isEmpty ? '/' : uri.path,
      );
    }

    final hostPort = raw.split(':');
    if (hostPort.length == 2) {
      final port = int.tryParse(hostPort[1]);
      if (port == null) {
        throw const FormatException('端口格式错误');
      }
      return ParsedNetworkTarget(raw: raw, host: hostPort[0], port: port);
    }

    return ParsedNetworkTarget(raw: raw, host: raw, port: defaultPort);
  }

  static String normalizeHost(String input) {
    return parse(input).host.toLowerCase();
  }
}
