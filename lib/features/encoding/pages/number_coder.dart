import 'package:ctf_tools/features/encoding/utils/number_encoding/number_codec.dart';
import 'package:ctf_tools/shared/widgets/dropdown_menu.dart';
import 'package:ctf_tools/shared/widgets/mbutton.dart';
import 'package:ctf_tools/shared/widgets/show_toast.dart';
import 'package:ctf_tools/shared/widgets/tool_page_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 数值/进制转换页面。
class NumberCoder extends StatefulWidget {
  const NumberCoder({super.key});

  @override
  State<NumberCoder> createState() => _NumberCoderState();
}

class _NumberCoderState extends State<NumberCoder> {
  static const String _modeBase = '进制互转(2~64)';
  static const String _modeBinaryHex = 'Binary ↔ Hex';
  static const String _modeBcd = '十进制 ↔ BCD';
  static const List<String> _modes = [_modeBase, _modeBinaryHex, _modeBcd];

  final List<String> _bases = List<String>.generate(
    63,
    (index) => (index + 2).toString(),
  );

  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _outputController = TextEditingController();

  String _mode = _modeBase;
  String _fromBase = '10';
  String _toBase = '16';

  @override
  void dispose() {
    _inputController.dispose();
    _outputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ToolPageShell(
      title: '数值与进制转换',
      description: '覆盖 2~64 进制互转、Binary ↔ Hex 和十进制 ↔ BCD，统一为 MD3 工具页结构。',
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
                  initialValue: _mode,
                  items: _modes,
                  onChanged: (value) => setState(() {
                    _mode = value;
                  }),
                ),
                if (_mode == _modeBase) ...[
                  Text('From', style: TextStyle(color: scheme.onSurfaceVariant)),
                  MDropdownMenu(
                    initialValue: _fromBase,
                    items: _bases,
                    onChanged: (value) => setState(() {
                      _fromBase = value;
                    }),
                  ),
                  Text('To', style: TextStyle(color: scheme.onSurfaceVariant)),
                  MDropdownMenu(
                    initialValue: _toBase,
                    items: _bases,
                    onChanged: (value) => setState(() {
                      _toBase = value;
                    }),
                  ),
                  MElevatedButton(
                    icon: Icons.swap_horiz,
                    text: '换基',
                    onPressed: _swapBases,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          ToolSectionCard(
            title: '输入',
            trailing: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                MElevatedButton(
                  icon: Icons.copy,
                  text: '复制',
                  onPressed: () => _copy(_inputController.text),
                ),
                MElevatedButton(
                  icon: Icons.delete,
                  text: '清空',
                  onPressed: _clear,
                ),
              ],
            ),
            child: TextField(
              controller: _inputController,
              maxLines: 8,
              inputFormatters: const [],
              decoration: InputDecoration(hintText: _inputHint),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            runSpacing: 10,
            children: [
              MElevatedButton(
                icon: Icons.auto_fix_high,
                text: '转换',
                onPressed: _encode,
              ),
              MElevatedButton(
                icon: Icons.undo,
                text: '反向',
                onPressed: _decode,
              ),
              MElevatedButton(
                icon: Icons.swap_vert,
                text: '互换',
                onPressed: _swap,
              ),
            ],
          ),
          const SizedBox(height: 12),
          ToolSectionCard(
            title: '输出',
            trailing: MElevatedButton(
              icon: Icons.copy,
              text: '复制',
              onPressed: () => _copy(_outputController.text),
            ),
            child: SizedBox(
              height: kToolOutputHeight,
              child: TextField(
                controller: _outputController,
                maxLines: null,
                expands: true,
                readOnly: true,
                textAlignVertical: TextAlignVertical.top,
                decoration: InputDecoration(
                  hintText: '输出 (${_modeDescription(forEncode: false)})',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String get _inputHint {
    switch (_mode) {
      case _modeBase:
        return '输入 $_fromBase 进制数字';
      case _modeBinaryHex:
        return '编码: 输入二进制；解码: 输入十六进制';
      case _modeBcd:
        return '编码: 输入十进制；解码: 输入 BCD 十六进制';
      default:
        return '请输入待转换内容';
    }
  }

  String _modeDescription({required bool forEncode}) {
    if (_mode == _modeBase) {
      return forEncode ? '$_fromBase → $_toBase' : '$_toBase → $_fromBase';
    }
    if (_mode == _modeBinaryHex) {
      return forEncode ? 'Binary → Hex' : 'Hex → Binary';
    }
    return forEncode ? 'Decimal → BCD' : 'BCD → Decimal';
  }

  void _encode() {
    try {
      if (_inputController.text.trim().isEmpty) {
        showToast('请输入内容喵', context);
        return;
      }

      switch (_mode) {
        case _modeBase:
          _outputController.text = NumberCodec.convertBase(
            _inputController.text,
            fromBase: int.parse(_fromBase),
            toBase: int.parse(_toBase),
          );
          break;
        case _modeBinaryHex:
          _outputController.text = NumberCodec.binaryToHex(_inputController.text);
          break;
        case _modeBcd:
          _outputController.text = NumberCodec.decimalToBcdHex(_inputController.text);
          break;
      }
      setState(() {});
    } catch (e) {
      showToast('转换失败: $e', context);
    }
  }

  void _decode() {
    try {
      if (_inputController.text.trim().isEmpty) {
        showToast('请输入内容喵', context);
        return;
      }

      switch (_mode) {
        case _modeBase:
          _outputController.text = NumberCodec.convertBase(
            _inputController.text,
            fromBase: int.parse(_toBase),
            toBase: int.parse(_fromBase),
          );
          break;
        case _modeBinaryHex:
          _outputController.text = NumberCodec.hexToBinary(_inputController.text);
          break;
        case _modeBcd:
          _outputController.text = NumberCodec.bcdHexToDecimal(_inputController.text);
          break;
      }
      setState(() {});
    } catch (e) {
      showToast('反向转换失败: $e', context);
    }
  }

  void _swapBases() {
    final oldFrom = _fromBase;
    _fromBase = _toBase;
    _toBase = oldFrom;
    setState(() {});
  }

  void _swap() {
    final temp = _inputController.text;
    _inputController.text = _outputController.text;
    _outputController.text = temp;
    if (_mode == _modeBase) {
      _swapBases();
    } else {
      setState(() {});
    }
  }

  void _clear() {
    if (_inputController.text.isEmpty && _outputController.text.isEmpty) {
      showToast('无内容可清空喵', context);
      return;
    }
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
