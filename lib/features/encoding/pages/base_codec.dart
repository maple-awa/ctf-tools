import 'dart:convert';
import 'package:ctf_tools/features/encoding/utils/base_encoding/base_list.dart';
import 'package:ctf_tools/shared/widgets/dropdown_menu.dart';
import 'package:ctf_tools/shared/widgets/mbutton.dart';
import 'package:ctf_tools/shared/widgets/show_toast.dart';
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
  /// 当前选中的字符编码。
  String selectedCharacterEncoding =
      CharacterEncoding.characterEncodingList[0];
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
      color: Color(0xFF101622),
      child: Padding(
        padding: EdgeInsetsGeometry.all(20),
        child: Column(
          children: [
            // 顶栏
            Row(
              children: [
                // 标题
                Text(
                  "Base 编码/解码",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFFE1D4),
                  ),
                ),
                const SizedBox(width: 26),

                // 字符集切换按钮
                Text(
                  "字符集",
                  style: TextStyle(color: Color(0xFF9497A0), fontSize: 16),
                ),
                const SizedBox(width: 6),
                MDropdownMenu(
                  initialValue: selectedCharacterEncoding,
                  items: CharacterEncoding.characterEncodingList,
                  onChanged: (value) {
                    setState(() {
                      selectedCharacterEncoding = value;
                    });
                  },
                ),

                const SizedBox(width: 16),

                // Base编码切换按钮
                Text(
                  "Base编码",
                  style: TextStyle(color: Color(0xFF9497A0), fontSize: 16),
                ),
                const SizedBox(width: 6),
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

            SizedBox(height: 20),

            // 输入框标题
            Row(
              children: [
                Text(
                  "输入框 (INPUT)",
                  style: TextStyle(color: Color(0xFF9497A0), fontSize: 16),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Color(0xFF122244),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.all(5),
                  child: Text(
                    "RAW Text",
                    style: TextStyle(color: Color(0xFF2B64D1)),
                  ),
                ),
                Spacer(),

                // 复制按钮
                MElevatedButton(
                  icon: Icons.copy,
                  text: "复制",
                  onPressed: () => {_copyText(inputController.text)},
                ),
                const SizedBox(width: 12),
                // 导入文件按钮
                MElevatedButton(
                  icon: Icons.file_open,
                  text: "导入文件",
                  onPressed: () => {},
                ),
                const SizedBox(width: 12),
                // 清空按钮
                MElevatedButton(
                  icon: Icons.delete,
                  text: "清空",
                  onPressed: () => {_clear()},
                ),
              ],
            ),
            SizedBox(height: 20),

            // 输入框
            TextField(
              maxLines: 8,
              controller: inputController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Color(0xFF0F17AA)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: Color(0xFF3B82F6), // 聚焦时高亮边框
                    width: 1.5,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),

            // 中间的编码解码按钮
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                MElevatedButton(
                  icon: Icons.lock,
                  iconColor: Colors.white,
                  text: "编码",
                  textColor: Colors.white,
                  onPressed: _baseEncoding,
                ),
                SizedBox(width: 20),
                MElevatedButton(
                  icon: Icons.lock_open,
                  iconColor: Colors.white,
                  text: "解码",
                  textColor: Colors.white,
                  onPressed: _baseDecoding,
                ),
                SizedBox(width: 20),
                MElevatedButton(
                  icon: Icons.sync_outlined,
                  iconColor: Colors.white,
                  text: "交换",
                  textColor: Colors.white,
                  onPressed: () => {
                    swapTextTemp = inputController.text,
                    inputController.text = outputController.text,
                    outputController.text = swapTextTemp,
                  },
                ),
              ],
            ),
            SizedBox(height: 20),

            // 输出框标题
            Row(
              children: [
                Text(
                  "输出框 (OUTPUT)",
                  style: TextStyle(color: Color(0xFF9497A0), fontSize: 16),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Color(0xFF0C312D),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.all(5),
                  child: Text(
                    "READY",
                    style: TextStyle(color: Color(0xFF0F9F6D)),
                  ),
                ),
                Spacer(),

                // 复制按钮
                MElevatedButton(
                  icon: Icons.copy,
                  text: "复制",
                  onPressed: () => {_copyText(outputController.text)},
                ),
                const SizedBox(width: 12),
                // 导出文件按钮
                MElevatedButton(
                  icon: Icons.file_copy,
                  text: "导出到文件",
                  onPressed: () => {},
                ),
                const SizedBox(width: 12),
                // 清空按钮
                MElevatedButton(
                  icon: Icons.delete,
                  text: "清空",
                  onPressed: () => {_clear()},
                ),
              ],
            ),
            SizedBox(height: 20),

            //输出框
            Expanded(
              child: TextField(
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                textAlign: TextAlign.start,
                controller: outputController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Color(0xFF0F17AA)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: Color(0xFF3B82F6), // 聚焦时高亮边框
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),
          ],
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
      showToast("无内容可清空喵",context);
      return;
    }
    inputController.clear();
    outputController.clear();
    showToast("已清空喵",context);
  }

  /// 复制文本
  Future<void> _copyText(String text) async {
    if (text.isEmpty) {
      showToast("无内容可复制喵",context);
      return;
    }
    await Clipboard.setData(ClipboardData(text: text));
    if(!mounted) return;
    showToast("复制成功喵",context);
  }
}
