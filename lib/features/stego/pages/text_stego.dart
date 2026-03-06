import 'package:ctf_tools/features/stego/utils/space_tab_codec.dart';
import 'package:ctf_tools/features/stego/utils/zero_width_codec.dart';
import 'package:ctf_tools/shared/widgets/dropdown_menu.dart';
import 'package:ctf_tools/shared/widgets/mbutton.dart';
import 'package:ctf_tools/shared/widgets/show_toast.dart';
import 'package:ctf_tools/shared/widgets/tool_page_shell.dart';
import 'package:flutter/material.dart';

class TextStegoScreen extends StatefulWidget {
  const TextStegoScreen({super.key});

  @override
  State<TextStegoScreen> createState() => _TextStegoScreenState();
}

class _TextStegoScreenState extends State<TextStegoScreen> {
  final inputController = TextEditingController();
  String codec = 'Zero Width';
  String output = '';

  @override
  void dispose() {
    inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ToolPageShell(
      title: '文本隐写',
      description: '补齐零宽字符与 Space/Tab(Snow-like) 隐写的编码、解码和统计检测。',
      badge: 'Stego',
      child: Column(
        children: [
          ToolSectionCard(
            title: '参数',
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text('编码方案', style: TextStyle(color: scheme.onSurfaceVariant)),
                MDropdownMenu(
                  initialValue: codec,
                  items: const ['Zero Width', 'Space/Tab'],
                  onChanged: (value) => setState(() {
                    codec = value;
                  }),
                ),
              ],
            ),
          ),
          const SizedBox(height: kToolSectionGap),
          ToolSectionCard(
            title: '输入',
            child: TextField(
              controller: inputController,
              maxLines: 10,
              decoration: const InputDecoration(
                hintText: '输入明文生成载荷，或粘贴可疑文本进行解码/检测',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(height: kToolSectionGap),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              MElevatedButton(icon: Icons.visibility_off, text: '生成载荷', onPressed: _encode),
              MElevatedButton(icon: Icons.lock_open, text: '尝试解码', onPressed: _decode),
              MElevatedButton(icon: Icons.analytics, text: '字符统计', onPressed: _inspect),
            ],
          ),
          const SizedBox(height: kToolSectionGap),
          ToolSectionCard(title: '输出', child: SelectableText(output.isEmpty ? '暂无结果' : output)),
        ],
      ),
    );
  }

  void _encode() {
    try {
      final result = codec == 'Zero Width' ? ZeroWidthCodec.encode(inputController.text) : SpaceTabCodec.encode(inputController.text);
      setState(() {
        output = codec == 'Zero Width'
            ? '零宽载荷长度: ${result.length}\n可视化预览: ${_visualizeZeroWidth(result)}'
            : 'Space/Tab 载荷行数: ${result.split('\n').length}\n$result';
      });
    } catch (error) {
      showToast('编码失败: $error', context);
    }
  }

  void _decode() {
    try {
      setState(() {
        output = codec == 'Zero Width' ? ZeroWidthCodec.decode(inputController.text) : SpaceTabCodec.decode(inputController.text);
      });
    } catch (error) {
      showToast('解码失败: $error', context);
    }
  }

  void _inspect() {
    setState(() {
      output = codec == 'Zero Width' ? ZeroWidthCodec.inspect(inputController.text) : SpaceTabCodec.inspect(inputController.text);
    });
  }

  String _visualizeZeroWidth(String text) {
    return text
        .replaceAll(ZeroWidthCodec.zero, '<0>')
        .replaceAll(ZeroWidthCodec.one, '<1>')
        .replaceAll(ZeroWidthCodec.separator, '<|>');
  }
}
