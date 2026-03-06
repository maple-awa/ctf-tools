import 'package:ctf_tools/shared/widgets/module_hub_screen.dart';
import 'package:flutter/material.dart';

class BinaryHubScreen extends StatelessWidget {
  const BinaryHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ModuleHubScreen(
      title: '二进制分析',
      description: '面向 RE/PWN 的基础二进制工作台，覆盖头部检查、字符串提取、离线反汇编和利用辅助。',
      badge: 'Binary',
      statusItems: [
        '文件解析已扩展为 ELF/PE/Mach-O 头部摘要与 checksec 风格结果。',
        '反汇编支持 gadget 查找和控制流摘要；利用页支持 cyclic、format string 与 shellcode 模板。',
      ],
      recommendedFlows: [
        '文件解析 -> 字符串提取 -> 反汇编，适合先建立样本轮廓。',
        '反汇编 -> 漏洞利用，适合快速定位 gadget 与 offset。',
      ],
      knownLimits: [
        '当前为离线静态分析，不接外部反汇编引擎，不做完整 ELF/PE section 级深度解析。',
      ],
      sections: [
        ModuleHubSection(
          title: '文件解析',
          summary: 'ELF/PE/Mach-O 头部解析、文件类型识别与 checksec 风格摘要。',
          route: '/binary/info',
          icon: Icons.file_open,
          inputs: ['Hex'],
          highlights: ['ELF', 'PE', 'Mach-O', 'checksec'],
        ),
        ModuleHubSection(
          title: '字符串提取',
          summary: 'ASCII/UTF-16LE 静态字符串提取。',
          route: '/binary/strings',
          icon: Icons.text_snippet,
          inputs: ['UTF-8', 'Hex'],
          highlights: ['ASCII', 'UTF-16LE'],
        ),
        ModuleHubSection(
          title: '反汇编',
          summary: '离线 opcode 反汇编、ROP gadget 搜索与控制流摘要。',
          route: '/binary/disasm',
          icon: Icons.code,
          inputs: ['Hex'],
          highlights: ['disasm', 'ROP gadget', 'flow summary'],
        ),
        ModuleHubSection(
          title: '漏洞利用',
          summary: 'cyclic、格式化字符串 offset 与 shellcode 模板。',
          route: '/binary/exploit',
          icon: Icons.bug_report,
          inputs: ['文本', 'Hex', '长度'],
          highlights: ['cyclic', 'fmtstr', 'shellcode'],
        ),
      ],
    );
  }
}
