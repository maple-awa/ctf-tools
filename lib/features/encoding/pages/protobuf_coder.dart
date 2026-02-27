import 'package:ctf_tools/features/encoding/utils/protobuf_encoding/parse_protobuf.dart';
import 'package:ctf_tools/shared/widgets/dropdown_menu.dart';
import 'package:ctf_tools/shared/widgets/mbutton.dart';
import 'package:ctf_tools/shared/widgets/show_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ProtobufCoder extends StatefulWidget {
  const ProtobufCoder({super.key});

  @override
  State<ProtobufCoder> createState() => _ProtobufCoderState();
}

class _ProtobufCoderState extends State<ProtobufCoder> {
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
    return Container(
      color: const Color(0xFF101622),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                children: [
                  const Text(
                    'ProtoBuf 编码/解码',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFFE1D4),
                    ),
                  ),
                  const SizedBox(width: 20),
                  const Text(
                    '模式',
                    style: TextStyle(color: Color(0xFF9497A0), fontSize: 16),
                  ),
                  const SizedBox(width: 6),
                  MDropdownMenu(
                    initialValue: _selectedMode,
                    items: _modes,
                    onChanged: (value) {
                      setState(() {
                        _selectedMode = value;
                      });
                    },
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    '格式',
                    style: TextStyle(color: Color(0xFF9497A0), fontSize: 16),
                  ),
                  const SizedBox(width: 6),
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
                style: const TextStyle(color: Colors.white),
                decoration: _textFieldDecoration(),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MElevatedButton(
                    icon: Icons.play_arrow,
                    text: _selectedMode == _modeSchemaEncode ? '编码' : '解码',
                    onPressed: _run,
                  ),
                  const SizedBox(width: 12),
                  MElevatedButton(
                    icon: Icons.sync_alt,
                    text: '交换',
                    onPressed: _swap,
                  ),
                  const SizedBox(width: 12),
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
                height: 260,
                child: TextField(
                  controller: _outputController,
                  maxLines: null,
                  expands: true,
                  readOnly: true,
                  style: const TextStyle(color: Colors.white),
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
        Row(
          children: [
            const Text(
              'Proto Schema',
              style: TextStyle(color: Color(0xFF9497A0), fontSize: 16),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 220,
              child: TextField(
                controller: _rootMessageController,
                style: const TextStyle(color: Colors.white),
                decoration: _textFieldDecoration(hintText: 'Root Message（可选）'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _schemaController,
          maxLines: 6,
          style: const TextStyle(color: Colors.white),
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

    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(color: Color(0xFF9497A0), fontSize: 16),
        ),
        const Spacer(),
        MElevatedButton(
          icon: Icons.copy,
          text: '复制输入',
          onPressed: () => _copy(_inputController.text),
        ),
      ],
    );
  }

  Widget _buildOutputHeader() {
    return Row(
      children: [
        Text(
          _selectedMode == _modeSchemaEncode
              ? '输出 (${_selectedFormat.toUpperCase()})'
              : '输出 JSON',
          style: const TextStyle(color: Color(0xFF9497A0), fontSize: 16),
        ),
        const Spacer(),
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
      hintStyle: const TextStyle(color: Color(0xFF6B7280)),
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
