import 'dart:convert';

import 'package:ctf_tools/shared/utils/hex_input.dart';

class PcapInspectResult {
  const PcapInspectResult({
    required this.summary,
    required this.packets,
    required this.notes,
    required this.flows,
  });

  final List<String> summary;
  final List<PcapPacketInfo> packets;
  final List<String> notes;
  final List<PcapFlowInfo> flows;
}

class PcapPacketInfo {
  const PcapPacketInfo({
    required this.index,
    required this.summary,
    required this.payloadPreview,
    required this.flowKey,
    required this.protocol,
  });

  final int index;
  final List<String> summary;
  final String payloadPreview;
  final String flowKey;
  final String protocol;
}

class PcapFlowInfo {
  const PcapFlowInfo({
    required this.key,
    required this.protocol,
    required this.packets,
    required this.transcriptPreview,
    required this.httpPreview,
    required this.summary,
  });

  final String key;
  final String protocol;
  final List<int> packets;
  final String transcriptPreview;
  final String? httpPreview;
  final List<String> summary;
}

class PcapInspector {
  static PcapInspectResult inspectHex(String input) {
    final bytes = HexInput.parseBytes(
      input,
      minBytes: 24,
      errorMessage: '请输入至少 24 字节 PCAP 十六进制数据',
    );
    final magic = HexInput.readUint32Be(bytes, 0);
    final profile = _profileFromMagic(magic);
    if (profile == null) {
      throw const FormatException('当前仅支持经典 PCAP，不支持未知魔数或 pcapng');
    }

    final major = profile.readUint16(bytes, 4);
    final minor = profile.readUint16(bytes, 6);
    final snaplen = profile.readUint32(bytes, 16);
    final linkType = profile.readUint32(bytes, 20);
    final summary = <String>[
      'PCAP Version: $major.$minor',
      'Byte Order: ${profile.bigEndian ? 'Big Endian' : 'Little Endian'}',
      'Timestamp Precision: ${profile.nanoPrecision ? 'Nanoseconds' : 'Microseconds'}',
      'Snaplen: $snaplen',
      'LinkType: ${_linkTypeName(linkType)} ($linkType)',
    ];

    final packets = <PcapPacketInfo>[];
    final notes = <String>[];
    final flowMap = <String, _FlowBuilder>{};
    var offset = 24;
    var index = 0;

    while (offset + 16 <= bytes.length) {
      final tsSec = profile.readUint32(bytes, offset);
      final tsSub = profile.readUint32(bytes, offset + 4);
      final inclLen = profile.readUint32(bytes, offset + 8);
      final origLen = profile.readUint32(bytes, offset + 12);
      final dataStart = offset + 16;
      final dataEnd = dataStart + inclLen;
      if (dataEnd > bytes.length) {
        notes.add('Packet ${index + 1} 长度超出输入边界，后续数据可能被截断');
        break;
      }
      final packet = _parsePacket(
        index: index,
        timestampSeconds: tsSec,
        timestampSubseconds: tsSub,
        timestampDigits: profile.nanoPrecision ? 9 : 6,
        capturedLength: inclLen,
        originalLength: origLen,
        data: bytes.sublist(dataStart, dataEnd),
        linkType: linkType,
      );
      packets.add(packet);
      if (packet.flowKey.isNotEmpty) {
        final builder = flowMap.putIfAbsent(
          packet.flowKey,
          () => _FlowBuilder(packet.protocol),
        );
        builder.packetIndexes.add(index + 1);
        builder.payloads.add(packet.payloadPreview);
        if (packet.protocol == 'TCP' || packet.protocol == 'UDP') {
          final previewBytes = utf8.encode(packet.payloadPreview);
          builder.bytePreview.addAll(previewBytes);
        }
      }
      offset = dataEnd;
      index++;
    }

    final flows = flowMap.entries.map((entry) {
      final builder = entry.value;
      final transcript = builder.payloads
          .where((item) => item != 'No Payload')
          .join('\n');
      final httpPreview = _guessHttp(transcript);
      return PcapFlowInfo(
        key: entry.key,
        protocol: builder.protocol,
        packets: builder.packetIndexes,
        transcriptPreview: transcript.isEmpty ? 'No Payload' : transcript,
        httpPreview: httpPreview,
        summary: [
          'Protocol: ${builder.protocol}',
          'Packets: ${builder.packetIndexes.length}',
          if (httpPreview != null) 'Detected: HTTP-like transcript',
        ],
      );
    }).toList();

    summary.add('Packets: ${packets.length}');
    summary.add('Flows: ${flows.length}');
    if (packets.isEmpty) {
      notes.add('未解析到完整数据包');
    }

    return PcapInspectResult(
      summary: summary,
      packets: packets,
      notes: notes,
      flows: flows,
    );
  }

  static PcapPacketInfo _parsePacket({
    required int index,
    required int timestampSeconds,
    required int timestampSubseconds,
    required int timestampDigits,
    required int capturedLength,
    required int originalLength,
    required List<int> data,
    required int linkType,
  }) {
    final lines = <String>[
      'Packet #${index + 1}',
      'Captured/Original: $capturedLength / $originalLength bytes',
      'Timestamp: $timestampSeconds.${timestampSubseconds.toString().padLeft(timestampDigits, '0')}',
    ];
    if (linkType != 1) {
      lines.add('Link: ${_linkTypeName(linkType)}');
      return PcapPacketInfo(
        index: index + 1,
        summary: lines,
        payloadPreview: HexInput.asciiPreview(data),
        flowKey: '',
        protocol: _linkTypeName(linkType),
      );
    }
    if (data.length < 14) {
      lines.add('Ethernet frame 太短');
      return PcapPacketInfo(
        index: index + 1,
        summary: lines,
        payloadPreview: HexInput.asciiPreview(data),
        flowKey: '',
        protocol: 'Ethernet',
      );
    }

    final etherType = HexInput.readUint16Be(data, 12);
    lines.add(
      'EtherType: 0x${etherType.toRadixString(16).padLeft(4, '0').toUpperCase()}',
    );
    if (etherType != 0x0800 || data.length < 34) {
      return PcapPacketInfo(
        index: index + 1,
        summary: lines,
        payloadPreview: HexInput.asciiPreview(data),
        flowKey: '',
        protocol: 'Ethernet',
      );
    }

    final ipOffset = 14;
    final version = data[ipOffset] >> 4;
    final ihl = (data[ipOffset] & 0x0F) * 4;
    if (version != 4 || data.length < ipOffset + ihl) {
      lines.add('IPv4 头异常');
      return PcapPacketInfo(
        index: index + 1,
        summary: lines,
        payloadPreview: HexInput.asciiPreview(data),
        flowKey: '',
        protocol: 'IPv4',
      );
    }
    final protocol = data[ipOffset + 9];
    final srcIp = _ipv4(data, ipOffset + 12);
    final dstIp = _ipv4(data, ipOffset + 16);
    lines.add('IPv4: $srcIp -> $dstIp');
    lines.add('Protocol: ${_protocolName(protocol)} ($protocol)');

    final transportOffset = ipOffset + ihl;
    if (protocol == 6 && data.length >= transportOffset + 20) {
      final srcPort = HexInput.readUint16Be(data, transportOffset);
      final dstPort = HexInput.readUint16Be(data, transportOffset + 2);
      final tcpHeaderLength = ((data[transportOffset + 12] >> 4) & 0x0F) * 4;
      final payload = data.length >= transportOffset + tcpHeaderLength
          ? data.sublist(transportOffset + tcpHeaderLength)
          : <int>[];
      final app = _applicationGuess(srcPort, dstPort, payload);
      lines.add('TCP: $srcPort -> $dstPort');
      if (app != null) {
        lines.add('App Guess: $app');
      }
      return PcapPacketInfo(
        index: index + 1,
        summary: lines,
        payloadPreview: _payloadPreview(payload),
        flowKey: 'TCP $srcIp:$srcPort -> $dstIp:$dstPort',
        protocol: 'TCP',
      );
    }
    if (protocol == 17 && data.length >= transportOffset + 8) {
      final srcPort = HexInput.readUint16Be(data, transportOffset);
      final dstPort = HexInput.readUint16Be(data, transportOffset + 2);
      final payload = data.sublist(transportOffset + 8);
      final app = _applicationGuess(srcPort, dstPort, payload);
      lines.add('UDP: $srcPort -> $dstPort');
      if (app != null) {
        lines.add('App Guess: $app');
      }
      return PcapPacketInfo(
        index: index + 1,
        summary: lines,
        payloadPreview: _payloadPreview(payload),
        flowKey: 'UDP $srcIp:$srcPort -> $dstIp:$dstPort',
        protocol: 'UDP',
      );
    }

    return PcapPacketInfo(
      index: index + 1,
      summary: lines,
      payloadPreview: HexInput.asciiPreview(data),
      flowKey: '',
      protocol: _protocolName(protocol),
    );
  }

  static _EndianProfile? _profileFromMagic(int magic) {
    return switch (magic) {
      0xA1B2C3D4 => const _EndianProfile.big(),
      0xD4C3B2A1 => const _EndianProfile.little(),
      0xA1B23C4D => const _EndianProfile.big(nanoPrecision: true),
      0x4D3CB2A1 => const _EndianProfile.little(nanoPrecision: true),
      _ => null,
    };
  }

  static String _linkTypeName(int linkType) {
    return switch (linkType) {
      1 => 'Ethernet',
      101 => 'Raw IP',
      113 => 'Linux Cooked',
      127 => 'IEEE 802.11 Radio',
      _ => 'Unknown',
    };
  }

  static String _protocolName(int protocol) {
    return switch (protocol) {
      1 => 'ICMP',
      6 => 'TCP',
      17 => 'UDP',
      _ => 'Other',
    };
  }

  static String _ipv4(List<int> bytes, int offset) {
    return '${bytes[offset]}.${bytes[offset + 1]}.${bytes[offset + 2]}.${bytes[offset + 3]}';
  }

  static String? _applicationGuess(
    int srcPort,
    int dstPort,
    List<int> payload,
  ) {
    final ports = {srcPort, dstPort};
    final text = String.fromCharCodes(
      payload.where((byte) => byte >= 0x09 && byte <= 0x7E),
    );
    if (ports.contains(80) || ports.contains(8080) || ports.contains(8000)) {
      if (text.startsWith('GET ') ||
          text.startsWith('POST ') ||
          text.startsWith('HTTP/')) {
        return 'HTTP';
      }
    }
    if (ports.contains(53)) {
      return 'DNS';
    }
    if (ports.contains(443)) {
      return 'TLS/HTTPS';
    }
    if (ports.contains(22)) {
      return 'SSH';
    }
    return null;
  }

  static String _payloadPreview(List<int> payload) {
    if (payload.isEmpty) {
      return 'No Payload';
    }
    return HexInput.asciiPreview(payload, maxLength: 80);
  }

  static String? _guessHttp(String transcript) {
    if (transcript.startsWith('GET ') ||
        transcript.startsWith('POST ') ||
        transcript.startsWith('HTTP/')) {
      return transcript;
    }
    return null;
  }
}

class _FlowBuilder {
  _FlowBuilder(this.protocol);

  final String protocol;
  final List<int> packetIndexes = [];
  final List<String> payloads = [];
  final List<int> bytePreview = [];
}

class _EndianProfile {
  const _EndianProfile.big({this.nanoPrecision = false}) : bigEndian = true;
  const _EndianProfile.little({this.nanoPrecision = false}) : bigEndian = false;

  final bool bigEndian;
  final bool nanoPrecision;

  int readUint16(List<int> bytes, int offset) {
    return bigEndian
        ? HexInput.readUint16Be(bytes, offset)
        : HexInput.readUint16Le(bytes, offset);
  }

  int readUint32(List<int> bytes, int offset) {
    return bigEndian
        ? HexInput.readUint32Be(bytes, offset)
        : HexInput.readUint32Le(bytes, offset);
  }
}
