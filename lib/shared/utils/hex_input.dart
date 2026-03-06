class HexInput {
  static String normalize(String input) {
    return input.replaceAll(RegExp(r'[^0-9a-fA-F]'), '').toUpperCase();
  }

  static List<int> parseBytes(
    String input, {
    int minBytes = 1,
    String? errorMessage,
  }) {
    final cleaned = normalize(input);
    if (cleaned.isEmpty) {
      throw FormatException(errorMessage ?? '请输入十六进制数据');
    }
    if (cleaned.length.isOdd) {
      throw const FormatException('十六进制长度必须为偶数');
    }

    final bytes = <int>[
      for (int i = 0; i < cleaned.length; i += 2)
        int.parse(cleaned.substring(i, i + 2), radix: 16),
    ];
    if (bytes.length < minBytes) {
      throw FormatException(errorMessage ?? '数据长度不足');
    }
    return bytes;
  }

  static String formatBytes(List<int> bytes, {int columns = 16}) {
    if (bytes.isEmpty) return '';
    final parts = <String>[];
    for (var i = 0; i < bytes.length; i++) {
      parts.add(bytes[i].toRadixString(16).padLeft(2, '0').toUpperCase());
      if (columns > 0 && i < bytes.length - 1 && (i + 1) % columns == 0) {
        parts.add('\n');
      }
    }
    return parts.join(' ').replaceAll('\n ', '\n').trim();
  }

  static String asciiPreview(List<int> bytes, {int maxLength = 48}) {
    final preview = bytes.take(maxLength).map((byte) {
      if (byte >= 0x20 && byte <= 0x7E) {
        return String.fromCharCode(byte);
      }
      return '.';
    }).join();
    if (bytes.length > maxLength) {
      return '$preview...';
    }
    return preview;
  }

  static int readUint32Le(List<int> bytes, int offset) {
    return bytes[offset] |
        (bytes[offset + 1] << 8) |
        (bytes[offset + 2] << 16) |
        (bytes[offset + 3] << 24);
  }

  static int readUint32Be(List<int> bytes, int offset) {
    return (bytes[offset] << 24) |
        (bytes[offset + 1] << 16) |
        (bytes[offset + 2] << 8) |
        bytes[offset + 3];
  }

  static int readUint16Le(List<int> bytes, int offset) {
    return bytes[offset] | (bytes[offset + 1] << 8);
  }

  static int readUint16Be(List<int> bytes, int offset) {
    return (bytes[offset] << 8) | bytes[offset + 1];
  }

  static String ascii(List<int> bytes, int start, int end) {
    return String.fromCharCodes(bytes.sublist(start, end));
  }
}
