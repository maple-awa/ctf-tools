import 'package:ctf_tools/features/encoding/utils/number_encoding/number_codec.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NumberCodec', () {
    test('base conversion 10 -> 16', () {
      final result = NumberCodec.convertBase('255', fromBase: 10, toBase: 16);
      expect(result, 'FF');
    });

    test('base conversion 2 -> 10', () {
      final result = NumberCodec.convertBase(
        '11111111',
        fromBase: 2,
        toBase: 10,
      );
      expect(result, '255');
    });

    test('base conversion supports >36 (62)', () {
      final result = NumberCodec.convertBase('zz', fromBase: 62, toBase: 10);
      expect(result, '3843');
    });

    test('base conversion supports 64 charset', () {
      final to10 = NumberCodec.convertBase('+/', fromBase: 64, toBase: 10);
      expect(to10, '4031');

      final to64 = NumberCodec.convertBase('4031', fromBase: 10, toBase: 64);
      expect(to64, '+/');
    });

    test('base<=36 accepts lower case input', () {
      final result = NumberCodec.convertBase('ff', fromBase: 16, toBase: 10);
      expect(result, '255');
    });

    test('binary <-> hex', () {
      expect(NumberCodec.binaryToHex('1010 1111'), 'AF');
      expect(NumberCodec.hexToBinary('AF'), '10101111');
    });

    test('decimal <-> bcd', () {
      final bcd = NumberCodec.decimalToBcdHex('123456');
      expect(bcd, '12 34 56');
      expect(NumberCodec.bcdHexToDecimal(bcd), '123456');
    });

    test('invalid base char should throw', () {
      expect(
        () => NumberCodec.convertBase('A', fromBase: 10, toBase: 2),
        throwsA(isA<FormatException>()),
      );
    });

    test('invalid bcd should throw', () {
      expect(
        () => NumberCodec.bcdHexToDecimal('1A'),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
