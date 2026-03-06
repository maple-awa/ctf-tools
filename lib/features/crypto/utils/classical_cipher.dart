class ClassicalCipher {
  static const List<String> methods = [
    'Caesar',
    'Atbash',
    'Vigenere',
    'Affine',
    'Rail Fence',
    'Baconian',
  ];

  static String encode(String method, String input, {String key = 'KEY'}) {
    return switch (method) {
      'Caesar' => _caesar(input, _parseShift(key)),
      'Atbash' => _atbash(input),
      'Vigenere' => _vigenere(input, key, true),
      'Affine' => _affine(input, key, true),
      'Rail Fence' => _railFence(input, _parseRail(key), true),
      'Baconian' => _baconian(input, true),
      _ => throw ArgumentError('Unsupported classical cipher: $method'),
    };
  }

  static String decode(String method, String input, {String key = 'KEY'}) {
    return switch (method) {
      'Caesar' => _caesar(input, -_parseShift(key)),
      'Atbash' => _atbash(input),
      'Vigenere' => _vigenere(input, key, false),
      'Affine' => _affine(input, key, false),
      'Rail Fence' => _railFence(input, _parseRail(key), false),
      'Baconian' => _baconian(input, false),
      _ => throw ArgumentError('Unsupported classical cipher: $method'),
    };
  }

  static int _parseShift(String key) {
    final parsed = int.tryParse(key.trim());
    if (parsed == null) {
      throw const FormatException('Caesar 需要整数位移');
    }
    return parsed;
  }

  static int _parseRail(String key) {
    final parsed = int.tryParse(key.trim());
    if (parsed == null || parsed < 2) {
      throw const FormatException('Rail Fence 需要至少 2 条 rail');
    }
    return parsed;
  }

  static String _caesar(String input, int shift) {
    final out = StringBuffer();
    for (final rune in input.runes) {
      if (rune >= 65 && rune <= 90) {
        out.writeCharCode(_rotate(rune, 65, shift));
      } else if (rune >= 97 && rune <= 122) {
        out.writeCharCode(_rotate(rune, 97, shift));
      } else {
        out.writeCharCode(rune);
      }
    }
    return out.toString();
  }

  static String _atbash(String input) {
    final out = StringBuffer();
    for (final rune in input.runes) {
      if (rune >= 65 && rune <= 90) {
        out.writeCharCode(90 - (rune - 65));
      } else if (rune >= 97 && rune <= 122) {
        out.writeCharCode(122 - (rune - 97));
      } else {
        out.writeCharCode(rune);
      }
    }
    return out.toString();
  }

  static String _vigenere(String input, String key, bool encode) {
    final cleanedKey = key.toUpperCase().replaceAll(RegExp(r'[^A-Z]'), '');
    if (cleanedKey.isEmpty) {
      throw const FormatException('Vigenere 需要字母密钥');
    }
    final out = StringBuffer();
    var keyIndex = 0;
    for (final rune in input.runes) {
      if (rune >= 65 && rune <= 90 || rune >= 97 && rune <= 122) {
        final base = rune >= 97 ? 97 : 65;
        final shift = cleanedKey.codeUnitAt(keyIndex % cleanedKey.length) - 65;
        final currentShift = encode ? shift : -shift;
        final normalized = (rune - base + currentShift) % 26;
        out.writeCharCode(base + (normalized < 0 ? normalized + 26 : normalized));
        keyIndex++;
      } else {
        out.writeCharCode(rune);
      }
    }
    return out.toString();
  }

  static String _affine(String input, String key, bool encode) {
    final parts = key.split(RegExp(r'[,\s]+')).where((item) => item.isNotEmpty).toList();
    if (parts.length < 2) {
      throw const FormatException('Affine 密钥格式为 a,b，例如 5,8');
    }
    final a = int.tryParse(parts[0]);
    final b = int.tryParse(parts[1]);
    if (a == null || b == null) {
      throw const FormatException('Affine 密钥必须是整数');
    }
    final inverse = _modInverse(a, 26);
    final out = StringBuffer();
    for (final rune in input.runes) {
      if (rune >= 65 && rune <= 90 || rune >= 97 && rune <= 122) {
        final base = rune >= 97 ? 97 : 65;
        final x = rune - base;
        final value = encode ? ((a * x) + b) % 26 : (inverse * (x - b)) % 26;
        out.writeCharCode(base + (value < 0 ? value + 26 : value));
      } else {
        out.writeCharCode(rune);
      }
    }
    return out.toString();
  }

  static String _railFence(String input, int rails, bool encode) {
    if (input.isEmpty) {
      return input;
    }
    if (encode) {
      final buckets = List.generate(rails, (_) => StringBuffer());
      var rail = 0;
      var step = 1;
      for (final char in input.split('')) {
        buckets[rail].write(char);
        if (rail == 0) {
          step = 1;
        } else if (rail == rails - 1) {
          step = -1;
        }
        rail += step;
      }
      return buckets.map((buffer) => buffer.toString()).join();
    }

    final pattern = <int>[];
    var rail = 0;
    var step = 1;
    for (var index = 0; index < input.length; index++) {
      pattern.add(rail);
      if (rail == 0) {
        step = 1;
      } else if (rail == rails - 1) {
        step = -1;
      }
      rail += step;
    }
    final counts = List<int>.filled(rails, 0);
    for (final currentRail in pattern) {
      counts[currentRail]++;
    }
    final railsText = <List<String>>[];
    var offset = 0;
    for (final count in counts) {
      railsText.add(input.substring(offset, offset + count).split(''));
      offset += count;
    }
    final positions = List<int>.filled(rails, 0);
    final output = StringBuffer();
    for (final currentRail in pattern) {
      output.write(railsText[currentRail][positions[currentRail]++]);
    }
    return output.toString();
  }

  static String _baconian(String input, bool encode) {
    const alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    if (encode) {
      final parts = <String>[];
      for (final rune in input.toUpperCase().runes) {
        if (rune < 65 || rune > 90) {
          continue;
        }
        final value = rune - 65;
        parts.add(value.toRadixString(2).padLeft(5, '0').replaceAll('0', 'A').replaceAll('1', 'B'));
      }
      return parts.join(' ');
    }
    final cleaned = input.toUpperCase().replaceAll(RegExp(r'[^AB]'), '');
    if (cleaned.isEmpty || cleaned.length % 5 != 0) {
      throw const FormatException('Baconian 密文需要 5 位一组的 A/B 串');
    }
    final output = StringBuffer();
    for (var index = 0; index < cleaned.length; index += 5) {
      final chunk = cleaned.substring(index, index + 5).replaceAll('A', '0').replaceAll('B', '1');
      output.write(alphabet[int.parse(chunk, radix: 2)]);
    }
    return output.toString();
  }

  static int _rotate(int rune, int base, int shift) {
    final normalized = (rune - base + shift) % 26;
    return base + (normalized < 0 ? normalized + 26 : normalized);
  }

  static int _modInverse(int value, int modulus) {
    var t = 0;
    var newT = 1;
    var r = modulus;
    var newR = value % modulus;
    while (newR != 0) {
      final quotient = r ~/ newR;
      final tempT = t - quotient * newT;
      t = newT;
      newT = tempT;
      final tempR = r - quotient * newR;
      r = newR;
      newR = tempR;
    }
    if (r != 1) {
      throw const FormatException('Affine 的 a 与 26 不互素');
    }
    return t < 0 ? t + modulus : t;
  }
}
