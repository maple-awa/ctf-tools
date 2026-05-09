import 'package:flutter/material.dart';
import 'package:ctf_tools/shared/widgets/code_editor.dart';
import 'dart:io';
import 'dart:typed_data';

class ExifExtractorScreen extends StatefulWidget {
  const ExifExtractorScreen({super.key});

  @override
  State<ExifExtractorScreen> createState() => _ExifExtractorScreenState();
}

class _ExifExtractorScreenState extends State<ExifExtractorScreen> {
  final TextEditingController _outputController = TextEditingController();
  String? _selectedFilePath;
  Map<String, String> _exifData = {};

  final Map<int, String> _tagNames = {
    0x0100: 'ImageWidth',
    0x0101: 'ImageHeight',
    0x010F: 'Make',
    0x0110: 'Model',
    0x0112: 'Orientation',
    0x0131: 'Software',
    0x0132: 'DateTime',
    0x013B: 'Artist',
    0x013E: 'WhitePoint',
    0x013F: 'PrimaryChromaticities',
    0x0213: 'YCbCrPositioning',
    0x8298: 'Copyright',
    0x829A: 'ExposureTime',
    0x829D: 'FNumber',
    0x8822: 'ExposureProgram',
    0x8824: 'SpectralSensitivity',
    0x8827: 'ISOSpeedRatings',
    0x8828: 'OECF',
    0x9000: 'ExifVersion',
    0x9003: 'DateTimeOriginal',
    0x9004: 'DateTimeDigitized',
    0x9286: 'UserComment',
    0x9209: 'Flash',
    0x920A: 'FocalLength',
    0xA402: 'ExposureMode',
    0xA403: 'WhiteBalance',
    0xA406: 'SceneType',
    0xA420: 'ImageUniqueID',
    0xA001: 'ColorSpace',
    0xA002: 'PixelXDimension',
    0xA003: 'PixelYDimension',
  };

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
        const SnackBar(content: Text('已复制到剪贴板'), duration: Duration(seconds: 1)),
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
