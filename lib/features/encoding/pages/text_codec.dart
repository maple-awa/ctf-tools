import 'package:ctf_tools/features/encoding/utils/text_encoding/text_codec.dart';
import 'package:ctf_tools/features/encoding/utils/text_encoding/text_list.dart';
import 'package:ctf_tools/shared/widgets/dropdown_menu.dart';
import 'package:ctf_tools/shared/widgets/mbutton.dart';
import 'package:ctf_tools/shared/widgets/show_toast.dart';
import 'package:ctf_tools/shared/widgets/tool_page_shell.dart';
import 'package:ctf_tools/shared/widgets/tool_status_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TextEncodingScreen extends StatefulWidget {
  const TextEncodingScreen({super.key});

  @override
  State<TextEncodingScreen> createState() => _TextEncodingScreenState();
}

class _TextEncodingScreenState extends State<TextEncodingScreen> {
  String selectedCharacterEncoding = getTextCoderList[0];
  final TextEditingController inputController = TextEditingController();
  final TextEditingController outputController = TextEditingController();

  @override
  void dispose() {
    inputController.dispose();
    outputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ToolPageShell(
      title: '文本编码/解码',
      description: '统一处理 URL、HTML、Unicode、Quoted-Printable 和 Morse Code 等文本层编码。',
      badge: 'Encoding',
      child: Column(
        children: [
          ToolSectionCard(
            title: '参数',
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text('编码器', style: TextStyle(color: scheme.onSurfaceVariant)),
                MDropdownMenu(
                  initialValue: selectedCharacterEncoding,
                  items: getTextCoderList,
                  onChanged: (value) => setState(() {
                    selectedCharacterEncoding = value;
                  }),
                ),
                const ToolStatusChip(label: 'RAW Text', icon: Icons.text_fields),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ToolSectionCard(
            title: '输入',
            trailing: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                MElevatedButton(
                  icon: Icons.copy,
                  text: '复制',
                  onPressed: () => _copyText(inputController.text),
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
              maxLines: 8,
              style: TextStyle(color: scheme.onSurface),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            runSpacing: 10,
            children: [
              MElevatedButton(icon: Icons.lock, text: '编码', onPressed: _encode),
              MElevatedButton(
                icon: Icons.lock_open,
                text: '解码',
                onPressed: _decode,
              ),
              MElevatedButton(
                icon: Icons.swap_horiz,
                text: '交换',
                onPressed: () {
                  final temp = inputController.text;
                  inputController.text = outputController.text;
                  outputController.text = temp;
                  setState(() {});
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          ToolSectionCard(
            title: '输出',
            trailing: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                const ToolStatusChip(label: 'READY', icon: Icons.check_circle_outline),
                MElevatedButton(
                  icon: Icons.copy,
                  text: '复制',
                  onPressed: () => _copyText(outputController.text),
                ),
              ],
            ),
            child: SizedBox(
              height: kToolOutputHeight,
              child: TextField(
                controller: outputController,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                style: TextStyle(color: scheme.onSurface),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _encode() {
    try {
      outputController.text = TextCoderFactory.encode(
        selectedCharacterEncoding,
        inputController.text,
      );
      setState(() {});
    } catch (e) {
      showToast('编码失败: $e', context);
    }
  }

  void _decode() {
    try {
      outputController.text = TextCoderFactory.decode(
        selectedCharacterEncoding,
        inputController.text,
      );
      setState(() {});
    } catch (e) {
      showToast('解码失败: $e', context);
    }
  }

  void _clear() {
    if (inputController.text.isEmpty && outputController.text.isEmpty) {
      showToast('无内容可清空喵', context);
      return;
    }
    inputController.clear();
    outputController.clear();
    showToast('已清空喵', context);
  }

  Future<void> _copyText(String text) async {
    if (text.isEmpty) {
      showToast('无内容可复制喵', context);
      return;
    }
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    showToast('复制成功喵', context);
  }
}
