import 'dart:convert';

import 'package:ctf_tools/features/network/utils/dns_utils.dart';
import 'package:ctf_tools/features/network/utils/target_parser.dart';
import 'package:ctf_tools/features/network/utils/whois_util.dart';
import 'package:ctf_tools/shared/widgets/dropdown_menu.dart';
import 'package:ctf_tools/shared/widgets/mbutton.dart';
import 'package:ctf_tools/shared/widgets/show_toast.dart';
import 'package:ctf_tools/shared/widgets/tool_page_shell.dart';
import 'package:dns_client/dns_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:whois/whois.dart';

class ReconScreen extends StatefulWidget {
  const ReconScreen({super.key});

  @override
  State<ReconScreen> createState() => _ReconScreenState();
}

class _ReconScreenState extends State<ReconScreen> {
  final targetController = TextEditingController(text: 'example.com');
  final customDnsController = TextEditingController();
  final List<String> recentTargets = [];
  String selectedDns = DnsUtils.dnsServers.keys.first;
  bool useCustomDns = false;
  bool rawWhois = false;
  bool loading = false;
  String dnsOutput = '';
  String whoisOutput = '';

  @override
  void dispose() {
    targetController.dispose();
    customDnsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DefaultTabController(
      length: 2,
      child: ToolPageShell(
        title: '网络探测与信息收集',
        description: '统一清洗目标输入，收敛 DNS/WHOIS 查询、最近查询列表和分段输出。',
        badge: 'Network',
        child: Column(
          children: [
            ToolSectionCard(
              title: '查询目标',
              child: Column(
                children: [
                  TextField(
                    controller: targetController,
                    decoration: const InputDecoration(
                      labelText: '域名或 URL',
                      hintText: 'example.com / https://example.com/path',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text('DNS Provider', style: TextStyle(color: scheme.onSurfaceVariant)),
                      MDropdownMenu(
                        initialValue: selectedDns,
                        items: DnsUtils.dnsServers.keys.toList(),
                        onChanged: useCustomDns ? null : (value) => setState(() => selectedDns = value),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('使用自定义 DoH 地址'),
                    value: useCustomDns,
                    onChanged: (value) => setState(() => useCustomDns = value),
                  ),
                  if (useCustomDns) ...[
                    const SizedBox(height: 8),
                    TextField(
                      controller: customDnsController,
                      decoration: const InputDecoration(
                        labelText: 'DoH URL',
                        hintText: 'https://dns.google/dns-query',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('WHOIS 原始输出'),
                    value: rawWhois,
                    onChanged: (value) => setState(() => rawWhois = value),
                  ),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      MElevatedButton(icon: Icons.search, text: loading ? '查询中...' : '查询 DNS + WHOIS', onPressed: loading ? null : _runLookup),
                      MElevatedButton(icon: Icons.copy, text: '复制结果', onPressed: _copyCurrent),
                      MElevatedButton(icon: Icons.delete, text: '清空', onPressed: _clear),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: kToolSectionGap),
            if (recentTargets.isNotEmpty)
              ToolSectionCard(
                title: '最近查询',
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: recentTargets.map((target) {
                    return ActionChip(
                      label: Text(target),
                      onPressed: () {
                        targetController.text = target;
                        setState(() {});
                      },
                    );
                  }).toList(),
                ),
              ),
            if (recentTargets.isNotEmpty) const SizedBox(height: kToolSectionGap),
            Card(
              child: const TabBar(
                tabs: [
                  Tab(icon: Icon(Icons.dns), text: 'DNS'),
                  Tab(icon: Icon(Icons.language), text: 'WHOIS'),
                ],
              ),
            ),
            const SizedBox(height: kToolSectionGap),
            SizedBox(
              height: kToolLargeOutputHeight,
              child: TabBarView(
                children: [
                  _resultPane(dnsOutput),
                  _resultPane(whoisOutput),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _resultPane(String text) {
    return ToolSectionCard(
      title: '输出',
      child: SingleChildScrollView(
        child: SelectableText(text.isEmpty ? '暂无结果' : text),
      ),
    );
  }

  Future<void> _runLookup() async {
    final rawTarget = targetController.text.trim();
    if (rawTarget.isEmpty) {
      showToast('请输入查询目标', context);
      return;
    }
    final host = NetworkTargetParser.normalizeHost(rawTarget);
    setState(() {
      loading = true;
    });
    try {
      late final DnsOverHttps dns;
      if (useCustomDns) {
        if (customDnsController.text.trim().isEmpty) {
          throw const FormatException('请填写自定义 DoH 地址');
        }
        dns = DnsOverHttps(customDnsController.text.trim());
      } else {
        dns = DnsUtils.dnsServers[selectedDns]!;
      }
      final dnsResult = await DnsUtils.queryAllWith(dns, host);
      final whoisResult = rawWhois
          ? utf8.decode(latin1.encode(await Whois.lookup(host)), allowMalformed: true)
          : await WhoisUtil.lookupAndFormatChinese(host);
      if (!mounted) {
        return;
      }
      setState(() {
        dnsOutput = _formatDns(host, dnsResult);
        whoisOutput = whoisResult;
        recentTargets.remove(host);
        recentTargets.insert(0, host);
        if (recentTargets.length > 6) {
          recentTargets.removeLast();
        }
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      showToast('查询失败: $error', context);
      setState(() {
        dnsOutput = '查询失败: $error';
        whoisOutput = '查询失败: $error';
      });
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  String _formatDns(String host, DnsResult result) {
    if (result.error != null) {
      return 'Host: $host\nError: ${result.error}';
    }
    if (!result.exists) {
      return 'Host: $host\nStatus: NXDOMAIN';
    }
    final lines = <String>['Host: $host'];
    void addSection(String label, List<String> values) {
      if (values.isEmpty) {
        return;
      }
      lines.add('');
      lines.add('$label:');
      lines.addAll(values.map((value) => '  - $value'));
    }

    addSection('A', result.aRecords);
    addSection('AAAA', result.aaaaRecords);
    addSection('CNAME', result.cnameRecords);
    addSection('MX', result.mxRecords);
    addSection('TXT', result.txtRecords);
    addSection('NS', result.nsRecords);
    if (result.soaRecord != null) {
      lines.add('');
      lines.add('SOA: ${result.soaRecord}');
    }
    return lines.join('\n');
  }

  Future<void> _copyCurrent() async {
    final sections = <String>[];
    if (dnsOutput.isNotEmpty) {
      sections.add('DNS:\n$dnsOutput');
    }
    if (whoisOutput.isNotEmpty) {
      sections.add('WHOIS:\n$whoisOutput');
    }
    final text = sections.join('\n\n');
    if (text.isEmpty) {
      showToast('无内容可复制', context);
      return;
    }
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) {
      return;
    }
    showToast('复制成功', context);
  }

  void _clear() {
    targetController.clear();
    customDnsController.clear();
    setState(() {
      dnsOutput = '';
      whoisOutput = '';
      recentTargets.clear();
    });
  }
}
