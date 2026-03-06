import 'package:ctf_tools/shared/widgets/module_hub_screen.dart';
import 'package:flutter/material.dart';

class CryptoHubScreen extends StatelessWidget {
  const CryptoHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ModuleHubScreen(
      title: '密码学',
      description: '面向 CTF 题型的密码学工作台，覆盖经典密码、现代密码、摘要与分析辅助。',
      badge: 'Crypto',
      statusItems: [
        '经典密码、哈希、AES/RSA 与 XOR 分析已可直接使用。',
        '本轮扩展到更多经典算法、对称算法、JWT/PEM/DER 与字典爆破。',
      ],
      recommendedFlows: [
        '哈希计算 -> 字典爆破 -> 密码分析，适合先识别后验证。',
        '现代密码 -> RSA 修复/攻击 -> 输出转换，适合处理常见非填充 RSA 题。',
      ],
      knownLimits: ['不内置大型字典或在线爆破能力，所有爆破候选词均由用户输入。'],
      sections: [
        ModuleHubSection(
          title: '经典密码',
          summary: 'Caesar、Atbash、Vigenere、Affine、Rail Fence、Baconian。',
          route: '/crypto/classical',
          icon: Icons.history_edu,
          inputs: ['UTF-8'],
          highlights: ['替换', '栅栏', '培根'],
        ),
        ModuleHubSection(
          title: '现代密码',
          summary: 'AES/3DES 与 RSA 修复、运算、攻击辅助。',
          route: '/crypto/modern',
          icon: Icons.shield,
          inputs: ['UTF-8', 'Hex', 'Base64', 'Integer'],
          highlights: ['AES', 'DES family', 'RSA'],
        ),
        ModuleHubSection(
          title: '哈希计算',
          summary: '摘要、HMAC、识别与本地字典爆破。',
          route: '/crypto/hash',
          icon: Icons.fingerprint,
          inputs: ['UTF-8', 'Hex', 'Base64', '字典列表'],
          highlights: ['digest', 'identify', 'crack'],
        ),
        ModuleHubSection(
          title: '密码分析',
          summary: 'XOR、字频、替换分析、JWT 与 PEM/DER 转换。',
          route: '/crypto/analysis',
          icon: Icons.analytics,
          inputs: ['UTF-8', 'Hex', 'Base64', 'JWT'],
          highlights: ['XOR', 'JWT', 'PEM/DER'],
        ),
      ],
    );
  }
}
