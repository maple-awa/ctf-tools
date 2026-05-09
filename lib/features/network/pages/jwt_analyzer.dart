import 'package:flutter/material.dart';
import 'package:ctf_tools/shared/widgets/code_editor.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart' as crypto_lib;

class JWTAnalyzerScreen extends StatefulWidget {
  const JWTAnalyzerScreen({super.key});

  @override
  State<JWTAnalyzerScreen> createState() => _JWTAnalyzerScreenState();
}

class _JWTAnalyzerScreenState extends State<JWTAnalyzerScreen> {
  final TextEditingController _jwtController = TextEditingController();
  final TextEditingController _secretController = TextEditingController();
  final TextEditingController _outputController = TextEditingController();
  String _operation = 'decode';

  Map<String, dynamic>? _decodedHeader;
  Map<String, dynamic>? _decodedPayload;
  String? _signature;

  void _decodeJWT() {
    try {
      final token = _jwtController.text.trim();
      final parts = token.split('.');

      if (parts.length != 3) {
        setState(() {
          _outputController.text = '无效的 JWT 格式：应该包含 3 个部分';
        });
        return;
      }

      final header = parts[0];
      final payload = parts[1];
      final signature = parts[2];

      String decodeBase64Url(String input) {
        String normalized = input.replaceAll('-', '+').replaceAll('_', '/');
        while (normalized.length % 4 != 0) {
          normalized += '=';
        }
        return utf8.decode(base64Url.decode(normalized));
      }

      final headerJson = decodeBase64Url(header);
      final payloadJson = decodeBase64Url(payload);

      _decodedHeader = jsonDecode(headerJson);
      _decodedPayload = jsonDecode(payloadJson);
      _signature = signature;

      final buffer = StringBuffer();
      buffer.writeln('=== JWT 解码结果 ===\n');
      buffer.writeln('【Header】');
      buffer.writeln(
        const JsonEncoder.withIndent('  ').convert(_decodedHeader),
      );
      buffer.writeln('\n【Payload】');
      buffer.writeln(
        const JsonEncoder.withIndent('  ').convert(_decodedPayload),
      );
      buffer.writeln('\n【Signature】');
      buffer.writeln(_signature);

      buffer.writeln('\n=== 分析 ===');
      final alg = _decodedHeader?['alg'];
      final typ = _decodedHeader?['typ'];
      buffer.writeln('算法：$alg');
      buffer.writeln('类型：$typ');

      if (alg == 'none' || alg == 'None' || alg == 'NONE') {
        buffer.writeln('\n⚠️ 警告：使用 none 算法，可能存在安全漏洞！');
      }

      if (_decodedPayload != null) {
        final exp = _decodedPayload?['exp'];
        if (exp != null) {
          final expDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
          final isExpired = expDate.isBefore(DateTime.now());
          buffer.writeln('\n过期时间：${expDate.toIso8601String()}');
          buffer.writeln(isExpired ? '状态：已过期' : '状态：未过期');
        }
      }

      setState(() {
        _outputController.text = buffer.toString();
      });
    } catch (e) {
      setState(() {
        _outputController.text = '解码失败：${e.toString()}';
      });
    }
  }

  void _forgeJWT() {
    try {
      final secret = _secretController.text;
      var header = _decodedHeader ?? {'alg': 'HS256', 'typ': 'JWT'};
      var payload =
          _decodedPayload ??
          {'sub': '1234567890', 'name': 'John Doe', 'iat': 1516239022};

      header['alg'] = 'HS256';

      String base64UrlEncodeBytes(List<int> input) {
        return base64Url.encode(input).replaceAll('=', '');
      }

      final headerEncoded = base64UrlEncodeBytes(
        utf8.encode(jsonEncode(header)),
      );
      final payloadEncoded = base64UrlEncodeBytes(
        utf8.encode(jsonEncode(payload)),
      );

      final signingInput = '$headerEncoded.$payloadEncoded';

      final key = utf8.encode(secret.isEmpty ? 'secret' : secret);
      final hmac = crypto_lib.Hmac(crypto_lib.sha256, key);
      final digest = hmac.convert(utf8.encode(signingInput));
      final signature = base64UrlEncodeBytes(digest.bytes);

      final forgedToken = '$headerEncoded.$payloadEncoded.$signature';

      setState(() {
        _outputController.text =
            '=== 伪造的 JWT ===\n\n$forgedToken\n\n=== Payload ===\n${const JsonEncoder.withIndent('  ').convert(payload)}';
      });
    } catch (e) {
      setState(() {
        _outputController.text = '伪造失败：${e.toString()}';
      });
    }
  }

  void _process() {
    if (_operation == 'decode') {
      _decodeJWT();
    } else {
      _forgeJWT();
    }
  }

  void _clear() {
    setState(() {
      _jwtController.clear();
      _secretController.clear();
      _outputController.clear();
      _decodedHeader = null;
      _decodedPayload = null;
      _signature = null;
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
                    'JWT 分析工具',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '解码 JWT Token，分析其结构和内容，支持伪造和签名爆破。',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _operation,
                          decoration: const InputDecoration(
                            labelText: '操作',
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'decode',
                              child: Text('解码/分析'),
                            ),
                            DropdownMenuItem(
                              value: 'forge',
                              child: Text('伪造 Token'),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _operation = value!;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  if (_operation == 'forge') ...[
                    const SizedBox(height: 16),
                    TextField(
                      controller: _secretController,
                      decoration: const InputDecoration(
                        labelText: '密钥 (Secret)',
                        border: OutlineInputBorder(),
                        helperText: '用于签名伪造的 JWT',
                      ),
                    ),
                  ],
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
            controller: _jwtController,
            label: 'JWT Token',
            height: 120,
          ),
          const SizedBox(height: 16),
          Center(
            child: ElevatedButton.icon(
              onPressed: _process,
              icon: Icon(_operation == 'decode' ? Icons.search : Icons.edit),
              label: Text(_operation == 'decode' ? '解码' : '伪造'),
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
            label: '分析结果',
            height: 300,
            readOnly: true,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _jwtController.dispose();
    _secretController.dispose();
    _outputController.dispose();
    super.dispose();
  }
}
