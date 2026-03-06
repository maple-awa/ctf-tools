import 'package:ctf_tools/shared/widgets/module_hub_screen.dart';
import 'package:flutter/material.dart';

class StegoHubScreen extends StatelessWidget {
  const StegoHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ModuleHubScreen(
      title: '隐写工具',
      description: '覆盖文本、图像、音视频三类隐写排查入口，统一输出可疑点、提取预览与结构摘要。',
      badge: 'Stego',
      statusItems: [
        '文本隐写支持零宽字符和 Space/Tab 载荷。',
        '图像与音视频工具支持结构检查、尾随/嵌入签名扫描，以及 PNG/WAV 的专项分析。',
      ],
      recommendedFlows: [
        '图像 chunk 检查 -> 嵌入签名扫描 -> LSB 提取。',
        '音视频容器检查 -> WAV 频谱摘要 -> 尾随数据与文件签名判断。',
      ],
      knownLimits: [
        'LSB MVP 仅覆盖 PNG；音视频频谱 MVP 仅覆盖 WAV PCM 样本。',
      ],
      sections: [
        ModuleHubSection(
          title: '图像',
          summary: 'PNG chunk、嵌入签名扫描与 LSB 位平面提取。',
          route: '/stego/image',
          icon: Icons.image_search,
          inputs: ['Hex'],
          highlights: ['chunk', 'embedded file', 'LSB'],
        ),
        ModuleHubSection(
          title: '音视频',
          summary: 'WAV/AVI/MP4/MP3/OGG/FLAC 容器检查、嵌入签名扫描与 WAV 频谱摘要。',
          route: '/stego/audio_video',
          icon: Icons.music_video,
          inputs: ['Hex'],
          highlights: ['container', 'embedded file', 'WAV spectrum'],
        ),
        ModuleHubSection(
          title: '文本',
          summary: '零宽字符与 Snow-like 空格/Tab 载荷编解码、统计检测。',
          route: '/stego/text',
          icon: Icons.visibility_off,
          inputs: ['UTF-8'],
          highlights: ['zero width', 'space/tab'],
        ),
      ],
    );
  }
}
