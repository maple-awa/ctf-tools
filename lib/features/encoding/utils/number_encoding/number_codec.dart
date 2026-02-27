/// 数值与进制转换工具集。
class NumberCodec {
  /// 通用进制转换（支持 2~64）。
  ///
  /// 字符集顺序：`0-9 A-Z a-z + /`。
  static String convertBase(
    String input, {
    required int fromBase,
    required int toBase,
  }) {
    _validateBase(fromBase);
    _validateBase(toBase);

    final normalized = _normalizeNumberInput(input);
    if (normalized.isEmpty) {
      throw const FormatException('输入不能为空');
    }

    final negative = normalized.startsWith('-');
    final body = negative ? normalized.substring(1) : normalized;
    if (body.isEmpty) {
      throw const FormatException('非法数字');
    }

    final value = _parseBigIntByBase(body, fromBase);
    final converted = _formatBigIntByBase(value, toBase);
    return negative && value != BigInt.zero ? '-$converted' : converted;
  }

  /// 二进制转十六进制。
  static String binaryToHex(String binary) {
    final cleaned = binary.replaceAll(RegExp(r'\s+'), '');
    if (cleaned.isEmpty) {
      throw const FormatException('输入不能为空');
    }
    if (!RegExp(r'^[01]+$').hasMatch(cleaned)) {
      throw const FormatException('二进制输入仅允许 0/1');
    }

    final rem = cleaned.length % 4;
    final padded = rem == 0 ? cleaned : '${'0' * (4 - rem)}$cleaned';

    final out = StringBuffer();
    for (int i = 0; i < padded.length; i += 4) {
      final chunk = padded.substring(i, i + 4);
      out.write(int.parse(chunk, radix: 2).toRadixString(16));
    }
    return out.toString().toUpperCase();
  }

  /// 十六进制转二进制（每个 hex 保留 4 位）。
  static String hexToBinary(String hexInput) {
    final cleaned = hexInput
        .replaceAll(RegExp(r'0x', caseSensitive: false), '')
        .replaceAll(RegExp(r'\s+'), '')
        .toUpperCase();

    if (cleaned.isEmpty) {
      throw const FormatException('输入不能为空');
    }
    if (!RegExp(r'^[0-9A-F]+$').hasMatch(cleaned)) {
      throw const FormatException('十六进制输入非法');
    }

    final out = StringBuffer();
    for (final ch in cleaned.split('')) {
      final value = int.parse(ch, radix: 16);
      out.write(value.toRadixString(2).padLeft(4, '0'));
    }
    return out.toString();
  }

  /// 十进制字符串转 BCD（输出 hex）。
  static String decimalToBcdHex(String decimal) {
    final cleaned = decimal.replaceAll(RegExp(r'\s+'), '');
    if (cleaned.isEmpty) {
      throw const FormatException('输入不能为空');
    }
    if (!RegExp(r'^\d+$').hasMatch(cleaned)) {
      throw const FormatException('BCD 编码仅支持十进制数字');
    }

    final normalized = cleaned.length.isOdd ? '0$cleaned' : cleaned;
    final out = <String>[];
    for (int i = 0; i < normalized.length; i += 2) {
      final high = int.parse(normalized[i]);
      final low = int.parse(normalized[i + 1]);
      final byte = (high << 4) | low;
      out.add(byte.toRadixString(16).padLeft(2, '0').toUpperCase());
    }
    return out.join(' ');
  }

  /// BCD hex 转十进制字符串。
  static String bcdHexToDecimal(String bcdHex) {
    final cleaned = bcdHex
        .replaceAll(RegExp(r'0x', caseSensitive: false), '')
        .replaceAll(RegExp(r'\s+'), '')
        .toUpperCase();

    if (cleaned.isEmpty) {
      throw const FormatException('输入不能为空');
    }
    if (!RegExp(r'^[0-9A-F]+$').hasMatch(cleaned) || cleaned.length.isOdd) {
      throw const FormatException('BCD 输入必须是偶数长度十六进制');
    }

    final out = StringBuffer();
    for (int i = 0; i < cleaned.length; i += 2) {
      final byte = int.parse(cleaned.substring(i, i + 2), radix: 16);
      final high = (byte >> 4) & 0x0F;
      final low = byte & 0x0F;
      if (high > 9 || low > 9) {
        throw const FormatException('非法 BCD 字节，nibble 必须在 0~9');
      }
      out.write(high);
      out.write(low);
    }

    return out.toString().replaceFirst(RegExp(r'^0+(?!$)'), '');
  }

  static BigInt _parseBigIntByBase(String source, int radix) {
    var result = BigInt.zero;
    final radixBigInt = BigInt.from(radix);

    for (final ch in source.split('')) {
      final digit = _charToDigit(ch, radix);
      if (digit < 0 || digit >= radix) {
        throw FormatException('字符 "$ch" 不属于 $radix 进制');
      }
      result = result * radixBigInt + BigInt.from(digit);
    }

    return result;
  }

  static String _formatBigIntByBase(BigInt value, int radix) {
    if (value == BigInt.zero) {
      return '0';
    }

    final radixBigInt = BigInt.from(radix);
    final chars = <String>[];
    var temp = value;
    while (temp > BigInt.zero) {
      final mod = (temp % radixBigInt).toInt();
      chars.add(_digitToChar(mod));
      temp = temp ~/ radixBigInt;
    }

    return chars.reversed.join();
  }

  static int _charToDigit(String ch, int radix) {
    final index = _digits.indexOf(ch);
    if (index >= 0) {
      if (index < radix) {
        return index;
      }
      // base<=36 时，小写字母优先按 A-Z 解释。
      if (radix <= 36 && RegExp(r'^[a-z]$').hasMatch(ch)) {
        final upper = ch.toUpperCase();
        final upperIndex = _digits.indexOf(upper);
        if (upperIndex >= 0 && upperIndex < radix) {
          return upperIndex;
        }
      }
      return -1;
    }

    return -1;
  }

  static String _digitToChar(int digit) {
    if (digit < 0 || digit >= _digits.length) {
      throw FormatException('非法 digit: $digit');
    }
    return _digits[digit];
  }

  static String _normalizeNumberInput(String input) {
    return input.trim().replaceAll(RegExp(r'\s+'), '');
  }

  static void _validateBase(int radix) {
    if (radix < 2 || radix > 64) {
      throw FormatException('进制必须在 2~64: $radix');
    }
  }

  static const String _digits =
      '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz+/';
}
