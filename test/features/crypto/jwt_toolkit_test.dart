import 'package:ctf_tools/features/crypto/utils/jwt_toolkit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('JwtToolkit', () {
    test('encodes and verifies hs256 token', () {
      final token = JwtToolkit.encode(
        header: {'typ': 'JWT'},
        payload: {'sub': 'flag'},
        algorithm: 'HS256',
        secret: 'secret',
      );
      expect(JwtToolkit.verify(token, 'secret'), isTrue);
      final decoded = JwtToolkit.decode(token, secret: 'secret');
      expect(decoded.payload['sub'], 'flag');
      expect(decoded.verified, isTrue);
    });

    test('supports none token', () {
      final token = JwtToolkit.encode(
        header: {'typ': 'JWT'},
        payload: {'sub': 'flag'},
        algorithm: 'none',
      );
      expect(token.endsWith('.'), isTrue);
    });
  });
}
