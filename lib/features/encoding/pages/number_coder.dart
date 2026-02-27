import 'package:ctf_tools/features/encoding/utils/number_encoding/number_codec.dart';
import 'package:ctf_tools/shared/widgets/dropdown_menu.dart';
import 'package:ctf_tools/shared/widgets/show_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 数值/进制转换页面。
class NumberCoder extends StatefulWidget {
  const NumberCoder({super.key});

  @override
  State<NumberCoder> createState() => _NumberCoderState();
}

class _NumberCoderState extends State<NumberCoder> {
  ColorScheme get scheme => Theme.of(context).colorScheme;
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
    return Container(
      color: scheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    Text(
                      '数值与进制转换',
                      style: TextStyle(
                        fontSize: 26,
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
                      initialValue: _mode,
                      items: _modes,
                      onChanged: (value) {
                        setState(() {
                          _mode = value;
                        });
                      },
                    ),
                    if (_mode == _modeBase) ...[
                      Text(
                        'From',
                        style: TextStyle(
                          color: scheme.onSurfaceVariant,
                          fontSize: 16,
                        ),
                      ),
                      MDropdownMenu(
                        initialValue: _fromBase,
                        items: _bases,
                        onChanged: (value) {
                          setState(() {
                            _fromBase = value;
                          });
                        },
                      ),
                      Text(
                        'To',
                        style: TextStyle(
                          color: scheme.onSurfaceVariant,
                          fontSize: 16,
                        ),
                      ),
                      MDropdownMenu(
                        initialValue: _toBase,
                        items: _bases,
                        onChanged: (value) {
                          setState(() {
                            _toBase = value;
                          });
                        },
                      ),
                      _compactButton(
                        icon: Icons.swap_horiz,
                        text: '换基',
                        onPressed: _swapBases,
                      ),
                    ],
                  ],
                ),
              ),
              if (_mode == _modeBase) ...[
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '字符集: 0-9 A-Z a-z + /（2~36 支持小写兼容输入）',
                    style: TextStyle(
                      color: scheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              _buildInputHeader(),
              const SizedBox(height: 10),
              TextField(
                controller: _inputController,
                maxLines: 8,
                style: TextStyle(color: scheme.onSurface),
                decoration: _inputDecoration(hintText: _inputHint),
              ),
              const SizedBox(height: 16),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  _compactButton(
                    icon: Icons.auto_fix_high,
                    text: '转',
                    onPressed: _encode,
                  ),
                  _compactButton(
                    icon: Icons.undo,
                    text: '反转',
                    onPressed: _decode,
                  ),
                  _compactButton(
                    icon: Icons.swap_vert,
                    text: '互换',
                    onPressed: _swap,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildOutputHeader(),
              const SizedBox(height: 10),
              SizedBox(
                height: 260,
                child: TextField(
                  controller: _outputController,
                  textAlignVertical: TextAlignVertical.top,
                  maxLines: null,
                  expands: true,
                  readOnly: true,
                  style: TextStyle(color: scheme.onSurface),
                  decoration: _inputDecoration(hintText: '转换结果输出在这里'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputHeader() {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: [
        Text(
          '输入 (${_modeDescription(forEncode: true)})',
          style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 16),
        ),
        _compactButton(
          icon: Icons.content_copy,
          text: '复制',
          onPressed: () => _copy(_inputController.text),
        ),
        _compactButton(icon: Icons.clear, text: '清空', onPressed: _clear),
      ],
    );
  }

  Widget _buildOutputHeader() {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: [
        Text(
          '输出 (${_modeDescription(forEncode: false)})',
          style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 16),
        ),
        _compactButton(
          icon: Icons.content_copy,
          text: '复制',
          onPressed: () => _copy(_outputController.text),
        ),
      ],
    );
  }

  Widget _compactButton({
    required IconData icon,
    required String text,
    required VoidCallback onPressed,
  }) {
    return FilledButton.icon(
      style: FilledButton.styleFrom(
        backgroundColor: scheme.primary.withValues(alpha: 0.18),
        foregroundColor: scheme.onSurface,
        visualDensity: VisualDensity.compact,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        minimumSize: const Size(0, 34),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(text, style: TextStyle(fontSize: 12)),
    );
  }

  InputDecoration _inputDecoration({String? hintText}) {
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

  String get _inputHint {
    switch (_mode) {
      case _modeBase:
        return '输入 $_fromBase 进制数字，例如 ${_fromBase == '10' ? '12345' : '1010'}';
      case _modeBinaryHex:
        return '编码: 输入二进制；解码: 输入十六进制';
      case _modeBcd:
        return '编码: 输入十进制数字；解码: 输入 BCD 十六进制';
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
          _outputController.text = NumberCodec.binaryToHex(
            _inputController.text,
          );
          break;
        case _modeBcd:
          _outputController.text = NumberCodec.decimalToBcdHex(
            _inputController.text,
          );
          break;
      }
      setState(() {});
    } catch (e) {
      showToast('编码失败: $e', context);
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
          _outputController.text = NumberCodec.hexToBinary(
            _inputController.text,
          );
          break;
        case _modeBcd:
          _outputController.text = NumberCodec.bcdHexToDecimal(
            _inputController.text,
          );
          break;
      }
      setState(() {});
    } catch (e) {
      showToast('解码失败: $e', context);
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
      return;
    }

    setState(() {});
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
