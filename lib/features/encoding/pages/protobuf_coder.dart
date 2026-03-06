import 'package:ctf_tools/features/encoding/utils/protobuf_encoding/parse_protobuf.dart';
import 'package:ctf_tools/shared/widgets/dropdown_menu.dart';
import 'package:ctf_tools/shared/widgets/mbutton.dart';
import 'package:ctf_tools/shared/widgets/show_toast.dart';
import 'package:ctf_tools/shared/widgets/tool_page_shell.dart';
import 'package:ctf_tools/shared/widgets/tool_status_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
    final isMobile = MediaQuery.sizeOf(context).width < 700;
    return ToolPageShell(
      title: 'ProtoBuf 编码/解码',
      description: '支持无 schema 硬解码，以及基于 proto schema 的编解码流程，尺寸与交互已统一到当前工具页体系。',
      badge: 'Encoding',
      child: Column(
        children: [
          ToolSectionCard(
            title: '参数',
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text('模式', style: TextStyle(color: scheme.onSurfaceVariant)),
                MDropdownMenu(
                  initialValue: _selectedMode,
                  items: _modes,
                  onChanged: (value) {
                    setState(() {
                      _selectedMode = value;
                    });
                  },
                ),
                Text('格式', style: TextStyle(color: scheme.onSurfaceVariant)),
                MDropdownMenu(
                  initialValue: _selectedFormat,
                  items: _formats,
                  onChanged: (value) {
                    setState(() {
                      _selectedFormat = value;
                    });
                  },
                ),
                const ToolStatusChip(label: 'Schema Optional', icon: Icons.schema),
              ],
            ),
          ),
          if (_isSchemaMode) ...[
            const SizedBox(height: kToolSectionGap),
            _buildSchemaEditor(),
          ],
          const SizedBox(height: kToolSectionGap),
          ToolSectionCard(
            title: _selectedMode == _modeSchemaEncode
                ? '输入 JSON（按 schema 字段名）'
                : '输入数据 (${_selectedFormat.toUpperCase()})',
            trailing: MElevatedButton(
              icon: Icons.copy,
              text: '复制输入',
              onPressed: () => _copy(_inputController.text),
            ),
            child: TextField(
              controller: _inputController,
              maxLines: 8,
              style: TextStyle(color: scheme.onSurface),
            ),
          ),
          const SizedBox(height: kToolSectionGap),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
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
          const SizedBox(height: kToolSectionGap),
          ToolSectionCard(
            title: _selectedMode == _modeSchemaEncode
                ? '输出 (${_selectedFormat.toUpperCase()})'
                : '输出 JSON',
            trailing: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                const ToolStatusChip(label: 'READY', icon: Icons.check_circle_outline),
                MElevatedButton(
                  icon: Icons.copy,
                  text: '复制输出',
                  onPressed: () => _copy(_outputController.text),
                ),
              ],
            ),
            child: SizedBox(
              height: isMobile ? 240 : kToolOutputHeight,
              child: TextField(
                controller: _outputController,
                maxLines: null,
                expands: true,
                readOnly: true,
                textAlignVertical: TextAlignVertical.top,
                style: TextStyle(color: scheme.onSurface),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSchemaEditor() {
    return ToolSectionCard(
      title: 'Proto Schema',
      trailing: const ToolStatusChip(label: 'Schema Mode', icon: Icons.data_object),
      child: Column(
        children: [
          TextField(
            controller: _rootMessageController,
            style: TextStyle(color: scheme.onSurface),
            decoration: const InputDecoration(
              labelText: 'Root Message（可选）',
              prefixIcon: Icon(Icons.account_tree_outlined),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _schemaController,
            maxLines: 6,
            style: TextStyle(color: scheme.onSurface),
            decoration: const InputDecoration(
              hintText: 'message User { uint32 id = 1; string name = 2; }',
              prefixIcon: Icon(Icons.schema_outlined),
            ),
          ),
        ],
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
