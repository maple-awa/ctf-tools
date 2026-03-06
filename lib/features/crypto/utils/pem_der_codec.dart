import 'dart:convert';

class PemDerCodec {
  static String pemToDerHex(String pem) {
    final cleaned = pem
        .replaceAll(RegExp(r'-----BEGIN [^-]+-----'), '')
        .replaceAll(RegExp(r'-----END [^-]+-----'), '')
        .replaceAll(RegExp(r'\s+'), '');
    if (cleaned.isEmpty) {
      throw const FormatException('PEM 内容为空');
    }
    final bytes = base64.decode(cleaned);
    return bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join().toUpperCase();
  }

  static String derHexToPem(String hex, {String label = 'PUBLIC KEY'}) {
    final cleaned = hex.replaceAll(RegExp(r'[^0-9a-fA-F]'), '');
    if (cleaned.isEmpty || cleaned.length.isOdd) {
      throw const FormatException('DER Hex 非法');
    }
    final bytes = <int>[];
    for (var index = 0; index < cleaned.length; index += 2) {
      bytes.add(int.parse(cleaned.substring(index, index + 2), radix: 16));
    }
    final body = base64.encode(bytes);
    final chunks = <String>[];
    for (var index = 0; index < body.length; index += 64) {
      final end = (index + 64) > body.length ? body.length : index + 64;
      chunks.add(body.substring(index, end));
    }
    return '-----BEGIN $label-----\n${chunks.join('\n')}\n-----END $label-----';
  }
}
