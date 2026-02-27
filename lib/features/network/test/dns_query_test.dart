import 'package:dns_client/dns_client.dart';
import 'package:flutter/foundation.dart';

import '../utils/dns_utils.dart';

void main() async {
  final result = await DnsUtils.queryAllWith(DnsOverHttps.dnsSb(), 'baidu.com');
  debugPrint(result.toString());
}
