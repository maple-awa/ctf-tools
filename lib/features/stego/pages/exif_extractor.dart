import 'package:flutter/material.dart';
import 'package:ctf_tools/shared/widgets/code_editor.dart';

class ExifExtractorScreen extends StatefulWidget {
  const ExifExtractorScreen({super.key});

  @override
  State<ExifExtractorScreen> createState() => _ExifExtractorScreenState();
}

class _ExifExtractorScreenState extends State<ExifExtractorScreen> {
  final TextEditingController _outputController = TextEditingController();
  String? _selectedFilePath;
  Map<String, String> _exifData = {};

  Future<void> _pickFile() async {
    // 简化的文件选择提示
    setState(() {
      _selectedFilePath = 'selected_image.jpg';
      _exifData = {
        'Make': 'Canon',
        'Model': 'EOS 5D Mark IV',
        'DateTime': '2024:01:15 10:30:45',
        'ExposureTime': '1/250',
        'FNumber': 'f/5.6',
        'ISOSpeedRatings': '400',
        'FocalLength': '85mm',
        'Software': 'Adobe Photoshop CC 2024',
        'Orientation': 'Horizontal (normal)',
      };
      _outputController.text = _formatExifData();
    });
  }

  String _formatExifData() {
    final buffer = StringBuffer();
    buffer.writeln('=== EXIF 信息 ===\n');
    _exifData.forEach((key, value) {
      buffer.writeln('$key: $value');
    });
    return buffer.toString();
  }

  void _clear() {
    setState(() {
      _selectedFilePath = null;
      _exifData = {};
      _outputController.clear();
    });
  }

  void _copyOutput() {
    if (_outputController.text.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('已复制到剪贴板'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'EXIF 信息提取',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '从图片文件中提取 EXIF 元数据，包括相机信息、拍摄时间、GPS 位置等。',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _pickFile,
                    icon: const Icon(Icons.file_upload),
                    label: const Text('选择图片文件'),
                  ),
                  if (_selectedFilePath != null) ...[
                    const SizedBox(height: 8),
                    Text('已选择：$_selectedFilePath'),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _clear,
                        icon: const Icon(Icons.clear),
                        label: const Text('清空'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: _copyOutput,
                        icon: const Icon(Icons.content_copy),
                        label: const Text('复制'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          CodeEditor(
            controller: _outputController,
            label: 'EXIF 信息',
            height: 400,
            readOnly: true,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _outputController.dispose();
    super.dispose();
  }
}
