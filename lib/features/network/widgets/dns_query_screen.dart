import 'package:ctf_tools/features/network/utils/dns_utils.dart';
import 'package:ctf_tools/shared/widgets/dropdown_menu.dart';
import 'package:ctf_tools/shared/widgets/mbutton.dart';
import 'package:ctf_tools/shared/widgets/show_toast.dart';
import 'package:ctf_tools/shared/widgets/tool_page_shell.dart';
import 'package:ctf_tools/shared/widgets/tool_status_chip.dart';
import 'package:dns_client/dns_client.dart';
import 'package:flutter/material.dart';

class DnsQueryScreen extends StatefulWidget {
  const DnsQueryScreen({super.key});

  @override
  State<DnsQueryScreen> createState() => _DnsQueryScreenState();
}

class _DnsQueryScreenState extends State<DnsQueryScreen> {
  final TextEditingController inputController = TextEditingController();
  final TextEditingController outputController = TextEditingController();
  final TextEditingController dnsController = TextEditingController();

  bool isEnableDns = false;
  bool isRawMode = false;
  String _selectedDnsKey = DnsUtils.dnsServers.keys.first;
  List<DataRow> _resultRows = [];
  DnsOverHttps? _customDns;

  @override
  void dispose() {
    _customDns?.close();
    inputController.dispose();
    outputController.dispose();
    dnsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        ToolSectionCard(
          title: '查询参数',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 12,
                runSpacing: 12,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  const ToolStatusChip(label: 'DNS Lookup', icon: Icons.dns),
                  MDropdownMenu(
                    initialValue: _selectedDnsKey,
                    items: DnsUtils.dnsServers.keys.toList(),
                    onChanged: isEnableDns
                        ? null
                        : (value) => setState(() {
                            _selectedDnsKey = value;
                          }),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('启用自定义 DNS 服务器'),
                value: isEnableDns,
                onChanged: (value) => setState(() {
                  isEnableDns = value;
                }),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('文本模式输出'),
                value: isRawMode,
                onChanged: (value) => setState(() {
                  isRawMode = value;
                }),
              ),
              if (isEnableDns) ...[
                const SizedBox(height: 8),
                TextField(
                  controller: dnsController,
                  decoration: const InputDecoration(
                    labelText: '自定义 DNS 服务器',
                    prefixIcon: Icon(Icons.dns_outlined),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),
        ToolSectionCard(
          title: '输入域名',
          trailing: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              MElevatedButton(
                icon: Icons.search,
                text: '查询',
                onPressed: _dnsSearch,
              ),
              MElevatedButton(
                icon: Icons.delete,
                text: '清空',
                onPressed: _clear,
              ),
            ],
          ),
          child: TextField(
            controller: inputController,
            decoration: InputDecoration(
              labelText: '输入想要查询的域名',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                onPressed: () {
                  inputController.clear();
                  setState(() {});
                },
                icon: const Icon(Icons.clear),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        ToolSectionCard(
          title: '输出',
          trailing: ToolStatusChip(
            label: isRawMode ? 'TEXT MODE' : 'TABLE MODE',
            icon: Icons.table_chart_outlined,
          ),
          child: SizedBox(
            height: kToolLargeOutputHeight,
            child: isRawMode ? _buildTextOutput(scheme) : _buildTableOutput(scheme),
          ),
        ),
      ],
    );
  }

  Widget _buildTextOutput(ColorScheme scheme) {
    return TextField(
      controller: outputController,
      maxLines: null,
      expands: true,
      textAlignVertical: TextAlignVertical.top,
      style: TextStyle(color: scheme.onSurface),
    );
  }

  Widget _buildTableOutput(ColorScheme scheme) {
    if (_resultRows.isEmpty) {
      return Center(
        child: Text(
          '暂无 DNS 记录',
          style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 16),
        ),
      );
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        dataRowColor: WidgetStateColor.resolveWith(
          (states) => scheme.surfaceContainerLow,
        ),
        headingRowColor: WidgetStateColor.resolveWith(
          (states) => scheme.surfaceContainerHigh,
        ),
        columns: const [
          DataColumn(label: Text('记录类型')),
          DataColumn(label: Text('值')),
        ],
        rows: _resultRows,
      ),
    );
  }

  Future<void> _dnsSearch() async {
    final domain = inputController.text.trim();
    if (domain.isEmpty) {
      showToast('不知道你要查询什么喵', context);
      return;
    }
    if (isEnableDns && dnsController.text.trim().isEmpty) {
      showToast('请输入自定义DNS服务器喵', context);
      return;
    }

    try {
      late final DnsOverHttps dnsToUse;
      if (!isEnableDns) {
        final defaultDns = DnsUtils.dnsServers[_selectedDnsKey];
        if (defaultDns == null) {
          showToast('DNS服务器不存在喵', context);
          return;
        }
        dnsToUse = defaultDns;
      } else {
        _customDns?.close();
        _customDns = DnsOverHttps(dnsController.text.trim());
        dnsToUse = _customDns!;
      }

      final result = await DnsUtils.queryAllWith(dnsToUse, domain);
      if (!mounted) return;

      setState(() {
        if (isRawMode) {
          outputController.text = result.toString();
          _resultRows = [];
        } else {
          _resultRows = _buildResultRows(result);
          outputController.clear();
        }
      });
    } catch (e) {
      if (!mounted) return;
      showToast('查询失败: ${e.toString()}', context);
    }
  }

  List<DataRow> _buildResultRows(DnsResult result) {
    final rows = <DataRow>[];

    void addRows(String type, List<String> records) {
      for (final record in records) {
        rows.add(
          DataRow(cells: [DataCell(Text(type)), DataCell(Text(record))]),
        );
      }
    }

    if (result.error != null) {
      rows.add(
        DataRow(
          cells: [
            const DataCell(Text('错误')),
            DataCell(Text(result.error!, style: const TextStyle(color: Colors.red))),
          ],
        ),
      );
      return rows;
    }

    if (!result.exists) {
      rows.add(
        const DataRow(
          cells: [
            DataCell(Text('状态')),
            DataCell(Text('域名不存在 (NXDOMAIN)')),
          ],
        ),
      );
      return rows;
    }

    addRows('A', result.aRecords);
    addRows('AAAA', result.aaaaRecords);
    addRows('CNAME', result.cnameRecords);
    addRows('MX', result.mxRecords);
    addRows('TXT', result.txtRecords);
    addRows('NS', result.nsRecords);
    if (result.soaRecord != null) {
      rows.add(
        DataRow(
          cells: [
            const DataCell(Text('SOA')),
            DataCell(Text(result.soaRecord!)),
          ],
        ),
      );
    }

    return rows;
  }

  void _clear() {
    if (inputController.text.isEmpty &&
        dnsController.text.isEmpty &&
        outputController.text.isEmpty &&
        _resultRows.isEmpty) {
      showToast('无内容可清空喵', context);
      return;
    }
    inputController.clear();
    dnsController.clear();
    outputController.clear();
    _resultRows = [];
    setState(() {});
    showToast('已清空喵', context);
  }
}
