/// 简单替换密码工具集。
class ReplaceCipher {
  static const List<String> methods = ['ROT13', 'ROT47', 'Caesar', 'Atbash'];

  static String encode(String method, String input, {int shift = 13}) {
    return switch (method) {
      'ROT13' => _rotateLetters(input, 13),
      'ROT47' => _rotateAscii(input, 33, 126, 47),
      'Caesar' => _rotateLetters(input, shift),
      'Atbash' => _atbash(input),
      _ => throw ArgumentError('Unsupported replace cipher: $method'),
    };
  }

  static String decode(String method, String input, {int shift = 13}) {
    return switch (method) {
      'ROT13' => _rotateLetters(input, 13),
      'ROT47' => _rotateAscii(input, 33, 126, 47),
      'Caesar' => _rotateLetters(input, -shift),
      'Atbash' => _atbash(input),
      _ => throw ArgumentError('Unsupported replace cipher: $method'),
    };
  }

  static String _rotateLetters(String input, int shift) {
    final output = StringBuffer();
    for (final rune in input.runes) {
      final code = rune;
      if (code >= 65 && code <= 90) {
        output.writeCharCode(_rotate(code, 65, 26, shift));
      } else if (code >= 97 && code <= 122) {
        output.writeCharCode(_rotate(code, 97, 26, shift));
      } else {
        output.writeCharCode(code);
      }
    }
    return output.toString();
  }

  static String _rotateAscii(
    String input,
    int start,
    int end,
    int shift,
  ) {
    final range = end - start + 1;
    final output = StringBuffer();
    for (final rune in input.runes) {
      if (rune >= start && rune <= end) {
        output.writeCharCode(_rotate(rune, start, range, shift));
      } else {
        output.writeCharCode(rune);
      }
    }
    return output.toString();
  }

  static String _atbash(String input) {
    final output = StringBuffer();
    for (final rune in input.runes) {
      if (rune >= 65 && rune <= 90) {
        output.writeCharCode(90 - (rune - 65));
      } else if (rune >= 97 && rune <= 122) {
        output.writeCharCode(122 - (rune - 97));
      } else {
        output.writeCharCode(rune);
      }
    }
    return output.toString();
  }

  static int _rotate(int code, int start, int range, int shift) {
    final offset = (code - start + shift) % range;
    return start + (offset < 0 ? offset + range : offset);
  }
}
