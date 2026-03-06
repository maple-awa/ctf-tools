import 'dart:convert';

import 'package:crypto/crypto.dart' as crypto;

class JwtDecodeResult {
  const JwtDecodeResult({
    required this.header,
    required this.payload,
    required this.signature,
    required this.verified,
  });

  final Map<String, dynamic> header;
  final Map<String, dynamic> payload;
  final String signature;
  final bool? verified;
}

class JwtToolkit {
  static JwtDecodeResult decode(String token, {String? secret}) {
    final parts = token.trim().split('.');
    if (parts.length != 3) {
      throw const FormatException('JWT 必须包含 header.payload.signature');
    }
    final header = json.decode(utf8.decode(base64Url.decode(base64Url.normalize(parts[0])))) as Map<String, dynamic>;
    final payload = json.decode(utf8.decode(base64Url.decode(base64Url.normalize(parts[1])))) as Map<String, dynamic>;
    bool? verified;
    if (secret != null && secret.isNotEmpty) {
      verified = verify(token, secret);
    }
    return JwtDecodeResult(header: header, payload: payload, signature: parts[2], verified: verified);
  }

  static String encode({
    required Map<String, dynamic> header,
    required Map<String, dynamic> payload,
    required String algorithm,
    String secret = '',
  }) {
    final normalizedHeader = {...header, 'alg': algorithm};
    final encodedHeader = _encodeJson(normalizedHeader);
    final encodedPayload = _encodeJson(payload);
    final signingInput = '$encodedHeader.$encodedPayload';
    final signature = switch (algorithm) {
      'none' => '',
      'HS256' => _sign(signingInput, secret, crypto.sha256),
      'HS384' => _sign(signingInput, secret, crypto.sha384),
      'HS512' => _sign(signingInput, secret, crypto.sha512),
      _ => throw FormatException('不支持的 JWT 算法: $algorithm'),
    };
    return '$signingInput.$signature';
  }

  static bool verify(String token, String secret) {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw const FormatException('JWT 格式错误');
    }
    final header = json.decode(utf8.decode(base64Url.decode(base64Url.normalize(parts[0])))) as Map<String, dynamic>;
    final alg = (header['alg'] ?? '').toString();
    if (alg == 'none') {
      return parts[2].isEmpty;
    }
    final expected = encode(
      header: header,
      payload: json.decode(utf8.decode(base64Url.decode(base64Url.normalize(parts[1])))) as Map<String, dynamic>,
      algorithm: alg,
      secret: secret,
    );
    return expected == token;
  }

  static String _encodeJson(Map<String, dynamic> value) {
    return base64Url.encode(utf8.encode(json.encode(value))).replaceAll('=', '');
  }

  static String _sign(String input, String secret, crypto.Hash hash) {
    final digest = crypto.Hmac(hash, utf8.encode(secret)).convert(utf8.encode(input));
    return base64Url.encode(digest.bytes).replaceAll('=', '');
  }
}
