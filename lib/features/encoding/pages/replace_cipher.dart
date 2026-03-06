import 'package:ctf_tools/features/encoding/utils/replace_cipher/replace_cipher.dart';
import 'package:ctf_tools/shared/widgets/dropdown_menu.dart';
import 'package:ctf_tools/shared/widgets/mbutton.dart';
import 'package:ctf_tools/shared/widgets/show_toast.dart';
import 'package:ctf_tools/shared/widgets/tool_page_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ReplaceCipherScreen extends StatefulWidget {
  const ReplaceCipherScreen({super.key});

  @override
  State<ReplaceCipherScreen> createState() => _ReplaceCipherScreenState();
}

class _ReplaceCipherScreenState extends State<ReplaceCipherScreen> {
  final inputController = TextEditingController();
  final outputController = TextEditingController();
  final shiftController = TextEditingController(text: '13');
  String selectedMethod = ReplaceCipher.methods.first;

  @override
  void dispose() {
    inputController.dispose();
    outputController.dispose();
    shiftController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ToolPageShell(
      title: '替换密码',
      description: '覆盖 ROT13、ROT47、Caesar、Atbash，适合处理 CTF 中最常见的轻量替换题。',
      child: Column(
        children: [
          ToolSectionCard(
            title: '参数',
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text('算法', style: TextStyle(color: scheme.onSurfaceVariant)),
                MDropdownMenu(
                  initialValue: selectedMethod,
                  items: ReplaceCipher.methods,
                  onChanged: (value) {
                    setState(() {
                      selectedMethod = value;
                    });
                  },
                ),
                if (selectedMethod == 'Caesar')
                  SizedBox(
                    width: 120,
                    child: TextField(
                      controller: shiftController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'-?\d*')),
                      ],
                      decoration: const InputDecoration(
                        labelText: '位移',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ToolSectionCard(
            title: '输入',
            trailing: Wrap(
              spacing: 8,
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
              decoration: const InputDecoration(border: OutlineInputBorder()),
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
            trailing: MElevatedButton(
              icon: Icons.copy,
              text: '复制',
              onPressed: () => _copyText(outputController.text),
            ),
            child: TextField(
              controller: outputController,
              maxLines: 8,
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
          ),
        ],
      ),
    );
  }

  void _encode() {
    try {
      outputController.text = ReplaceCipher.encode(
        selectedMethod,
        inputController.text,
        shift: _currentShift,
      );
      setState(() {});
    } catch (e) {
      showToast('编码失败: $e', context);
    }
  }

  void _decode() {
    try {
      outputController.text = ReplaceCipher.decode(
        selectedMethod,
        inputController.text,
        shift: _currentShift,
      );
      setState(() {});
    } catch (e) {
      showToast('解码失败: $e', context);
    }
  }

  int get _currentShift => int.tryParse(shiftController.text.trim()) ?? 13;

  void _clear() {
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
