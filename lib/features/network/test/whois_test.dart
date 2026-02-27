import 'package:whois/whois.dart';
import 'package:flutter/foundation.dart';

Future<void> main() async {
  final whoisResponse = await Whois.lookup('xeost.com');
  final parsedResponse = Whois.formatLookup(whoisResponse);
  debugPrint(parsedResponse.toString());
}
