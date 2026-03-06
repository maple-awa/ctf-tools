/// 类似 pwntools cyclic 的模式生成与偏移查询工具。
class CyclicPattern {
  static String generate(int length) {
    if (length <= 0) {
      throw const FormatException('长度必须大于 0');
    }

    const upper = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const lower = 'abcdefghijklmnopqrstuvwxyz';
    const digits = '0123456789';
    final buffer = StringBuffer();

    for (final a in upper.split('')) {
      for (final b in lower.split('')) {
        for (final c in digits.split('')) {
          buffer.write(a);
          if (buffer.length >= length) return buffer.toString().substring(0, length);
          buffer.write(b);
          if (buffer.length >= length) return buffer.toString().substring(0, length);
          buffer.write(c);
          if (buffer.length >= length) return buffer.toString().substring(0, length);
        }
      }
    }

    return buffer.toString().substring(0, length);
  }

  static int findOffset(String needle, {int maxLength = 8192}) {
    final normalized = needle.trim();
    if (normalized.isEmpty) {
      throw const FormatException('查找内容不能为空');
    }

    final pattern = generate(maxLength);
    final index = pattern.indexOf(normalized);
    if (index >= 0) {
      return index;
    }

    if (RegExp(r'^[0-9a-fA-F]+$').hasMatch(normalized) &&
        normalized.length.isEven &&
        normalized.length <= 16) {
      final asciiNeedle = _hexToAscii(normalized);
      return pattern.indexOf(asciiNeedle);
    }

    return -1;
  }

  static String _hexToAscii(String hex) {
    final chars = <int>[];
    for (int i = 0; i < hex.length; i += 2) {
      chars.add(int.parse(hex.substring(i, i + 2), radix: 16));
    }
    return String.fromCharCodes(chars);
  }
}
