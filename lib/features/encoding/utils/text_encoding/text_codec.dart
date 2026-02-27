import 'dart:convert';

/// 文本编解码器统一接口。
abstract class TextCodec {
  /// 将原始文本转换为目标编码文本。
  String encode(String text);

  /// 将目标编码文本还原为原始文本。
  String decode(String text);
}

/// 文本编解码器工厂，按名称分发具体实现。
class TextCoderFactory {
  static final Map<String, TextCodec> _codecs = {
    "Unicode": UnicodeCoder(),
    "URL": UrlCoder(),
    "HTML": HtmlCoder(),
    "Quoted Printable": QuotedPrintableCoder(),
    "Morse Code": MorseCodeCoder()
  };

  /// 使用指定编码器执行编码。
  ///
  /// 当 [name] 未注册时抛出 [ArgumentError]。
  static String encode(String name, String text) {
    final codec = _codecs[name];
    if (codec == null) {
      throw ArgumentError('Unsupported text codec: $name');
    }
    return codec.encode(text);
  }

  /// 使用指定编码器执行解码。
  ///
  /// 当 [name] 未注册时抛出 [ArgumentError]。
  static String decode(String name, String text) {
    final codec = _codecs[name];
    if (codec == null) {
      throw ArgumentError('Unsupported text codec: $name');
    }
    return codec.decode(text);
  }
}

/// Unicode 转义（`\uXXXX`）编解码器。
class UnicodeCoder implements TextCodec {
  @override
  String decode(String text) {
    if (text.isEmpty) return "";
    // 正则匹配 \uXXXX 格式的 Unicode 编码
    RegExp unicodeRegex = RegExp(r'\\u([0-9a-fA-F]{4})');
    return text.replaceAllMapped(unicodeRegex, (match) {
      // 将 16 进制字符串转为整数，再转为字符
      int code = int.parse(match.group(1)!, radix: 16);
      return String.fromCharCode(code);
    });
  }

  @override
  String encode(String text) {
    if (text.isEmpty) return "";
    StringBuffer buffer = StringBuffer();
    for (int codeUnit in text.runes) {
      // 对非 ASCII 字符进行 Unicode 编码，ASCII 字符保持原样
      if (codeUnit > 127) {
        buffer.write("\\u${codeUnit.toRadixString(16).padLeft(4, '0')}");
      } else {
        buffer.writeCharCode(codeUnit);
      }
    }
    return buffer.toString();
  }
}

/// URL 组件编解码器。
class UrlCoder implements TextCodec {
  @override
  String decode(String text) {
    if (text.isEmpty) return "";
    return Uri.decodeComponent(text);
  }

  @override
  String encode(String text) {
    if (text.isEmpty) return "";
    return Uri.encodeComponent(text);
  }
}

/// 常见 HTML 实体编解码器。
class HtmlCoder implements TextCodec {
  @override
  String decode(String text) {
    if (text.isEmpty) return "";
    return text
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'");
  }

  @override
  String encode(String text) {
    if (text.isEmpty) return "";
    return text
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#39;');
  }
}

/// Quoted-Printable 编解码器（以 UTF-8 作为字节源）。
class QuotedPrintableCoder implements TextCodec {
  @override
  String decode(String text) {
    if (text.isEmpty) return "";

    final bytes = <int>[];
    int i = 0;

    while (i < text.length) {
      // 软换行（=CRLF 或 =LF）直接忽略。
      if (text[i] == '=' &&
          i + 1 < text.length &&
          (text[i + 1] == '\r' || text[i + 1] == '\n')) {
        i += 2;
        if (i < text.length && text[i - 1] == '\r' && text[i] == '\n') {
          i++;
        }
        continue;
      }

      // =XX 十六进制字节。
      if (text[i] == '=' && i + 2 < text.length) {
        final hex = text.substring(i + 1, i + 3);
        if (RegExp(r'^[0-9A-Fa-f]{2}$').hasMatch(hex)) {
          bytes.add(int.parse(hex, radix: 16));
          i += 3;
          continue;
        }
      }

      // 普通字符原样写入单字节。
      bytes.add(text.codeUnitAt(i));
      i++;
    }

    return utf8.decode(bytes, allowMalformed: true);
  }

  @override
  String encode(String text) {
    if (text.isEmpty) return "";

    final bytes = utf8.encode(text);
    final result = StringBuffer();
    int lineLength = 0;

    for (final value in bytes) {
      final bool isPrintable = (value >= 33 && value <= 60) || (value >= 62 && value <= 126);
      final String token;

      if (isPrintable) {
        token = String.fromCharCode(value);
      } else if (value == 32) {
        token = '=20';
      } else if (value == 61) {
        token = '=3D';
      } else {
        token = '=${value.toRadixString(16).toUpperCase().padLeft(2, '0')}';
      }

      // 写入前预判长度，超出则先换行，避免 token 被截断。
      if (lineLength + token.length > 76) {
        result.write('=\r\n');
        lineLength = 0;
      }
      result.write(token);
      lineLength += token.length;
    }

    return result.toString();
  }
}

/// 国际摩尔斯电码编解码器。
class MorseCodeCoder implements TextCodec {
  /// 标准摩尔斯映射表。
  static const Map<String, String> _morseMap = {
    'A': '.-', 'B': '-...', 'C': '-.-.', 'D': '-..', 'E': '.',
    'F': '..-.', 'G': '--.', 'H': '....', 'I': '..', 'J': '.---',
    'K': '-.-', 'L': '.-..', 'M': '--', 'N': '-.', 'O': '---',
    'P': '.--.', 'Q': '--.-', 'R': '.-.', 'S': '...', 'T': '-',
    'U': '..-', 'V': '...-', 'W': '.--', 'X': '-..-', 'Y': '-.--',
    'Z': '--..', '0': '-----', '1': '.----', '2': '..---',
    '3': '...--', '4': '....-', '5': '.....', '6': '-....',
    '7': '--...', '8': '---..', '9': '----.', '.': '.-.-.-',
    ',': '--..--', '?': '..--..', '!': '-.-.--', '/': '-..-.',
    '(': '-.--.', ')': '-.--.-', '&': '.-...', ':': '---...',
    ';': '-.-.-.', '=': '-...-', '+': '.-.-.', '-': '-....-',
    '_': '..--.-', '"': '.-..-.', r'$': '...-..-', '@': '.--.-.',
    ' ': '/'
  };

  /// 反向映射表，用于解码。
  static final Map<String, String> _reverseMorseMap = {
    for (final entry in _morseMap.entries) entry.value: entry.key
  };

  @override
  String decode(String text) {
    if (text.isEmpty) return "";

    final result = StringBuffer();
    final words = text.split('/');

    for (final word in words) {
      final chars = word.trim().split(RegExp(r'\s+'));
      for (final char in chars) {
        if (char.isNotEmpty) {
          result.write(_reverseMorseMap[char] ?? char);
        }
      }
      result.write(' ');
    }

    return result.toString().trim();
  }

  @override
  String encode(String text) {
    if (text.isEmpty) return "";

    final upperText = text.toUpperCase();
    final tokens = <String>[];

    for (int i = 0; i < upperText.length; i++) {
      final char = upperText[i];
      tokens.add(_morseMap[char] ?? char);
    }

    return tokens.join(' ').replaceAll(' / ', '/');
  }
}
