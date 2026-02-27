import 'package:ctf_tools/features/encoding/utils/text_encoding/text_codec.dart';
import 'package:ctf_tools/features/encoding/utils/text_encoding/text_list.dart';
import 'package:ctf_tools/shared/widgets/dropdown_menu.dart';
import 'package:ctf_tools/shared/widgets/mbutton.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ctf_tools/shared/layout/responsive.dart';

class TextEncodingScreen extends StatefulWidget {
  const TextEncodingScreen({super.key});

  @override
  State<TextEncodingScreen> createState() => _TextEncodingScreen();
}

class _TextEncodingScreen extends State<TextEncodingScreen> {
  ColorScheme get scheme => Theme.of(context).colorScheme;

  /// 当前选中的文本编解码类型。
  String selectedCharacterEncoding = getTextCoderList[0];

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
                      "文本 编码/解码",
                      style: TextStyle(
                        fontSize: isMobile ? 22 : 26,
                        fontWeight: FontWeight.bold,
                        color: scheme.onSurface,
                      ),
                    ),
                    Text(
                      "编码/解码选择",
                      style: TextStyle(
                        color: scheme.onSurfaceVariant,
                        fontSize: 16,
                      ),
                    ),
                    MDropdownMenu(
                      initialValue: selectedCharacterEncoding,
                      items: getTextCoderList,
                      onChanged: (value) {
                        setState(() {
                          selectedCharacterEncoding = value;
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
                    onPressed: _encode,
                  ),
                  MElevatedButton(
                    icon: Icons.lock_open,
                    iconColor: scheme.onSurface,
                    text: "解码",
                    textColor: scheme.onSurface,
                    onPressed: _decode,
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
  /// 根据当前编码类型对输入文本执行编码。
  void _encode() {
    try {
      outputController.text = TextCoderFactory.encode(
        selectedCharacterEncoding,
        inputController.text,
      );
      setState(() {});
    } catch (e) {
      _showToast("编码失败: $e");
    }
  }

  /// 根据当前编码类型对输入文本执行解码。
  void _decode() {
    try {
      outputController.text = TextCoderFactory.decode(
        selectedCharacterEncoding,
        inputController.text,
      );
      setState(() {});
    } catch (e) {
      _showToast("解码失败: $e");
    }
  }

  /// 清理输入输出框
  void _clear() {
    if (inputController.text.isEmpty && outputController.text.isEmpty) {
      _showToast("无内容可清空喵");
      return;
    }
    inputController.clear();
    outputController.clear();
    _showToast("已清空喵");
  }

  /// 复制文本
  Future<void> _copyText(String text) async {
    if (text.isEmpty) {
      _showToast("无内容可复制喵");
      return;
    }
    await Clipboard.setData(ClipboardData(text: text));
    _showToast("复制成功喵");
  }

  /// 显示提示弹窗（Toast）
  void _showToast(String message) {
    final scheme = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: scheme.primary,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
