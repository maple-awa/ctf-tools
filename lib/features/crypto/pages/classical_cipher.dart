import 'package:ctf_tools/features/crypto/utils/classical_cipher.dart';
import 'package:ctf_tools/shared/widgets/dropdown_menu.dart';
import 'package:ctf_tools/shared/widgets/mbutton.dart';
import 'package:ctf_tools/shared/widgets/show_toast.dart';
import 'package:ctf_tools/shared/widgets/tool_page_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ClassicalCipherScreen extends StatefulWidget {
  const ClassicalCipherScreen({super.key});

  @override
  State<ClassicalCipherScreen> createState() => _ClassicalCipherScreenState();
}

class _ClassicalCipherScreenState extends State<ClassicalCipherScreen> {
  final inputController = TextEditingController();
  final outputController = TextEditingController();
  final keyController = TextEditingController(text: '3');
  String selectedMethod = ClassicalCipher.methods.first;

  @override
  void dispose() {
    inputController.dispose();
    outputController.dispose();
    keyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final inputFormatters = selectedMethod == 'Caesar'
        ? [FilteringTextInputFormatter.allow(RegExp(r'-?\d*'))]
        : null;
    return ToolPageShell(
      title: '经典密码',
      description: '扩展到 Caesar、Atbash、Vigenere、Affine、Rail Fence、Baconian 六类常见题型。',
      badge: 'Crypto',
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
                  items: ClassicalCipher.methods,
                  onChanged: (value) => setState(() {
                    selectedMethod = value;
                    keyController.text = switch (value) {
                      'Caesar' => '3',
                      'Vigenere' => 'KEY',
                      'Affine' => '5,8',
                      'Rail Fence' => '3',
                      _ => '',
                    };
                  }),
                ),
                SizedBox(
                  width: 220,
                  child: TextField(
                    controller: keyController,
                    inputFormatters: inputFormatters,
                    decoration: InputDecoration(
                      labelText: _keyLabel,
                      hintText: _keyHint,
                      border: const OutlineInputBorder(),
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
              MElevatedButton(icon: Icons.lock_open, text: '解码', onPressed: _decode),
              MElevatedButton(icon: Icons.copy, text: '复制输出', onPressed: () => _copyText(outputController.text)),
            ],
          ),
          const SizedBox(height: 12),
          ToolSectionCard(
            title: '输出',
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

  String get _keyLabel {
    return switch (selectedMethod) {
      'Caesar' => '位移',
      'Vigenere' => '密钥',
      'Affine' => 'a,b',
      'Rail Fence' => 'Rail 数',
      _ => '可留空',
    };
  }

  String get _keyHint {
    return switch (selectedMethod) {
      'Caesar' => '例如 3',
      'Vigenere' => '例如 KEY',
      'Affine' => '例如 5,8',
      'Rail Fence' => '例如 3',
      _ => '',
    };
  }

  void _encode() {
    try {
      outputController.text = ClassicalCipher.encode(selectedMethod, inputController.text, key: keyController.text);
      setState(() {});
    } catch (error) {
      showToast('编码失败: $error', context);
    }
  }

  void _decode() {
    try {
      outputController.text = ClassicalCipher.decode(selectedMethod, inputController.text, key: keyController.text);
      setState(() {});
    } catch (error) {
      showToast('解码失败: $error', context);
    }
  }

  Future<void> _copyText(String text) async {
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
}
