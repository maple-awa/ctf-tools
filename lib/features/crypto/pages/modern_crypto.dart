import 'package:ctf_tools/features/crypto/utils/aes_toolkit.dart';
import 'package:ctf_tools/features/crypto/utils/crypto_codec.dart';
import 'package:ctf_tools/features/crypto/utils/legacy_block_cipher_toolkit.dart';
import 'package:ctf_tools/features/crypto/utils/rsa_toolkit.dart';
import 'package:ctf_tools/shared/widgets/dropdown_menu.dart';
import 'package:ctf_tools/shared/widgets/mbutton.dart';
import 'package:ctf_tools/shared/widgets/show_toast.dart';
import 'package:ctf_tools/shared/widgets/tool_page_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ModernCryptoScreen extends StatefulWidget {
  const ModernCryptoScreen({super.key});

  @override
  State<ModernCryptoScreen> createState() => _ModernCryptoScreenState();
}

class _ModernCryptoScreenState extends State<ModernCryptoScreen> {
  final aesInputController = TextEditingController(text: 'flag{aes_demo}');
  final aesKeyController = TextEditingController(text: '0123456789ABCDEF');
  final aesIvController = TextEditingController(text: 'ABCDEF0123456789');
  final aesOutputController = TextEditingController();
  String aesMode = AesToolkit.modes[1];
  String aesPadding = AesToolkit.paddings.first;
  String aesInputFormat = CryptoCodec.byteFormats.first;
  String aesOutputFormat = 'Base64';
  String aesKeyFormat = CryptoCodec.byteFormats.first;
  String aesIvFormat = CryptoCodec.byteFormats.first;

  final legacyInputController = TextEditingController(
    text: 'flag{legacy_demo}',
  );
  final legacyKeyController = TextEditingController(text: '12345678');
  final legacyIvController = TextEditingController(text: '12345678');
  final legacyOutputController = TextEditingController();
  String legacyAlgorithm = LegacyBlockCipherToolkit.algorithms.first;
  String legacyPadding = LegacyBlockCipherToolkit.paddings.first;
  String legacyInputFormat = CryptoCodec.byteFormats.first;
  String legacyOutputFormat = 'Base64';
  String legacyKeyFormat = CryptoCodec.byteFormats.first;
  String legacyIvFormat = CryptoCodec.byteFormats.first;

  final pController = TextEditingController(text: '61');
  final qController = TextEditingController(text: '53');
  final eController = TextEditingController(text: '17');
  final nController = TextEditingController(text: '3233');
  final phiController = TextEditingController(text: '3120');
  final dController = TextEditingController(text: '2753');
  final rsaInputController = TextEditingController(text: 'A');
  final rsaSignatureController = TextEditingController();
  final commonE1Controller = TextEditingController(text: '7');
  final commonE2Controller = TextEditingController(text: '11');
  final commonC1Controller = TextEditingController();
  final commonC2Controller = TextEditingController();
  String rsaInputFormat = RsaToolkit.inputFormats[1];
  String rsaOutputFormat = RsaToolkit.outputFormats.first;
  String rsaSignatureFormat = RsaToolkit.outputFormats.first;
  String commonCipherFormat = RsaToolkit.outputFormats.first;
  String commonOutputFormat = RsaToolkit.outputFormats[1];
  String rsaOutput = '';

  @override
  void dispose() {
    aesInputController.dispose();
    aesKeyController.dispose();
    aesIvController.dispose();
    aesOutputController.dispose();
    legacyInputController.dispose();
    legacyKeyController.dispose();
    legacyIvController.dispose();
    legacyOutputController.dispose();
    pController.dispose();
    qController.dispose();
    eController.dispose();
    nController.dispose();
    phiController.dispose();
    dController.dispose();
    rsaInputController.dispose();
    rsaSignatureController.dispose();
    commonE1Controller.dispose();
    commonE2Controller.dispose();
    commonC1Controller.dispose();
    commonC2Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: ToolPageShell(
        title: '现代密码',
        description: '当前版本覆盖 AES、3DES 与 RSA 修复、运算、攻击辅助。',
        badge: 'Crypto',
        child: Column(
          children: [
            Card(
              child: TabBar(
                isScrollable: true,
                tabs: const [
                  Tab(icon: Icon(Icons.lock), text: 'AES'),
                  Tab(icon: Icon(Icons.vpn_key), text: 'RSA'),
                  Tab(icon: Icon(Icons.shield_outlined), text: '3DES'),
                ],
              ),
            ),
            const SizedBox(height: kToolSectionGap),
            SizedBox(
              height: 980,
              child: TabBarView(
                children: [
                  _buildAesPanel(),
                  _buildRsaPanel(),
                  _buildLegacyPanel(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAesPanel() {
    final scheme = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      child: Column(
        children: [
          ToolSectionCard(
            title: 'AES 参数',
            child: Column(
              children: [
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      '模式',
                      style: TextStyle(color: scheme.onSurfaceVariant),
                    ),
                    MDropdownMenu(
                      initialValue: aesMode,
                      items: AesToolkit.modes,
                      onChanged: (value) => setState(() {
                        aesMode = value;
                        if (!AesToolkit.supportsPadding(value)) {
                          aesPadding = 'NoPadding';
                        }
                      }),
                    ),
                    Text(
                      '填充',
                      style: TextStyle(color: scheme.onSurfaceVariant),
                    ),
                    MDropdownMenu(
                      initialValue: aesPadding,
                      items: AesToolkit.paddings,
                      onChanged: AesToolkit.supportsPadding(aesMode)
                          ? (value) => setState(() {
                              aesPadding = value;
                            })
                          : null,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    Text('输入'),
                    MDropdownMenu(
                      initialValue: aesInputFormat,
                      items: CryptoCodec.byteFormats,
                      onChanged: (value) =>
                          setState(() => aesInputFormat = value),
                    ),
                    Text('输出'),
                    MDropdownMenu(
                      initialValue: aesOutputFormat,
                      items: CryptoCodec.outputFormats,
                      onChanged: (value) =>
                          setState(() => aesOutputFormat = value),
                    ),
                    Text('Key'),
                    MDropdownMenu(
                      initialValue: aesKeyFormat,
                      items: CryptoCodec.byteFormats,
                      onChanged: (value) =>
                          setState(() => aesKeyFormat = value),
                    ),
                    Text('IV'),
                    MDropdownMenu(
                      initialValue: aesIvFormat,
                      items: CryptoCodec.byteFormats,
                      onChanged: (value) => setState(() => aesIvFormat = value),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: kToolSectionGap),
          ToolSectionCard(
            title: 'Key / IV / 输入',
            child: Column(
              children: [
                TextField(
                  controller: aesKeyController,
                  decoration: const InputDecoration(labelText: 'AES Key'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: aesIvController,
                  enabled: AesToolkit.requiresIv(aesMode),
                  decoration: const InputDecoration(labelText: 'IV / Counter'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: aesInputController,
                  maxLines: 8,
                  decoration: const InputDecoration(labelText: '输入内容'),
                ),
              ],
            ),
          ),
          const SizedBox(height: kToolSectionGap),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              MElevatedButton(
                icon: Icons.lock,
                text: 'AES 加密',
                onPressed: _encryptAes,
              ),
              MElevatedButton(
                icon: Icons.lock_open,
                text: 'AES 解密',
                onPressed: _decryptAes,
              ),
              MElevatedButton(
                icon: Icons.info_outline,
                text: '参数说明',
                onPressed: _describeAes,
              ),
              MElevatedButton(
                icon: Icons.copy,
                text: '复制输出',
                onPressed: () => _copyText(aesOutputController.text),
              ),
            ],
          ),
          const SizedBox(height: kToolSectionGap),
          ToolSectionCard(
            title: '输出',
            child: TextField(
              controller: aesOutputController,
              maxLines: 14,
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegacyPanel() {
    final scheme = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      child: Column(
        children: [
          ToolSectionCard(
            title: 'Legacy Block 参数',
            child: Column(
              children: [
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      '算法',
                      style: TextStyle(color: scheme.onSurfaceVariant),
                    ),
                    MDropdownMenu(
                      initialValue: legacyAlgorithm,
                      items: LegacyBlockCipherToolkit.algorithms,
                      onChanged: (value) =>
                          setState(() => legacyAlgorithm = value),
                    ),
                    Text(
                      '填充',
                      style: TextStyle(color: scheme.onSurfaceVariant),
                    ),
                    MDropdownMenu(
                      initialValue: legacyPadding,
                      items: LegacyBlockCipherToolkit.paddings,
                      onChanged: (value) =>
                          setState(() => legacyPadding = value),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    Text('输入'),
                    MDropdownMenu(
                      initialValue: legacyInputFormat,
                      items: CryptoCodec.byteFormats,
                      onChanged: (value) =>
                          setState(() => legacyInputFormat = value),
                    ),
                    Text('输出'),
                    MDropdownMenu(
                      initialValue: legacyOutputFormat,
                      items: CryptoCodec.outputFormats,
                      onChanged: (value) =>
                          setState(() => legacyOutputFormat = value),
                    ),
                    Text('Key'),
                    MDropdownMenu(
                      initialValue: legacyKeyFormat,
                      items: CryptoCodec.byteFormats,
                      onChanged: (value) =>
                          setState(() => legacyKeyFormat = value),
                    ),
                    Text('IV'),
                    MDropdownMenu(
                      initialValue: legacyIvFormat,
                      items: CryptoCodec.byteFormats,
                      onChanged: (value) =>
                          setState(() => legacyIvFormat = value),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: kToolSectionGap),
          ToolSectionCard(
            title: 'Key / IV / 输入',
            child: Column(
              children: [
                TextField(
                  controller: legacyKeyController,
                  decoration: const InputDecoration(labelText: 'Key'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: legacyIvController,
                  enabled: LegacyBlockCipherToolkit.requiresIv(legacyAlgorithm),
                  decoration: const InputDecoration(labelText: 'IV'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: legacyInputController,
                  maxLines: 8,
                  decoration: const InputDecoration(labelText: '输入内容'),
                ),
              ],
            ),
          ),
          const SizedBox(height: kToolSectionGap),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              MElevatedButton(
                icon: Icons.lock,
                text: '加密',
                onPressed: _encryptLegacy,
              ),
              MElevatedButton(
                icon: Icons.lock_open,
                text: '解密',
                onPressed: _decryptLegacy,
              ),
              MElevatedButton(
                icon: Icons.info_outline,
                text: '参数说明',
                onPressed: _describeLegacy,
              ),
              MElevatedButton(
                icon: Icons.copy,
                text: '复制输出',
                onPressed: () => _copyText(legacyOutputController.text),
              ),
            ],
          ),
          const SizedBox(height: kToolSectionGap),
          ToolSectionCard(
            title: '输出',
            child: TextField(
              controller: legacyOutputController,
              maxLines: 14,
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRsaPanel() {
    return SingleChildScrollView(
      child: Column(
        children: [
          ToolSectionCard(
            title: 'RSA 参数与推导',
            child: Column(
              children: [
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    SizedBox(
                      width: 160,
                      child: TextField(
                        controller: pController,
                        decoration: const InputDecoration(labelText: 'p'),
                      ),
                    ),
                    SizedBox(
                      width: 160,
                      child: TextField(
                        controller: qController,
                        decoration: const InputDecoration(labelText: 'q'),
                      ),
                    ),
                    SizedBox(
                      width: 160,
                      child: TextField(
                        controller: eController,
                        decoration: const InputDecoration(labelText: 'e'),
                      ),
                    ),
                    SizedBox(
                      width: 180,
                      child: TextField(
                        controller: nController,
                        decoration: const InputDecoration(labelText: 'n'),
                      ),
                    ),
                    SizedBox(
                      width: 180,
                      child: TextField(
                        controller: phiController,
                        decoration: const InputDecoration(labelText: 'phi(n)'),
                      ),
                    ),
                    SizedBox(
                      width: 180,
                      child: TextField(
                        controller: dController,
                        decoration: const InputDecoration(labelText: 'd'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    MElevatedButton(
                      icon: Icons.key,
                      text: '由 p/q/e 推导',
                      onPressed: _deriveRsaPrivateKey,
                    ),
                    MElevatedButton(
                      icon: Icons.functions,
                      text: '由 phi 推导 d',
                      onPressed: _deriveRsaFromPhi,
                    ),
                    MElevatedButton(
                      icon: Icons.auto_fix_high,
                      text: 'Fermat 分解',
                      onPressed: _fermatFactorRsa,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: kToolSectionGap),
          ToolSectionCard(
            title: '数据格式',
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                Text('输入'),
                MDropdownMenu(
                  initialValue: rsaInputFormat,
                  items: RsaToolkit.inputFormats,
                  onChanged: (value) => setState(() => rsaInputFormat = value),
                ),
                Text('输出'),
                MDropdownMenu(
                  initialValue: rsaOutputFormat,
                  items: RsaToolkit.outputFormats,
                  onChanged: (value) => setState(() => rsaOutputFormat = value),
                ),
                Text('签名'),
                MDropdownMenu(
                  initialValue: rsaSignatureFormat,
                  items: RsaToolkit.outputFormats,
                  onChanged: (value) =>
                      setState(() => rsaSignatureFormat = value),
                ),
              ],
            ),
          ),
          const SizedBox(height: kToolSectionGap),
          ToolSectionCard(
            title: '消息 / 密文 / 签名',
            child: Column(
              children: [
                TextField(
                  controller: rsaInputController,
                  maxLines: 5,
                  decoration: const InputDecoration(labelText: '消息或密文'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: rsaSignatureController,
                  maxLines: 4,
                  decoration: const InputDecoration(labelText: '签名'),
                ),
              ],
            ),
          ),
          const SizedBox(height: kToolSectionGap),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              MElevatedButton(
                icon: Icons.lock,
                text: 'RSA 加密',
                onPressed: _encryptRsa,
              ),
              MElevatedButton(
                icon: Icons.lock_open,
                text: 'RSA 解密',
                onPressed: _decryptRsa,
              ),
              MElevatedButton(
                icon: Icons.edit,
                text: '签名',
                onPressed: _signRsa,
              ),
              MElevatedButton(
                icon: Icons.verified,
                text: '验签',
                onPressed: _verifyRsa,
              ),
              MElevatedButton(
                icon: Icons.keyboard_double_arrow_down,
                text: '小指数开根',
                onPressed: _recoverSmallExponentRsa,
              ),
              MElevatedButton(
                icon: Icons.info_outline,
                text: '输入分析',
                onPressed: _inspectRsaInput,
              ),
            ],
          ),
          const SizedBox(height: kToolSectionGap),
          ToolSectionCard(
            title: '共模攻击',
            child: Column(
              children: [
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    SizedBox(
                      width: 150,
                      child: TextField(
                        controller: commonE1Controller,
                        decoration: const InputDecoration(labelText: 'e1'),
                      ),
                    ),
                    SizedBox(
                      width: 150,
                      child: TextField(
                        controller: commonE2Controller,
                        decoration: const InputDecoration(labelText: 'e2'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    Text('密文输入'),
                    MDropdownMenu(
                      initialValue: commonCipherFormat,
                      items: RsaToolkit.outputFormats,
                      onChanged: (value) =>
                          setState(() => commonCipherFormat = value),
                    ),
                    Text('恢复输出'),
                    MDropdownMenu(
                      initialValue: commonOutputFormat,
                      items: RsaToolkit.outputFormats,
                      onChanged: (value) =>
                          setState(() => commonOutputFormat = value),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: commonC1Controller,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'c1'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: commonC2Controller,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'c2'),
                ),
                const SizedBox(height: 8),
                MElevatedButton(
                  icon: Icons.crisis_alert,
                  text: '执行共模攻击',
                  onPressed: _runCommonModulusAttack,
                ),
              ],
            ),
          ),
          const SizedBox(height: kToolSectionGap),
          ToolSectionCard(
            title: '输出',
            child: SelectableText(rsaOutput.isEmpty ? '暂无结果' : rsaOutput),
          ),
        ],
      ),
    );
  }

  void _encryptAes() {
    try {
      aesOutputController.text = AesToolkit.encrypt(
        mode: aesMode,
        padding: aesPadding,
        input: aesInputController.text,
        inputFormat: aesInputFormat,
        key: aesKeyController.text,
        keyFormat: aesKeyFormat,
        iv: aesIvController.text,
        ivFormat: aesIvFormat,
        outputFormat: aesOutputFormat,
      );
      setState(() {});
    } catch (error) {
      showToast('AES 加密失败: $error', context);
    }
  }

  void _decryptAes() {
    try {
      aesOutputController.text = AesToolkit.decrypt(
        mode: aesMode,
        padding: aesPadding,
        input: aesInputController.text,
        inputFormat: aesInputFormat,
        key: aesKeyController.text,
        keyFormat: aesKeyFormat,
        iv: aesIvController.text,
        ivFormat: aesIvFormat,
        outputFormat: aesOutputFormat,
      );
      setState(() {});
    } catch (error) {
      showToast('AES 解密失败: $error', context);
    }
  }

  void _describeAes() {
    try {
      aesOutputController.text = AesToolkit.describe(
        key: aesKeyController.text,
        keyFormat: aesKeyFormat,
        iv: aesIvController.text,
        ivFormat: aesIvFormat,
        mode: aesMode,
      );
      setState(() {});
    } catch (error) {
      showToast('参数分析失败: $error', context);
    }
  }

  void _encryptLegacy() {
    try {
      legacyOutputController.text = LegacyBlockCipherToolkit.encrypt(
        algorithm: legacyAlgorithm,
        padding: legacyPadding,
        input: legacyInputController.text,
        inputFormat: legacyInputFormat,
        key: legacyKeyController.text,
        keyFormat: legacyKeyFormat,
        iv: legacyIvController.text,
        ivFormat: legacyIvFormat,
        outputFormat: legacyOutputFormat,
      );
      setState(() {});
    } catch (error) {
      showToast('加密失败: $error', context);
    }
  }

  void _decryptLegacy() {
    try {
      legacyOutputController.text = LegacyBlockCipherToolkit.decrypt(
        algorithm: legacyAlgorithm,
        padding: legacyPadding,
        input: legacyInputController.text,
        inputFormat: legacyInputFormat,
        key: legacyKeyController.text,
        keyFormat: legacyKeyFormat,
        iv: legacyIvController.text,
        ivFormat: legacyIvFormat,
        outputFormat: legacyOutputFormat,
      );
      setState(() {});
    } catch (error) {
      showToast('解密失败: $error', context);
    }
  }

  void _describeLegacy() {
    try {
      legacyOutputController.text = LegacyBlockCipherToolkit.describe(
        algorithm: legacyAlgorithm,
        key: legacyKeyController.text,
        keyFormat: legacyKeyFormat,
        iv: legacyIvController.text,
        ivFormat: legacyIvFormat,
      );
      setState(() {});
    } catch (error) {
      showToast('参数分析失败: $error', context);
    }
  }

  void _deriveRsaPrivateKey() {
    try {
      final result = RsaToolkit.derivePrivateKey(
        pText: pController.text,
        qText: qController.text,
        eText: eController.text,
      );
      nController.text = result.n.toString();
      phiController.text = result.phi.toString();
      dController.text = result.d.toString();
      setState(() {
        rsaOutput = [
          'Derived by p / q / e',
          '',
          'n',
          RsaToolkit.formatBigInt(result.n),
          '',
          'phi(n)',
          RsaToolkit.formatBigInt(result.phi),
          '',
          'd',
          RsaToolkit.formatBigInt(result.d),
          '',
          'dp',
          RsaToolkit.formatBigInt(result.dp),
          '',
          'dq',
          RsaToolkit.formatBigInt(result.dq),
          '',
          'qInv',
          RsaToolkit.formatBigInt(result.qInv),
        ].join('\n');
      });
    } catch (error) {
      showToast('RSA 私钥推导失败: $error', context);
    }
  }

  void _deriveRsaFromPhi() {
    try {
      final result = RsaToolkit.derivePrivateKeyFromPhi(
        nText: nController.text,
        phiText: phiController.text,
        eText: eController.text,
      );
      dController.text = result.d.toString();
      setState(() {
        rsaOutput = [
          'Derived by phi(n)',
          '',
          'd',
          RsaToolkit.formatBigInt(result.d),
        ].join('\n');
      });
    } catch (error) {
      showToast('由 phi 推导失败: $error', context);
    }
  }

  void _fermatFactorRsa() {
    try {
      final result = RsaToolkit.fermatFactor(nText: nController.text);
      pController.text = result.p.toString();
      qController.text = result.q.toString();
      setState(() {
        rsaOutput = [
          'Fermat Factorization',
          '',
          'p',
          RsaToolkit.formatBigInt(result.p),
          '',
          'q',
          RsaToolkit.formatBigInt(result.q),
          '',
          'Iterations: ${result.iterations}',
        ].join('\n');
      });
    } catch (error) {
      showToast('Fermat 分解失败: $error', context);
    }
  }

  void _encryptRsa() {
    try {
      final result = RsaToolkit.encrypt(
        messageText: rsaInputController.text,
        inputFormat: rsaInputFormat,
        outputFormat: rsaOutputFormat,
        nText: nController.text,
        eText: eController.text,
      );
      setState(() {
        rsaOutput = _formatRsaProcessOutput('Cipher', result);
      });
    } catch (error) {
      showToast('RSA 加密失败: $error', context);
    }
  }

  void _decryptRsa() {
    try {
      final result = RsaToolkit.decrypt(
        cipherText: rsaInputController.text,
        inputFormat: rsaInputFormat,
        outputFormat: rsaOutputFormat,
        nText: nController.text,
        dText: dController.text,
      );
      setState(() {
        rsaOutput = _formatRsaProcessOutput('Plain', result);
      });
    } catch (error) {
      showToast('RSA 解密失败: $error', context);
    }
  }

  void _signRsa() {
    try {
      final result = RsaToolkit.sign(
        messageText: rsaInputController.text,
        inputFormat: rsaInputFormat,
        outputFormat: rsaSignatureFormat,
        nText: nController.text,
        dText: dController.text,
      );
      rsaSignatureController.text = result.formatted;
      setState(() {
        rsaOutput = [
          'Signature:',
          result.formatted,
          '',
          'Integer:',
          result.value.toString(),
        ].join('\n');
      });
    } catch (error) {
      showToast('RSA 签名失败: $error', context);
    }
  }

  void _verifyRsa() {
    try {
      final result = RsaToolkit.verify(
        messageText: rsaInputController.text,
        messageFormat: rsaInputFormat,
        signatureText: rsaSignatureController.text,
        signatureFormat: _mapOutputToInput(rsaSignatureFormat),
        nText: nController.text,
        eText: eController.text,
      );
      setState(() {
        rsaOutput = [
          'Verify: ${result.isValid ? 'VALID' : 'INVALID'}',
          '',
          'Recovered Integer:',
          result.recoveredValue.toString(),
          if (result.recoveredPreview.isNotEmpty) '',
          if (result.recoveredPreview.isNotEmpty)
            'Recovered UTF-8: ${result.recoveredPreview}',
        ].join('\n');
      });
    } catch (error) {
      showToast('RSA 验证失败: $error', context);
    }
  }

  void _recoverSmallExponentRsa() {
    try {
      final result = RsaToolkit.recoverSmallExponent(
        cipherText: rsaInputController.text,
        inputFormat: rsaInputFormat,
        outputFormat: rsaOutputFormat,
        eText: eController.text,
      );
      setState(() {
        rsaOutput = [
          'Small Exponent Root',
          '',
          _formatRsaProcessOutput('Recovered Plain', result),
        ].join('\n');
      });
    } catch (error) {
      showToast('小指数开根失败: $error', context);
    }
  }

  void _runCommonModulusAttack() {
    try {
      final result = RsaToolkit.commonModulusAttack(
        nText: nController.text,
        c1Text: commonC1Controller.text,
        c2Text: commonC2Controller.text,
        e1Text: commonE1Controller.text,
        e2Text: commonE2Controller.text,
        cipherFormat: _mapOutputToInput(commonCipherFormat),
        outputFormat: commonOutputFormat,
      );
      setState(() {
        rsaOutput = [
          'Common Modulus Attack',
          '',
          _formatRsaProcessOutput('Recovered Plain', result),
        ].join('\n');
      });
    } catch (error) {
      showToast('共模攻击失败: $error', context);
    }
  }

  void _inspectRsaInput() {
    try {
      setState(() {
        rsaOutput = RsaToolkit.describeInput(
          rsaInputController.text,
          rsaInputFormat,
        );
      });
    } catch (error) {
      showToast('输入分析失败: $error', context);
    }
  }

  String _formatRsaProcessOutput(String label, RsaProcessResult result) {
    return [
      '$label:',
      result.formatted,
      '',
      'Integer:',
      result.value.toString(),
      if (result.utf8Preview.isNotEmpty) '',
      if (result.utf8Preview.isNotEmpty) 'UTF-8 Preview: ${result.utf8Preview}',
    ].join('\n');
  }

  String _mapOutputToInput(String format) {
    return switch (format) {
      'Integer' => 'Integer',
      'UTF-8' => 'UTF-8',
      'Hex lower' || 'Hex upper' => 'Hex',
      'Base64' => 'Base64',
      _ => 'Integer',
    };
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
