import 'package:ctf_tools/shared/utils/hex_input.dart';

class EmbeddedSignatureHit {
  const EmbeddedSignatureHit({
    required this.type,
    required this.offset,
    required this.preview,
  });

  final String type;
  final int offset;
  final String preview;
}

class EmbeddedSignatureScanner {
  static const Map<String, List<int>> _signatures = {
    'PNG': [0x89, 0x50, 0x4E, 0x47],
    'JPEG': [0xFF, 0xD8, 0xFF],
    'GIF': [0x47, 0x49, 0x46, 0x38],
    'ZIP': [0x50, 0x4B, 0x03, 0x04],
    'PDF': [0x25, 0x50, 0x44, 0x46],
    'GZIP': [0x1F, 0x8B, 0x08],
    'WAV/AVI-RIFF': [0x52, 0x49, 0x46, 0x46],
  };

  static List<EmbeddedSignatureHit> scanHex(String input) {
    return scanBytes(HexInput.parseBytes(input));
  }

  static List<EmbeddedSignatureHit> scanBytes(List<int> bytes) {
    final hits = <EmbeddedSignatureHit>[];
    for (final entry in _signatures.entries) {
      final signature = entry.value;
      for (var index = 0; index <= bytes.length - signature.length; index++) {
        var matched = true;
        for (var offset = 0; offset < signature.length; offset++) {
          if (bytes[index + offset] != signature[offset]) {
            matched = false;
            break;
          }
        }
        if (matched) {
          final previewEnd = (index + 24) > bytes.length ? bytes.length : index + 24;
          hits.add(
            EmbeddedSignatureHit(
              type: entry.key,
              offset: index,
              preview: HexInput.formatBytes(bytes.sublist(index, previewEnd), columns: 12),
            ),
          );
        }
      }
    }
    return hits;
  }
}
