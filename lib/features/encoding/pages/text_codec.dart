import 'package:ctf_tools/features/encoding/utils/text_encoding/text_codec.dart';
import 'package:ctf_tools/features/encoding/utils/text_encoding/text_list.dart';
import 'package:ctf_tools/shared/widgets/dropdown_menu.dart';
import 'package:ctf_tools/shared/widgets/mbutton.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TextEncodingScreen extends StatefulWidget {
  const TextEncodingScreen({super.key});

  @override
  State<TextEncodingScreen> createState() => _TextEncodingScreen();
}

class _TextEncodingScreen extends State<TextEncodingScreen> {
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
                  "文本 编码/解码",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFFE1D4),
                  ),
                ),
                const SizedBox(width: 26),

                // Base编码切换按钮
                Text(
                  "编码/解码选择",
                  style: TextStyle(color: Color(0xFF9497A0), fontSize: 16),
                ),
                const SizedBox(width: 6),
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
                  onPressed: _encode,
                ),
                SizedBox(width: 20),
                MElevatedButton(
                  icon: Icons.lock_open,
                  iconColor: Colors.white,
                  text: "解码",
                  textColor: Colors.white,
                  onPressed: _decode,
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF2B5EC9),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
