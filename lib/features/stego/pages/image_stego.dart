import 'package:ctf_tools/features/stego/utils/embedded_signature_scanner.dart';
import 'package:ctf_tools/features/stego/utils/png_chunk_inspector.dart';
import 'package:ctf_tools/features/stego/utils/png_lsb_extractor.dart';
import 'package:ctf_tools/shared/widgets/dropdown_menu.dart';
import 'package:ctf_tools/shared/widgets/mbutton.dart';
import 'package:ctf_tools/shared/widgets/show_toast.dart';
import 'package:ctf_tools/shared/widgets/tool_page_shell.dart';
import 'package:flutter/material.dart';

class ImageStegoScreen extends StatefulWidget {
  const ImageStegoScreen({super.key});

  @override
  State<ImageStegoScreen> createState() => _ImageStegoScreenState();
}

class _ImageStegoScreenState extends State<ImageStegoScreen> {
  final inputController = TextEditingController();
  String bitPlane = '0';
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
        title: '图像隐写',
        description: '补齐 PNG chunk/meta 检查、嵌入签名扫描与 LSB 位平面提取。',
        badge: 'Stego',
        child: Column(
          children: [
            ToolSectionCard(
              title: 'PNG 十六进制输入',
              child: TextField(
                controller: inputController,
                maxLines: 12,
                decoration: const InputDecoration(
                  hintText: '粘贴 PNG 文件头和 chunk 十六进制数据',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: kToolSectionGap),
            Card(
              child: TabBar(
                tabs: const [
                  Tab(icon: Icon(Icons.list_alt), text: 'Chunk'),
                  Tab(icon: Icon(Icons.search), text: '嵌入签名'),
                  Tab(icon: Icon(Icons.grid_3x3), text: 'LSB'),
                ],
              ),
            ),
            const SizedBox(height: kToolSectionGap),
            SizedBox(
              height: 520,
              child: TabBarView(
                children: [
                  _actionPane([
                    MElevatedButton(icon: Icons.image_search, text: '检查 PNG', onPressed: _inspectChunks),
                  ]),
                  _actionPane([
                    MElevatedButton(icon: Icons.saved_search, text: '扫描签名', onPressed: _scanEmbedded),
                  ]),
                  _lsbPane(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionPane(List<Widget> actions) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Wrap(spacing: 10, runSpacing: 10, children: actions),
          const SizedBox(height: kToolSectionGap),
          ToolSectionCard(title: '输出', child: SelectableText(output.isEmpty ? '暂无结果' : output)),
        ],
      ),
    );
  }

  Widget _lsbPane() {
    return SingleChildScrollView(
      child: Column(
        children: [
          ToolSectionCard(
            title: 'LSB 参数',
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                const Text('Bit Plane'),
                MDropdownMenu(
                  initialValue: bitPlane,
                  items: const ['0', '1'],
                  onChanged: (value) => setState(() {
                    bitPlane = value;
                  }),
                ),
                MElevatedButton(icon: Icons.grid_3x3, text: '提取 LSB', onPressed: _extractLsb),
              ],
            ),
          ),
          const SizedBox(height: kToolSectionGap),
          ToolSectionCard(title: '输出', child: SelectableText(output.isEmpty ? '暂无结果' : output)),
        ],
      ),
    );
  }

  void _inspectChunks() {
    try {
      final result = PngChunkInspector.inspectHex(inputController.text);
      setState(() {
        output = [
          'Chunks:',
          ...result.chunks.map((item) => '${item.type} (${item.length} bytes)'),
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

  void _extractLsb() {
    try {
      final result = PngLsbExtractor.extract(inputController.text, bitPlane: int.parse(bitPlane));
      setState(() {
        output = [
          ...result.notes,
          '',
          'Bit Stream Preview:',
          result.bitStream,
          '',
          'Text Preview:',
          result.textPreview,
        ].join('\n');
      });
    } catch (error) {
      showToast('提取失败: $error', context);
    }
  }
}
