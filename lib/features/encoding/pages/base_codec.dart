import 'dart:convert';
import 'package:ctf_tools/features/encoding/utils/base_encoding/base_list.dart';
import 'package:ctf_tools/shared/widgets/dropdown_menu.dart';
import 'package:ctf_tools/shared/widgets/mbutton.dart';
import 'package:ctf_tools/shared/widgets/show_toast.dart';
import 'package:ctf_tools/shared/layout/responsive.dart';
import 'package:flutter/material.dart';
import 'package:ctf_tools/features/encoding/utils/character_encoding.dart';
import 'package:flutter/services.dart';
import 'package:ctf_tools/features/encoding/utils/base_encoding/base_codec.dart';

class BaseCodecScreen extends StatefulWidget {
  const BaseCodecScreen({super.key});

  @override
  State<BaseCodecScreen> createState() => _BaseCodecScreen();
}

class _BaseCodecScreen extends State<BaseCodecScreen> {
  ColorScheme get scheme => Theme.of(context).colorScheme;

  /// 当前选中的字符编码。
  String selectedCharacterEncoding = CharacterEncoding.characterEncodingList[0];

  /// 当前选中的 Base 编码类型。
  String baseInitialValue = getBaseEncodingList[7];

  /// 输入框控制器。
  TextEditingController inputController = TextEditingController();

  /// 交换输入输出时的临时变量。
  String swapTextTemp = "";

  /// 输出框控制器。
  TextEditingController outputController = TextEditingController();

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
              Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    Text(
                      "Base 编码/解码",
                      style: TextStyle(
                        fontSize: isMobile ? 22 : 26,
                        fontWeight: FontWeight.bold,
                        color: scheme.onSurface,
                      ),
                    ),
                    Text(
                      "字符集",
                      style: TextStyle(
                        color: scheme.onSurfaceVariant,
                        fontSize: 16,
                      ),
                    ),
                    MDropdownMenu(
                      initialValue: selectedCharacterEncoding,
                      items: CharacterEncoding.characterEncodingList,
                      onChanged: (value) {
                        setState(() {
                          selectedCharacterEncoding = value;
                        });
                      },
                    ),
                    Text(
                      "Base编码",
                      style: TextStyle(
                        color: scheme.onSurfaceVariant,
                        fontSize: 16,
                      ),
                    ),
                    MDropdownMenu(
                      initialValue: baseInitialValue,
                      items: getBaseEncodingList,
                      onChanged: (value) {
                        setState(() {
                          baseInitialValue = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 10,
                runSpacing: 10,
                children: [
                  Text(
                    "输入框 (INPUT)",
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
                      "RAW Text",
                      style: TextStyle(color: scheme.primary),
                    ),
                  ),
                  MElevatedButton(
                    icon: Icons.copy,
                    text: "复制",
                    onPressed: () => _copyText(inputController.text),
                  ),
                  MElevatedButton(
                    icon: Icons.file_open,
                    text: "导入文件",
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
              TextField(
                maxLines: 8,
                controller: inputController,
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
              ),
              const SizedBox(height: 20),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 12,
                runSpacing: 10,
                children: [
                  MElevatedButton(
                    icon: Icons.lock,
                    iconColor: scheme.onSurface,
                    text: "编码",
                    textColor: scheme.onSurface,
                    onPressed: _baseEncoding,
                  ),
                  MElevatedButton(
                    icon: Icons.lock_open,
                    iconColor: scheme.onSurface,
                    text: "解码",
                    textColor: scheme.onSurface,
                    onPressed: _baseDecoding,
                  ),
                  MElevatedButton(
                    icon: Icons.sync_outlined,
                    iconColor: scheme.onSurface,
                    text: "交换",
                    textColor: scheme.onSurface,
                    onPressed: () {
                      swapTextTemp = inputController.text;
                      inputController.text = outputController.text;
                      outputController.text = swapTextTemp;
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
                      "READY",
                      style: TextStyle(color: scheme.secondary),
                    ),
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
                SizedBox(height: 260, child: _buildOutputTextField())
              else
                Expanded(child: _buildOutputTextField()),
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

  Widget _buildOutputTextField() {
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

  ///=== 私有方法 ===///
  /// 将输入文本按 UTF-8 转字节后执行 Base 编码。
  void _baseEncoding() {
    try {
      final utf8Bytes = utf8.encode(inputController.text);
      outputController.text = BaseCodecFactory.encode(
        baseInitialValue,
        utf8Bytes,
      );
      setState(() {});
    } catch (e) {
      showToast("编码失败: $e", context);
    }
  }

  /// 将 Base 文本解码为字节，再按选定字符集转换并显示。
  void _baseDecoding() {
    try {
      final decodedBytes = BaseCodecFactory.decode(
        baseInitialValue,
        inputController.text,
      );
      final utf8Bytes = CharacterEncoding.convertToUtf8(
        decodedBytes,
        selectedCharacterEncoding,
      );
      outputController.text = utf8.decode(utf8Bytes, allowMalformed: true);
      setState(() {});
    } catch (e) {
      showToast("解码失败: $e", context);
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
