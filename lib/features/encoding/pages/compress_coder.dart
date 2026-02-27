import 'package:ctf_tools/features/encoding/utils/compress/compress_codec.dart';
import 'package:ctf_tools/shared/widgets/dropdown_menu.dart';
import 'package:ctf_tools/shared/widgets/mbutton.dart';
import 'package:ctf_tools/shared/widgets/show_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CompressCoderScreen extends StatefulWidget {
  const CompressCoderScreen({super.key});

  @override
  State<StatefulWidget> createState() => _CompressCoderScreen();
}

class _CompressCoderScreen extends State<CompressCoderScreen> {
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
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFF101622),
        appBar: AppBar(
          backgroundColor: const Color(0xFF101622),
          title: const Text(
            "Gzip/Zlib 压缩/解压",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFFE1D4),
            ),
          ),
          centerTitle: false,
        ),
        body: Column(
          children: [
            const SizedBox(height: 8),
            const TabBar(
              labelColor: Colors.white,
              unselectedLabelColor: Color(0xFF9497A0),
              indicatorColor: Color(0xFF2B64D1),
              tabs: [
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.folder_zip),
                      SizedBox(width: 8),
                      Text("Gzip"),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.zoom_in_map),
                      SizedBox(width: 8),
                      Text("Zlib"),
                    ],
                  ),
                ),
              ],
            ),
            Expanded(
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
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              const Text(
                "输入格式",
                style: TextStyle(color: Color(0xFF9497A0), fontSize: 16),
              ),
              const SizedBox(width: 6),
              MDropdownMenu(
                initialValue: inputFormatLabel,
                items: _formatItems,
                onChanged: (value) {
                  setState(() {
                    inputFormatLabel = value;
                  });
                },
              ),
              const SizedBox(width: 16),
              const Text(
                "输出格式",
                style: TextStyle(color: Color(0xFF9497A0), fontSize: 16),
              ),
              const SizedBox(width: 6),
              MDropdownMenu(
                initialValue: outputFormatLabel,
                items: _formatItems,
                onChanged: (value) {
                  setState(() {
                    outputFormatLabel = value;
                  });
                },
              ),
              const SizedBox(width: 16),
              const Text(
                "压缩级别",
                style: TextStyle(color: Color(0xFF9497A0), fontSize: 16),
              ),
              const SizedBox(width: 6),
              MDropdownMenu(
                initialValue: compressionLevel,
                items: _levelItems,
                onChanged: (value) {
                  setState(() {
                    compressionLevel = value;
                  });
                },
              ),
              const Spacer(),
              MElevatedButton(
                icon: Icons.copy,
                text: "复制输出",
                onPressed: () => _copyText(outputController.text),
              ),
              const SizedBox(width: 12),
              MElevatedButton(
                icon: Icons.delete,
                text: "清空",
                onPressed: _clear,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Text(
                "输入框 (INPUT)",
                style: TextStyle(color: Color(0xFF9497A0), fontSize: 16),
              ),
              const SizedBox(width: 12),
              _tag(
                inputFormatLabel,
                const Color(0xFF122244),
                const Color(0xFF2B64D1),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            maxLines: 7,
            controller: inputController,
            style: const TextStyle(color: Colors.white),
            decoration: _textFieldDecoration(),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MElevatedButton(
                icon: Icons.compress,
                iconColor: Colors.white,
                text: "压缩",
                textColor: Colors.white,
                onPressed: () => _process(algorithm, false),
              ),
              const SizedBox(width: 20),
              MElevatedButton(
                icon: Icons.unarchive,
                iconColor: Colors.white,
                text: "解压",
                textColor: Colors.white,
                onPressed: () => _process(algorithm, true),
              ),
              const SizedBox(width: 20),
              MElevatedButton(
                icon: Icons.sync_outlined,
                iconColor: Colors.white,
                text: "交换",
                textColor: Colors.white,
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
              const Text(
                "输出框 (OUTPUT)",
                style: TextStyle(color: Color(0xFF9497A0), fontSize: 16),
              ),
              const SizedBox(width: 12),
              _tag(
                outputFormatLabel,
                const Color(0xFF0C312D),
                const Color(0xFF0F9F6D),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: TextField(
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              controller: outputController,
              style: const TextStyle(color: Colors.white),
              decoration: _textFieldDecoration(),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _textFieldDecoration() {
    return InputDecoration(
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF0F17AA)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 1.5),
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

  void _process(CompressAlgorithm algorithm, bool isDecompress) {
    try {
      final inputFormat = _mapFormat(inputFormatLabel);
      final outputFormat = _mapFormat(outputFormatLabel);
      final result = isDecompress
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
      setState(() {
        outputController.text = result;
      });
    } catch (e) {
      showToast("${isDecompress ? '解压' : '压缩'}失败: $e", context);
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
        throw FormatException("不支持的数据格式: $text");
    }
  }

  void _clear() {
    if (inputController.text.isEmpty && outputController.text.isEmpty) {
      showToast("无内容可清空喵", context);
      return;
    }
    setState(() {
      inputController.clear();
      outputController.clear();
    });
    showToast("已清空喵", context);
  }

  Future<void> _copyText(String text) async {
    if (text.isEmpty) {
      showToast("输出为空，无法复制", context);
      return;
    }
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    showToast("已复制到剪贴板", context);
  }
}
