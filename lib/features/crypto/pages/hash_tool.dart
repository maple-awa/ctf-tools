import 'package:ctf_tools/features/crypto/utils/hash_cracker.dart';
import 'package:ctf_tools/features/crypto/utils/hash_tools.dart';
import 'package:ctf_tools/shared/widgets/dropdown_menu.dart';
import 'package:ctf_tools/shared/widgets/mbutton.dart';
import 'package:ctf_tools/shared/widgets/show_toast.dart';
import 'package:ctf_tools/shared/widgets/tool_page_shell.dart';
import 'package:ctf_tools/shared/widgets/tool_status_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HashToolScreen extends StatefulWidget {
  const HashToolScreen({super.key});

  @override
  State<HashToolScreen> createState() => _HashToolScreenState();
}

class _HashToolScreenState extends State<HashToolScreen> {
  final inputController = TextEditingController();
  final outputController = TextEditingController();
  final hmacKeyController = TextEditingController();
  final crackTargetController = TextEditingController();
  final crackCandidatesController = TextEditingController(text: 'flag\nadmin\nctf-tools\npassword');

  String selectedAlgorithm = HashTools.algorithms.first;
  String selectedInputFormat = HashTools.inputFormats.first;
  String selectedOutputFormat = HashTools.outputFormats[1];
  bool enableHmac = false;

  @override
  void dispose() {
    inputController.dispose();
    outputController.dispose();
    hmacKeyController.dispose();
    crackTargetController.dispose();
    crackCandidatesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final hmacSupported = HashTools.supportsHmac(selectedAlgorithm);
    return DefaultTabController(
      length: 2,
      child: ToolPageShell(
        title: '哈希计算',
        description: '覆盖常见摘要、HMAC、摘要识别与本地字典爆破。',
        badge: 'Crypto',
        child: Column(
          children: [
            Card(
              child: const TabBar(
                tabs: [
                  Tab(icon: Icon(Icons.fingerprint), text: '摘要'),
                  Tab(icon: Icon(Icons.key_off), text: '字典爆破'),
                ],
              ),
            ),
            const SizedBox(height: kToolSectionGap),
            SizedBox(
              height: 860,
              child: TabBarView(
                children: [
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        ToolSectionCard(
                          title: '参数',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Wrap(
                                spacing: 12,
                                runSpacing: 12,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Text('算法', style: TextStyle(color: scheme.onSurfaceVariant)),
                                  MDropdownMenu(
                                    initialValue: selectedAlgorithm,
                                    items: HashTools.algorithms,
                                    onChanged: (value) => setState(() {
                                      selectedAlgorithm = value;
                                      if (!HashTools.supportsHmac(value)) {
                                        enableHmac = false;
                                        hmacKeyController.clear();
                                      }
                                    }),
                                  ),
                                  Text('输入', style: TextStyle(color: scheme.onSurfaceVariant)),
                                  MDropdownMenu(initialValue: selectedInputFormat, items: HashTools.inputFormats, onChanged: (value) => setState(() => selectedInputFormat = value)),
                                  Text('输出', style: TextStyle(color: scheme.onSurfaceVariant)),
                                  MDropdownMenu(initialValue: selectedOutputFormat, items: HashTools.outputFormats, onChanged: (value) => setState(() => selectedOutputFormat = value)),
                                  ToolStatusChip(label: enableHmac ? 'HMAC' : 'DIGEST', icon: enableHmac ? Icons.key : Icons.fingerprint),
                                ],
                              ),
                              const SizedBox(height: 8),
                              SwitchListTile(
                                contentPadding: EdgeInsets.zero,
                                title: const Text('启用 HMAC'),
                                subtitle: Text(
                                  hmacSupported ? '当前算法支持 HMAC' : '当前算法不支持 HMAC',
                                  style: TextStyle(color: scheme.onSurfaceVariant),
                                ),
                                value: enableHmac,
                                onChanged: hmacSupported ? (value) => setState(() => enableHmac = value) : null,
                              ),
                              if (enableHmac) ...[
                                const SizedBox(height: 8),
                                TextField(controller: hmacKeyController, decoration: const InputDecoration(labelText: 'HMAC Key')),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: kToolSectionGap),
                        ToolSectionCard(
                          title: '输入',
                          child: TextField(controller: inputController, maxLines: 8, decoration: InputDecoration(hintText: _inputHint, prefixIcon: const Icon(Icons.input_outlined))),
                        ),
                        const SizedBox(height: kToolSectionGap),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            MElevatedButton(icon: Icons.fingerprint, text: '计算当前', onPressed: _digest),
                            MElevatedButton(icon: Icons.dashboard_customize, text: '计算全部', onPressed: _digestAll),
                            MElevatedButton(icon: Icons.search, text: '识别摘要', onPressed: _identify),
                            MElevatedButton(icon: Icons.info_outline, text: '输入摘要', onPressed: _inspectInput),
                            MElevatedButton(icon: Icons.copy, text: '复制输出', onPressed: () => _copyText(outputController.text)),
                          ],
                        ),
                        const SizedBox(height: kToolSectionGap),
                        ToolSectionCard(
                          title: '输出',
                          child: SizedBox(
                            height: kToolLargeOutputHeight,
                            child: TextField(controller: outputController, maxLines: null, expands: true, textAlignVertical: TextAlignVertical.top, decoration: const InputDecoration(hintText: '结果输出')),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        ToolSectionCard(
                          title: '字典爆破',
                          child: Column(
                            children: [
                              TextField(controller: crackTargetController, decoration: const InputDecoration(labelText: '目标摘要', border: OutlineInputBorder())),
                              const SizedBox(height: 8),
                              TextField(controller: crackCandidatesController, maxLines: 10, decoration: const InputDecoration(labelText: '候选词（每行一个）', border: OutlineInputBorder())),
                            ],
                          ),
                        ),
                        const SizedBox(height: kToolSectionGap),
                        MElevatedButton(icon: Icons.key_off, text: '开始爆破', onPressed: _crackDigest),
                        const SizedBox(height: kToolSectionGap),
                        ToolSectionCard(title: '输出', child: SelectableText(outputController.text.isEmpty ? '暂无结果' : outputController.text)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String get _inputHint {
    return switch (selectedInputFormat) {
      'UTF-8' => '输入明文，例如 flag{test}',
      'Hex' => '输入十六进制数据，例如 66 6C 61 67',
      'Base64' => '输入 Base64 数据，例如 ZmxhZw==',
      _ => '输入待处理内容',
    };
  }

  void _digest() {
    try {
      outputController.text = HashTools.digest(
        algorithm: selectedAlgorithm,
        input: inputController.text,
        inputFormat: selectedInputFormat,
        outputFormat: selectedOutputFormat,
        hmacKey: enableHmac ? hmacKeyController.text : null,
      );
      setState(() {});
    } catch (error) {
      showToast('计算失败: $error', context);
    }
  }

  void _digestAll() {
    try {
      final result = HashTools.digestAll(
        input: inputController.text,
        inputFormat: selectedInputFormat,
        outputFormat: selectedOutputFormat,
        hmacKey: enableHmac ? hmacKeyController.text : null,
      );
      outputController.text = result.entries.map((entry) => '${entry.key}: ${entry.value}').join('\n');
      setState(() {});
    } catch (error) {
      showToast('批量计算失败: $error', context);
    }
  }

  void _identify() {
    try {
      outputController.text = HashTools.identifyDigest(inputController.text).join('\n');
      setState(() {});
    } catch (error) {
      showToast('识别失败: $error', context);
    }
  }

  void _inspectInput() {
    try {
      outputController.text = HashTools.describeInput(inputController.text, selectedInputFormat);
      setState(() {});
    } catch (error) {
      showToast('分析失败: $error', context);
    }
  }

  void _crackDigest() {
    try {
      final result = HashCracker.crack(
        algorithm: selectedAlgorithm,
        targetDigest: crackTargetController.text,
        outputFormat: selectedOutputFormat,
        candidates: crackCandidatesController.text,
      );
      outputController.text = [
        'Checked: ${result.checked}',
        'Matches: ${result.matches.isEmpty ? 'None' : result.matches.join(', ')}',
      ].join('\n');
      setState(() {});
    } catch (error) {
      showToast('爆破失败: $error', context);
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
