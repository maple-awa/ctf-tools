import 'package:flutter/material.dart';
import 'package:ctf_tools/shared/widgets/code_editor.dart';
import 'dart:convert';

class UrlCodecScreen extends StatefulWidget {
  const UrlCodecScreen({super.key});

  @override
  State<UrlCodecScreen> createState() => _UrlCodecScreenState();
}

class _UrlCodecScreenState extends State<UrlCodecScreen> {
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _outputController = TextEditingController();
  bool _isDoubleEncode = false;
  bool _isEncoded = false;

  void _encode() {
    String input = _inputController.text;
    String encoded = Uri.encodeComponent(input);
    
    if (_isDoubleEncode) {
      encoded = Uri.encodeComponent(encoded);
    }
    
    setState(() {
      _outputController.text = encoded;
      _isEncoded = true;
    });
  }

  void _decode() {
    try {
      String input = _inputController.text;
      String decoded = Uri.decodeComponent(input);
      
      if (_isDoubleEncode && _isEncoded) {
        decoded = Uri.decodeComponent(decoded);
      }
      
      setState(() {
        _outputController.text = decoded;
        _isEncoded = false;
      });
    } catch (e) {
      setState(() {
        _outputController.text = '解码失败：${e.toString()}';
      });
    }
  }

  void _clear() {
    setState(() {
      _inputController.clear();
      _outputController.clear();
      _isEncoded = false;
    });
  }

  void _copyOutput() {
    if (_outputController.text.isNotEmpty) {
      // Clipboard.setData(ClipboardData(text: _outputController.text));
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
                    'URL 编码/解码',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'URL 编码用于在 URL 中传输特殊字符，支持双重编码模式。',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Checkbox(
                        value: _isDoubleEncode,
                        onChanged: (value) {
                          setState(() {
                            _isDoubleEncode = value ?? false;
                          });
                        },
                      ),
                      const Text('双重编码/解码'),
                      const Spacer(),
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
