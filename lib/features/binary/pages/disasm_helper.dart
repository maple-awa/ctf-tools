import 'package:ctf_tools/features/binary/utils/rop_gadget_finder.dart';
import 'package:ctf_tools/features/binary/utils/simple_disassembler.dart';
import 'package:ctf_tools/shared/widgets/dropdown_menu.dart';
import 'package:ctf_tools/shared/widgets/mbutton.dart';
import 'package:ctf_tools/shared/widgets/tool_page_shell.dart';
import 'package:flutter/material.dart';

class BinaryDisasmHelperScreen extends StatefulWidget {
  const BinaryDisasmHelperScreen({super.key});

  @override
  State<BinaryDisasmHelperScreen> createState() => _BinaryDisasmHelperScreenState();
}

class _BinaryDisasmHelperScreenState extends State<BinaryDisasmHelperScreen> {
  final inputController = TextEditingController(text: '55 48 89 E5 5F C3 48 31 C0 C3 0F 05');
  String selectedMode = SimpleDisassembler.modes.last;
  String summaryOutput = '';
  String instructionOutput = '';

  @override
  void dispose() {
    inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ToolPageShell(
      title: '反汇编与代码分析',
      description: '在离线 opcode 反汇编基础上补充 ROP gadget 检索和简化控制流摘要。',
      badge: 'Binary',
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
                  initialValue: selectedMode,
                  items: SimpleDisassembler.modes,
                  onChanged: (value) => setState(() {
                    selectedMode = value;
                  }),
                ),
              ],
            ),
          ),
          const SizedBox(height: kToolSectionGap),
          ToolSectionCard(
            title: 'Opcode / Shellcode 输入',
            child: TextField(
              controller: inputController,
              maxLines: 8,
              decoration: const InputDecoration(
                hintText: '粘贴十六进制机器码，例如 55 48 89 E5 ...',
                prefixIcon: Icon(Icons.code),
              ),
            ),
          ),
          const SizedBox(height: kToolSectionGap),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            runSpacing: 10,
            children: [
              MElevatedButton(icon: Icons.play_arrow, text: '反汇编 + gadget', onPressed: _disassemble),
            ],
          ),
          const SizedBox(height: kToolSectionGap),
          ToolSectionCard(title: '摘要', child: SelectableText(summaryOutput.isEmpty ? '暂无结果' : summaryOutput)),
          const SizedBox(height: kToolSectionGap),
          ToolSectionCard(title: '指令 / Gadget', child: SelectableText(instructionOutput.isEmpty ? '暂无结果' : instructionOutput)),
        ],
      ),
    );
  }

  void _disassemble() {
    try {
      final result = SimpleDisassembler.disassembleHex(inputController.text, mode: selectedMode);
      final gadgets = RopGadgetFinder.findHex(inputController.text);
      final flowHints = <String>[];
      if (result.instructions.any((instruction) => instruction.prettyLine.contains('call'))) {
        flowHints.add('检测到 call 指令，样本可能包含子过程调用');
      }
      if (result.instructions.any((instruction) => instruction.prettyLine.contains('jmp'))) {
        flowHints.add('检测到跳转指令，存在控制流分支');
      }
      if (result.instructions.any((instruction) => instruction.prettyLine.contains('ret'))) {
        flowHints.add('检测到 ret 指令，适合进一步做 gadget 检索');
      }
      setState(() {
        summaryOutput = [
          'Mode: ${result.mode}',
          'Bytes: ${result.byteLength}',
          'Instructions: ${result.instructions.length}',
          'ASCII Preview: ${result.asciiPreview}',
          'Gadgets: ${gadgets.gadgets.length}',
          if (flowHints.isNotEmpty) '',
          if (flowHints.isNotEmpty) 'Flow Summary:',
          if (flowHints.isNotEmpty) ...flowHints,
          if (result.warnings.isNotEmpty) '',
          if (result.warnings.isNotEmpty) 'Warnings:',
          if (result.warnings.isNotEmpty) ...result.warnings,
        ].join('\n');
        instructionOutput = [
          ...result.instructions.map((instruction) => instruction.prettyLine),
          if (gadgets.gadgets.isNotEmpty) '',
          if (gadgets.gadgets.isNotEmpty) 'Gadgets:',
          if (gadgets.gadgets.isNotEmpty) ...gadgets.gadgets,
        ].join('\n');
      });
    } catch (error) {
      setState(() {
        summaryOutput = '反汇编失败: $error';
        instructionOutput = '';
      });
    }
  }
}
