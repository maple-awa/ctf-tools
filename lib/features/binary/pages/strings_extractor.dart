import 'package:ctf_tools/features/binary/utils/strings_extractor.dart';
import 'package:ctf_tools/shared/widgets/dropdown_menu.dart';
import 'package:ctf_tools/shared/widgets/tool_page_shell.dart';
import 'package:flutter/material.dart';

class StringsExtractorScreen extends StatefulWidget {
  const StringsExtractorScreen({super.key});

  @override
  State<StringsExtractorScreen> createState() => _StringsExtractorScreenState();
}

class _StringsExtractorScreenState extends State<StringsExtractorScreen> {
  final inputController = TextEditingController();
  final minLengthController = TextEditingController(text: '4');
  String inputMode = 'HEX';
  String asciiOutput = '';
  String utf16Output = '';

  @override
  void dispose() {
    inputController.dispose();
    minLengthController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ToolPageShell(
      title: '字符串提取',
      description: '模拟 strings 的常用工作流，支持原始 UTF-8 文本和十六进制字节流输入。',
      child: Column(
        children: [
          ToolSectionCard(
            title: '参数',
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text('输入格式', style: TextStyle(color: scheme.onSurfaceVariant)),
                MDropdownMenu(
                  initialValue: inputMode,
                  items: const ['HEX', 'UTF-8 文本'],
                  onChanged: (value) {
                    setState(() {
                      inputMode = value;
                    });
                  },
                ),
                SizedBox(
                  width: 120,
                  child: TextField(
                    controller: minLengthController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: '最短长度',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                FilledButton.icon(
                  onPressed: _extract,
                  icon: const Icon(Icons.search),
                  label: const Text('提取'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ToolSectionCard(
            title: '输入',
            child: TextField(
              controller: inputController,
              maxLines: 8,
              decoration: InputDecoration(
                hintText: inputMode == 'HEX'
                    ? '例如 48 65 6C 6C 6F 00 66 6C 61 67'
                    : '直接粘贴文件文本片段或转储内容',
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(height: 12),
          ToolSectionCard(
            title: 'ASCII',
            child: SelectableText(
              asciiOutput.isEmpty ? '暂无结果' : asciiOutput,
              style: TextStyle(color: scheme.onSurface, height: 1.5),
            ),
          ),
          const SizedBox(height: 12),
          ToolSectionCard(
            title: 'UTF-16LE',
            child: SelectableText(
              utf16Output.isEmpty ? '暂无结果' : utf16Output,
              style: TextStyle(color: scheme.onSurface, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  void _extract() {
    final minLength = int.tryParse(minLengthController.text.trim()) ?? 4;
    try {
      final bytes = StringsExtractor.parseInput(
        inputController.text,
        isHex: inputMode == 'HEX',
      );
      final ascii = StringsExtractor.extractAscii(bytes, minLength: minLength);
      final utf16 = StringsExtractor.extractUtf16Le(bytes, minLength: minLength);
      setState(() {
        asciiOutput = ascii.join('\n');
        utf16Output = utf16.join('\n');
      });
    } catch (e) {
      setState(() {
        asciiOutput = '提取失败: $e';
        utf16Output = '';
      });
    }
  }
}
