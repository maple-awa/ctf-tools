import 'dart:convert';

import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart' as crypto;

/// 常见哈希/校验算法工具。
class HashTools {
  static const List<String> algorithms = [
    'MD5',
    'SHA-1',
    'SHA-224',
    'SHA-256',
    'SHA-384',
    'SHA-512',
    'CRC32',
    'Adler32',
    'FNV-1 32',
    'FNV-1a 32',
    'FNV-1 64',
    'FNV-1a 64',
  ];

  static const List<String> inputFormats = ['UTF-8', 'Hex', 'Base64'];
  static const List<String> outputFormats = ['HEX lower', 'HEX upper', 'Base64'];

  static final Map<String, crypto.Hash> _digestAlgorithms = {
    'MD5': crypto.md5,
    'SHA-1': crypto.sha1,
    'SHA-224': crypto.sha224,
    'SHA-256': crypto.sha256,
    'SHA-384': crypto.sha384,
    'SHA-512': crypto.sha512,
  };

  static String digest({
    required String algorithm,
    required String input,
    required String inputFormat,
    required String outputFormat,
    String? hmacKey,
  }) {
    final inputBytes = parseInput(input, inputFormat);
    final resultBytes = _computeBytes(
      algorithm: algorithm,
      inputBytes: inputBytes,
      hmacKey: hmacKey,
    );
    return formatBytes(resultBytes, outputFormat);
  }

  static Map<String, String> digestAll({
    required String input,
    required String inputFormat,
    required String outputFormat,
    String? hmacKey,
  }) {
    final inputBytes = parseInput(input, inputFormat);
    final result = <String, String>{};

    if (_isHmacEnabled(hmacKey)) {
      for (final algorithm in _digestAlgorithms.keys) {
        final bytes = _computeBytes(
          algorithm: algorithm,
          inputBytes: inputBytes,
          hmacKey: hmacKey,
        );
        result['HMAC-$algorithm'] = formatBytes(bytes, outputFormat);
      }
      return result;
    }

    for (final algorithm in algorithms) {
      final bytes = _computeBytes(
        algorithm: algorithm,
        inputBytes: inputBytes,
      );
      result[algorithm] = formatBytes(bytes, outputFormat);
    }
    return result;
  }

  static List<String> identifyDigest(String input) {
    final trimmed = input.trim();
    final cleaned = trimmed.replaceAll(RegExp(r'\s+'), '');
    if (cleaned.isEmpty) {
      throw const FormatException('摘要不能为空');
    }

    final results = <String>[];

    if (_looksLikePasswordHash(cleaned, results)) {
      return results;
    }

    if (RegExp(r'^\d+$').hasMatch(cleaned)) {
      results.add('可能是十进制 CRC32 / Adler32 / 32-bit 校验值');
    }

    final isHex = RegExp(r'^[0-9a-fA-F]+$').hasMatch(cleaned);
    if (isHex && cleaned.length.isEven) {
      final byteLength = cleaned.length ~/ 2;
      results.add('HEX 摘要，长度 ${cleaned.length} 字符 / $byteLength 字节');
      results.addAll(_algorithmsForByteLength(byteLength, isHex: true));
    }

    final decodedBase64 = _tryDecodeBase64(cleaned);
    if (decodedBase64 != null && decodedBase64.isNotEmpty) {
      results.add('可能是 Base64 编码内容，解码后 ${decodedBase64.length} 字节');
      results.addAll(_algorithmsForByteLength(decodedBase64.length, isHex: false));
    }

    if (trimmed.startsWith('{SHA}')) {
      results.add('LDAP SHA-1');
    } else if (trimmed.startsWith('{SSHA}')) {
      results.add('LDAP SSHA / Salted SHA-1');
    }

    if (results.isEmpty) {
      results.add('未命中常见摘要模式');
    }
    return _deduplicate(results);
  }

  static List<int> parseInput(String input, String inputFormat) {
    final text = input.trim();
    if (text.isEmpty) {
      throw const FormatException('输入不能为空');
    }

    return switch (inputFormat) {
      'UTF-8' => utf8.encode(input),
      'Hex' => _parseHex(text),
      'Base64' => base64.decode(text),
      _ => throw FormatException('不支持的输入格式: $inputFormat'),
    };
  }

  static String formatBytes(List<int> bytes, String outputFormat) {
    return switch (outputFormat) {
      'HEX lower' => hex.encode(bytes),
      'HEX upper' => hex.encode(bytes).toUpperCase(),
      'Base64' => base64.encode(bytes),
      _ => throw FormatException('不支持的输出格式: $outputFormat'),
    };
  }

  static bool supportsHmac(String algorithm) {
    return _digestAlgorithms.containsKey(algorithm);
  }

  static String describeInput(String input, String inputFormat) {
    final bytes = parseInput(input, inputFormat);
    return [
      'Input Format: $inputFormat',
      'Byte Length: ${bytes.length}',
      'ASCII Preview: ${_asciiPreview(bytes)}',
    ].join('\n');
  }

  static List<int> _computeBytes({
    required String algorithm,
    required List<int> inputBytes,
    String? hmacKey,
  }) {
    if (_isHmacEnabled(hmacKey)) {
      final digest = _digestAlgorithms[algorithm];
      if (digest == null) {
        throw ArgumentError('HMAC 仅支持标准摘要算法');
      }
      return crypto.Hmac(digest, utf8.encode(hmacKey!)).convert(inputBytes).bytes;
    }

    final digest = _digestAlgorithms[algorithm];
    if (digest != null) {
      return digest.convert(inputBytes).bytes;
    }

    return switch (algorithm) {
      'CRC32' => _intToBytes(_crc32(inputBytes), 4),
      'Adler32' => _intToBytes(_adler32(inputBytes), 4),
      'FNV-1 32' => _intToBytes(_fnv32(inputBytes), 4),
      'FNV-1a 32' => _intToBytes(_fnv1a32(inputBytes), 4),
      'FNV-1 64' => _intToBytes(_fnv64(inputBytes), 8),
      'FNV-1a 64' => _intToBytes(_fnv1a64(inputBytes), 8),
      _ => throw ArgumentError('Unsupported hash algorithm: $algorithm'),
    };
  }

  static bool _looksLikePasswordHash(String input, List<String> results) {
    if (input.startsWith(r'$2a$') ||
        input.startsWith(r'$2b$') ||
        input.startsWith(r'$2x$') ||
        input.startsWith(r'$2y$')) {
      results.add('BCrypt');
      return true;
    }
    if (input.startsWith(r'$argon2i$') ||
        input.startsWith(r'$argon2d$') ||
        input.startsWith(r'$argon2id$')) {
      results.add('Argon2');
      return true;
    }
    if (input.startsWith(r'$1$')) {
      results.add('MD5 Crypt');
      return true;
    }
    if (input.startsWith(r'$5$')) {
      results.add('SHA-256 Crypt');
      return true;
    }
    if (input.startsWith(r'$6$')) {
      results.add('SHA-512 Crypt');
      return true;
    }
    if (input.startsWith(r'$apr1$')) {
      results.add('Apache APR1-MD5');
      return true;
    }
    return false;
  }

  static List<String> _algorithmsForByteLength(int byteLength, {required bool isHex}) {
    return switch (byteLength) {
      4 => ['CRC32 / Adler32 / FNV-1 32 / FNV-1a 32'],
      8 => isHex
          ? ['FNV-1 64 / FNV-1a 64']
          : ['64-bit digest / checksum'],
      16 => ['MD5', 'MD4 / NTLM（长度相同，当前仅识别不计算）'],
      20 => ['SHA-1', 'RIPEMD-160（长度相同）'],
      28 => ['SHA-224', 'SHA-512/224（长度相同）'],
      32 => ['SHA-256', 'SHA3-256 / Keccak-256（长度相同）'],
      48 => ['SHA-384', 'SHA3-384（长度相同）'],
      64 => ['SHA-512', 'SHA3-512 / BLAKE2b-512（长度相同）'],
      _ => [],
    };
  }

  static List<String> _deduplicate(List<String> items) {
    final seen = <String>{};
    final output = <String>[];
    for (final item in items) {
      if (seen.add(item)) {
        output.add(item);
      }
    }
    return output;
  }

  static List<int>? _tryDecodeBase64(String value) {
    try {
      if (!RegExp(r'^[A-Za-z0-9+/=]+$').hasMatch(value)) return null;
      if (value.length % 4 != 0) return null;
      return base64.decode(value);
    } catch (_) {
      return null;
    }
  }

  static List<int> _parseHex(String value) {
    final cleaned = value.replaceAll(RegExp(r'[^0-9a-fA-F]'), '');
    if (cleaned.isEmpty) {
      throw const FormatException('十六进制输入不能为空');
    }
    if (cleaned.length.isOdd) {
      throw const FormatException('十六进制长度必须为偶数');
    }
    return hex.decode(cleaned);
  }

  static List<int> _intToBytes(int value, int byteCount) {
    return [
      for (int i = byteCount - 1; i >= 0; i--) (value >> (i * 8)) & 0xFF,
    ];
  }

  static String _asciiPreview(List<int> bytes) {
    if (bytes.isEmpty) return '';
    final text = bytes.take(48).map((byte) {
      if (byte >= 0x20 && byte <= 0x7E) {
        return String.fromCharCode(byte);
      }
      return '.';
    }).join();
    return bytes.length > 48 ? '$text...' : text;
  }

  static bool _isHmacEnabled(String? hmacKey) {
    return hmacKey != null && hmacKey.isNotEmpty;
  }

  static int _crc32(List<int> bytes) {
    var crc = 0xFFFFFFFF;
    for (final byte in bytes) {
      crc ^= byte;
      for (int i = 0; i < 8; i++) {
        final lsb = crc & 1;
        crc >>= 1;
        if (lsb == 1) {
          crc ^= 0xEDB88320;
        }
      }
    }
    return (crc ^ 0xFFFFFFFF) & 0xFFFFFFFF;
  }

  static int _adler32(List<int> bytes) {
    const mod = 65521;
    var a = 1;
    var b = 0;
    for (final byte in bytes) {
      a = (a + byte) % mod;
      b = (b + a) % mod;
    }
    return ((b << 16) | a) & 0xFFFFFFFF;
  }

  static int _fnv32(List<int> bytes) {
    var hash = 0x811C9DC5;
    for (final byte in bytes) {
      hash = (hash * 0x01000193) & 0xFFFFFFFF;
      hash ^= byte;
    }
    return hash;
  }

  static int _fnv1a32(List<int> bytes) {
    var hash = 0x811C9DC5;
    for (final byte in bytes) {
      hash ^= byte;
      hash = (hash * 0x01000193) & 0xFFFFFFFF;
    }
    return hash;
  }

  static int _fnv64(List<int> bytes) {
    var hash = 0xCBF29CE484222325;
    for (final byte in bytes) {
      hash = (hash * 0x100000001B3) & 0xFFFFFFFFFFFFFFFF;
      hash ^= byte;
    }
    return hash;
  }

  static int _fnv1a64(List<int> bytes) {
    var hash = 0xCBF29CE484222325;
    for (final byte in bytes) {
      hash ^= byte;
      hash = (hash * 0x100000001B3) & 0xFFFFFFFFFFFFFFFF;
    }
    return hash;
  }
}
