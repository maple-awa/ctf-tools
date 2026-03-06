import 'dart:convert';

/// 从字节流中提取 ASCII 与 UTF-16LE 可打印字符串。
class StringsExtractor {
  static List<int> parseInput(String input, {required bool isHex}) {
    if (!isHex) {
      return utf8.encode(input);
    }

    final cleaned = input.replaceAll(RegExp(r'[^0-9a-fA-F]'), '');
    if (cleaned.isEmpty || cleaned.length.isOdd) {
      throw const FormatException('十六进制输入必须是偶数长度');
    }

    return [
      for (int i = 0; i < cleaned.length; i += 2)
        int.parse(cleaned.substring(i, i + 2), radix: 16),
    ];
  }

  static List<String> extractAscii(List<int> bytes, {int minLength = 4}) {
    return _extractByPredicate(
      bytes,
      minLength: minLength,
      predicate: (value) => value >= 32 && value <= 126,
      decoder: String.fromCharCodes,
    );
  }

  static List<String> extractUtf16Le(List<int> bytes, {int minLength = 4}) {
    final results = <String>[];
    final buffer = <int>[];

    for (int i = 0; i + 1 < bytes.length; i += 2) {
      final low = bytes[i];
      final high = bytes[i + 1];
      if (high == 0 && low >= 32 && low <= 126) {
        buffer.add(low);
      } else {
        if (buffer.length >= minLength) {
          results.add(String.fromCharCodes(buffer));
        }
        buffer.clear();
      }
    }

    if (buffer.length >= minLength) {
      results.add(String.fromCharCodes(buffer));
    }
    return results;
  }

  static List<String> _extractByPredicate(
    List<int> bytes, {
    required int minLength,
    required bool Function(int value) predicate,
    required String Function(List<int> value) decoder,
  }) {
    final results = <String>[];
    final buffer = <int>[];
    for (final value in bytes) {
      if (predicate(value)) {
        buffer.add(value);
      } else {
        if (buffer.length >= minLength) {
          results.add(decoder(List<int>.from(buffer)));
        }
        buffer.clear();
      }
    }
    if (buffer.length >= minLength) {
      results.add(decoder(List<int>.from(buffer)));
    }
    return results;
  }
}
