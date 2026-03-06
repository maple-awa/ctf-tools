import 'dart:math';

class CidrInfo {
  const CidrInfo({
    required this.network,
    required this.broadcast,
    required this.mask,
    required this.firstHost,
    required this.lastHost,
    required this.hostCount,
  });

  final String network;
  final String broadcast;
  final String mask;
  final String firstHost;
  final String lastHost;
  final int hostCount;
}

class IpTools {
  static String ipv4ToDecimal(String ipv4) {
    final parts = _parseIpv4(ipv4);
    var value = 0;
    for (final part in parts) {
      value = (value << 8) | part;
    }
    return value.toString();
  }

  static String ipv4ToHex(String ipv4) {
    final parts = _parseIpv4(ipv4);
    return parts.map((part) => part.toRadixString(16).padLeft(2, '0')).join(' ').toUpperCase();
  }

  static String ipv4ToBinary(String ipv4) {
    final parts = _parseIpv4(ipv4);
    return parts.map((part) => part.toRadixString(2).padLeft(8, '0')).join('.');
  }

  static String decimalToIpv4(String decimal) {
    final value = int.tryParse(decimal.trim());
    if (value == null || value < 0 || value > 0xFFFFFFFF) {
      throw const FormatException('十进制 IPv4 超出范围');
    }
    return _intToIpv4(value);
  }

  static String binaryToIpv4(String binary) {
    final cleaned = binary.replaceAll(RegExp(r'[^01]'), '');
    if (cleaned.length != 32) {
      throw const FormatException('二进制 IPv4 必须是 32 位');
    }
    final parts = [
      for (int i = 0; i < 32; i += 8) int.parse(cleaned.substring(i, i + 8), radix: 2),
    ];
    return parts.join('.');
  }

  static String normalizeIpv6(String input) {
    final groups = _expandIpv6(input);
    return groups.map((group) => group.toRadixString(16).padLeft(4, '0')).join(':').toUpperCase();
  }

  static String compressIpv6(String input) {
    final groups = _expandIpv6(input);
    final hexGroups = groups.map((group) => group.toRadixString(16)).toList();
    var bestStart = -1;
    var bestLength = 0;
    for (var index = 0; index < hexGroups.length;) {
      if (hexGroups[index] != '0') {
        index++;
        continue;
      }
      var end = index;
      while (end < hexGroups.length && hexGroups[end] == '0') {
        end++;
      }
      if (end - index > bestLength) {
        bestStart = index;
        bestLength = end - index;
      }
      index = end;
    }
    if (bestLength < 2) {
      return hexGroups.join(':');
    }
    final before = hexGroups.sublist(0, bestStart).join(':');
    final after = hexGroups.sublist(bestStart + bestLength).join(':');
    if (before.isEmpty && after.isEmpty) {
      return '::';
    }
    if (before.isEmpty) {
      return '::$after';
    }
    if (after.isEmpty) {
      return '$before::';
    }
    return '$before::$after';
  }

  static CidrInfo inspectCidr(String input) {
    final parts = input.trim().split('/');
    if (parts.length != 2) {
      throw const FormatException('CIDR 格式必须为 address/prefix');
    }
    final ip = ipv4ToInt(parts[0]);
    final prefix = int.tryParse(parts[1]);
    if (prefix == null || prefix < 0 || prefix > 32) {
      throw const FormatException('CIDR 前缀必须在 0~32');
    }
    final mask = prefix == 0 ? 0 : (0xFFFFFFFF << (32 - prefix)) & 0xFFFFFFFF;
    final network = ip & mask;
    final broadcast = network | (~mask & 0xFFFFFFFF);
    final hostCount = prefix >= 31 ? max(0, 1 << (32 - prefix)) : max(0, (1 << (32 - prefix)) - 2);
    final firstHost = prefix >= 31 ? network : network + 1;
    final lastHost = prefix >= 31 ? broadcast : broadcast - 1;
    return CidrInfo(
      network: _intToIpv4(network),
      broadcast: _intToIpv4(broadcast),
      mask: _intToIpv4(mask),
      firstHost: _intToIpv4(firstHost),
      lastHost: _intToIpv4(lastHost),
      hostCount: hostCount,
    );
  }

  static int ipv4ToInt(String ipv4) {
    final parts = _parseIpv4(ipv4);
    var value = 0;
    for (final part in parts) {
      value = (value << 8) | part;
    }
    return value;
  }

  static List<int> parsePorts(String input) {
    final ports = <int>{};
    for (final token in input.split(',')) {
      final trimmed = token.trim();
      if (trimmed.isEmpty) {
        continue;
      }
      if (trimmed.contains('-')) {
        final bounds = trimmed.split('-');
        if (bounds.length != 2) {
          throw FormatException('端口范围非法: $trimmed');
        }
        final start = int.tryParse(bounds[0]);
        final end = int.tryParse(bounds[1]);
        if (start == null || end == null || start < 1 || end > 65535 || start > end) {
          throw FormatException('端口范围非法: $trimmed');
        }
        for (var port = start; port <= end; port++) {
          ports.add(port);
        }
      } else {
        final port = int.tryParse(trimmed);
        if (port == null || port < 1 || port > 65535) {
          throw FormatException('端口非法: $trimmed');
        }
        ports.add(port);
      }
    }
    return ports.toList()..sort();
  }

  static List<int> _parseIpv4(String input) {
    final parts = input.trim().split('.');
    if (parts.length != 4) {
      throw const FormatException('IPv4 必须包含 4 段');
    }
    return parts.map((part) {
      final value = int.tryParse(part);
      if (value == null || value < 0 || value > 255) {
        throw const FormatException('IPv4 每段必须在 0~255');
      }
      return value;
    }).toList();
  }

  static List<int> _expandIpv6(String input) {
    final value = input.trim();
    if (value.isEmpty) {
      throw const FormatException('IPv6 不能为空');
    }
    final halves = value.split('::');
    if (halves.length > 2) {
      throw const FormatException('IPv6 格式非法');
    }
    final left = halves.first.isEmpty ? <String>[] : halves.first.split(':');
    final right = halves.length == 2 && halves.last.isNotEmpty ? halves.last.split(':') : <String>[];
    final missing = 8 - (left.length + right.length);
    if (missing < 0) {
      throw const FormatException('IPv6 分组超出 8 段');
    }
    final full = [...left, ...List.filled(missing, '0'), ...right];
    if (full.length != 8) {
      throw const FormatException('IPv6 需要 8 段');
    }
    return full.map((group) {
      final parsed = int.tryParse(group, radix: 16);
      if (parsed == null || parsed < 0 || parsed > 0xFFFF) {
        throw const FormatException('IPv6 分组非法');
      }
      return parsed;
    }).toList();
  }

  static String _intToIpv4(int value) {
    final parts = [
      (value >> 24) & 0xFF,
      (value >> 16) & 0xFF,
      (value >> 8) & 0xFF,
      value & 0xFF,
    ];
    return parts.join('.');
  }
}
