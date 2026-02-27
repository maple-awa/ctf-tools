import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:convert/convert.dart';

enum CompressAlgorithm { gzip, zlib }

enum CompressDataFormat { raw, base64, hex }

class CompressCodec {
  static String compress({
    required String input,
    required CompressAlgorithm algorithm,
    required CompressDataFormat inputFormat,
    required CompressDataFormat outputFormat,
    int level = 6,
    bool upperCaseHex = true,
  }) {
    final inputBytes = _parseInput(input, inputFormat);
    final encoded = _encoder(algorithm, level).encode(inputBytes);
    return _formatOutput(
      Uint8List.fromList(encoded),
      outputFormat,
      upperCaseHex: upperCaseHex,
    );
  }

  static String decompress({
    required String input,
    required CompressAlgorithm algorithm,
    required CompressDataFormat inputFormat,
    required CompressDataFormat outputFormat,
    bool upperCaseHex = true,
  }) {
    final inputBytes = _parseInput(input, inputFormat);
    final decoded = _decoder(algorithm).decode(inputBytes);
    return _formatOutput(
      Uint8List.fromList(decoded),
      outputFormat,
      upperCaseHex: upperCaseHex,
    );
  }

  static Codec<List<int>, List<int>> _encoder(
    CompressAlgorithm algorithm,
    int level,
  ) {
    if (level < 0 || level > 9) {
      throw const FormatException('压缩级别必须在 0~9 之间');
    }
    return switch (algorithm) {
      CompressAlgorithm.gzip => GZipCodec(level: level),
      CompressAlgorithm.zlib => ZLibCodec(level: level),
    };
  }

  static Codec<List<int>, List<int>> _decoder(CompressAlgorithm algorithm) {
    return switch (algorithm) {
      CompressAlgorithm.gzip => GZipCodec(),
      CompressAlgorithm.zlib => ZLibCodec(),
    };
  }

  static Uint8List _parseInput(String input, CompressDataFormat format) {
    final text = input.trim();
    return switch (format) {
      CompressDataFormat.raw => Uint8List.fromList(utf8.encode(input)),
      CompressDataFormat.base64 => Uint8List.fromList(
        base64.decode(text.replaceAll(RegExp(r'\s+'), '')),
      ),
      CompressDataFormat.hex => Uint8List.fromList(
        hex.decode(_normalizeHex(text)),
      ),
    };
  }

  static String _formatOutput(
    Uint8List bytes,
    CompressDataFormat format, {
    required bool upperCaseHex,
  }) {
    return switch (format) {
      CompressDataFormat.raw => utf8.decode(bytes, allowMalformed: true),
      CompressDataFormat.base64 => base64.encode(bytes),
      CompressDataFormat.hex => _formatHex(bytes, upperCaseHex: upperCaseHex),
    };
  }

  static String _normalizeHex(String input) {
    final normalized = input
        .replaceAll(RegExp(r'0x', caseSensitive: false), '')
        .replaceAll(RegExp(r'[^0-9a-fA-F]'), '');
    if (normalized.isEmpty) {
      return normalized;
    }
    if (normalized.length.isOdd) {
      throw const FormatException('十六进制长度必须为偶数');
    }
    return normalized;
  }

  static String _formatHex(Uint8List bytes, {required bool upperCaseHex}) {
    final output = hex.encode(bytes);
    return upperCaseHex ? output.toUpperCase() : output;
  }
}
