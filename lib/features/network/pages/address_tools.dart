import 'package:ctf_tools/features/network/utils/ip_tools.dart';
import 'package:ctf_tools/features/network/utils/port_scanner.dart';
import 'package:ctf_tools/shared/widgets/mbutton.dart';
import 'package:ctf_tools/shared/widgets/show_toast.dart';
import 'package:ctf_tools/shared/widgets/tool_page_shell.dart';
import 'package:flutter/material.dart';

class AddressToolsScreen extends StatefulWidget {
  const AddressToolsScreen({super.key});

  @override
  State<AddressToolsScreen> createState() => _AddressToolsScreenState();
}

class _AddressToolsScreenState extends State<AddressToolsScreen> {
  final ipv4Controller = TextEditingController(text: '192.168.1.10');
  final ipv6Controller = TextEditingController(text: '2001:0db8::1');
  final cidrController = TextEditingController(text: '192.168.1.0/24');
  final scanHostController = TextEditingController(text: 'scanme.nmap.org');
  final scanPortsController = TextEditingController(text: '22,80,443');
  String output = '';
  bool scanning = false;

  @override
  void dispose() {
    ipv4Controller.dispose();
    ipv6Controller.dispose();
    cidrController.dispose();
    scanHostController.dispose();
    scanPortsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: ToolPageShell(
        title: '地址扫描',
        description: '补齐 IPv4/IPv6/CIDR 计算与 TCP connect 端口扫描。',
        badge: 'Network',
        child: Column(
          children: [
            Card(
              child: const TabBar(
                isScrollable: true,
                tabs: [
                  Tab(icon: Icon(Icons.language), text: 'IPv4'),
                  Tab(icon: Icon(Icons.public), text: 'IPv6'),
                  Tab(icon: Icon(Icons.account_tree), text: 'CIDR'),
                  Tab(icon: Icon(Icons.search), text: '端口扫描'),
                ],
              ),
            ),
            const SizedBox(height: kToolSectionGap),
            SizedBox(
              height: 760,
              child: TabBarView(
                children: [
                  _buildIpv4Tab(),
                  _buildIpv6Tab(),
                  _buildCidrTab(),
                  _buildScanTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIpv4Tab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          ToolSectionCard(
            title: 'IPv4 转换',
            child: TextField(
              controller: ipv4Controller,
              decoration: const InputDecoration(
                hintText: '例如 192.168.1.10 / 3232235786 / 11000000...',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(height: kToolSectionGap),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              MElevatedButton(icon: Icons.tag, text: 'IPv4 -> DEC/HEX/BIN', onPressed: _ipv4ToAll),
              MElevatedButton(icon: Icons.numbers, text: 'DEC -> IPv4', onPressed: _decimalToIpv4),
              MElevatedButton(icon: Icons.memory, text: 'BIN -> IPv4', onPressed: _binaryToIpv4),
            ],
          ),
          const SizedBox(height: kToolSectionGap),
          _outputCard(),
        ],
      ),
    );
  }

  Widget _buildIpv6Tab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          ToolSectionCard(
            title: 'IPv6 标准化 / 压缩',
            child: TextField(
              controller: ipv6Controller,
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
          ),
          const SizedBox(height: kToolSectionGap),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              MElevatedButton(icon: Icons.unfold_more, text: '标准化展开', onPressed: _normalizeIpv6),
              MElevatedButton(icon: Icons.unfold_less, text: '压缩表示', onPressed: _compressIpv6),
            ],
          ),
          const SizedBox(height: kToolSectionGap),
          _outputCard(),
        ],
      ),
    );
  }

  Widget _buildCidrTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          ToolSectionCard(
            title: 'CIDR / 子网信息',
            child: TextField(
              controller: cidrController,
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
          ),
          const SizedBox(height: kToolSectionGap),
          MElevatedButton(icon: Icons.calculate, text: '计算子网', onPressed: _inspectCidr),
          const SizedBox(height: kToolSectionGap),
          _outputCard(),
        ],
      ),
    );
  }

  Widget _buildScanTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          ToolSectionCard(
            title: 'TCP Connect 扫描',
            child: Column(
              children: [
                TextField(
                  controller: scanHostController,
                  decoration: const InputDecoration(labelText: 'Host', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: scanPortsController,
                  decoration: const InputDecoration(labelText: 'Ports', hintText: '22,80,443 或 1-1024', border: OutlineInputBorder()),
                ),
              ],
            ),
          ),
          const SizedBox(height: kToolSectionGap),
          MElevatedButton(icon: Icons.search, text: scanning ? '扫描中...' : '开始扫描', onPressed: scanning ? null : _scanPorts),
          const SizedBox(height: kToolSectionGap),
          _outputCard(),
        ],
      ),
    );
  }

  Widget _outputCard() {
    return ToolSectionCard(
      title: '输出',
      child: SelectableText(output.isEmpty ? '暂无结果' : output),
    );
  }

  void _ipv4ToAll() {
    try {
      final value = ipv4Controller.text.trim();
      setState(() {
        output = [
          'Decimal: ${IpTools.ipv4ToDecimal(value)}',
          'Hex: ${IpTools.ipv4ToHex(value)}',
          'Binary: ${IpTools.ipv4ToBinary(value)}',
        ].join('\n');
      });
    } catch (error) {
      showToast('转换失败: $error', context);
    }
  }

  void _decimalToIpv4() {
    try {
      setState(() {
        output = IpTools.decimalToIpv4(ipv4Controller.text);
      });
    } catch (error) {
      showToast('转换失败: $error', context);
    }
  }

  void _binaryToIpv4() {
    try {
      setState(() {
        output = IpTools.binaryToIpv4(ipv4Controller.text);
      });
    } catch (error) {
      showToast('转换失败: $error', context);
    }
  }

  void _normalizeIpv6() {
    try {
      setState(() {
        output = 'Expanded: ${IpTools.normalizeIpv6(ipv6Controller.text)}';
      });
    } catch (error) {
      showToast('转换失败: $error', context);
    }
  }

  void _compressIpv6() {
    try {
      setState(() {
        output = 'Compressed: ${IpTools.compressIpv6(ipv6Controller.text)}';
      });
    } catch (error) {
      showToast('转换失败: $error', context);
    }
  }

  void _inspectCidr() {
    try {
      final info = IpTools.inspectCidr(cidrController.text);
      setState(() {
        output = [
          'Network: ${info.network}',
          'Broadcast: ${info.broadcast}',
          'Mask: ${info.mask}',
          'First Host: ${info.firstHost}',
          'Last Host: ${info.lastHost}',
          'Host Count: ${info.hostCount}',
        ].join('\n');
      });
    } catch (error) {
      showToast('计算失败: $error', context);
    }
  }

  Future<void> _scanPorts() async {
    setState(() {
      scanning = true;
    });
    try {
      final ports = IpTools.parsePorts(scanPortsController.text);
      final result = await PortScanner.scan(host: scanHostController.text.trim(), ports: ports);
      if (!mounted) {
        return;
      }
      setState(() {
        output = [
          'Host: ${scanHostController.text.trim()}',
          'Open Ports: ${result.openPorts.isEmpty ? 'None' : result.openPorts.join(', ')}',
          'Closed/Filtered: ${result.closedPorts.length}',
          if (result.errors.isNotEmpty) '',
          if (result.errors.isNotEmpty) 'Errors:',
          if (result.errors.isNotEmpty) ...result.errors,
        ].join('\n');
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      showToast('扫描失败: $error', context);
      setState(() {
        output = '扫描失败: $error';
      });
    } finally {
      if (mounted) {
        setState(() {
          scanning = false;
        });
      }
    }
  }
}

