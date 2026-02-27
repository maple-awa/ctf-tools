import 'package:ctf_tools/features/network/utils/dns_utils.dart';
import 'package:ctf_tools/shared/widgets/dropdown_menu.dart';
import 'package:ctf_tools/shared/widgets/mbutton.dart';
import 'package:ctf_tools/shared/widgets/show_toast.dart';
import 'package:dns_client/dns_client.dart';
import 'package:flutter/material.dart';
import 'package:ctf_tools/shared/layout/responsive.dart';

class DnsQueryScreen extends StatefulWidget {
  const DnsQueryScreen({super.key});

  @override
  State<DnsQueryScreen> createState() => _DnsQueryScreen();
}

class _DnsQueryScreen extends State<DnsQueryScreen> {
  ColorScheme get scheme => Theme.of(context).colorScheme;

  /// 输入框文本控制器。
  TextEditingController inputController = TextEditingController();

  /// 输出框文本控制器（文本模式）。
  TextEditingController outputController = TextEditingController();

  /// 是否启用自定义 DNS 服务器。
  bool isEnableDns = false;

  /// 是否输出为纯文本模式。
  bool isRawMode = false;

  /// 自定义 DNS 地址输入控制器。
  TextEditingController dnsController = TextEditingController();

  /// 当前选中的内置 DNS 名称。
  String _selectedDnsKey = DnsUtils.dnsServers.keys.first;

  /// 表格模式下的行数据。
  List<DataRow> _resultRows = [];

  /// 自定义 DNS 客户端实例。
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
    return Container(
      color: scheme.surface,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = Responsive.isMobileWidth(constraints.maxWidth);
          final content = Column(
            children: [
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 10,
                runSpacing: 10,
                children: [
                  Text(
                    "域名 (DOMAIN)",
                    style: TextStyle(
                      color: scheme.onSurfaceVariant,
                      fontSize: 16,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: scheme.primary.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.all(5),
                    child: Text(
                      "INPUT",
                      style: TextStyle(color: scheme.primary),
                    ),
                  ),
                  Text(
                    "自定义DNS服务器",
                    style: TextStyle(
                      color: scheme.onSurfaceVariant,
                      fontSize: 16,
                    ),
                  ),
                  Switch(
                    value: isEnableDns,
                    activeThumbColor: scheme.primary,
                    activeTrackColor: scheme.primary.withValues(alpha: 0.5),
                    inactiveThumbColor: scheme.outline,
                    inactiveTrackColor: scheme.surfaceContainerHighest,
                    onChanged: (value) => setState(() => isEnableDns = value),
                  ),
                  Text(
                    "文本模式",
                    style: TextStyle(
                      color: scheme.onSurfaceVariant,
                      fontSize: 16,
                    ),
                  ),
                  Switch(
                    value: isRawMode,
                    activeThumbColor: scheme.primary,
                    activeTrackColor: scheme.primary.withValues(alpha: 0.5),
                    inactiveThumbColor: scheme.outline,
                    inactiveTrackColor: scheme.surfaceContainerHighest,
                    onChanged: (value) => setState(() => isRawMode = value),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 10,
                runSpacing: 10,
                children: [
                  if (!isEnableDns)
                    MDropdownMenu(
                      initialValue: _selectedDnsKey,
                      items: DnsUtils.dnsServers.keys.toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedDnsKey = value;
                        });
                      },
                    ),
                  SizedBox(
                    width: isMobile ? constraints.maxWidth - 40 : 420,
                    child: TextField(
                      controller: inputController,
                      style: TextStyle(color: scheme.onSurface),
                      decoration: InputDecoration(
                        labelText: '输入想要查询的域名...',
                        labelStyle: TextStyle(color: scheme.onSurfaceVariant),
                        prefixIcon: Icon(
                          Icons.search,
                          color: scheme.onSurfaceVariant,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            Icons.clear,
                            color: scheme.onSurfaceVariant,
                          ),
                          onPressed: () {
                            inputController.clear();
                            setState(() {});
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                  ),
                  MElevatedButton(
                    icon: Icons.search,
                    text: "搜索",
                    onPressed: () {
                      _dnsSearch();
                      setState(() {});
                    },
                  ),
                  MElevatedButton(
                    icon: Icons.delete,
                    text: "清空",
                    onPressed: _clear,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (isEnableDns) ...[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "自定义DNS服务器 (DNS Server)",
                    style: TextStyle(
                      color: scheme.onSurfaceVariant,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: dnsController,
                  style: TextStyle(color: scheme.onSurface),
                  decoration: InputDecoration(
                    labelText: 'DNS 服务器...',
                    labelStyle: TextStyle(color: scheme.onSurfaceVariant),
                    prefixIcon: Icon(
                      Icons.dns_outlined,
                      color: scheme.onSurfaceVariant,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.clear, color: scheme.onSurfaceVariant),
                      onPressed: () {
                        dnsController.clear();
                        setState(() {});
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 10,
                runSpacing: 10,
                children: [
                  Text(
                    "输出 (OUTPUT)",
                    style: TextStyle(
                      color: scheme.onSurfaceVariant,
                      fontSize: 16,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: scheme.secondary.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.all(5),
                    child: Text(
                      "READY",
                      style: TextStyle(color: scheme.secondary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (isMobile)
                SizedBox(height: 280, child: _buildOutputArea())
              else
                Expanded(child: _buildOutputArea()),
            ],
          );
          if (isMobile) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: content,
            );
          }
          return Padding(padding: const EdgeInsets.all(20), child: content);
        },
      ),
    );
  }

  Widget _buildOutputArea() {
    if (isRawMode) {
      return TextField(
        maxLines: null,
        expands: true,
        textAlignVertical: TextAlignVertical.top,
        textAlign: TextAlign.start,
        controller: outputController,
        style: TextStyle(color: scheme.onSurface),
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: scheme.outlineVariant),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: scheme.primary, width: 1.5),
          ),
        ),
      );
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: _buildTableOutput(),
      ),
    );
  }

  /// 构建表格模式输出组件。
  Widget _buildTableOutput() {
    if (_resultRows.isEmpty) {
      return Center(
        child: Text(
          '📭 无 DNS 记录',
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
        headingTextStyle: TextStyle(
          fontWeight: FontWeight.bold,
          color: scheme.onSurface,
        ),
        dataTextStyle: TextStyle(color: scheme.onSurface),
        columns: const [
          DataColumn(label: Text('记录类型')),
          DataColumn(label: Text('值')),
        ],
        rows: _resultRows,
      ),
    );
  }

  /// 执行 DNS 查询并刷新结果。
  Future<void> _dnsSearch() async {
    final domain = inputController.text.trim();
    if (domain.isEmpty) {
      showToast("不知道你要查询什么喵", context);
      return;
    }
    if (isEnableDns && dnsController.text.trim().isEmpty) {
      showToast("请输入自定义DNS服务器喵", context);
      return;
    }

    try {
      late final DnsOverHttps dnsToUse;
      if (!isEnableDns) {
        final defaultDns = DnsUtils.dnsServers[_selectedDnsKey];
        if (defaultDns == null) {
          showToast("DNS服务器不存在喵", context);
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

  /// 将 [DnsResult] 转换为表格行集合。
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
            DataCell(Text(result.error!, style: TextStyle(color: Colors.red))),
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
            DataCell(
              Text('域名不存在 (NXDOMAIN)', style: TextStyle(color: Colors.orange)),
            ),
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

  /// 清理输入输出框
  void _clear() {
    if (inputController.text.isEmpty &&
        dnsController.text.isEmpty &&
        outputController.text.isEmpty &&
        _resultRows.isEmpty) {
      showToast("无内容可清空喵", context);
      return;
    }
    inputController.clear();
    dnsController.clear();
    outputController.clear();
    _resultRows = [];
    setState(() {});
    showToast("已清空喵", context);
  }
}
