import 'package:ctf_tools/features/network/utils/http_message_parser.dart';
import 'package:ctf_tools/features/network/utils/pcap_inspector.dart';
import 'package:ctf_tools/shared/widgets/dropdown_menu.dart';
import 'package:ctf_tools/shared/widgets/mbutton.dart';
import 'package:ctf_tools/shared/widgets/show_toast.dart';
import 'package:ctf_tools/shared/widgets/tool_page_shell.dart';
import 'package:flutter/material.dart';

class TrafficAnalysisScreen extends StatefulWidget {
  const TrafficAnalysisScreen({super.key});

  @override
  State<TrafficAnalysisScreen> createState() => _TrafficAnalysisScreenState();
}

class _TrafficAnalysisScreenState extends State<TrafficAnalysisScreen> {
  final inputController = TextEditingController();
  String mode = 'Raw HTTP';
  String summaryOutput = '';
  String detailOutput = '';
  static const List<String> _modes = ['Raw HTTP', 'PCAP Hex'];

  @override
  void dispose() {
    inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ToolPageShell(
      title: '流量分析',
      description: '支持 Raw HTTP 报文解析，以及经典 PCAP 的包列表、五元组分流、TCP/UDP 重组预览与 HTTP 自动识别。',
      badge: 'Network',
      child: Column(
        children: [
          ToolSectionCard(
            title: '模式',
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text('分析模式', style: TextStyle(color: scheme.onSurfaceVariant)),
                MDropdownMenu(
                  initialValue: mode,
                  items: _modes,
                  onChanged: (value) => setState(() {
                    mode = value;
                  }),
                ),
              ],
            ),
          ),
          const SizedBox(height: kToolSectionGap),
          ToolSectionCard(
            title: mode == 'Raw HTTP' ? 'HTTP 报文输入' : 'PCAP 十六进制输入',
            trailing: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                MElevatedButton(icon: Icons.auto_fix_high, text: '样例', onPressed: _fillSample),
                MElevatedButton(
                  icon: Icons.delete,
                  text: '清空',
                  onPressed: () {
                    inputController.clear();
                    setState(() {
                      summaryOutput = '';
                      detailOutput = '';
                    });
                  },
                ),
              ],
            ),
            child: TextField(
              controller: inputController,
              maxLines: 12,
              decoration: InputDecoration(
                hintText: mode == 'Raw HTTP' ? '粘贴完整 HTTP request 或 response' : '粘贴经典 PCAP 文件的十六进制数据',
                prefixIcon: Icon(mode == 'Raw HTTP' ? Icons.http_outlined : Icons.memory_outlined),
              ),
            ),
          ),
          const SizedBox(height: kToolSectionGap),
          MElevatedButton(icon: Icons.timeline, text: mode == 'Raw HTTP' ? '解析报文' : '解析 PCAP', onPressed: _parse),
          const SizedBox(height: kToolSectionGap),
          ToolSectionCard(title: '摘要', child: SelectableText(summaryOutput.isEmpty ? '暂无结果' : summaryOutput)),
          const SizedBox(height: kToolSectionGap),
          ToolSectionCard(title: '详情', child: SelectableText(detailOutput.isEmpty ? '暂无结果' : detailOutput)),
        ],
      ),
    );
  }

  void _parse() {
    try {
      if (mode == 'Raw HTTP') {
        final result = HttpMessageParser.parse(inputController.text);
        final headerLines = result.headers.map((header) => '${header.name}: ${header.value}').join('\n');
        setState(() {
          summaryOutput = [result.messageType, ...result.summary].join('\n');
          detailOutput = [
            if (headerLines.isNotEmpty) 'Headers:',
            if (headerLines.isNotEmpty) headerLines,
            if (result.bodyPreview.isNotEmpty) '',
            if (result.bodyPreview.isNotEmpty) 'Body:',
            if (result.bodyPreview.isNotEmpty) result.bodyPreview,
          ].join('\n');
        });
        return;
      }

      final result = PcapInspector.inspectHex(inputController.text);
      setState(() {
        summaryOutput = [
          ...result.summary,
          if (result.notes.isNotEmpty) '',
          if (result.notes.isNotEmpty) 'Notes:',
          if (result.notes.isNotEmpty) ...result.notes,
        ].join('\n');
        detailOutput = [
          'Packets:',
          ...result.packets.map((packet) => '${packet.summary.join(' | ')}\nPayload: ${packet.payloadPreview}'),
          if (result.flows.isNotEmpty) '',
          if (result.flows.isNotEmpty) 'Flows:',
          if (result.flows.isNotEmpty)
            ...result.flows.map((flow) => '${flow.key}\n${flow.summary.join(' | ')}\nTranscript:\n${flow.transcriptPreview}\n${flow.httpPreview == null ? '' : 'HTTP Preview:\n${flow.httpPreview}'}'),
        ].join('\n\n');
      });
    } catch (error) {
      showToast('解析失败: $error', context);
      setState(() {
        summaryOutput = '解析失败: $error';
        detailOutput = '';
      });
    }
  }

  void _fillSample() {
    inputController.text = mode == 'Raw HTTP'
        ? 'GET /flag HTTP/1.1\r\nHost: example.com\r\nUser-Agent: CTF-Tools\r\nAccept: */*\r\n\r\n'
        : 'D4 C3 B2 A1 02 00 04 00 00 00 00 00 00 00 00 00 '
            'FF FF 00 00 01 00 00 00 01 00 00 00 20 A1 07 00 '
            '48 00 00 00 48 00 00 00 FF FF FF FF FF FF 00 11 '
            '22 33 44 55 08 00 45 00 00 3A 00 01 00 00 40 06 '
            '00 00 C0 A8 01 0A 5D B8 D8 22 30 39 00 50 00 00 '
            '00 00 00 00 00 00 50 18 20 00 00 00 00 00 47 45 '
            '54 20 2F 20 48 54 54 50 2F 31 2E 31 0D 0A 48 6F '
            '73 74 3A 20 65 78 61 6D 70 6C 65 2E 63 6F 6D 0D '
            '0A 0D 0A';
    setState(() {});
  }
}
