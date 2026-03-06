/// PNG chunk 与元数据检查工具。
class PngChunkInspector {
  static PngInspectResult inspectHex(String input) {
    final cleaned = input.replaceAll(RegExp(r'[^0-9a-fA-F]'), '').toUpperCase();
    if (cleaned.length < 16) {
      throw const FormatException('PNG 数据至少需要 8 字节签名');
    }
    if (!cleaned.startsWith('89504E470D0A1A0A')) {
      throw const FormatException('不是有效的 PNG 签名');
    }

    final bytes = <int>[
      for (int i = 0; i < cleaned.length; i += 2) int.parse(cleaned.substring(i, i + 2), radix: 16),
    ];

    var offset = 8;
    final chunks = <PngChunkInfo>[];
    final notes = <String>[];
    var foundIend = false;

    while (offset + 12 <= bytes.length) {
      final length = _readUint32(bytes, offset);
      final typeBytes = bytes.sublist(offset + 4, offset + 8);
      final type = String.fromCharCodes(typeBytes);
      final dataStart = offset + 8;
      final dataEnd = dataStart + length;
      final crcEnd = dataEnd + 4;

      if (crcEnd > bytes.length) {
        notes.add('Chunk $type 长度超出输入边界，数据可能被截断');
        break;
      }

      final data = bytes.sublist(dataStart, dataEnd);
      chunks.add(PngChunkInfo(type: type, length: length));

      if (type == 'IHDR' && data.length >= 8) {
        final width = _readUint32(data, 0);
        final height = _readUint32(data, 4);
        notes.add('IHDR: ${width}x$height');
      }
      if (type == 'tEXt') {
        notes.add('tEXt: ${_decodeLatin1(data)}');
      }
      if (type == 'zTXt') {
        notes.add('zTXt: 检测到压缩文本块');
      }
      if (type == 'iTXt') {
        notes.add('iTXt: 检测到国际化文本块');
      }
      if (type == 'eXIf') {
        notes.add('eXIf: 检测到 EXIF 元数据');
      }
      if (type == 'IEND') {
        foundIend = true;
        if (crcEnd < bytes.length) {
          notes.add('IEND 后仍有 ${bytes.length - crcEnd} 字节尾随数据，存在隐藏载荷嫌疑');
        }
        break;
      }

      offset = crcEnd;
    }

    if (!foundIend) {
      notes.add('未找到 IEND，PNG 可能不完整');
    }

    return PngInspectResult(chunks: chunks, notes: notes);
  }

  static int _readUint32(List<int> bytes, int offset) {
    return (bytes[offset] << 24) |
        (bytes[offset + 1] << 16) |
        (bytes[offset + 2] << 8) |
        bytes[offset + 3];
  }

  static String _decodeLatin1(List<int> bytes) {
    return String.fromCharCodes(bytes).replaceAll('\u0000', ' = ');
  }
}

class PngInspectResult {
  const PngInspectResult({
    required this.chunks,
    required this.notes,
  });

  final List<PngChunkInfo> chunks;
  final List<String> notes;
}

class PngChunkInfo {
  const PngChunkInfo({
    required this.type,
    required this.length,
  });

  final String type;
  final int length;
}
