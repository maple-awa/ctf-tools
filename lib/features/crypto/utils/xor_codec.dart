import 'dart:convert';

/// XOR 编解码辅助工具，支持文本和十六进制输出。
class XorCodec {
  static String xorText(String input, String key) {
    final inputBytes = utf8.encode(input);
    final keyBytes = _parseKey(key);
    return utf8.decode(_xorBytes(inputBytes, keyBytes), allowMalformed: true);
  }

  static String xorToHex(String input, String key) {
    final inputBytes = utf8.encode(input);
    final keyBytes = _parseKey(key);
    return _xorBytes(
      inputBytes,
      keyBytes,
    ).map((value) => value.toRadixString(16).padLeft(2, '0')).join(' ').toUpperCase();
  }

  static String decodeHex(String hexInput, String key) {
    final bytes = _parseHex(hexInput);
    final keyBytes = _parseKey(key);
    return utf8.decode(_xorBytes(bytes, keyBytes), allowMalformed: true);
  }

  static List<int> _parseKey(String key) {
    if (key.isEmpty) {
      throw const FormatException('XOR 密钥不能为空');
    }
    return utf8.encode(key);
  }

  static List<int> _parseHex(String value) {
    final cleaned = value.replaceAll(RegExp(r'[^0-9a-fA-F]'), '');
    if (cleaned.isEmpty || cleaned.length.isOdd) {
      throw const FormatException('十六进制输入必须是偶数长度');
    }
    return [
      for (int i = 0; i < cleaned.length; i += 2)
        int.parse(cleaned.substring(i, i + 2), radix: 16),
    ];
  }

  static List<int> _xorBytes(List<int> input, List<int> key) {
    return [
      for (int i = 0; i < input.length; i++) input[i] ^ key[i % key.length],
    ];
  }
}
