import 'dart:typed_data';

import 'package:ctf_tools/features/crypto/utils/crypto_codec.dart';
import 'package:pointycastle/export.dart';

class LegacyBlockCipherToolkit {
  static const List<String> algorithms = ['3DES-ECB', '3DES-CBC'];
  static const List<String> paddings = ['PKCS7', 'ZeroPadding', 'NoPadding'];

  static bool requiresIv(String algorithm) => algorithm.endsWith('CBC');

  static String encrypt({
    required String algorithm,
    required String padding,
    required String input,
    required String inputFormat,
    required String key,
    required String keyFormat,
    required String iv,
    required String ivFormat,
    required String outputFormat,
  }) {
    final bytes = _process(
      encrypt: true,
      algorithm: algorithm,
      padding: padding,
      inputBytes: CryptoCodec.parseBytes(input, inputFormat),
      keyBytes: CryptoCodec.parseBytes(key, keyFormat),
      ivBytes: requiresIv(algorithm)
          ? CryptoCodec.parseBytes(iv, ivFormat)
          : <int>[],
    );
    return CryptoCodec.formatBytes(bytes, outputFormat);
  }

  static String decrypt({
    required String algorithm,
    required String padding,
    required String input,
    required String inputFormat,
    required String key,
    required String keyFormat,
    required String iv,
    required String ivFormat,
    required String outputFormat,
  }) {
    final bytes = _process(
      encrypt: false,
      algorithm: algorithm,
      padding: padding,
      inputBytes: CryptoCodec.parseBytes(input, inputFormat),
      keyBytes: CryptoCodec.parseBytes(key, keyFormat),
      ivBytes: requiresIv(algorithm)
          ? CryptoCodec.parseBytes(iv, ivFormat)
          : <int>[],
    );
    return CryptoCodec.formatBytes(bytes, outputFormat);
  }

  static String describe({
    required String algorithm,
    required String key,
    required String keyFormat,
    required String iv,
    required String ivFormat,
  }) {
    final keyBytes = CryptoCodec.parseBytes(key, keyFormat);
    final blockSize = _blockCipher(algorithm).blockSize;
    _validateKey(algorithm, keyBytes.length);
    final lines = <String>[
      'Algorithm: $algorithm',
      'Block Size: $blockSize bytes',
      'Key Length: ${keyBytes.length} bytes',
    ];
    if (requiresIv(algorithm)) {
      final ivBytes = CryptoCodec.parseBytes(iv, ivFormat);
      if (ivBytes.length != blockSize) {
        throw FormatException('IV 必须是 $blockSize 字节');
      }
      lines.add('IV Length: ${ivBytes.length} bytes');
    }
    return lines.join('\n');
  }

  static List<int> _process({
    required bool encrypt,
    required String algorithm,
    required String padding,
    required List<int> inputBytes,
    required List<int> keyBytes,
    required List<int> ivBytes,
  }) {
    _validateKey(algorithm, keyBytes.length);
    final cipher = _blockCipher(algorithm);
    final blockSize = cipher.blockSize;
    if (requiresIv(algorithm) && ivBytes.length != blockSize) {
      throw FormatException('IV 必须是 $blockSize 字节');
    }

    final working = encrypt
        ? _applyPadding(Uint8List.fromList(inputBytes), padding, blockSize)
        : Uint8List.fromList(inputBytes);
    if (working.length % blockSize != 0) {
      throw FormatException('输入长度必须是 $blockSize 字节的整数倍');
    }

    final finalCipher = algorithm.endsWith('CBC')
        ? CBCBlockCipher(cipher)
        : cipher;
    final CipherParameters params = algorithm.endsWith('CBC')
        ? ParametersWithIV(
            KeyParameter(Uint8List.fromList(keyBytes)),
            Uint8List.fromList(ivBytes),
          )
        : KeyParameter(Uint8List.fromList(keyBytes));
    finalCipher.init(encrypt, params);

    final output = Uint8List(working.length);
    for (var offset = 0; offset < working.length; offset += blockSize) {
      finalCipher.processBlock(working, offset, output, offset);
    }
    return encrypt ? output : _removePadding(output, padding);
  }

  static BlockCipher _blockCipher(String algorithm) {
    return switch (algorithm) {
      '3DES-ECB' || '3DES-CBC' => DESedeEngine(),
      _ => throw FormatException('不支持的算法: $algorithm'),
    };
  }

  static void _validateKey(String algorithm, int length) {
    switch (algorithm) {
      case '3DES-ECB':
      case '3DES-CBC':
        if (length != 16 && length != 24) {
          throw const FormatException('3DES Key 必须为 16 或 24 字节');
        }
        break;
    }
  }

  static Uint8List _applyPadding(
    Uint8List input,
    String padding,
    int blockSize,
  ) {
    return switch (padding) {
      'PKCS7' => _pkcs7Pad(input, blockSize),
      'ZeroPadding' => _zeroPad(input, blockSize),
      'NoPadding' => _requireExactBlocks(input, blockSize),
      _ => throw FormatException('不支持的填充方式: $padding'),
    };
  }

  static List<int> _removePadding(Uint8List input, String padding) {
    return switch (padding) {
      'PKCS7' => _pkcs7Unpad(input),
      'ZeroPadding' => _zeroUnpad(input),
      'NoPadding' => input,
      _ => throw FormatException('不支持的填充方式: $padding'),
    };
  }

  static Uint8List _pkcs7Pad(Uint8List input, int blockSize) {
    final padLength = blockSize - (input.length % blockSize);
    final effectivePad = padLength == 0 ? blockSize : padLength;
    return Uint8List.fromList([
      ...input,
      ...List<int>.filled(effectivePad, effectivePad),
    ]);
  }

  static List<int> _pkcs7Unpad(Uint8List input) {
    if (input.isEmpty) {
      throw const FormatException('PKCS7 数据为空');
    }
    final pad = input.last;
    if (pad < 1 || pad > input.length) {
      throw const FormatException('PKCS7 填充非法');
    }
    for (var index = input.length - pad; index < input.length; index++) {
      if (input[index] != pad) {
        throw const FormatException('PKCS7 填充校验失败');
      }
    }
    return input.sublist(0, input.length - pad);
  }

  static Uint8List _zeroPad(Uint8List input, int blockSize) {
    if (input.length % blockSize == 0) {
      return input;
    }
    final targetLength =
        ((input.length + blockSize - 1) ~/ blockSize) * blockSize;
    return Uint8List.fromList([
      ...input,
      ...List<int>.filled(targetLength - input.length, 0),
    ]);
  }

  static List<int> _zeroUnpad(Uint8List input) {
    var end = input.length;
    while (end > 0 && input[end - 1] == 0) {
      end--;
    }
    return input.sublist(0, end);
  }

  static Uint8List _requireExactBlocks(Uint8List input, int blockSize) {
    if (input.length % blockSize != 0) {
      throw FormatException('NoPadding 要求输入长度是 $blockSize 的整数倍');
    }
    return input;
  }
}
