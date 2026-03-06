import 'package:ctf_tools/features/encoding/utils/compress/compress_codec.dart';
import 'package:ctf_tools/shared/widgets/dropdown_menu.dart';
import 'package:ctf_tools/shared/widgets/mbutton.dart';
import 'package:ctf_tools/shared/widgets/show_toast.dart';
import 'package:ctf_tools/shared/widgets/tool_page_shell.dart';
import 'package:ctf_tools/shared/widgets/tool_status_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CompressCoderScreen extends StatefulWidget {
  const CompressCoderScreen({super.key});

  @override
  State<CompressCoderScreen> createState() => _CompressCoderScreenState();
}

class _CompressCoderScreenState extends State<CompressCoderScreen> {
  final TextEditingController inputController = TextEditingController();
  final TextEditingController outputController = TextEditingController();

  String inputFormatLabel = 'RAW';
  String outputFormatLabel = 'Base64';
  String compressionLevel = '6';

  static const List<String> _formatItems = ['RAW', 'Base64', 'Hex'];
  static const List<String> _levelItems = [
    '0',
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
  ];

  @override
  void dispose() {
    inputController.dispose();
    outputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: ToolPageShell(
        title: 'Gzip/Zlib 压缩/解压',
        description: '统一的压缩工具页，支持 RAW / Base64 / Hex 三种输入输出格式。',
        badge: 'Compression',
        child: Column(
          children: [
            Card(
              child: TabBar(
                tabs: const [
                  Tab(icon: Icon(Icons.folder_zip), text: 'Gzip'),
                  Tab(icon: Icon(Icons.zoom_in_map), text: 'Zlib'),
                ],
              ),
            ),
            const SizedBox(height: kToolSectionGap),
            SizedBox(
              height: kToolTabViewportHeight,
              child: TabBarView(
                children: [
                  _buildPanel(CompressAlgorithm.gzip),
                  _buildPanel(CompressAlgorithm.zlib),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPanel(CompressAlgorithm algorithm) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 4),
      child: Column(
        children: [
          ToolSectionCard(
            title: '参数',
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const ToolStatusChip(label: 'RAW / Base64 / Hex', icon: Icons.tune),
                Text('输入格式'),
                MDropdownMenu(
                  initialValue: inputFormatLabel,
                  items: _formatItems,
                  onChanged: (value) => setState(() {
                    inputFormatLabel = value;
                  }),
                ),
                Text('输出格式'),
                MDropdownMenu(
                  initialValue: outputFormatLabel,
                  items: _formatItems,
                  onChanged: (value) => setState(() {
                    outputFormatLabel = value;
                  }),
                ),
                Text('压缩级别'),
                MDropdownMenu(
                  initialValue: compressionLevel,
                  items: _levelItems,
                  onChanged: (value) => setState(() {
                    compressionLevel = value;
                  }),
                ),
              ],
            ),
          ),
          const SizedBox(height: kToolSectionGap),
          ToolSectionCard(
            title: '输入',
            trailing: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                MElevatedButton(
                  icon: Icons.copy,
                  text: '复制',
                  onPressed: () => _copyText(inputController.text),
                ),
                MElevatedButton(
                  icon: Icons.delete,
                  text: '清空',
                  onPressed: _clear,
                ),
              ],
            ),
            child: TextField(controller: inputController, maxLines: 8),
          ),
          const SizedBox(height: kToolSectionGap),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            runSpacing: 10,
            children: [
              MElevatedButton(
                icon: Icons.compress,
                text: '压缩',
                onPressed: () => _process(algorithm, false),
              ),
              MElevatedButton(
                icon: Icons.unarchive,
                text: '解压',
                onPressed: () => _process(algorithm, true),
              ),
              MElevatedButton(
                icon: Icons.swap_horiz,
                text: '交换',
                onPressed: () {
                  final temp = inputController.text;
                  inputController.text = outputController.text;
                  outputController.text = temp;
                  setState(() {});
                },
              ),
            ],
          ),
          const SizedBox(height: kToolSectionGap),
          ToolSectionCard(
            title: '输出',
            trailing: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ToolStatusChip(label: outputFormatLabel, icon: Icons.output),
                MElevatedButton(
                  icon: Icons.copy,
                  text: '复制',
                  onPressed: () => _copyText(outputController.text),
                ),
              ],
            ),
            child: SizedBox(
              height: kToolOutputHeight,
              child: TextField(
                controller: outputController,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _process(CompressAlgorithm algorithm, bool isDecompress) {
    try {
      final inputFormat = _mapFormat(inputFormatLabel);
      final outputFormat = _mapFormat(outputFormatLabel);
      outputController.text = isDecompress
          ? CompressCodec.decompress(
              input: inputController.text,
              algorithm: algorithm,
              inputFormat: inputFormat,
              outputFormat: outputFormat,
            )
          : CompressCodec.compress(
              input: inputController.text,
              algorithm: algorithm,
              inputFormat: inputFormat,
              outputFormat: outputFormat,
              level: int.parse(compressionLevel),
            );
      setState(() {});
    } catch (e) {
      showToast('${isDecompress ? '解压' : '压缩'}失败: $e', context);
    }
  }

  CompressDataFormat _mapFormat(String text) {
    return switch (text) {
      'RAW' => CompressDataFormat.raw,
      'Base64' => CompressDataFormat.base64,
      'Hex' => CompressDataFormat.hex,
      _ => throw FormatException('不支持的数据格式: $text'),
    };
  }

  void _clear() {
    if (inputController.text.isEmpty && outputController.text.isEmpty) {
      showToast('无内容可清空喵', context);
      return;
    }
    inputController.clear();
    outputController.clear();
    setState(() {});
    showToast('已清空喵', context);
  }

  Future<void> _copyText(String text) async {
    if (text.isEmpty) {
      showToast('输出为空，无法复制', context);
      return;
    }
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    showToast('已复制到剪贴板', context);
  }
}
