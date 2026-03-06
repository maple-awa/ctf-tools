/// 常见文件头识别工具。
class FileSignature {
  static FileSignatureResult inspectHex(String input) {
    final cleaned = input.replaceAll(RegExp(r'[^0-9a-fA-F]'), '').toUpperCase();
    if (cleaned.isEmpty || cleaned.length < 8) {
      throw const FormatException('至少需要 4 字节十六进制数据');
    }

    final type = _detectType(cleaned);
    final details = <String>[
      'Magic: ${_groupHex(cleaned.substring(0, cleaned.length >= 16 ? 16 : cleaned.length))}',
      'Type: $type',
    ];

    if (cleaned.startsWith('7F454C46')) {
      details.add('Class: ${_elfClass(cleaned)}');
      details.add('Endian: ${_elfEndian(cleaned)}');
    } else if (cleaned.startsWith('4D5A')) {
      details.add('DOS Header: MZ');
      if (cleaned.length >= 128) {
        final peOffsetHex = cleaned.substring(120, 128);
        final peOffset = _littleEndianToInt(peOffsetHex);
        details.add('PE Offset: 0x${peOffset.toRadixString(16).toUpperCase()}');
      }
    } else if (_isMachO(cleaned)) {
      details.add('Mach-O Header: detected');
    } else if (cleaned.startsWith('89504E470D0A1A0A')) {
      details.add('PNG Signature: valid');
    } else if (cleaned.startsWith('504B0304')) {
      details.add('ZIP Local Header: valid');
    }

    return FileSignatureResult(type: type, details: details);
  }

  static String _detectType(String hex) {
    if (hex.startsWith('7F454C46')) return 'ELF';
    if (hex.startsWith('4D5A')) return 'PE / MZ Executable';
    if (_isMachO(hex)) return 'Mach-O';
    if (hex.startsWith('89504E470D0A1A0A')) return 'PNG';
    if (hex.startsWith('FFD8FF')) return 'JPEG';
    if (hex.startsWith('474946383761') || hex.startsWith('474946383961')) {
      return 'GIF';
    }
    if (hex.startsWith('25504446')) return 'PDF';
    if (hex.startsWith('504B0304')) return 'ZIP / JAR / APK / DOCX';
    if (hex.startsWith('526172211A0700') || hex.startsWith('526172211A070100')) {
      return 'RAR';
    }
    if (hex.startsWith('1F8B08')) return 'GZIP';
    return 'Unknown';
  }

  static bool _isMachO(String hex) {
    return hex.startsWith('FEEDFACE') ||
        hex.startsWith('FEEDFACF') ||
        hex.startsWith('CEFAEDFE') ||
        hex.startsWith('CFFAEDFE') ||
        hex.startsWith('CAFEBABE');
  }

  static String _elfClass(String hex) {
    if (hex.length < 10) return 'Unknown';
    final value = hex.substring(8, 10);
    return switch (value) {
      '01' => 'ELF32',
      '02' => 'ELF64',
      _ => 'Unknown',
    };
  }

  static String _elfEndian(String hex) {
    if (hex.length < 12) return 'Unknown';
    final value = hex.substring(10, 12);
    return switch (value) {
      '01' => 'Little Endian',
      '02' => 'Big Endian',
      _ => 'Unknown',
    };
  }

  static int _littleEndianToInt(String hex) {
    final bytes = [
      for (int i = 0; i < hex.length; i += 2) hex.substring(i, i + 2),
    ].reversed;
    return int.parse(bytes.join(), radix: 16);
  }

  static String _groupHex(String hex) {
    return [
      for (int i = 0; i < hex.length; i += 2) hex.substring(i, i + 2),
    ].join(' ');
  }
}

class FileSignatureResult {
  const FileSignatureResult({required this.type, required this.details});

  final String type;
  final List<String> details;
}
