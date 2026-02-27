import 'dart:convert';
import 'package:ctf_tools/features/network/utils/whois_util.dart';
import 'package:ctf_tools/shared/widgets/mbutton.dart';
import 'package:ctf_tools/shared/widgets/show_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:whois/whois.dart';

class WhoisScreen extends StatefulWidget {
  const WhoisScreen({super.key});

  @override
  State<WhoisScreen> createState() => _WhoisScreen();
}

class _WhoisScreen extends State<WhoisScreen> {
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
      color: Color(0xFF101622),
      child: Padding(
        padding: EdgeInsetsGeometry.all(20),
        child: Column(
          children: [
            // 输入框标题
            Row(
              children: [
                Text(
                  "域名 (DOMAIN)",
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
                    "INPUT",
                    style: TextStyle(color: Color(0xFF2B64D1)),
                  ),
                ),
                Spacer(),
              ],
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Flexible(
                  child: TextField(
                    controller: inputController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: '输入想要查询的域名...',
                      prefixIcon: Icon(Icons.search),
                      suffixIcon: inputController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear),
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
                SizedBox(width: 20),
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
                    "RAW OUTPUT",
                    style: TextStyle(color: Color(0xFF0F9F6D)),
                  ),
                ),
                const SizedBox(width: 12),
                Switch(
                  value: isRawMode,
                  activeThumbColor: Colors.blueAccent, // 开关开启时的滑块颜色
                  activeTrackColor: Colors.blueAccent[1], // 开关开启时的轨道颜色
                  inactiveThumbColor: Colors.grey, // 开关关闭时的滑块颜色
                  inactiveTrackColor: Colors.black, // 开关关闭时的轨道颜色
                  onChanged: (value) {
                    setState(() {
                      isRawMode = value;
                    });
                  },
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
