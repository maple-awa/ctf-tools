import 'package:ctf_tools/features/crypto/utils/classical_cipher.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ClassicalCipher', () {
    test('affine round trip', () {
      final cipher = ClassicalCipher.encode('Affine', 'flag', key: '5,8');
      expect(ClassicalCipher.decode('Affine', cipher, key: '5,8'), 'flag');
    });

    test('rail fence round trip', () {
      final cipher = ClassicalCipher.encode('Rail Fence', 'WEAREDISCOVERED', key: '3');
      expect(ClassicalCipher.decode('Rail Fence', cipher, key: '3'), 'WEAREDISCOVERED');
    });

    test('baconian round trip', () {
      final cipher = ClassicalCipher.encode('Baconian', 'ABC');
      expect(ClassicalCipher.decode('Baconian', cipher), 'ABC');
    });
  });
}
