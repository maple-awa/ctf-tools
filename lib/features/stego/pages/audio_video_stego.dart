import 'package:ctf_tools/features/stego/utils/embedded_signature_scanner.dart';
import 'package:ctf_tools/features/stego/utils/media_container_inspector.dart';
import 'package:ctf_tools/features/stego/utils/wav_spectrum_analyzer.dart';
import 'package:ctf_tools/shared/widgets/mbutton.dart';
import 'package:ctf_tools/shared/widgets/show_toast.dart';
import 'package:ctf_tools/shared/widgets/tool_page_shell.dart';
import 'package:flutter/material.dart';

class AudioVideoStegoScreen extends StatefulWidget {
  const AudioVideoStegoScreen({super.key});

  @override
  State<AudioVideoStegoScreen> createState() => _AudioVideoStegoScreenState();
}

class _AudioVideoStegoScreenState extends State<AudioVideoStegoScreen> {
  final inputController = TextEditingController(
    text: '52 49 46 46 24 08 00 00 57 41 56 45 66 6D 74 20 '
        '10 00 00 00 01 00 01 00 44 AC 00 00 88 58 01 00 '
        '02 00 10 00 64 61 74 61 00 08 00 00',
  );
  String output = '';

  @override
  void dispose() {
    inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: ToolPageShell(
        title: '音视频隐写',
        description: '保留容器结构检查，并补嵌入签名扫描和 WAV 频谱/峰值摘要。',
        badge: 'Stego',
        child: Column(
          children: [
            ToolSectionCard(
              title: '容器十六进制输入',
              child: TextField(
                controller: inputController,
                maxLines: 12,
                decoration: const InputDecoration(
                  hintText: '粘贴 WAV/AVI/MP4/MP3/OGG/FLAC 十六进制数据',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: kToolSectionGap),
            Card(
              child: TabBar(
                tabs: const [
                  Tab(icon: Icon(Icons.library_music), text: '容器结构'),
                  Tab(icon: Icon(Icons.saved_search), text: '嵌入签名'),
                  Tab(icon: Icon(Icons.graphic_eq), text: 'WAV 频谱'),
                ],
              ),
            ),
            const SizedBox(height: kToolSectionGap),
            SizedBox(
              height: 520,
              child: TabBarView(
                children: [
                  _actionPane(MElevatedButton(icon: Icons.search, text: '检查容器', onPressed: _inspectContainer)),
                  _actionPane(MElevatedButton(icon: Icons.saved_search, text: '扫描签名', onPressed: _scanEmbedded)),
                  _actionPane(MElevatedButton(icon: Icons.graphic_eq, text: '分析 WAV', onPressed: _analyzeWav)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionPane(Widget action) {
    return SingleChildScrollView(
      child: Column(
        children: [
          action,
          const SizedBox(height: kToolSectionGap),
          ToolSectionCard(title: '输出', child: SelectableText(output.isEmpty ? '暂无结果' : output)),
        ],
      ),
    );
  }

  void _inspectContainer() {
    try {
      final result = MediaContainerInspector.inspectHex(inputController.text);
      setState(() {
        output = [
          'Type: ${result.type}',
          '',
          'Summary:',
          ...result.summary,
          if (result.structure.isNotEmpty) '',
          if (result.structure.isNotEmpty) 'Structure:',
          if (result.structure.isNotEmpty) ...result.structure,
          if (result.notes.isNotEmpty) '',
          if (result.notes.isNotEmpty) 'Notes:',
          if (result.notes.isNotEmpty) ...result.notes,
        ].join('\n');
      });
    } catch (error) {
      showToast('检查失败: $error', context);
    }
  }

  void _scanEmbedded() {
    try {
      final hits = EmbeddedSignatureScanner.scanHex(inputController.text);
      setState(() {
        output = hits.isEmpty
            ? '未发现明显嵌入文件签名'
            : hits.map((hit) => '${hit.type} @ 0x${hit.offset.toRadixString(16).toUpperCase()}\n${hit.preview}').join('\n\n');
      });
    } catch (error) {
      showToast('扫描失败: $error', context);
    }
  }

  void _analyzeWav() {
    try {
      final result = WavSpectrumAnalyzer.analyzeHex(inputController.text);
      setState(() {
        output = [
          ...result.summary,
          'Peak: ${result.peak}',
          '',
          'Sample Preview:',
          result.samplePreview.join(', '),
        ].join('\n');
      });
    } catch (error) {
      showToast('分析失败: $error', context);
    }
  }
}
