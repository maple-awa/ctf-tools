import 'package:flutter/material.dart';
import 'package:ctf_tools/shared/widgets/code_editor.dart';

class EscapeCodecScreen extends StatefulWidget {
  const EscapeCodecScreen({super.key});

  @override
  State<EscapeCodecScreen> createState() => _EscapeCodecScreenState();
}

class _EscapeCodecScreenState extends State<EscapeCodecScreen> {
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _outputController = TextEditingController();
  String _escapeType = 'encodeURI';

  String _encodeURI(String input) {
    // 不编码 ASCII 字母数字字符和 - _ . ! ~ * ' ( )
    return input.replaceAllMapped(
      RegExp(r'[^a-zA-Z0-9\-_.!~*'()"@#\$&*+,;=/:?%\[\]{}]'),
      (match) {
        final char = match.group(0)!;
        return char.codeUnits.map((c) => '%${c.toRadixString(16).toUpperCase().padLeft(2, '0')}').join();
      },
    );
  }

  String _decodeURI(String input) {
    try {
      final regex = RegExp(r'%([0-9A-Fa-f]{2})');
      return input.replaceAllMapped(regex, (match) {
        final byte = int.parse(match.group(1)!, radix: 16);
        return String.fromCharCode(byte);
      });
    } catch (e) {
      return '解码失败：${e.toString()}';
    }
  }

  String _encodeURI_Component(String input) {
    // 编码除了 ASCII 字母数字字符和 - _ . ! ~ * ' ( ) 之外的所有字符
    return input.replaceAllMapped(
      RegExp(r'[^a-zA-Z0-9\-_.!~*'()]'),
      (match) {
        final char = match.group(0)!;
        return char.codeUnits.map((c) => '%${c.toRadixString(16).toUpperCase().padLeft(2, '0')}').join();
      },
    );
  }

  String _decodeURI_Component(String input) {
    try {
      final regex = RegExp(r'%([0-9A-Fa-f]{2})');
      return input.replaceAllMapped(regex, (match) {
        final byte = int.parse(match.group(1)!, radix: 16);
        return String.fromCharCode(byte);
      });
    } catch (e) {
      return '解码失败：${e.toString()}';
    }
  }

  String _encodeJavaScript(String input) {
    // JavaScript escape 编码
    return input.replaceAllMapped(
      RegExp(r'[^\x00-\x7F]|\\|\'|\"'),
      (match) {
        final char = match.group(0)!;
        final code = char.codeUnitAt(0);
        if (code > 127) {
          return '\\x${code.toRadixString(16).toUpperCase().padLeft(2, '0')}';
        } else if (char == '\\') {
          return '\\\\';
        } else if (char == '\'') {
          return '\\\'';
        } else if (char == '\"') {
          return '\\\"';
        }
        return char;
      },
    );
  }

  String _decodeJavaScript(String input) {
    try {
      String result = input;
      // 解码 \xHH
      result = result.replaceAllMapped(
        RegExp(r'\\x([0-9A-Fa-f]{2})'),
        (match) => String.fromCharCode(int.parse(match.group(1)!, radix: 16)),
      );
      // 解码转义字符
      result = result.replaceAll('\\\\', '\\')
                      .replaceAll("\\'", "'")
                      .replaceAll('\\"', '"');
      return result;
    } catch (e) {
      return '解码失败：${e.toString()}';
    }
  }

  void _process() {
    try {
      String input = _inputController.text;
      String result = '';

      switch (_escapeType) {
        case 'encodeURI':
          result = _mode == 'encode' ? _encodeURI(input) : _decodeURI(input);
          break;
        case 'encodeURIComponent':
          result = _mode == 'encode' ? _encodeURI_Component(input) : _decodeURI_Component(input);
          break;
        case 'escape':
          result = _mode == 'encode' ? _encodeJavaScript(input) : _decodeJavaScript(input);
          break;
      }

      setState(() {
        _outputController.text = result;
      });
    } catch (e) {
      setState(() {
        _outputController.text = '操作失败：${e.toString()}';
      });
    }
  }

  String _mode = 'encode';

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
                    'Escape/Unescape 编码',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'JavaScript 风格的 Escape 编码，支持 encodeURI、encodeURIComponent 和 escape 格式。',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _escapeType,
                          decoration: const InputDecoration(
                            labelText: '编码类型',
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'encodeURI', child: Text('encodeURI')),
                            DropdownMenuItem(value: 'encodeURIComponent', child: Text('encodeURIComponent')),
                            DropdownMenuItem(value: 'escape', child: Text('escape (Legacy)')),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _escapeType = value!;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _mode,
                          decoration: const InputDecoration(
                            labelText: '模式',
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'encode', child: Text('编码')),
                            DropdownMenuItem(value: 'decode', child: Text('解码')),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _mode = value!;
                            });
                          },
                        ),
                      ),
                    ],
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
          Center(
            child: ElevatedButton.icon(
              onPressed: _process,
              icon: Icon(_mode == 'encode' ? Icons.lock : Icons.lock_open),
              label: Text(_mode == 'encode' ? '编码' : '解码'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
              ),
            ),
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
