import 'package:dns_client/dns_client.dart';

/// DNS 查询结果的数据模型。
class DnsResult {
  /// IPv4 地址记录（A）。
  final List<String> aRecords;

  /// IPv6 地址记录（AAAA）。
  final List<String> aaaaRecords;

  /// 别名记录（CNAME）。
  final List<String> cnameRecords;

  /// 邮件交换记录（MX）。
  final List<String> mxRecords;

  /// 文本记录（TXT）。
  final List<String> txtRecords;

  /// 域名服务器记录（NS）。
  final List<String> nsRecords;

  /// 授权起始记录（SOA）。
  final String? soaRecord;

  /// 域名是否存在（排除 NXDOMAIN）。
  final bool exists;

  /// 查询失败时的错误信息。
  final String? error;

  @override
  String toString() {
    if (error != null) {
      return 'DnsResult(error: $error)';
    }
    if (!exists) {
      return 'DnsResult(domain does not exist)';
    }

    final buffer = StringBuffer('DnsResult(\n');
    if (aRecords.isNotEmpty) buffer.write('  A: $aRecords\n');
    if (aaaaRecords.isNotEmpty) buffer.write('  AAAA: $aaaaRecords\n');
    if (cnameRecords.isNotEmpty) buffer.write('  CNAME: $cnameRecords\n');
    if (mxRecords.isNotEmpty) buffer.write('  MX: $mxRecords\n');
    if (txtRecords.isNotEmpty) buffer.write('  TXT: $txtRecords\n');
    if (nsRecords.isNotEmpty) buffer.write('  NS: $nsRecords\n');
    if (soaRecord != null) buffer.write('  SOA: $soaRecord\n');
    buffer.write(')');
    return buffer.toString();
  }

  DnsResult({
    this.aRecords = const [],
    this.aaaaRecords = const [],
    this.cnameRecords = const [],
    this.mxRecords = const [],
    this.txtRecords = const [],
    this.nsRecords = const [],
    this.soaRecord,
    this.exists = true,
    this.error,
  });
}

/// DNS 查询工具类。
class DnsUtils {
  /// 预定义 DNS-over-HTTPS 服务列表。
  ///
  /// 使用 `final` 避免每次访问都重复创建客户端实例。
  static final Map<String, DnsOverHttps> dnsServers = {
    'Cloudflare': DnsOverHttps.cloudflare(timeout: const Duration(seconds: 10)),
    'Google DNS': DnsOverHttps.google(timeout: const Duration(seconds: 10)),
    'AdGuard': DnsOverHttps.adguard(timeout: const Duration(seconds: 10)),
    'AdGuardFamily': DnsOverHttps.adguardFamily(timeout: const Duration(seconds: 10)),
    'AdGuardNonFiltering': DnsOverHttps.adguardNonFiltering(timeout: const Duration(seconds: 10)),
    'DnsSb': DnsOverHttps.dnsSb(timeout: const Duration(seconds: 10)),
    'NextDns': DnsOverHttps.nextdns(timeout: const Duration(seconds: 10)),
    'NextDnsAnycast': DnsOverHttps.nextdnsAnycast(timeout: const Duration(seconds: 10)),
    '阿里DNS': DnsOverHttps("https://dns.alidns.com/dns-query", timeout: const Duration(seconds: 10)),
    '腾讯DNSPod': DnsOverHttps("https://doh.pub/dns-query", timeout: const Duration(seconds: 10)),
    '华为Cloud': DnsOverHttps("https://dns.huaweicloud.com/dns-query", timeout: const Duration(seconds: 10)),
    '360 DoH': DnsOverHttps("https://doh.360.cn/dns-query", timeout: const Duration(seconds: 10)),
    '114 DoH': DnsOverHttps("https://doh.114dns.com/dns-query", timeout: const Duration(seconds: 10)),
  };

  /// 使用指定 DoH 客户端查询域名常见记录。
  ///
  /// 返回 [DnsResult]，不会向外抛出网络异常。
  static Future<DnsResult> queryAllWith(DnsOverHttps dns, String domain) async {
    final cleanDomain = _sanitizeDomain(domain);
    if (cleanDomain.isEmpty) {
      return DnsResult(error: 'Invalid domain input');
    }

    try {
      // 先查 A 记录判断是否存在
      final aResponse = await dns.lookupHttpsByRRType(cleanDomain, RRType.A);

      if (aResponse.isNxDomain) {
        return DnsResult(exists: false);
      }
      if (aResponse.isServerFailure) {
        return DnsResult(error: 'DNS server failure (SERVFAIL)');
      }

      // 并发查询各类记录
      final recordFutures = [
        _safeLookup(dns, RRType.A, cleanDomain),
        _safeLookup(dns, RRType.AAAA, cleanDomain),
        _safeLookup(dns, RRType.CNAME, cleanDomain),
        _safeLookup(dns, RRType.MX, cleanDomain),
        _safeLookup(dns, RRType.TXT, cleanDomain),
        _safeLookup(dns, RRType.NS, cleanDomain),
      ];
      final records = await Future.wait(recordFutures);

      final soa = await _safeLookupSoa(dns, cleanDomain);

      return DnsResult(
        aRecords: records[0],
        aaaaRecords: records[1],
        cnameRecords: records[2],
        mxRecords: records[3],
        txtRecords: records[4],
        nsRecords: records[5],
        soaRecord: soa,
        exists: true,
      );
    } on DnsHttpException catch (e) {
      return DnsResult(
        error: 'Network error: ${e.message} (HTTP ${e.statusCode})',
      );
    } on Exception catch (e) {
      return DnsResult(error: 'Unexpected error: ${e.toString()}');
    }
  }

  /// 安全查询指定记录类型，查询异常时返回空列表。
  static Future<List<String>> _safeLookup(
    DnsOverHttps dns,
    RRType type,
    String domain,
  ) async {
    try {
      return await dns.lookupDataByRRType(domain, type);
    } catch (e) {
      return [];
    }
  }

  /// 安全查询 SOA 记录，查询异常时返回 `null`。
  static Future<String?> _safeLookupSoa(DnsOverHttps dns, String domain) async {
    try {
      final records = await dns.lookupDataByRRType(domain, RRType.SOA);
      return records.isNotEmpty ? records.first : null;
    } catch (e) {
      return null;
    }
  }

  /// 规范化用户输入的域名/URL，提取纯主机名。
  static String _sanitizeDomain(String input) {
    final raw = input.trim();
    if (raw.isEmpty) return '';

    // 优先按 URL 解析，兼容 `https://example.com:443/path`。
    final uri = Uri.tryParse(raw);
    if (uri != null && uri.hasScheme && uri.host.isNotEmpty) {
      return uri.host.toLowerCase().replaceAll(RegExp(r'\.$'), '');
    }

    // 兼容不带 scheme 的输入：example.com/path 或 example.com:443。
    var domain = raw.split('/').first.trim();
    if (domain.contains(':')) {
      domain = domain.split(':').first;
    }

    return domain.toLowerCase().replaceAll(RegExp(r'\.$'), '');
  }
}
