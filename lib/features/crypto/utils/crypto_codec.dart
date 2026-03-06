import 'dart:convert';

import 'package:convert/convert.dart';

class CryptoCodec {
  static const List<String> byteFormats = ['UTF-8', 'Hex', 'Base64'];
  static const List<String> rsaFormats = ['Integer', 'UTF-8', 'Hex', 'Base64'];
  static const List<String> outputFormats = ['UTF-8', 'Hex lower', 'Hex upper', 'Base64'];

  static List<int> parseBytes(String input, String format) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) {
      throw const FormatException('输入不能为空');
    }

    return switch (format) {
      'UTF-8' => utf8.encode(input),
      'Hex' => _parseHex(trimmed),
      'Base64' => base64.decode(trimmed),
      _ => throw FormatException('不支持的字节格式: $format'),
    };
  }

  static String formatBytes(List<int> bytes, String format) {
    return switch (format) {
      'UTF-8' => utf8.decode(bytes, allowMalformed: true),
      'Hex lower' => hex.encode(bytes),
      'Hex upper' => hex.encode(bytes).toUpperCase(),
      'Base64' => base64.encode(bytes),
      _ => throw FormatException('不支持的输出格式: $format'),
    };
  }

  static BigInt parseRsaValue(String input, String format) {
    return switch (format) {
      'Integer' => parseBigInt(input),
      'UTF-8' || 'Hex' || 'Base64' => bytesToBigInt(parseBytes(input, format)),
      _ => throw FormatException('不支持的 RSA 输入格式: $format'),
    };
  }

  static String formatRsaValue(BigInt value, String format) {
    return switch (format) {
      'Integer' => value.toString(),
      'UTF-8' || 'Hex lower' || 'Hex upper' || 'Base64' =>
        formatBytes(bigIntToBytes(value), format),
      _ => throw FormatException('不支持的 RSA 输出格式: $format'),
    };
  }

  static BigInt parseBigInt(String input) {
    final normalized = input.trim().replaceAll(RegExp(r'\s+'), '');
    if (normalized.isEmpty) {
      throw const FormatException('数值不能为空');
    }
    if (normalized.startsWith('0x') || normalized.startsWith('0X')) {
      return BigInt.parse(normalized.substring(2), radix: 16);
    }
    if (RegExp(r'^[0-9a-fA-F]+$').hasMatch(normalized) &&
        RegExp(r'[a-fA-F]').hasMatch(normalized)) {
      return BigInt.parse(normalized, radix: 16);
    }
    return BigInt.parse(normalized);
  }

  static String formatBigInt(BigInt value) {
    return 'DEC: $value\nHEX: 0x${value.toRadixString(16).toUpperCase()}';
  }

  static BigInt bytesToBigInt(List<int> bytes) {
    if (bytes.isEmpty) return BigInt.zero;
    final encoded = hex.encode(bytes);
    return BigInt.parse(encoded, radix: 16);
  }

  static List<int> bigIntToBytes(BigInt value) {
    if (value == BigInt.zero) return [0];
    var hexText = value.toRadixString(16);
    if (hexText.length.isOdd) {
      hexText = '0$hexText';
    }
    return hex.decode(hexText);
  }

  static String asciiPreview(List<int> bytes, {int maxLength = 48}) {
    final preview = bytes.take(maxLength).map((byte) {
      if (byte >= 0x20 && byte <= 0x7E) {
        return String.fromCharCode(byte);
      }
      return '.';
    }).join();
    return bytes.length > maxLength ? '$preview...' : preview;
  }

  static List<int> _parseHex(String text) {
    final cleaned = text.replaceAll(RegExp(r'[^0-9a-fA-F]'), '');
    if (cleaned.isEmpty) {
      throw const FormatException('十六进制输入不能为空');
    }
    if (cleaned.length.isOdd) {
      throw const FormatException('十六进制长度必须为偶数');
    }
    return hex.decode(cleaned);
  }
}
