import 'package:flutter/material.dart';
import 'package:ctf_tools/shared/widgets/code_editor.dart';
import 'dart:convert';

class BaseVariantCodecScreen extends StatefulWidget {
  const BaseVariantCodecScreen({super.key});

  @override
  State<BaseVariantCodecScreen> createState() => _BaseVariantCodecScreenState();
}

class _BaseVariantCodecScreenState extends State<BaseVariantCodecScreen> {
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _outputController = TextEditingController();
  String _baseType = 'base64';
  String _mode = 'encode';

  final base16Encoder = Base16Codec();
  final base32Encoder = Base32Codec();

  String _encodeBase16(String input) {
    final bytes = utf8.encode(input);
    return base16Encoder.encode(bytes);
  }

  String _decodeBase16(String input) {
    final bytes = base16Encoder.decode(input.toUpperCase());
    return utf8.decode(bytes);
  }

  String _encodeBase32(String input) {
    final bytes = utf8.encode(input);
    return base32Encoder.encode(bytes);
  }

  String _decodeBase32(String input) {
    final bytes = base32Encoder.decode(input.toUpperCase());
    return utf8.decode(bytes);
  }

  String _encodeBase64(String input, bool urlSafe) {
    final bytes = utf8.encode(input);
    String encoded = base64.encode(bytes);
    if (urlSafe) {
      encoded = encoded.replaceAll('+', '-').replaceAll('/', '_');
    }
    return encoded;
  }

  String _decodeBase64(String input, bool urlSafe) {
    String normalized = input;
    if (urlSafe) {
      normalized = normalized.replaceAll('-', '+').replaceAll('_', '/');
    }
    // 添加填充
    while (normalized.length % 4 != 0) {
      normalized += '=';
    }
    final bytes = base64.decode(normalized);
    return utf8.decode(bytes);
  }

  void _process() {
    try {
      String input = _inputController.text.trim();
      String result = '';

      switch (_baseType) {
        case 'base16':
          result = _mode == 'encode'
              ? _encodeBase16(input)
              : _decodeBase16(input);
          break;
        case 'base32':
          result = _mode == 'encode'
              ? _encodeBase32(input)
              : _decodeBase32(input);
          break;
        case 'base64':
          result = _mode == 'encode'
              ? _encodeBase64(input, false)
              : _decodeBase64(input, false);
          break;
        case 'base64url':
          result = _mode == 'encode'
              ? _encodeBase64(input, true)
              : _decodeBase64(input, true);
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

  void _clear() {
    setState(() {
      _inputController.clear();
      _outputController.clear();
    });
  }

  void _copyOutput() {
    if (_outputController.text.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('已复制到剪贴板'),
          duration: Duration(seconds: 1),
        ),
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
                    'Base 系列编码变体',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '支持 Base16 (Hex)、Base32、Base64 和 Base64Url 编码，适用于不同场景。',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _baseType,
                          decoration: const InputDecoration(
                            labelText: '编码类型',
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'base16',
                              child: Text('Base16 (Hex)'),
                            ),
                            DropdownMenuItem(
                              value: 'base32',
                              child: Text('Base32'),
                            ),
                            DropdownMenuItem(
                              value: 'base64',
                              child: Text('Base64'),
                            ),
                            DropdownMenuItem(
                              value: 'base64url',
                              child: Text('Base64Url'),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _baseType = value!;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _mode,
                          decoration: const InputDecoration(
                            labelText: '模式',
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'encode',
                              child: Text('编码'),
                            ),
                            DropdownMenuItem(
                              value: 'decode',
                              child: Text('解码'),
                            ),
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
          CodeEditor(controller: _inputController, label: '输入', height: 200),
          const SizedBox(height: 16),
          Center(
            child: ElevatedButton.icon(
              onPressed: _process,
              icon: Icon(_mode == 'encode' ? Icons.lock : Icons.lock_open),
              label: Text(_mode == 'encode' ? '编码' : '解码'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 48,
                  vertical: 16,
                ),
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

class Base16Codec {
  String encode(List<int> bytes) {
    return bytes
        .map((b) => b.toRadixString(16).toUpperCase().padLeft(2, '0'))
        .join();
  }

  List<int> decode(String input) {
    final cleaned = input.replaceAll(' ', '').toUpperCase();
    final bytes = <int>[];
    for (var i = 0; i < cleaned.length; i += 2) {
      bytes.add(int.parse(cleaned.substring(i, i + 2), radix: 16));
    }
    return bytes;
  }
}

class Base32Codec {
  String encode(List<int> bytes) {
    const alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';
    var result = '';
    var buffer = 0;
    var bitsLeft = 0;

    for (var byte in bytes) {
      buffer = (buffer << 8) | byte;
      bitsLeft += 8;

      while (bitsLeft >= 5) {
        bitsLeft -= 5;
        result += alphabet[(buffer >> bitsLeft) & 0x1F];
      }
    }

    if (bitsLeft > 0) {
      result += alphabet[(buffer << (5 - bitsLeft)) & 0x1F];
    }

    while (result.length % 8 != 0) {
      result += '=';
    }

    return result;
  }

  List<int> decode(String input) {
    const alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';
    final cleaned = input.replaceAll('=', '').toUpperCase();

    var buffer = 0;
    var bitsLeft = 0;
    final bytes = <int>[];

    for (var char in cleaned.split('')) {
      final index = alphabet.indexOf(char);
      if (index == -1) continue;

      buffer = (buffer << 5) | index;
      bitsLeft += 5;

      if (bitsLeft >= 8) {
        bitsLeft -= 8;
        bytes.add((buffer >> bitsLeft) & 0xFF);
      }
    }

    return bytes;
  }
}
