import 'package:ctf_tools/features/crypto/utils/crypto_codec.dart';

class RsaToolkit {
  static const List<String> inputFormats = CryptoCodec.rsaFormats;
  static const List<String> outputFormats = [
    'Integer',
    'UTF-8',
    'Hex lower',
    'Hex upper',
    'Base64',
  ];

  static RsaDerivedKey derivePrivateKey({
    required String pText,
    required String qText,
    required String eText,
  }) {
    final p = CryptoCodec.parseBigInt(pText);
    final q = CryptoCodec.parseBigInt(qText);
    final e = CryptoCodec.parseBigInt(eText);
    if (p <= BigInt.one || q <= BigInt.one) {
      throw const FormatException('p 和 q 必须大于 1');
    }

    final n = p * q;
    final phi = (p - BigInt.one) * (q - BigInt.one);
    _assertCoprime(e, phi, 'e 与 phi(n) 不互素，无法求逆');

    final d = _modInverse(e, phi);
    final dp = d % (p - BigInt.one);
    final dq = d % (q - BigInt.one);
    final qInv = _modInverse(q, p);

    return RsaDerivedKey(
      p: p,
      q: q,
      n: n,
      phi: phi,
      d: d,
      dp: dp,
      dq: dq,
      qInv: qInv,
    );
  }

  static RsaPhiDerivedKey derivePrivateKeyFromPhi({
    required String nText,
    required String phiText,
    required String eText,
  }) {
    final n = CryptoCodec.parseBigInt(nText);
    final phi = CryptoCodec.parseBigInt(phiText);
    final e = CryptoCodec.parseBigInt(eText);
    _assertCoprime(e, phi, 'e 与 phi 不互素，无法求逆');
    final d = _modInverse(e, phi);
    return RsaPhiDerivedKey(n: n, phi: phi, e: e, d: d);
  }

  static RsaProcessResult encrypt({
    required String messageText,
    required String inputFormat,
    required String outputFormat,
    required String nText,
    required String eText,
  }) {
    final message = _parseInputValue(messageText, inputFormat);
    final n = CryptoCodec.parseBigInt(nText);
    final e = CryptoCodec.parseBigInt(eText);
    if (message >= n) {
      throw const FormatException('原始消息整数必须小于 n');
    }
    final cipher = message.modPow(e, n);
    return _buildResult(cipher, outputFormat);
  }

  static RsaProcessResult decrypt({
    required String cipherText,
    required String inputFormat,
    required String outputFormat,
    required String nText,
    required String dText,
  }) {
    final cipher = _parseInputValue(cipherText, inputFormat);
    final n = CryptoCodec.parseBigInt(nText);
    final d = CryptoCodec.parseBigInt(dText);
    final plain = cipher.modPow(d, n);
    return _buildResult(plain, outputFormat);
  }

  static RsaProcessResult sign({
    required String messageText,
    required String inputFormat,
    required String outputFormat,
    required String nText,
    required String dText,
  }) {
    final message = _parseInputValue(messageText, inputFormat);
    final n = CryptoCodec.parseBigInt(nText);
    final d = CryptoCodec.parseBigInt(dText);
    if (message >= n) {
      throw const FormatException('待签名整数必须小于 n');
    }
    final signature = message.modPow(d, n);
    return _buildResult(signature, outputFormat);
  }

  static RsaVerifyResult verify({
    required String messageText,
    required String messageFormat,
    required String signatureText,
    required String signatureFormat,
    required String nText,
    required String eText,
  }) {
    final expected = _parseInputValue(messageText, messageFormat);
    final signature = _parseInputValue(signatureText, signatureFormat);
    final n = CryptoCodec.parseBigInt(nText);
    final e = CryptoCodec.parseBigInt(eText);
    final recovered = signature.modPow(e, n);
    return RsaVerifyResult(
      isValid: recovered == expected,
      recoveredValue: recovered,
      recoveredPreview: _preview(recovered),
    );
  }

  static RsaFermatResult fermatFactor({
    required String nText,
    int maxIterations = 200000,
  }) {
    final n = CryptoCodec.parseBigInt(nText);
    if (n <= BigInt.one || n.isEven) {
      throw const FormatException('Fermat 分解要求 n 为大于 1 的奇数');
    }

    var a = _ceilSqrt(n);
    for (var iteration = 0; iteration <= maxIterations; iteration++) {
      final bSquared = a * a - n;
      final b = _floorSqrt(bSquared);
      if (b * b == bSquared) {
        final p = a - b;
        final q = a + b;
        return RsaFermatResult(
          n: n,
          p: p <= q ? p : q,
          q: p <= q ? q : p,
          iterations: iteration,
        );
      }
      a += BigInt.one;
    }

    throw const FormatException('Fermat 在限制步数内未找到因子');
  }

  static RsaProcessResult recoverSmallExponent({
    required String cipherText,
    required String inputFormat,
    required String outputFormat,
    required String eText,
  }) {
    final cipher = _parseInputValue(cipherText, inputFormat);
    final exponentValue = CryptoCodec.parseBigInt(eText);
    if (exponentValue <= BigInt.one || exponentValue > BigInt.from(64)) {
      throw const FormatException('小指数开根仅支持 2 到 64 之间的 e');
    }
    final exponent = exponentValue.toInt();
    final root = _integerNthRoot(cipher, exponent);
    if (_pow(root, exponent) != cipher) {
      throw const FormatException('当前输入不是完美 e 次幂，无法直接开根');
    }
    return _buildResult(root, outputFormat);
  }

  static RsaProcessResult commonModulusAttack({
    required String nText,
    required String c1Text,
    required String c2Text,
    required String e1Text,
    required String e2Text,
    required String cipherFormat,
    required String outputFormat,
  }) {
    final n = CryptoCodec.parseBigInt(nText);
    final c1 = _parseInputValue(c1Text, cipherFormat);
    final c2 = _parseInputValue(c2Text, cipherFormat);
    final e1 = CryptoCodec.parseBigInt(e1Text);
    final e2 = CryptoCodec.parseBigInt(e2Text);

    final egcd = _extendedGcd(e1, e2);
    if (egcd.gcd != BigInt.one) {
      throw const FormatException('共模攻击要求 e1 与 e2 互素');
    }

    final part1 = _modPowSigned(c1, egcd.x, n);
    final part2 = _modPowSigned(c2, egcd.y, n);
    final message = (part1 * part2) % n;
    return _buildResult(message, outputFormat);
  }

  static String describeInput(String input, String format) {
    if (format == 'Integer') {
      final value = CryptoCodec.parseBigInt(input);
      return [
        'Input Format: Integer',
        'Bit Length: ${value.bitLength}',
        'Preview:',
        CryptoCodec.formatBigInt(value),
      ].join('\n');
    }
    final bytes = CryptoCodec.parseBytes(input, format);
    return [
      'Input Format: $format',
      'Byte Length: ${bytes.length}',
      'ASCII Preview: ${CryptoCodec.asciiPreview(bytes)}',
      'Integer: ${CryptoCodec.bytesToBigInt(bytes)}',
    ].join('\n');
  }

  static String formatBigInt(BigInt value) => CryptoCodec.formatBigInt(value);

  static BigInt _parseInputValue(String input, String format) {
    return CryptoCodec.parseRsaValue(input, format);
  }

  static RsaProcessResult _buildResult(BigInt value, String outputFormat) {
    return RsaProcessResult(
      value: value,
      formatted: CryptoCodec.formatRsaValue(value, outputFormat),
      utf8Preview: _preview(value),
    );
  }

  static String _preview(BigInt value) {
    try {
      return CryptoCodec.formatBytes(CryptoCodec.bigIntToBytes(value), 'UTF-8');
    } catch (_) {
      return '';
    }
  }

  static void _assertCoprime(BigInt left, BigInt right, String message) {
    if (_gcd(left, right) != BigInt.one) {
      throw FormatException(message);
    }
  }

  static BigInt _modPowSigned(BigInt value, BigInt exponent, BigInt modulus) {
    if (exponent >= BigInt.zero) {
      return value.modPow(exponent, modulus);
    }
    final inverse = _modInverse(value, modulus);
    return inverse.modPow(-exponent, modulus);
  }

  static BigInt _gcd(BigInt a, BigInt b) {
    var x = a.abs();
    var y = b.abs();
    while (y != BigInt.zero) {
      final temp = x % y;
      x = y;
      y = temp;
    }
    return x;
  }

  static BigInt _modInverse(BigInt a, BigInt m) {
    final result = _extendedGcd(a, m);
    if (result.gcd != BigInt.one) {
      throw const FormatException('模逆不存在');
    }
    return (result.x % m + m) % m;
  }

  static _ExtendedGcdResult _extendedGcd(BigInt a, BigInt b) {
    if (b == BigInt.zero) {
      return _ExtendedGcdResult(gcd: a, x: BigInt.one, y: BigInt.zero);
    }
    final next = _extendedGcd(b, a % b);
    return _ExtendedGcdResult(
      gcd: next.gcd,
      x: next.y,
      y: next.x - (a ~/ b) * next.y,
    );
  }

  static BigInt _floorSqrt(BigInt value) {
    if (value < BigInt.zero) {
      throw const FormatException('平方根输入不能为负数');
    }
    if (value < BigInt.from(2)) {
      return value;
    }

    var low = BigInt.one;
    var high = BigInt.one << ((value.bitLength + 1) ~/ 2 + 1);
    var answer = BigInt.one;
    while (low <= high) {
      final mid = (low + high) >> 1;
      final square = mid * mid;
      if (square == value) {
        return mid;
      }
      if (square < value) {
        answer = mid;
        low = mid + BigInt.one;
      } else {
        high = mid - BigInt.one;
      }
    }
    return answer;
  }

  static BigInt _ceilSqrt(BigInt value) {
    final floor = _floorSqrt(value);
    return floor * floor == value ? floor : floor + BigInt.one;
  }

  static BigInt _integerNthRoot(BigInt value, int exponent) {
    if (value < BigInt.zero) {
      throw const FormatException('负数不支持整数开根');
    }
    if (value <= BigInt.one) {
      return value;
    }

    var low = BigInt.zero;
    var high = BigInt.one << ((value.bitLength + exponent - 1) ~/ exponent + 1);
    var answer = BigInt.zero;
    while (low <= high) {
      final mid = (low + high) >> 1;
      final midPow = _pow(mid, exponent);
      if (midPow == value) {
        return mid;
      }
      if (midPow < value) {
        answer = mid;
        low = mid + BigInt.one;
      } else {
        high = mid - BigInt.one;
      }
    }
    return answer;
  }

  static BigInt _pow(BigInt base, int exponent) {
    var result = BigInt.one;
    var factor = base;
    var power = exponent;
    while (power > 0) {
      if (power.isOdd) {
        result *= factor;
      }
      factor *= factor;
      power >>= 1;
    }
    return result;
  }
}

class RsaDerivedKey {
  const RsaDerivedKey({
    required this.p,
    required this.q,
    required this.n,
    required this.phi,
    required this.d,
    required this.dp,
    required this.dq,
    required this.qInv,
  });

  final BigInt p;
  final BigInt q;
  final BigInt n;
  final BigInt phi;
  final BigInt d;
  final BigInt dp;
  final BigInt dq;
  final BigInt qInv;
}

class RsaPhiDerivedKey {
  const RsaPhiDerivedKey({
    required this.n,
    required this.phi,
    required this.e,
    required this.d,
  });

  final BigInt n;
  final BigInt phi;
  final BigInt e;
  final BigInt d;
}

class RsaFermatResult {
  const RsaFermatResult({
    required this.n,
    required this.p,
    required this.q,
    required this.iterations,
  });

  final BigInt n;
  final BigInt p;
  final BigInt q;
  final int iterations;
}

class RsaProcessResult {
  const RsaProcessResult({
    required this.value,
    required this.formatted,
    required this.utf8Preview,
  });

  final BigInt value;
  final String formatted;
  final String utf8Preview;
}

class RsaVerifyResult {
  const RsaVerifyResult({
    required this.isValid,
    required this.recoveredValue,
    required this.recoveredPreview,
  });

  final bool isValid;
  final BigInt recoveredValue;
  final String recoveredPreview;
}

class _ExtendedGcdResult {
  const _ExtendedGcdResult({
    required this.gcd,
    required this.x,
    required this.y,
  });

  final BigInt gcd;
  final BigInt x;
  final BigInt y;
}
