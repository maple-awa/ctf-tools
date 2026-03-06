import 'dart:convert';

import 'package:ctf_tools/features/network/utils/whois_util.dart';
import 'package:ctf_tools/shared/widgets/mbutton.dart';
import 'package:ctf_tools/shared/widgets/show_toast.dart';
import 'package:ctf_tools/shared/widgets/tool_page_shell.dart';
import 'package:ctf_tools/shared/widgets/tool_status_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:whois/whois.dart';

class WhoisScreen extends StatefulWidget {
  const WhoisScreen({super.key});

  @override
  State<WhoisScreen> createState() => _WhoisScreenState();
}

class _WhoisScreenState extends State<WhoisScreen> {
  final TextEditingController inputController = TextEditingController();
  final TextEditingController outputController = TextEditingController();
  bool isRawMode = false;

  @override
  void dispose() {
    inputController.dispose();
    outputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ToolSectionCard(
          title: '查询参数',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  ToolStatusChip(label: 'WHOIS Lookup', icon: Icons.search),
                ],
              ),
              const SizedBox(height: 10),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('原始输出模式'),
                value: isRawMode,
                onChanged: (value) => setState(() {
                  isRawMode = value;
                }),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ToolSectionCard(
          title: '输入域名',
          trailing: MElevatedButton(
            icon: Icons.search,
            text: '查询',
            onPressed: _whoisSearch,
          ),
          child: TextField(
            controller: inputController,
            decoration: InputDecoration(
              labelText: '输入想要查询的域名',
              prefixIcon: const Icon(Icons.language),
              suffixIcon: inputController.text.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        inputController.clear();
                        setState(() {});
                      },
                      icon: const Icon(Icons.clear),
                    )
                  : null,
            ),
            onChanged: (_) => setState(() {}),
          ),
        ),
        const SizedBox(height: 12),
        ToolSectionCard(
          title: '输出',
          trailing: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ToolStatusChip(
                label: isRawMode ? 'RAW OUTPUT' : 'FORMATTED',
                icon: Icons.article_outlined,
              ),
              MElevatedButton(
                icon: Icons.copy,
                text: '复制',
                onPressed: () => _copyText(outputController.text),
              ),
              MElevatedButton(
                icon: Icons.delete,
                text: '清空',
                onPressed: _clear,
              ),
            ],
          ),
          child: SizedBox(
            height: kToolLargeOutputHeight,
            child: TextField(
              controller: outputController,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _whoisSearch() async {
    final domain = inputController.text.trim();
    if (domain.isEmpty) {
      showToast('不知道你要查询什么喵', context);
      return;
    }
    try {
      final result = isRawMode
          ? utf8.decode(
              latin1.encode(await Whois.lookup(domain)),
              allowMalformed: true,
            )
          : await WhoisUtil.lookupAndFormatChinese(domain);
      outputController.text = result;
      if (mounted) setState(() {});
    } catch (e) {
      outputController.text = '查询出错：$e';
      if (!mounted) return;
      showToast('查询失败：$e', context);
    }
  }

  void _clear() {
    if (inputController.text.isEmpty && outputController.text.isEmpty) {
      showToast('无内容可清空喵', context);
      return;
    }
    inputController.clear();
    outputController.clear();
    setState(() {});
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
