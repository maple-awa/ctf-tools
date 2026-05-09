import 'package:flutter/material.dart';
import 'package:ctf_tools/shared/widgets/code_editor.dart';

class HtmlEntityCodecScreen extends StatefulWidget {
  const HtmlEntityCodecScreen({super.key});

  @override
  State<HtmlEntityCodecScreen> createState() => _HtmlEntityCodecScreenState();
}

class _HtmlEntityCodecScreenState extends State<HtmlEntityCodecScreen> {
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _outputController = TextEditingController();
  String _entityType = 'named'; // named, decimal, hexadecimal

  final Map<String, String> _htmlEntities = {
    '<': '&lt;',
    '>': '&gt;',
    '&': '&amp;',
    '"': '&quot;',
    "'": '&apos;',
    ' ': '&nbsp;',
    '©': '&copy;',
    '®': '&reg;',
    '™': '&trade;',
    '€': '&euro;',
    '£': '&pound;',
    '¥': '&yen;',
    '¢': '&cent;',
    '±': '&plusmn;',
    '×': '&times;',
    '÷': '&divide;',
    '«': '&laquo;',
    '»': '&raquo;',
    '—': '&mdash;',
    '–': '&ndash;',
    '…': '&hellip;',
    '"': '&ldquo;',
    '"': '&rdquo;',
    ''': '&lsquo;',
    ''': '&rsquo;',
  };

  void _encode() {
    String input = _inputController.text;
    String encoded = input;

    switch (_entityType) {
      case 'named':
        _htmlEntities.forEach((char, entity) {
          encoded = encoded.replaceAll(char, entity);
        });
        break;
      case 'decimal':
        encoded = input.codeUnits.map((c) => '&#$c;').join();
        break;
      case 'hexadecimal':
        encoded = input.codeUnits.map((c) => '&#x${c.toRadixString(16).toUpperCase()};').join();
        break;
    }

    setState(() {
      _outputController.text = encoded;
    });
  }

  void _decode() {
    String input = _inputController.text;
    String decoded = input;

    switch (_entityType) {
      case 'named':
        _htmlEntities.forEach((char, entity) {
          decoded = decoded.replaceAll(entity, char);
        });
        // 也尝试反向替换
        _htmlEntities.forEach((char, entity) {
          decoded = decoded.replaceAll(entity.toLowerCase(), char);
        });
        break;
      case 'decimal':
        final regex = RegExp(r'&#(\d+);');
        decoded = decoded.replaceAllMapped(regex, (match) {
          return String.fromCharCode(int.parse(match.group(1)!));
        });
        break;
      case 'hexadecimal':
        final regex = RegExp(r'&#x([0-9A-Fa-f]+);');
        decoded = decoded.replaceAllMapped(regex, (match) {
          return String.fromCharCode(int.parse(match.group(1)!, radix: 16));
        });
        break;
    }

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
                    'HTML 实体编码/解码',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'HTML 实体编码用于在 HTML 中表示特殊字符，支持命名实体、十进制和十六进制格式。',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _entityType,
                    decoration: const InputDecoration(
                      labelText: '实体类型',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'named', child: Text('命名实体 (&lt; &gt; &amp;)')),
                      DropdownMenuItem(value: 'decimal', child: Text('十进制 (&#60; &#62; &#38;)')),
                      DropdownMenuItem(value: 'hexadecimal', child: Text('十六进制 (&#x3C; &#x3E; &#x26;)')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _entityType = value!;
                      });
                    },
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
