import 'dart:convert';

import 'package:ctf_tools/features/crypto/utils/analysis_tools.dart';
import 'package:ctf_tools/features/crypto/utils/jwt_toolkit.dart';
import 'package:ctf_tools/features/crypto/utils/pem_der_codec.dart';
import 'package:ctf_tools/features/crypto/utils/xor_codec.dart';
import 'package:ctf_tools/shared/widgets/mbutton.dart';
import 'package:ctf_tools/shared/widgets/show_toast.dart';
import 'package:ctf_tools/shared/widgets/tool_page_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class XorAnalysisScreen extends StatefulWidget {
  const XorAnalysisScreen({super.key});

  @override
  State<XorAnalysisScreen> createState() => _XorAnalysisScreenState();
}

class _XorAnalysisScreenState extends State<XorAnalysisScreen> {
  final keyController = TextEditingController(text: 'key');
  final inputController = TextEditingController();
  final outputController = TextEditingController();
  final jwtSecretController = TextEditingController(text: 'ctf-tools');
  final jwtHeaderController = TextEditingController(text: '{"alg":"HS256","typ":"JWT"}');
  final jwtPayloadController = TextEditingController(text: '{"sub":"flag","admin":true}');
  final pemDerController = TextEditingController();

  @override
  void dispose() {
    keyController.dispose();
    inputController.dispose();
    outputController.dispose();
    jwtSecretController.dispose();
    jwtHeaderController.dispose();
    jwtPayloadController.dispose();
    pemDerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: ToolPageShell(
        title: '密码分析',
        description: '收敛 XOR、字频/替换分析、JWT 操作以及 PEM/DER 转换。',
        badge: 'Crypto',
        child: Column(
          children: [
            Card(
              child: const TabBar(
                isScrollable: true,
                tabs: [
                  Tab(icon: Icon(Icons.hexagon), text: 'XOR'),
                  Tab(icon: Icon(Icons.sort_by_alpha), text: '字频/替换'),
                  Tab(icon: Icon(Icons.vpn_key_outlined), text: 'JWT'),
                  Tab(icon: Icon(Icons.key), text: 'PEM/DER'),
                ],
              ),
            ),
            const SizedBox(height: kToolSectionGap),
            SizedBox(
              height: 860,
              child: TabBarView(
                children: [
                  _buildXorTab(),
                  _buildFrequencyTab(),
                  _buildJwtTab(),
                  _buildPemDerTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildXorTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          ToolSectionCard(
            title: 'XOR 参数',
            child: TextField(
              controller: keyController,
              decoration: const InputDecoration(labelText: '重复密钥', border: OutlineInputBorder()),
            ),
          ),
          const SizedBox(height: 12),
          ToolSectionCard(
            title: '输入',
            child: TextField(
              controller: inputController,
              maxLines: 8,
              decoration: const InputDecoration(hintText: '可输入原始文本，或输入十六进制字节流做解码/爆破', border: OutlineInputBorder()),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            runSpacing: 10,
            children: [
              MElevatedButton(icon: Icons.text_fields, text: '文本 XOR', onPressed: _xorText),
              MElevatedButton(icon: Icons.hexagon, text: '输出 HEX', onPressed: _xorHex),
              MElevatedButton(icon: Icons.lock_open, text: 'HEX 解码', onPressed: _decodeHex),
              MElevatedButton(icon: Icons.auto_awesome, text: '单字节爆破', onPressed: _bruteforceXor),
              MElevatedButton(icon: Icons.copy, text: '复制输出', onPressed: () => _copyText(outputController.text)),
            ],
          ),
          const SizedBox(height: 12),
          ToolSectionCard(
            title: '输出',
            child: TextField(controller: outputController, maxLines: 12, decoration: const InputDecoration(border: OutlineInputBorder())),
          ),
        ],
      ),
    );
  }

  Widget _buildFrequencyTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          ToolSectionCard(
            title: '字频 / 单表替换输入',
            child: TextField(controller: inputController, maxLines: 12, decoration: const InputDecoration(border: OutlineInputBorder())),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              MElevatedButton(icon: Icons.bar_chart, text: '字频分析', onPressed: _frequencyAnalyze),
              MElevatedButton(icon: Icons.swap_calls, text: '替换建议', onPressed: _suggestSubstitution),
            ],
          ),
          const SizedBox(height: 12),
          ToolSectionCard(title: '输出', child: TextField(controller: outputController, maxLines: 14, decoration: const InputDecoration(border: OutlineInputBorder()))),
        ],
      ),
    );
  }

  Widget _buildJwtTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          ToolSectionCard(
            title: 'JWT Token / Header / Payload',
            child: Column(
              children: [
                TextField(controller: inputController, maxLines: 4, decoration: const InputDecoration(labelText: 'JWT Token', border: OutlineInputBorder())),
                const SizedBox(height: 8),
                TextField(controller: jwtHeaderController, maxLines: 4, decoration: const InputDecoration(labelText: 'Header JSON', border: OutlineInputBorder())),
                const SizedBox(height: 8),
                TextField(controller: jwtPayloadController, maxLines: 6, decoration: const InputDecoration(labelText: 'Payload JSON', border: OutlineInputBorder())),
                const SizedBox(height: 8),
                TextField(controller: jwtSecretController, decoration: const InputDecoration(labelText: 'Secret', border: OutlineInputBorder())),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              MElevatedButton(icon: Icons.visibility, text: '解析', onPressed: _decodeJwt),
              MElevatedButton(icon: Icons.lock, text: 'HS256 重签', onPressed: _encodeJwtHs256),
              MElevatedButton(icon: Icons.no_accounts, text: 'none Token', onPressed: _encodeJwtNone),
              MElevatedButton(icon: Icons.verified, text: '校验', onPressed: _verifyJwt),
            ],
          ),
          const SizedBox(height: 12),
          ToolSectionCard(title: '输出', child: TextField(controller: outputController, maxLines: 14, decoration: const InputDecoration(border: OutlineInputBorder()))),
        ],
      ),
    );
  }

  Widget _buildPemDerTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          ToolSectionCard(
            title: 'PEM / DER',
            child: TextField(controller: pemDerController, maxLines: 14, decoration: const InputDecoration(hintText: '粘贴 PEM 或 DER Hex', border: OutlineInputBorder())),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              MElevatedButton(icon: Icons.file_present, text: 'PEM -> DER Hex', onPressed: _pemToDer),
              MElevatedButton(icon: Icons.file_open, text: 'DER Hex -> PEM', onPressed: _derToPem),
            ],
          ),
          const SizedBox(height: 12),
          ToolSectionCard(title: '输出', child: TextField(controller: outputController, maxLines: 14, decoration: const InputDecoration(border: OutlineInputBorder()))),
        ],
      ),
    );
  }

  void _xorText() => _run(() => XorCodec.xorText(inputController.text, keyController.text));

  void _xorHex() => _run(() => XorCodec.xorToHex(inputController.text, keyController.text));

  void _decodeHex() => _run(() => XorCodec.decodeHex(inputController.text, keyController.text));

  void _bruteforceXor() {
    _run(() {
      final candidates = CryptoAnalysisTools.bruteForceSingleByte(inputController.text);
      return candidates.map((candidate) => '${candidate.key} [${candidate.score.toStringAsFixed(2)}]\n${candidate.preview}').join('\n\n');
    });
  }

  void _frequencyAnalyze() {
    _run(() => CryptoAnalysisTools.frequencyAnalysis(inputController.text));
  }

  void _suggestSubstitution() {
    _run(() => CryptoAnalysisTools.suggestSubstitution(inputController.text));
  }

  void _decodeJwt() {
    _run(() {
      final result = JwtToolkit.decode(inputController.text, secret: jwtSecretController.text);
      jwtHeaderController.text = const JsonEncoder.withIndent('  ').convert(result.header);
      jwtPayloadController.text = const JsonEncoder.withIndent('  ').convert(result.payload);
      return [
        'Header:',
        const JsonEncoder.withIndent('  ').convert(result.header),
        '',
        'Payload:',
        const JsonEncoder.withIndent('  ').convert(result.payload),
        '',
        'Signature: ${result.signature}',
        if (result.verified != null) 'Verified: ${result.verified}',
      ].join('\n');
    });
  }

  void _encodeJwtHs256() {
    _run(() {
      final token = JwtToolkit.encode(
        header: json.decode(jwtHeaderController.text) as Map<String, dynamic>,
        payload: json.decode(jwtPayloadController.text) as Map<String, dynamic>,
        algorithm: 'HS256',
        secret: jwtSecretController.text,
      );
      inputController.text = token;
      return token;
    });
  }

  void _encodeJwtNone() {
    _run(() {
      final token = JwtToolkit.encode(
        header: json.decode(jwtHeaderController.text) as Map<String, dynamic>,
        payload: json.decode(jwtPayloadController.text) as Map<String, dynamic>,
        algorithm: 'none',
      );
      inputController.text = token;
      return token;
    });
  }

  void _verifyJwt() {
    _run(() => 'Verified: ${JwtToolkit.verify(inputController.text, jwtSecretController.text)}');
  }

  void _pemToDer() {
    _run(() => PemDerCodec.pemToDerHex(pemDerController.text));
  }

  void _derToPem() {
    _run(() => PemDerCodec.derHexToPem(pemDerController.text));
  }

  void _run(String Function() action) {
    try {
      outputController.text = action();
      setState(() {});
    } catch (error) {
      showToast('处理失败: $error', context);
    }
  }

  Future<void> _copyText(String text) async {
    if (text.isEmpty) {
      showToast('无内容可复制', context);
      return;
    }
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) {
      return;
    }
    showToast('复制成功', context);
  }
}

