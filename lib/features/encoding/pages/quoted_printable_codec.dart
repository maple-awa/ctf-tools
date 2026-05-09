import 'package:flutter/material.dart';
import 'package:ctf_tools/shared/widgets/code_editor.dart';
import 'dart:convert';

class QuotedPrintableCodecScreen extends StatefulWidget {
  const QuotedPrintableCodecScreen({super.key});

  @override
  State<QuotedPrintableCodecScreen> createState() => _QuotedPrintableCodecScreenState();
}

class _QuotedPrintableCodecScreenState extends State<QuotedPrintableCodecScreen> {
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _outputController = TextEditingController();
  String _charset = 'utf-8';

  String _encodeQuotedPrintable(String input) {
    final bytes = utf8.encode(input);
    final buffer = StringBuffer();
    
    for (var byte in bytes) {
      // 可打印 ASCII 字符（除了 =）
      if (byte >= 33 && byte <= 60 || byte >= 62 && byte <= 126) {
        buffer.write(String.fromCharCode(byte));
      } else if (byte == 32 || byte == 9) { // 空格或制表符
        // 行尾的空格需要编码
        buffer.write(String.fromCharCode(byte));
      } else {
        // 其他字符编码为 =XX
        buffer.write('=${byte.toRadixString(16).toUpperCase().padLeft(2, '0')}');
      }
    }
    
    return buffer.toString();
  }

  String _decodeQuotedPrintable(String input) {
    try {
      // 移除软换行（= 后跟换行符）
      String normalized = input.replaceAll('=\n', '').replaceAll('=\r\n', '');
      
      // 解码 =XX 格式
      final bytes = <int>[];
      final regex = RegExp(r'=([0-9A-Fa-f]{2})');
      int pos = 0;
      
      while (pos < normalized.length) {
        if (normalized[pos] == '=') {
          final match = regex.firstMatch(normalized.substring(pos));
          if (match != null) {
            bytes.add(int.parse(match.group(1)!, radix: 16));
            pos += 3;
          } else {
            bytes.add(utf8.encode('=')[0]);
            pos++;
          }
        } else {
          bytes.add(normalized.codeUnitAt(pos));
          pos++;
        }
      }
      
      return utf8.decode(bytes, allowMalformed: true);
    } catch (e) {
      return '解码失败：${e.toString()}';
    }
  }

  void _encode() {
    try {
      String input = _inputController.text;
      String encoded = _encodeQuotedPrintable(input);
      setState(() {
        _outputController.text = encoded;
      });
    } catch (e) {
      setState(() {
        _outputController.text = '编码失败：${e.toString()}';
      });
    }
  }

  void _decode() {
    String input = _inputController.text;
    String decoded = _decodeQuotedPrintable(input);
    setState(() {
      _outputController.text = decoded;
    });
  }

  void _clear() {
    setState(() {
      _inputController.clear();
      _outputController.clear();
    });
  }

  void _copyOutput() {
    if (_outputController.text.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('已复制到剪贴板'), duration: Duration(seconds: 1)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quoted-Printable 编码/解码',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Quoted-Printable 是一种用于邮件传输的编码方式，适合编码包含少量非 ASCII 字符的文本。',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _clear,
                        icon: const Icon(Icons.clear),
                        label: const Text('清空'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: _copyOutput,
                        icon: const Icon(Icons.content_copy),
                        label: const Text('复制'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          CodeEditor(
            controller: _inputController,
            label: '输入',
            height: 200,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: _encode,
                icon: const Icon(Icons.lock),
                label: const Text('编码'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: _decode,
                icon: const Icon(Icons.lock_open),
                label: const Text('解码'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          CodeEditor(
            controller: _outputController,
            label: '输出',
            height: 200,
            readOnly: true,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _inputController.dispose();
    _outputController.dispose();
    super.dispose();
  }
}
