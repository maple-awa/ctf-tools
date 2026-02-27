import 'package:ctf_tools/features/encoding/utils/protobuf_encoding/parse_protobuf.dart';
import 'package:ctf_tools/shared/widgets/dropdown_menu.dart';
import 'package:ctf_tools/shared/widgets/mbutton.dart';
import 'package:ctf_tools/shared/widgets/show_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ctf_tools/shared/layout/responsive.dart';

class ProtobufCoder extends StatefulWidget {
  const ProtobufCoder({super.key});

  @override
  State<ProtobufCoder> createState() => _ProtobufCoderState();
}

class _ProtobufCoderState extends State<ProtobufCoder> {
  ColorScheme get scheme => Theme.of(context).colorScheme;
  static const String _modeHardDecode = '无 Proto 硬解码';
  static const String _modeSchemaDecode = '有 Proto 解码';
  static const String _modeSchemaEncode = '有 Proto 编码';

  static const List<String> _modes = [
    _modeHardDecode,
    _modeSchemaDecode,
    _modeSchemaEncode,
  ];

  static const List<String> _formats = ['HEX', 'Base64'];

  final TextEditingController _schemaController = TextEditingController(
    text: _defaultSchema,
  );
  final TextEditingController _rootMessageController = TextEditingController(
    text: 'User',
  );
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _outputController = TextEditingController();

  String _selectedMode = _modeHardDecode;
  String _selectedFormat = _formats.first;

  bool get _isSchemaMode => _selectedMode != _modeHardDecode;

  @override
  void dispose() {
    _schemaController.dispose();
    _rootMessageController.dispose();
    _inputController.dispose();
    _outputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    return Container(
      color: scheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 10,
                runSpacing: 10,
                children: [
                  Text(
                    'ProtoBuf 编码/解码',
                    style: TextStyle(
                      fontSize: isMobile ? 22 : 26,
                      fontWeight: FontWeight.bold,
                      color: scheme.onSurface,
                    ),
                  ),
                  Text(
                    '模式',
                    style: TextStyle(
                      color: scheme.onSurfaceVariant,
                      fontSize: 16,
                    ),
                  ),
                  MDropdownMenu(
                    initialValue: _selectedMode,
                    items: _modes,
                    onChanged: (value) {
                      setState(() {
                        _selectedMode = value;
                      });
                    },
                  ),
                  Text(
                    '格式',
                    style: TextStyle(
                      color: scheme.onSurfaceVariant,
                      fontSize: 16,
                    ),
                  ),
                  MDropdownMenu(
                    initialValue: _selectedFormat,
                    items: _formats,
                    onChanged: (value) {
                      setState(() {
                        _selectedFormat = value;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (_isSchemaMode) ...[
                _buildSchemaEditor(),
                const SizedBox(height: 12),
              ],
              _buildInputHeader(),
              const SizedBox(height: 8),
              TextField(
                controller: _inputController,
                maxLines: 8,
                style: TextStyle(color: scheme.onSurface),
                decoration: _textFieldDecoration(),
              ),
              const SizedBox(height: 12),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 12,
                runSpacing: 10,
                children: [
                  MElevatedButton(
                    icon: Icons.play_arrow,
                    text: _selectedMode == _modeSchemaEncode ? '编码' : '解码',
                    onPressed: _run,
                  ),
                  MElevatedButton(
                    icon: Icons.sync_alt,
                    text: '交换',
                    onPressed: _swap,
                  ),
                  MElevatedButton(
                    icon: Icons.delete,
                    text: '清空',
                    onPressed: _clear,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildOutputHeader(),
              const SizedBox(height: 8),
              SizedBox(
                height: isMobile ? 220 : 260,
                child: TextField(
                  controller: _outputController,
                  maxLines: null,
                  expands: true,
                  readOnly: true,
                  style: TextStyle(color: scheme.onSurface),
                  decoration: _textFieldDecoration(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSchemaEditor() {
    return Column(
      children: [
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            Text(
              'Proto Schema',
              style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 16),
            ),
            SizedBox(
              width: 260,
              child: TextField(
                controller: _rootMessageController,
                style: TextStyle(color: scheme.onSurface),
                decoration: _textFieldDecoration(hintText: 'Root Message（可选）'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _schemaController,
          maxLines: 6,
          style: TextStyle(color: scheme.onSurface),
          decoration: _textFieldDecoration(
            hintText: 'message User { uint32 id = 1; string name = 2; }',
          ),
        ),
      ],
    );
  }

  Widget _buildInputHeader() {
    String label = '输入数据 (${_selectedFormat.toUpperCase()})';
    if (_selectedMode == _modeSchemaEncode) {
      label = '输入 JSON（按 schema 字段名）';
    }

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 10,
      runSpacing: 8,
      children: [
        Text(
          label,
          style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 16),
        ),
        MElevatedButton(
          icon: Icons.copy,
          text: '复制输入',
          onPressed: () => _copy(_inputController.text),
        ),
      ],
    );
  }

  Widget _buildOutputHeader() {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 10,
      runSpacing: 8,
      children: [
        Text(
          _selectedMode == _modeSchemaEncode
              ? '输出 (${_selectedFormat.toUpperCase()})'
              : '输出 JSON',
          style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 16),
        ),
        MElevatedButton(
          icon: Icons.copy,
          text: '复制输出',
          onPressed: () => _copy(_outputController.text),
        ),
      ],
    );
  }

  InputDecoration _textFieldDecoration({String? hintText}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: scheme.onSurfaceVariant),
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

  void _run() {
    try {
      final format = _selectedFormat == 'Base64'
          ? ProtobufDataFormat.base64
          : ProtobufDataFormat.hex;

      if (_selectedMode == _modeHardDecode) {
        final result = ParseProtobuf.hardDecode(
          _inputController.text,
          inputFormat: format,
        );
        _outputController.text = ParseProtobuf.prettyJson(result);
        setState(() {});
        return;
      }

      if (_selectedMode == _modeSchemaDecode) {
        final result = ParseProtobuf.decodeWithProto(
          _inputController.text,
          _schemaController.text,
          rootMessage: _rootMessageController.text.trim().isEmpty
              ? null
              : _rootMessageController.text.trim(),
          inputFormat: format,
        );
        _outputController.text = ParseProtobuf.prettyJson(result);
        setState(() {});
        return;
      }

      final encoded = ParseProtobuf.encodeWithProto(
        _inputController.text,
        _schemaController.text,
        rootMessage: _rootMessageController.text.trim().isEmpty
            ? null
            : _rootMessageController.text.trim(),
        outputFormat: format,
      );
      _outputController.text = encoded;
      setState(() {});
    } catch (e) {
      showToast('ProtoBuf 处理失败: $e', context);
    }
  }

  void _swap() {
    final tmp = _inputController.text;
    _inputController.text = _outputController.text;
    _outputController.text = tmp;
    setState(() {});
  }

  void _clear() {
    _inputController.clear();
    _outputController.clear();
    showToast('已清空喵', context);
  }

  Future<void> _copy(String text) async {
    if (text.isEmpty) {
      showToast('无内容可复制喵', context);
      return;
    }
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    showToast('复制成功喵', context);
  }
}

const String _defaultSchema = '''
syntax = "proto3";

message User {
  uint32 id = 1;
  string name = 2;
  repeated uint32 tags = 3;
}
''';
