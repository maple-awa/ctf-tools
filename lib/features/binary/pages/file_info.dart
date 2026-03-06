import 'package:ctf_tools/features/binary/utils/binary_header_analyzer.dart';
import 'package:ctf_tools/features/binary/utils/file_signature.dart';
import 'package:ctf_tools/shared/widgets/mbutton.dart';
import 'package:ctf_tools/shared/widgets/show_toast.dart';
import 'package:ctf_tools/shared/widgets/tool_page_shell.dart';
import 'package:flutter/material.dart';

class BinaryFileInfoScreen extends StatefulWidget {
  const BinaryFileInfoScreen({super.key});

  @override
  State<BinaryFileInfoScreen> createState() => _BinaryFileInfoScreenState();
}

class _BinaryFileInfoScreenState extends State<BinaryFileInfoScreen> {
  final inputController = TextEditingController();
  String output = '';

  @override
  void dispose() {
    inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ToolPageShell(
      title: '文件解析',
      description: '从文件头识别扩展到 ELF/PE/Mach-O 头部解析和 checksec 风格摘要。',
      badge: 'Binary',
      child: Column(
        children: [
          ToolSectionCard(
            title: '输入',
            child: TextField(
              controller: inputController,
              maxLines: 10,
              decoration: const InputDecoration(
                hintText: '粘贴文件头十六进制数据，例如 7F 45 4C 46 ...',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            runSpacing: 10,
            children: [
              MElevatedButton(icon: Icons.search, text: '识别文件头', onPressed: _inspect),
            ],
          ),
          const SizedBox(height: 12),
          ToolSectionCard(title: '输出', child: SelectableText(output.isEmpty ? '暂无结果' : output)),
        ],
      ),
    );
  }

  void _inspect() {
    try {
      final signature = FileSignature.inspectHex(inputController.text);
      final header = BinaryHeaderAnalyzer.inspectHex(inputController.text);
      setState(() {
        output = [
          'Signature:',
          ...signature.details,
          '',
          'Header Summary:',
          ...header.summary,
          '',
          'Checksec-ish:',
          ...header.checksec,
        ].join('\n');
      });
    } catch (error) {
      showToast('识别失败: $error', context);
    }
  }
}
