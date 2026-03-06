import 'package:ctf_tools/shared/widgets/module_hub_screen.dart';
import 'package:flutter/material.dart';

class NetworkHubScreen extends StatelessWidget {
  const NetworkHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ModuleHubScreen(
      title: '网络协议',
      description: '统一收敛真实协议交互、信息收集、抓包解析和地址扫描，面向 CTF 的网络排查场景。',
      badge: 'Network',
      statusItems: [
        '网络模块已支持真实 HTTP/TCP/WebSocket/简化协议交互，以及 DNS/WHOIS 查询。',
        '抓包分析支持经典 PCAP 的包列表、流分组和 HTTP 自动识别；地址工具支持 IPv4/IPv6/CIDR/端口扫描。',
      ],
      recommendedFlows: [
        '协议交互 -> 流量分析 -> 地址扫描，适合题目复现与抓包回放。',
        '信息收集 -> 地址工具 -> 协议交互，适合先枚举目标再验证服务。',
      ],
      knownLimits: [
        '所有联网行为都需要用户显式点击触发，不做后台扫描或历史持久化。',
      ],
      sections: [
        ModuleHubSection(
          title: '协议交互',
          summary: 'HTTP 构造+发送、WebSocket/TCP 文本客户端、SMTP/FTP/POP3 最小交互。',
          route: '/network/interaction',
          icon: Icons.sync_alt,
          inputs: ['URL', 'Host:Port', 'Headers', 'Body'],
          highlights: ['HTTP', 'WebSocket', 'SMTP/FTP/POP3'],
        ),
        ModuleHubSection(
          title: '信息收集',
          summary: 'WHOIS、DNS 查询、统一目标清洗与最近查询列表。',
          route: '/network/recon',
          icon: Icons.travel_explore,
          inputs: ['URL', 'Domain'],
          highlights: ['DNS', 'WHOIS', 'history'],
        ),
        ModuleHubSection(
          title: '流量分析',
          summary: 'Raw HTTP、PCAP 包列表、五元组分流、TCP/UDP 重组预览。',
          route: '/network/traffic',
          icon: Icons.timeline,
          inputs: ['HTTP message', 'PCAP Hex'],
          highlights: ['packet list', 'reassembly', 'HTTP detect'],
        ),
        ModuleHubSection(
          title: '地址扫描',
          summary: 'IPv4/IPv6、CIDR/子网信息与 TCP connect 端口扫描。',
          route: '/network/scanning',
          icon: Icons.map,
          inputs: ['IPv4', 'IPv6', 'CIDR', 'Host:Ports'],
          highlights: ['IPv6', 'CIDR', 'port scan'],
        ),
      ],
    );
  }
}

