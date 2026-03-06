import 'package:ctf_tools/shared/widgets/module_hub_screen.dart';
import 'package:flutter/material.dart';

class EncodingHubScreen extends StatelessWidget {
  const EncodingHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ModuleHubScreen(
      title: '编码解码',
      description: '统一收纳文本、二进制和结构化编码工具，便于按题目输入格式快速切换工作流。',
      badge: 'Encoding',
      statusItems: [
        '全部子路由均已接入真实工具页，可直接完成 Base/Text/ProtoBuf/压缩/数值/替换密码的 MVP 工作流。',
        '当前默认输入以文本、Hex、Base64 为主，不强依赖文件导入。',
      ],
      recommendedFlows: [
        'Base 系列 -> 文本编码 -> ProtoBuf，适合处理多层嵌套载荷。',
        '压缩/解压 -> 数值/进制 -> 替换密码，适合剥离简单混淆链路。',
      ],
      knownLimits: [
        '本轮不补批量文件处理与自动探测，只保留单次输入输出。',
      ],
      sections: [
        ModuleHubSection(
          title: 'Base 系列',
          summary: 'Base2/Base16/Base32/Base58/Base64/Base85 快速转换。',
          route: '/encoding/base',
          icon: Icons.tag,
          inputs: ['UTF-8', 'Hex', 'Base64'],
          highlights: ['多 Base 变换', '字符集切换'],
          sampleRoute: '/encoding/base',
        ),
        ModuleHubSection(
          title: '文本编码',
          summary: 'URL、HTML、Unicode、Quoted-Printable、Morse 等文本层编码。',
          route: '/encoding/text',
          icon: Icons.text_fields,
          inputs: ['UTF-8'],
          highlights: ['URL', 'HTML', 'Morse'],
          sampleRoute: '/encoding/text',
        ),
        ModuleHubSection(
          title: 'ProtoBuf',
          summary: '支持无 schema 硬解码与 schema 编解码。',
          route: '/encoding/protobuf',
          icon: Icons.schema,
          inputs: ['Hex', 'Base64', 'Proto'],
          highlights: ['hard decode', 'schema round-trip'],
        ),
        ModuleHubSection(
          title: '压缩/解压',
          summary: 'Gzip/Zlib 编解码，支持 RAW/Base64/Hex。',
          route: '/encoding/compress',
          icon: Icons.compress,
          inputs: ['UTF-8', 'Hex', 'Base64'],
          highlights: ['gzip', 'zlib'],
        ),
        ModuleHubSection(
          title: '数值/进制',
          summary: '2~64 进制、BCD、Binary/Hex 互转。',
          route: '/encoding/number',
          icon: Icons.numbers,
          inputs: ['文本数值'],
          highlights: ['base convert', 'BCD'],
        ),
        ModuleHubSection(
          title: '替换密码',
          summary: 'ROT13/ROT47/Caesar/Atbash 轻量替换题处理。',
          route: '/encoding/replace',
          icon: Icons.swap_horiz,
          inputs: ['UTF-8'],
          highlights: ['ROT', 'Caesar', 'Atbash'],
        ),
      ],
    );
  }
}
