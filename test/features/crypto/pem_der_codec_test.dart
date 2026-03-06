import 'package:ctf_tools/features/crypto/utils/pem_der_codec.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PemDerCodec', () {
    test('round trips hex and pem', () {
      const hex = '3003020105';
      final pem = PemDerCodec.derHexToPem(hex, label: 'TEST KEY');
      expect(PemDerCodec.pemToDerHex(pem), hex);
    });
  });
}
