import 'package:ctf_tools/features/encoding/utils/compress/compress_codec.dart';
import 'package:ctf_tools/shared/layout/responsive.dart';
import 'package:ctf_tools/shared/widgets/dropdown_menu.dart';
import 'package:ctf_tools/shared/widgets/mbutton.dart';
import 'package:ctf_tools/shared/widgets/show_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Gzip 编解码子页面。
class GzipCoderScreen extends StatefulWidget {
  const GzipCoderScreen({super.key});

  @override
  State<StatefulWidget> createState() => _GzipCoderScreen();
}

class _GzipCoderScreen extends State<GzipCoderScreen> {
  ColorScheme get scheme => Theme.of(context).colorScheme;
  final TextEditingController inputController = TextEditingController();
  final TextEditingController outputController = TextEditingController();

  String inputFormatLabel = 'RAW';
  String outputFormatLabel = 'Base64';
  String compressionLevel = '6';
  String swapTextTemp = '';

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
    final isMobile = Responsive.isMobile(context);
    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        backgroundColor: scheme.surface,
        title: Text(
          'Gzip 编解码',
          style: TextStyle(
            fontSize: isMobile ? 22 : 26,
            fontWeight: FontWeight.bold,
            color: scheme.onSurface,
          ),
        ),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 10,
              runSpacing: 10,
              children: [
                Text(
                  '输入格式',
                  style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 16),
                ),
                MDropdownMenu(
                  initialValue: inputFormatLabel,
                  items: _formatItems,
                  onChanged: (value) {
                    setState(() {
                      inputFormatLabel = value;
                    });
                  },
                ),
                Text(
                  '输出格式',
                  style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 16),
                ),
                MDropdownMenu(
                  initialValue: outputFormatLabel,
                  items: _formatItems,
                  onChanged: (value) {
                    setState(() {
                      outputFormatLabel = value;
                    });
                  },
                ),
                Text(
                  '压缩级别',
                  style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 16),
                ),
                MDropdownMenu(
                  initialValue: compressionLevel,
                  items: _levelItems,
                  onChanged: (value) {
                    setState(() {
                      compressionLevel = value;
                    });
                  },
                ),
                MElevatedButton(
                  icon: Icons.copy,
                  text: '复制输出',
                  onPressed: () => _copyText(outputController.text),
                ),
                MElevatedButton(
                  icon: Icons.delete,
                  text: '清空',
                  onPressed: _clear,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Text(
                  '输入框 (INPUT)',
                  style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 16),
                ),
                const SizedBox(width: 12),
                _tag(
                  inputFormatLabel,
                  scheme.primary.withValues(alpha: 0.18),
                  scheme.primary,
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              maxLines: 7,
              controller: inputController,
              style: TextStyle(color: scheme.onSurface),
              decoration: _textFieldDecoration(),
            ),
            const SizedBox(height: 20),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 12,
              runSpacing: 10,
              children: [
                MElevatedButton(
                  icon: Icons.compress,
                  iconColor: scheme.onSurface,
                  text: '压缩',
                  textColor: scheme.onSurface,
                  onPressed: () => _process(false),
                ),
                MElevatedButton(
                  icon: Icons.unarchive,
                  iconColor: scheme.onSurface,
                  text: '解压',
                  textColor: scheme.onSurface,
                  onPressed: () => _process(true),
                ),
                MElevatedButton(
                  icon: Icons.sync_outlined,
                  iconColor: scheme.onSurface,
                  text: '交换',
                  textColor: scheme.onSurface,
                  onPressed: () {
                    setState(() {
                      swapTextTemp = inputController.text;
                      inputController.text = outputController.text;
                      outputController.text = swapTextTemp;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Text(
                  '输出框 (OUTPUT)',
                  style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 16),
                ),
                const SizedBox(width: 12),
                _tag(
                  outputFormatLabel,
                  scheme.secondary.withValues(alpha: 0.18),
                  scheme.secondary,
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (isMobile)
              SizedBox(height: 260, child: _buildOutputField())
            else
              Expanded(child: _buildOutputField()),
          ],
        ),
      ),
    );
  }

  Widget _buildOutputField() {
    return TextField(
      maxLines: null,
      expands: true,
      textAlignVertical: TextAlignVertical.top,
      controller: outputController,
      style: TextStyle(color: scheme.onSurface),
      decoration: _textFieldDecoration(),
    );
  }

  InputDecoration _textFieldDecoration() {
    return InputDecoration(
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: scheme.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: scheme.primary, width: 1.5),
      ),
    );
  }

  Widget _tag(String text, Color bgColor, Color textColor) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(5),
      child: Text(text, style: TextStyle(color: textColor)),
    );
  }

  void _process(bool isDecompress) {
    try {
      final inputFormat = _mapFormat(inputFormatLabel);
      final outputFormat = _mapFormat(outputFormatLabel);
      final result = isDecompress
          ? CompressCodec.decompress(
              input: inputController.text,
              algorithm: CompressAlgorithm.gzip,
              inputFormat: inputFormat,
              outputFormat: outputFormat,
            )
          : CompressCodec.compress(
              input: inputController.text,
              algorithm: CompressAlgorithm.gzip,
              inputFormat: inputFormat,
              outputFormat: outputFormat,
              level: int.parse(compressionLevel),
            );
      setState(() {
        outputController.text = result;
      });
    } catch (e) {
      showToast('${isDecompress ? '解压' : '压缩'}失败: $e', context);
    }
  }

  CompressDataFormat _mapFormat(String text) {
    switch (text) {
      case 'RAW':
        return CompressDataFormat.raw;
      case 'Base64':
        return CompressDataFormat.base64;
      case 'Hex':
        return CompressDataFormat.hex;
      default:
        throw FormatException('不支持的数据格式: $text');
    }
  }

  void _clear() {
    if (inputController.text.isEmpty && outputController.text.isEmpty) {
      showToast('无内容可清空喵', context);
      return;
    }
    setState(() {
      inputController.clear();
      outputController.clear();
    });
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
