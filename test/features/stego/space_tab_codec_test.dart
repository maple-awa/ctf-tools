import 'package:ctf_tools/features/stego/utils/space_tab_codec.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SpaceTabCodec', () {
    test('round trips plaintext', () {
      const message = 'flag';
      final encoded = SpaceTabCodec.encode(message);
      expect(SpaceTabCodec.decode(encoded), message);
    });

    test('inspect counts spaces and tabs', () {
      final report = SpaceTabCodec.inspect(' \t \t');
      expect(report, contains('Spaces: 2'));
      expect(report, contains('Tabs: 2'));
    });
  });
}
