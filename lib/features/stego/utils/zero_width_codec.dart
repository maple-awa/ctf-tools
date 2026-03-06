import 'dart:convert';

/// 零宽字符隐写编解码工具。
class ZeroWidthCodec {
  static const String zero = '\u200B';
  static const String one = '\u200C';
  static const String separator = '\u200D';

  static String encode(String text) {
    if (text.isEmpty) {
      throw const FormatException('输入不能为空');
    }

    final bytes = utf8.encode(text);
    final parts = bytes.map((byte) {
      final binary = byte.toRadixString(2).padLeft(8, '0');
      return binary
          .split('')
          .map((bit) => bit == '0' ? zero : one)
          .join();
    });
    return parts.join(separator);
  }

  static String decode(String text) {
    final cleaned = text
        .split('')
        .where((char) => char == zero || char == one || char == separator)
        .join();
    if (cleaned.isEmpty) {
      throw const FormatException('未检测到零宽字符载荷');
    }

    final bytes = <int>[];
    for (final chunk in cleaned.split(separator)) {
      if (chunk.isEmpty) continue;
      final binary = chunk
          .split('')
          .map((char) => char == zero ? '0' : '1')
          .join();
      if (binary.length != 8) {
        throw const FormatException('零宽字符载荷格式非法');
      }
      bytes.add(int.parse(binary, radix: 2));
    }
    return utf8.decode(bytes, allowMalformed: true);
  }

  static String inspect(String text) {
    var zeroCount = 0;
    var oneCount = 0;
    var separatorCount = 0;

    for (final char in text.split('')) {
      if (char == zero) {
        zeroCount++;
      } else if (char == one) {
        oneCount++;
      } else if (char == separator) {
        separatorCount++;
      }
    }

    return 'U+200B: $zeroCount\nU+200C: $oneCount\nU+200D: $separatorCount';
  }
}
