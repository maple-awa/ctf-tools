import 'dart:convert';
import 'package:ctf_tools/features/network/utils/whois_util.dart';
import 'package:ctf_tools/shared/widgets/mbutton.dart';
import 'package:ctf_tools/shared/widgets/show_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:whois/whois.dart';
import 'package:ctf_tools/shared/layout/responsive.dart';

class WhoisScreen extends StatefulWidget {
  const WhoisScreen({super.key});

  @override
  State<WhoisScreen> createState() => _WhoisScreen();
}

class _WhoisScreen extends State<WhoisScreen> {
  ColorScheme get scheme => Theme.of(context).colorScheme;

  /// 输入框文本控制器。
  TextEditingController inputController = TextEditingController();

  /// 输出框文本控制器。
  TextEditingController outputController = TextEditingController();

  /// 是否使用原始 WHOIS 输出模式。
  bool isRawMode = false;

  @override
  void dispose() {
    inputController.dispose();
    outputController.dispose();
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
                ],
              ),
              const SizedBox(height: 20),
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 10,
                runSpacing: 10,
                children: [
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
                        suffixIcon: inputController.text.isNotEmpty
                            ? IconButton(
                                icon: Icon(
                                  Icons.clear,
                                  color: scheme.onSurfaceVariant,
                                ),
                                onPressed: () {
                                  inputController.clear();
                                  setState(() {});
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                  ),
                  MElevatedButton(
                    icon: Icons.search,
                    text: "查询",
                    onPressed: () {
                      _whoisSearch();
                      setState(() {});
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 10,
                runSpacing: 10,
                children: [
                  Text(
                    "输出框 (OUTPUT)",
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
                      "RAW OUTPUT",
                      style: TextStyle(color: scheme.secondary),
                    ),
                  ),
                  Switch(
                    value: isRawMode,
                    activeThumbColor: scheme.primary,
                    activeTrackColor: scheme.primary.withValues(alpha: 0.5),
                    inactiveThumbColor: scheme.outline,
                    inactiveTrackColor: scheme.surfaceContainerHighest,
                    onChanged: (value) {
                      setState(() {
                        isRawMode = value;
                      });
                    },
                  ),
                  MElevatedButton(
                    icon: Icons.copy,
                    text: "复制",
                    onPressed: () => _copyText(outputController.text),
                  ),
                  MElevatedButton(
                    icon: Icons.file_copy,
                    text: "导出到文件",
                    onPressed: () => {},
                  ),
                  MElevatedButton(
                    icon: Icons.delete,
                    text: "清空",
                    onPressed: _clear,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (isMobile)
                SizedBox(height: 300, child: _buildOutputField())
              else
                Expanded(child: _buildOutputField()),
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

  Widget _buildOutputField() {
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

  /// 执行 WHOIS 查询并更新输出内容。
  Future<void> _whoisSearch() async {
    final domain = inputController.text.trim();
    if (domain.isEmpty) {
      showToast("不知道你要查询什么喵", context);
      return;
    }
    try {
      String result;
      if (isRawMode) {
        final tmp = await Whois.lookup(domain);
        final originalUtf8Bytes = latin1.encode(tmp);
        result = utf8.decode(originalUtf8Bytes, allowMalformed: true);
      } else {
        result = await WhoisUtil.lookupAndFormatChinese(domain);
      }
      outputController.text = result;
      if (mounted) setState(() {});
    } catch (e) {
      final errorMessage = "查询出错：$e";
      outputController.text = errorMessage;
      if (!mounted) return;
      showToast("查询失败：$e", context);
    }
  }

  /// 清理输入输出框
  void _clear() {
    if (inputController.text.isEmpty && outputController.text.isEmpty) {
      showToast("无内容可清空喵", context);
      return;
    }
    inputController.clear();
    outputController.clear();
    showToast("已清空喵", context);
  }

  /// 复制文本
  Future<void> _copyText(String text) async {
    if (text.isEmpty) {
      showToast("无内容可复制喵", context);
      return;
    }
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    showToast("复制成功喵", context);
  }
}
