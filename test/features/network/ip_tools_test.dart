import 'package:ctf_tools/features/network/utils/ip_tools.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('IpTools', () {
    test('normalizes and compresses ipv6', () {
      final expanded = IpTools.normalizeIpv6('2001:db8::1');
      expect(expanded, '2001:0DB8:0000:0000:0000:0000:0000:0001');
      expect(IpTools.compressIpv6(expanded), '2001:db8::1');
    });

    test('inspects cidr', () {
      final info = IpTools.inspectCidr('192.168.1.0/24');
      expect(info.network, '192.168.1.0');
      expect(info.broadcast, '192.168.1.255');
      expect(info.hostCount, 254);
    });

    test('parses port ranges', () {
      expect(IpTools.parsePorts('80,443,8000-8002'), [80, 443, 8000, 8001, 8002]);
    });
  });
}
