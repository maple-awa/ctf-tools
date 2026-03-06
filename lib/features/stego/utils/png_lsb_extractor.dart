import 'dart:convert';

import 'package:ctf_tools/shared/utils/hex_input.dart';

class PngLsbExtractResult {
  const PngLsbExtractResult({
    required this.bitStream,
    required this.textPreview,
    required this.notes,
  });

  final String bitStream;
  final String textPreview;
  final List<String> notes;
}

class PngLsbExtractor {
  static PngLsbExtractResult extract(String input, {int bitPlane = 0}) {
    final bytes = HexInput.parseBytes(input, minBytes: 32, errorMessage: '请输入 PNG 十六进制数据');
    if (!HexInput.normalize(input).startsWith('89504E470D0A1A0A')) {
      throw const FormatException('不是有效的 PNG 数据');
    }
    final idatBytes = <int>[];
    var offset = 8;
    while (offset + 12 <= bytes.length) {
      final length = HexInput.readUint32Be(bytes, offset);
      final type = String.fromCharCodes(bytes.sublist(offset + 4, offset + 8));
      final dataStart = offset + 8;
      final dataEnd = dataStart + length;
      final crcEnd = dataEnd + 4;
      if (crcEnd > bytes.length) {
        break;
      }
      if (type == 'IDAT') {
        idatBytes.addAll(bytes.sublist(dataStart, dataEnd));
      }
      if (type == 'IEND') {
        break;
      }
      offset = crcEnd;
    }
    if (idatBytes.isEmpty) {
      throw const FormatException('未找到 IDAT chunk，无法提取 LSB');
    }
    final bits = idatBytes.map((byte) => ((byte >> bitPlane) & 0x01).toString()).join();
    final decoded = <int>[];
    for (var index = 0; index + 8 <= bits.length && decoded.length < 128; index += 8) {
      decoded.add(int.parse(bits.substring(index, index + 8), radix: 2));
    }
    final preview = utf8.decode(decoded, allowMalformed: true).replaceAll(RegExp(r'[^\x20-\x7E\n\r\t]'), '.');
    return PngLsbExtractResult(
      bitStream: bits.substring(0, bits.length > 256 ? 256 : bits.length),
      textPreview: preview,
      notes: [
        'IDAT Bytes: ${idatBytes.length}',
        'Bit Plane: $bitPlane',
        'Preview Bytes: ${decoded.length}',
      ],
    );
  }
}
