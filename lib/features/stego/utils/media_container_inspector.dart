import 'package:ctf_tools/shared/utils/hex_input.dart';

class MediaContainerInspector {
  static MediaInspectResult inspectHex(String input) {
    final bytes = HexInput.parseBytes(
      input,
      minBytes: 12,
      errorMessage: '请输入至少 12 字节音视频容器十六进制数据',
    );

    if (_startsWithAscii(bytes, 'RIFF') && bytes.length >= 12) {
      final formType = HexInput.ascii(bytes, 8, 12);
      if (formType == 'WAVE') {
        return _inspectWave(bytes);
      }
      if (formType == 'AVI ') {
        return _inspectAvi(bytes);
      }
      return MediaInspectResult(
        type: 'RIFF',
        summary: ['RIFF 容器', 'Form Type: $formType'],
        structure: _riffChunks(bytes, 12),
        notes: _riffNotes(bytes),
      );
    }

    if (bytes.length >= 12 && HexInput.ascii(bytes, 4, 8) == 'ftyp') {
      return _inspectMp4(bytes);
    }

    if (_startsWithAscii(bytes, 'ID3')) {
      return _inspectId3(bytes);
    }

    if (_startsWithAscii(bytes, 'OggS')) {
      final segments = bytes.length > 26 ? bytes[26] : 0;
      return MediaInspectResult(
        type: 'Ogg',
        summary: ['OGG 容器', 'Version: ${bytes[4]}', 'Segments: $segments'],
        structure: ['Page Header: OggS'],
        notes: const ['可继续结合具体 codec 头判断是否为 Vorbis / Opus / Theora'],
      );
    }

    if (_startsWithAscii(bytes, 'fLaC')) {
      return MediaInspectResult(
        type: 'FLAC',
        summary: const ['FLAC 无损音频'],
        structure: ['Magic: fLaC'],
        notes: const ['可继续检查 metadata block 中是否夹带异常注释信息'],
      );
    }

    if (_looksLikeMpegFrame(bytes)) {
      return _inspectMpegFrame(bytes);
    }

    return MediaInspectResult(
      type: 'Unknown',
      summary: ['未识别的音视频容器', 'ASCII Preview: ${HexInput.asciiPreview(bytes)}'],
      structure: [
        'Hex Head: ${HexInput.formatBytes(bytes.take(24).toList(), columns: 12)}',
      ],
      notes: const ['当前检查器优先覆盖 WAV / AVI / MP4 / MP3 / OGG / FLAC'],
    );
  }

  static MediaInspectResult _inspectWave(List<int> bytes) {
    final summary = <String>['WAV / RIFF 音频'];
    final structure = <String>[];
    final notes = _riffNotes(bytes);

    int? channels;
    int? sampleRate;
    int? byteRate;
    int? bitsPerSample;
    int? dataSize;

    var offset = 12;
    while (offset + 8 <= bytes.length) {
      final chunkId = HexInput.ascii(bytes, offset, offset + 4);
      final chunkSize = HexInput.readUint32Le(bytes, offset + 4);
      final dataStart = offset + 8;
      final nextOffset = dataStart + chunkSize + (chunkSize.isOdd ? 1 : 0);
      if (dataStart > bytes.length || nextOffset > bytes.length + 1) {
        notes.add('Chunk $chunkId 长度超出输入边界，可能被截断');
        break;
      }
      structure.add('$chunkId ($chunkSize bytes)');

      if (chunkId == 'fmt ' &&
          chunkSize >= 16 &&
          dataStart + 16 <= bytes.length) {
        channels = HexInput.readUint16Le(bytes, dataStart + 2);
        sampleRate = HexInput.readUint32Le(bytes, dataStart + 4);
        byteRate = HexInput.readUint32Le(bytes, dataStart + 8);
        bitsPerSample = HexInput.readUint16Le(bytes, dataStart + 14);
      }
      if (chunkId == 'data') {
        dataSize = chunkSize;
      }

      offset = nextOffset;
    }

    if (channels != null) summary.add('Channels: $channels');
    if (sampleRate != null) summary.add('Sample Rate: $sampleRate Hz');
    if (bitsPerSample != null) summary.add('Bits Per Sample: $bitsPerSample');
    if (dataSize != null) summary.add('Data Size: $dataSize bytes');
    if (dataSize != null && byteRate != null && byteRate > 0) {
      final duration = dataSize / byteRate;
      summary.add('Approx Duration: ${duration.toStringAsFixed(3)} s');
    }
    if (structure.where((item) => item.startsWith('LIST')).isNotEmpty) {
      notes.add('检测到 LIST chunk，可进一步检查 INFO/标签块里是否藏有文本');
    }

    return MediaInspectResult(
      type: 'WAV',
      summary: summary,
      structure: structure,
      notes: notes,
    );
  }

  static MediaInspectResult _inspectAvi(List<int> bytes) {
    return MediaInspectResult(
      type: 'AVI',
      summary: const ['AVI / RIFF 视频容器'],
      structure: _riffChunks(bytes, 12),
      notes: [
        ..._riffNotes(bytes),
        '可继续关注 LIST / JUNK / idx1 chunk 是否出现异常填充或尾随数据',
      ],
    );
  }

  static MediaInspectResult _inspectMp4(List<int> bytes) {
    final summary = <String>['MP4 / MOV 容器'];
    final structure = <String>[];
    final notes = <String>[];

    final majorBrand = HexInput.ascii(bytes, 8, 12);
    final compatible = <String>[];
    for (
      var offset = 16;
      offset + 4 <= bytes.length && compatible.length < 6;
      offset += 4
    ) {
      compatible.add(HexInput.ascii(bytes, offset, offset + 4));
    }
    summary.add('Major Brand: $majorBrand');
    summary.add(
      'Compatible: ${compatible.where((item) => item.trim().isNotEmpty).join(', ')}',
    );

    var offset = 0;
    while (offset + 8 <= bytes.length && structure.length < 12) {
      final size = HexInput.readUint32Be(bytes, offset);
      final type = HexInput.ascii(bytes, offset + 4, offset + 8);
      if (size < 8 || offset + size > bytes.length) {
        notes.add('Box $type 尺寸异常，可能为截断数据');
        break;
      }
      structure.add('$type ($size bytes)');
      offset += size;
    }

    if (!structure.any((item) => item.startsWith('moov'))) {
      notes.add('未发现 moov box，可能是截断样本或流式分片');
    }
    if (structure.any((item) => item.startsWith('free')) ||
        structure.any((item) => item.startsWith('skip'))) {
      notes.add('存在 free/skip box，可进一步检查是否承载隐藏填充');
    }

    return MediaInspectResult(
      type: 'MP4',
      summary: summary,
      structure: structure,
      notes: notes,
    );
  }

  static MediaInspectResult _inspectId3(List<int> bytes) {
    final size = _synchsafe(bytes[6], bytes[7], bytes[8], bytes[9]);
    final version = '2.${bytes[3]}.${bytes[4]}';
    return MediaInspectResult(
      type: 'MP3/ID3',
      summary: ['MP3 标签头', 'ID3 Version: $version', 'Tag Size: $size bytes'],
      structure: const ['ID3 Header'],
      notes: const ['可继续检查 TXXX/COMM/APIC 等帧中是否藏有文本或附加载荷'],
    );
  }

  static MediaInspectResult _inspectMpegFrame(List<int> bytes) {
    final versionBits = (bytes[1] >> 3) & 0x03;
    final layerBits = (bytes[1] >> 1) & 0x03;
    final bitrateIndex = (bytes[2] >> 4) & 0x0F;
    final sampleRateIndex = (bytes[2] >> 2) & 0x03;

    const versions = {0: 'MPEG 2.5', 2: 'MPEG 2', 3: 'MPEG 1'};
    const layers = {1: 'Layer III', 2: 'Layer II', 3: 'Layer I'};
    const bitrates = [
      null,
      32,
      40,
      48,
      56,
      64,
      80,
      96,
      112,
      128,
      160,
      192,
      224,
      256,
      320,
    ];
    const sampleRates = [44100, 48000, 32000];
    final sampleRate =
        sampleRateIndex >= 0 && sampleRateIndex < sampleRates.length
        ? sampleRates[sampleRateIndex]
        : null;

    return MediaInspectResult(
      type: 'MP3',
      summary: [
        'MPEG 音频帧',
        'Version: ${versions[versionBits] ?? 'Unknown'}',
        'Layer: ${layers[layerBits] ?? 'Unknown'}',
        'Bitrate: ${bitrates[bitrateIndex] ?? 'Unknown'} kbps',
        'Sample Rate: ${sampleRate ?? 'Unknown'} Hz',
      ],
      structure: const ['Frame Sync: 0xFFE'],
      notes: const ['未检测到 ID3 头，当前样本更像裸 MP3 帧数据'],
    );
  }

  static List<String> _riffChunks(List<int> bytes, int startOffset) {
    final chunks = <String>[];
    var offset = startOffset;
    while (offset + 8 <= bytes.length && chunks.length < 12) {
      final chunkId = HexInput.ascii(bytes, offset, offset + 4);
      final chunkSize = HexInput.readUint32Le(bytes, offset + 4);
      if (chunkSize < 0) break;
      chunks.add('$chunkId ($chunkSize bytes)');
      offset += 8 + chunkSize + (chunkSize.isOdd ? 1 : 0);
    }
    return chunks;
  }

  static List<String> _riffNotes(List<int> bytes) {
    if (bytes.length < 8) return const [];
    final declaredSize = HexInput.readUint32Le(bytes, 4) + 8;
    if (bytes.length > declaredSize) {
      return ['RIFF 声明长度后仍多出 ${bytes.length - declaredSize} 字节，存在尾随隐藏数据嫌疑'];
    }
    if (bytes.length < declaredSize) {
      return ['当前样本短于 RIFF 声明长度，数据可能被截断'];
    }
    return const [];
  }

  static bool _startsWithAscii(List<int> bytes, String value) {
    if (bytes.length < value.length) return false;
    return HexInput.ascii(bytes, 0, value.length) == value;
  }

  static bool _looksLikeMpegFrame(List<int> bytes) {
    return bytes.length >= 4 && bytes[0] == 0xFF && (bytes[1] & 0xE0) == 0xE0;
  }

  static int _synchsafe(int a, int b, int c, int d) {
    return (a << 21) | (b << 14) | (c << 7) | d;
  }
}

class MediaInspectResult {
  const MediaInspectResult({
    required this.type,
    required this.summary,
    required this.structure,
    required this.notes,
  });

  final String type;
  final List<String> summary;
  final List<String> structure;
  final List<String> notes;
}
