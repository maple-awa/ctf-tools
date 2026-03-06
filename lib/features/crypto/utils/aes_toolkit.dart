import 'dart:typed_data';

import 'package:ctf_tools/features/crypto/utils/crypto_codec.dart';
import 'package:pointycastle/export.dart';

class AesToolkit {
  static const List<String> modes = ['AES-ECB', 'AES-CBC', 'AES-CTR'];
  static const List<String> paddings = ['PKCS7', 'ZeroPadding', 'NoPadding'];

  static bool requiresIv(String mode) => mode != 'AES-ECB';

  static bool supportsPadding(String mode) => mode != 'AES-CTR';

  static String recommendedPadding(String mode) {
    return supportsPadding(mode) ? 'PKCS7' : 'NoPadding';
  }

  static String encrypt({
    required String mode,
    required String padding,
    required String input,
    required String inputFormat,
    required String key,
    required String keyFormat,
    required String iv,
    required String ivFormat,
    required String outputFormat,
  }) {
    final output = _process(
      encrypt: true,
      mode: mode,
      padding: padding,
      inputBytes: CryptoCodec.parseBytes(input, inputFormat),
      keyBytes: CryptoCodec.parseBytes(key, keyFormat),
      ivBytes: requiresIv(mode) ? CryptoCodec.parseBytes(iv, ivFormat) : <int>[],
    );
    return CryptoCodec.formatBytes(output, outputFormat);
  }

  static String decrypt({
    required String mode,
    required String padding,
    required String input,
    required String inputFormat,
    required String key,
    required String keyFormat,
    required String iv,
    required String ivFormat,
    required String outputFormat,
  }) {
    final output = _process(
      encrypt: false,
      mode: mode,
      padding: padding,
      inputBytes: CryptoCodec.parseBytes(input, inputFormat),
      keyBytes: CryptoCodec.parseBytes(key, keyFormat),
      ivBytes: requiresIv(mode) ? CryptoCodec.parseBytes(iv, ivFormat) : <int>[],
    );
    return CryptoCodec.formatBytes(output, outputFormat);
  }

  static String describe({
    required String key,
    required String keyFormat,
    required String iv,
    required String ivFormat,
    required String mode,
  }) {
    final keyBytes = CryptoCodec.parseBytes(key, keyFormat);
    _validateKeyLength(keyBytes);
    final lines = <String>[
      'Mode: $mode',
      'Block Size: 16 bytes',
      'Key Length: ${keyBytes.length} bytes (${keyBytes.length * 8} bits)',
      'Rounds: ${_roundCount(keyBytes.length)}',
    ];
    if (requiresIv(mode)) {
      final ivBytes = CryptoCodec.parseBytes(iv, ivFormat);
      if (ivBytes.length != 16) {
        throw const FormatException('IV / Counter 必须为 16 字节');
      }
      lines.add('IV / Counter Length: ${ivBytes.length} bytes');
    } else {
      lines.add('IV: ECB 模式不使用 IV');
    }
    lines.add(
      supportsPadding(mode)
          ? 'Padding: 支持 PKCS7 / ZeroPadding / NoPadding'
          : 'Padding: CTR 为流模式，仅使用 NoPadding',
    );
    return lines.join('\n');
  }

  static List<int> _process({
    required bool encrypt,
    required String mode,
    required String padding,
    required List<int> inputBytes,
    required List<int> keyBytes,
    required List<int> ivBytes,
  }) {
    _validateKeyLength(keyBytes);
    if (requiresIv(mode) && ivBytes.length != 16) {
      throw const FormatException('IV / Counter 必须为 16 字节');
    }
    if (!supportsPadding(mode) && padding != 'NoPadding') {
      throw const FormatException('AES-CTR 属于流模式，请选择 NoPadding');
    }

    return switch (mode) {
      'AES-ECB' || 'AES-CBC' => _processBlockMode(
        encrypt: encrypt,
        mode: mode,
        padding: padding,
        inputBytes: inputBytes,
        keyBytes: keyBytes,
        ivBytes: ivBytes,
      ),
      'AES-CTR' => _processCtr(
        inputBytes: inputBytes,
        keyBytes: keyBytes,
        counterBytes: ivBytes,
      ),
      _ => throw FormatException('不支持的 AES 模式: $mode'),
    };
  }

  static List<int> _processBlockMode({
    required bool encrypt,
    required String mode,
    required String padding,
    required List<int> inputBytes,
    required List<int> keyBytes,
    required List<int> ivBytes,
  }) {
    final working = encrypt
        ? _applyPadding(inputBytes, padding)
        : Uint8List.fromList(inputBytes);
    if (working.length % 16 != 0) {
      throw const FormatException('当前模式要求输入长度为 16 字节的整数倍');
    }

    final output = Uint8List(working.length);
    final encryptEngine = _createEngine(keyBytes, true);
    final decryptEngine = _createEngine(keyBytes, false);
    final previous = Uint8List.fromList(
      mode == 'AES-CBC' ? ivBytes : Uint8List(16),
    );

    for (var offset = 0; offset < working.length; offset += 16) {
      final block = Uint8List.fromList(working.sublist(offset, offset + 16));
      if (encrypt) {
        final plainBlock = mode == 'AES-CBC' ? _xorBlock(block, previous) : block;
        final cipherBlock = Uint8List(16);
        encryptEngine.processBlock(plainBlock, 0, cipherBlock, 0);
        output.setRange(offset, offset + 16, cipherBlock);
        if (mode == 'AES-CBC') {
          previous.setRange(0, 16, cipherBlock);
        }
      } else {
        final plainCandidate = Uint8List(16);
        decryptEngine.processBlock(block, 0, plainCandidate, 0);
        final plainBlock = mode == 'AES-CBC'
            ? _xorBlock(plainCandidate, previous)
            : plainCandidate;
        output.setRange(offset, offset + 16, plainBlock);
        if (mode == 'AES-CBC') {
          previous.setRange(0, 16, block);
        }
      }
    }

    return encrypt ? output : _removePadding(output, padding);
  }

  static List<int> _processCtr({
    required List<int> inputBytes,
    required List<int> keyBytes,
    required List<int> counterBytes,
  }) {
    final engine = _createEngine(keyBytes, true);
    final counter = Uint8List.fromList(counterBytes);
    final input = Uint8List.fromList(inputBytes);
    final output = Uint8List(input.length);

    for (var offset = 0; offset < input.length; offset += 16) {
      final keystream = Uint8List(16);
      engine.processBlock(counter, 0, keystream, 0);
      final remaining = input.length - offset;
      final chunkLength = remaining > 16 ? 16 : remaining;
      for (var index = 0; index < chunkLength; index++) {
        output[offset + index] = input[offset + index] ^ keystream[index];
      }
      _incrementCounter(counter);
    }

    return output;
  }

  static Uint8List _applyPadding(List<int> inputBytes, String padding) {
    final input = Uint8List.fromList(inputBytes);
    return switch (padding) {
      'PKCS7' => _pkcs7Pad(input),
      'ZeroPadding' => _zeroPad(input),
      'NoPadding' => _requireExactBlocks(input),
      _ => throw FormatException('不支持的填充方式: $padding'),
    };
  }

  static List<int> _removePadding(Uint8List bytes, String padding) {
    return switch (padding) {
      'PKCS7' => _pkcs7Unpad(bytes),
      'ZeroPadding' => _zeroUnpad(bytes),
      'NoPadding' => bytes,
      _ => throw FormatException('不支持的填充方式: $padding'),
    };
  }

  static Uint8List _pkcs7Pad(Uint8List input) {
    final padLength = 16 - (input.length % 16);
    final effectivePad = padLength == 0 ? 16 : padLength;
    return Uint8List.fromList([
      ...input,
      ...List<int>.filled(effectivePad, effectivePad),
    ]);
  }

  static List<int> _pkcs7Unpad(Uint8List input) {
    if (input.isEmpty || input.length % 16 != 0) {
      throw const FormatException('PKCS7 数据长度非法');
    }
    final pad = input.last;
    if (pad < 1 || pad > 16 || pad > input.length) {
      throw const FormatException('PKCS7 填充非法');
    }
    for (var index = input.length - pad; index < input.length; index++) {
      if (input[index] != pad) {
        throw const FormatException('PKCS7 填充校验失败');
      }
    }
    return input.sublist(0, input.length - pad);
  }

  static Uint8List _zeroPad(Uint8List input) {
    if (input.length % 16 == 0) {
      return input;
    }
    final targetLength = ((input.length + 15) ~/ 16) * 16;
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

  static Uint8List _requireExactBlocks(Uint8List input) {
    if (input.length % 16 != 0) {
      throw const FormatException('NoPadding 模式要求输入长度为 16 字节的整数倍');
    }
    return input;
  }

  static Uint8List _xorBlock(Uint8List left, Uint8List right) {
    final output = Uint8List(16);
    for (var index = 0; index < 16; index++) {
      output[index] = left[index] ^ right[index];
    }
    return output;
  }

  static AESEngine _createEngine(List<int> keyBytes, bool forEncryption) {
    final engine = AESEngine();
    engine.init(forEncryption, KeyParameter(Uint8List.fromList(keyBytes)));
    return engine;
  }

  static void _incrementCounter(Uint8List counter) {
    for (var index = counter.length - 1; index >= 0; index--) {
      counter[index] = (counter[index] + 1) & 0xFF;
      if (counter[index] != 0) {
        break;
      }
    }
  }

  static int _roundCount(int keyLength) {
    return switch (keyLength) {
      16 => 10,
      24 => 12,
      32 => 14,
      _ => throw const FormatException('AES key 必须是 16 / 24 / 32 字节'),
    };
  }

  static void _validateKeyLength(List<int> keyBytes) {
    _roundCount(keyBytes.length);
  }
}
