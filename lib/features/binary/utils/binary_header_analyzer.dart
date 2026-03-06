import 'package:ctf_tools/shared/utils/hex_input.dart';

class BinaryHeaderResult {
  const BinaryHeaderResult({
    required this.type,
    required this.summary,
    required this.checksec,
  });

  final String type;
  final List<String> summary;
  final List<String> checksec;
}

class BinaryHeaderAnalyzer {
  static BinaryHeaderResult inspectHex(String input) {
    final bytes = HexInput.parseBytes(input, minBytes: 16, errorMessage: '请输入至少 16 字节十六进制数据');
    final normalized = HexInput.normalize(input);
    if (normalized.startsWith('7F454C46')) {
      return _inspectElf(bytes);
    }
    if (normalized.startsWith('4D5A')) {
      return _inspectPe(bytes);
    }
    if (_isMachO(normalized)) {
      return _inspectMachO(bytes);
    }
    return BinaryHeaderResult(
      type: 'Unknown',
      summary: ['Magic: ${HexInput.formatBytes(bytes.take(16).toList())}'],
      checksec: const ['未知格式，无法生成 checksec 摘要'],
    );
  }

  static BinaryHeaderResult _inspectElf(List<int> bytes) {
    final is64 = bytes[4] == 2;
    final littleEndian = bytes[5] == 1;
    final read16 = littleEndian ? HexInput.readUint16Le : HexInput.readUint16Be;
    final read32 = littleEndian ? HexInput.readUint32Le : HexInput.readUint32Be;
    final type = read16(bytes, 16);
    final machine = read16(bytes, 18);
    final entryOffset = is64 ? 24 : 24;
    final entry = is64
        ? (littleEndian
            ? (HexInput.readUint32Le(bytes, entryOffset) | (HexInput.readUint32Le(bytes, entryOffset + 4) << 32))
            : (HexInput.readUint32Be(bytes, entryOffset + 4) | (HexInput.readUint32Be(bytes, entryOffset) << 32)))
        : read32(bytes, entryOffset);
    final checksec = <String>[
      'PIE: ${type == 3 ? 'Enabled (ET_DYN)' : 'Disabled/Unknown'}',
      'NX: ${bytes.length >= 64 ? 'Header present, static decision limited' : 'Unknown'}',
      'Canary: 仅凭头部无法确认',
      'RELRO: 仅凭头部无法确认',
    ];
    return BinaryHeaderResult(
      type: 'ELF',
      summary: [
        'Class: ${is64 ? 'ELF64' : 'ELF32'}',
        'Endian: ${littleEndian ? 'Little Endian' : 'Big Endian'}',
        'Type: 0x${type.toRadixString(16).toUpperCase()}',
        'Machine: 0x${machine.toRadixString(16).toUpperCase()}',
        'Entry: 0x${entry.toRadixString(16).toUpperCase()}',
      ],
      checksec: checksec,
    );
  }

  static BinaryHeaderResult _inspectPe(List<int> bytes) {
    if (bytes.length < 0x40) {
      throw const FormatException('PE 数据不足，无法读取 DOS/PE 头');
    }
    final peOffset = HexInput.readUint32Le(bytes, 0x3C);
    if (bytes.length < peOffset + 0x60) {
      throw const FormatException('PE Header 超出输入范围');
    }
    final machine = HexInput.readUint16Le(bytes, peOffset + 4);
    final characteristics = HexInput.readUint16Le(bytes, peOffset + 22);
    final optionalMagic = HexInput.readUint16Le(bytes, peOffset + 24);
    final dllCharacteristics = HexInput.readUint16Le(bytes, peOffset + 70);
    return BinaryHeaderResult(
      type: 'PE',
      summary: [
        'Machine: 0x${machine.toRadixString(16).toUpperCase()}',
        'Characteristics: 0x${characteristics.toRadixString(16).toUpperCase()}',
        'Optional Header: 0x${optionalMagic.toRadixString(16).toUpperCase()}',
        'PE Offset: 0x${peOffset.toRadixString(16).toUpperCase()}',
      ],
      checksec: [
        'ASLR: ${(dllCharacteristics & 0x40) != 0 ? 'Enabled' : 'Disabled'}',
        'NX (DEP): ${(dllCharacteristics & 0x100) != 0 ? 'Enabled' : 'Disabled'}',
        'CFG: ${(dllCharacteristics & 0x4000) != 0 ? 'Enabled' : 'Disabled/Unknown'}',
      ],
    );
  }

  static BinaryHeaderResult _inspectMachO(List<int> bytes) {
    final magic = HexInput.readUint32Be(bytes, 0);
    return BinaryHeaderResult(
      type: 'Mach-O',
      summary: [
        'Magic: 0x${magic.toRadixString(16).toUpperCase()}',
        '64-bit: ${magic == 0xFEEDFACF || magic == 0xCFFAEDFE}',
        'Fat Binary: ${magic == 0xCAFEBABE}',
      ],
      checksec: const [
        'PIE/NX: 仅凭当前头部样本无法稳定确认',
      ],
    );
  }

  static bool _isMachO(String hex) {
    return hex.startsWith('FEEDFACE') || hex.startsWith('FEEDFACF') || hex.startsWith('CEFAEDFE') || hex.startsWith('CFFAEDFE') || hex.startsWith('CAFEBABE');
  }
}
