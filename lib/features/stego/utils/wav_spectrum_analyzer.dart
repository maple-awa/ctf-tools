import 'package:ctf_tools/shared/utils/hex_input.dart';

class WavSpectrumResult {
  const WavSpectrumResult({
    required this.summary,
    required this.samplePreview,
    required this.peak,
  });

  final List<String> summary;
  final List<int> samplePreview;
  final int peak;
}

class WavSpectrumAnalyzer {
  static WavSpectrumResult analyzeHex(String input) {
    final bytes = HexInput.parseBytes(input, minBytes: 44, errorMessage: '请输入 WAV 十六进制数据');
    if (HexInput.ascii(bytes, 0, 4) != 'RIFF' || HexInput.ascii(bytes, 8, 12) != 'WAVE') {
      throw const FormatException('当前仅支持 WAV/RIFF 数据');
    }
    var offset = 12;
    var channels = 1;
    var sampleRate = 0;
    var bitsPerSample = 16;
    List<int> data = const [];
    while (offset + 8 <= bytes.length) {
      final chunkId = HexInput.ascii(bytes, offset, offset + 4);
      final chunkSize = HexInput.readUint32Le(bytes, offset + 4);
      final dataStart = offset + 8;
      final nextOffset = dataStart + chunkSize + (chunkSize.isOdd ? 1 : 0);
      if (nextOffset > bytes.length) {
        break;
      }
      if (chunkId == 'fmt ' && chunkSize >= 16) {
        channels = HexInput.readUint16Le(bytes, dataStart + 2);
        sampleRate = HexInput.readUint32Le(bytes, dataStart + 4);
        bitsPerSample = HexInput.readUint16Le(bytes, dataStart + 14);
      }
      if (chunkId == 'data') {
        data = bytes.sublist(dataStart, dataStart + chunkSize);
        break;
      }
      offset = nextOffset;
    }
    if (data.isEmpty) {
      throw const FormatException('未找到 WAV data chunk');
    }
    final samples = <int>[];
    if (bitsPerSample == 8) {
      samples.addAll(data.take(64));
    } else {
      for (var index = 0; index + 1 < data.length && samples.length < 64; index += 2) {
        final sample = HexInput.readUint16Le(data, index);
        samples.add(sample > 0x7FFF ? sample - 0x10000 : sample);
      }
    }
    var peak = 0;
    for (final sample in samples) {
      final absValue = sample.abs();
      if (absValue > peak) {
        peak = absValue;
      }
    }
    return WavSpectrumResult(
      summary: [
        'Channels: $channels',
        'Sample Rate: $sampleRate Hz',
        'Bits Per Sample: $bitsPerSample',
        'Preview Samples: ${samples.length}',
      ],
      samplePreview: samples,
      peak: peak,
    );
  }
}
