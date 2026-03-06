import 'package:ctf_tools/shared/utils/hex_input.dart';

class SimpleDisassembler {
  static const List<String> modes = ['x86 (32-bit)', 'x86_64 (64-bit)'];

  static DisasmResult disassembleHex(String input, {required String mode}) {
    final bytes = HexInput.parseBytes(
      input,
      minBytes: 1,
      errorMessage: '请输入至少 1 字节 shellcode/opcode 十六进制数据',
    );
    final is64 = mode == modes[1];
    final instructions = _decode(bytes, is64: is64);
    final warnings = <String>[];
    final unknownCount = instructions.where((item) => item.isUnknown).length;
    if (unknownCount > 0) {
      warnings.add('存在 $unknownCount 条未识别指令，已按 db 形式保留原始字节');
    }
    if (instructions.length == 1 && instructions.first.isUnknown) {
      warnings.add('当前离线反汇编器只覆盖常见 x86/x64 指令子集');
    }

    return DisasmResult(
      mode: mode,
      byteLength: bytes.length,
      asciiPreview: HexInput.asciiPreview(bytes),
      instructions: instructions,
      warnings: warnings,
    );
  }

  static List<DisasmInstruction> _decode(List<int> bytes, {required bool is64}) {
    final result = <DisasmInstruction>[];
    var offset = 0;

    while (offset < bytes.length) {
      final start = offset;
      final prefix = _readRexPrefix(bytes, offset, is64: is64);
      if (prefix != null) {
        offset++;
        if (offset >= bytes.length) {
          result.add(
            _instruction(
              bytes,
              start,
              offset,
              'rex',
              note: '孤立的 REX 前缀',
              isUnknown: true,
            ),
          );
          break;
        }
      }

      final opcode = bytes[offset];
      offset++;

      if (opcode == 0x90) {
        result.add(_instruction(bytes, start, offset, 'nop'));
        continue;
      }
      if (opcode == 0xCC) {
        result.add(_instruction(bytes, start, offset, 'int3'));
        continue;
      }
      if (opcode == 0xC3) {
        result.add(_instruction(bytes, start, offset, 'ret'));
        continue;
      }
      if (opcode == 0xCD && offset < bytes.length) {
        final imm = bytes[offset++];
        result.add(_instruction(bytes, start, offset, 'int', operand: '0x${_hex8(imm)}'));
        continue;
      }
      if (opcode >= 0x50 && opcode <= 0x57) {
        final reg = _regName(
          opcode - 0x50 + (prefix?.bExtension ?? 0),
          is64Mode: is64,
          operand64: is64,
        );
        result.add(_instruction(bytes, start, offset, 'push', operand: reg));
        continue;
      }
      if (opcode >= 0x58 && opcode <= 0x5F) {
        final reg = _regName(
          opcode - 0x58 + (prefix?.bExtension ?? 0),
          is64Mode: is64,
          operand64: is64,
        );
        result.add(_instruction(bytes, start, offset, 'pop', operand: reg));
        continue;
      }
      if (opcode == 0x68 && offset + 4 <= bytes.length) {
        final imm = _readLe(bytes, offset, 4);
        offset += 4;
        result.add(_instruction(bytes, start, offset, 'push', operand: '0x${_hexValue(imm, 8)}'));
        continue;
      }
      if (opcode == 0x6A && offset < bytes.length) {
        final imm = bytes[offset++];
        result.add(_instruction(bytes, start, offset, 'push', operand: '0x${_hex8(imm)}'));
        continue;
      }
      if (opcode >= 0xB8 && opcode <= 0xBF) {
        final force64 = prefix?.wBit ?? false;
        final immSize = is64 && force64 ? 8 : 4;
        if (offset + immSize <= bytes.length) {
          final imm = _readLe(bytes, offset, immSize);
          offset += immSize;
          final reg = _regName(
            opcode - 0xB8 + (prefix?.bExtension ?? 0),
            is64Mode: is64,
            operand64: force64,
          );
          result.add(
            _instruction(
              bytes,
              start,
              offset,
              'mov',
              operand: '$reg, 0x${_hexValue(imm, immSize * 2)}',
            ),
          );
          continue;
        }
      }
      if ((opcode == 0xE8 || opcode == 0xE9) && offset + 4 <= bytes.length) {
        final rel = _signed(_readLe(bytes, offset, 4), 32);
        offset += 4;
        final target = offset + rel;
        result.add(
          _instruction(
            bytes,
            start,
            offset,
            opcode == 0xE8 ? 'call' : 'jmp',
            operand: '0x${target.toRadixString(16).toUpperCase()}',
          ),
        );
        continue;
      }
      if (opcode == 0xEB && offset < bytes.length) {
        final rel = _signed(bytes[offset++], 8);
        final target = offset + rel;
        result.add(
          _instruction(
            bytes,
            start,
            offset,
            'jmp',
            operand: '0x${target.toRadixString(16).toUpperCase()}',
          ),
        );
        continue;
      }
      if (opcode >= 0x70 && opcode <= 0x7F && offset < bytes.length) {
        final rel = _signed(bytes[offset++], 8);
        final target = offset + rel;
        result.add(
          _instruction(
            bytes,
            start,
            offset,
            _conditionMnemonic(opcode),
            operand: '0x${target.toRadixString(16).toUpperCase()}',
          ),
        );
        continue;
      }
      if (opcode == 0x83 && offset < bytes.length) {
        final modrm = bytes[offset++];
        final group = (modrm >> 3) & 0x07;
        final mod = (modrm >> 6) & 0x03;
        final rm = modrm & 0x07;
        if (mod == 0x03 && offset < bytes.length) {
          final imm = bytes[offset++];
          final target = _regName(
            rm + (prefix?.bExtension ?? 0),
            is64Mode: is64,
            operand64: prefix?.wBit ?? false,
          );
          result.add(
            _instruction(
              bytes,
              start,
              offset,
              _group1Mnemonic(group),
              operand: '$target, 0x${_hex8(imm)}',
            ),
          );
          continue;
        }
      }
      if ((opcode == 0x31 || opcode == 0x33 || opcode == 0x89 || opcode == 0x8B) &&
          offset < bytes.length) {
        final modrm = bytes[offset++];
        final decoded = _decodeRegisterModrm(
          opcode,
          modrm,
          is64: is64,
          prefix: prefix,
        );
        result.add(
          _instruction(
            bytes,
            start,
            offset,
            decoded.mnemonic,
            operand: decoded.operand,
            note: decoded.note,
            isUnknown: decoded.isUnknown,
          ),
        );
        continue;
      }

      result.add(
        _instruction(
          bytes,
          start,
          offset,
          'db',
          operand: '0x${_hex8(opcode)}',
          isUnknown: true,
        ),
      );
    }

    return result;
  }

  static _DecodedRegisterInstruction _decodeRegisterModrm(
    int opcode,
    int modrm, {
    required bool is64,
    required _RexPrefix? prefix,
  }) {
    final mod = (modrm >> 6) & 0x03;
    if (mod != 0x03) {
      return _DecodedRegisterInstruction(
        mnemonic: _mnemonicForOpcode(opcode),
        operand: 'modrm 0x${_hex8(modrm)}',
        note: '当前仅对寄存器直寻址做离线解析',
        isUnknown: true,
      );
    }

    final regField = ((modrm >> 3) & 0x07) + (prefix?.rExtension ?? 0);
    final rmField = (modrm & 0x07) + (prefix?.bExtension ?? 0);
    final operand64 = prefix?.wBit ?? false;
    final left = _regName(regField, is64Mode: is64, operand64: operand64);
    final right = _regName(rmField, is64Mode: is64, operand64: operand64);

    return switch (opcode) {
      0x31 => _DecodedRegisterInstruction(mnemonic: 'xor', operand: '$right, $left'),
      0x33 => _DecodedRegisterInstruction(mnemonic: 'xor', operand: '$left, $right'),
      0x89 => _DecodedRegisterInstruction(mnemonic: 'mov', operand: '$right, $left'),
      0x8B => _DecodedRegisterInstruction(mnemonic: 'mov', operand: '$left, $right'),
      _ => _DecodedRegisterInstruction(
          mnemonic: 'db',
          operand: '0x${_hex8(opcode)}',
          isUnknown: true,
        ),
    };
  }

  static DisasmInstruction _instruction(
    List<int> bytes,
    int start,
    int end,
    String mnemonic, {
    String? operand,
    String? note,
    bool isUnknown = false,
  }) {
    return DisasmInstruction(
      offset: start,
      bytes: HexInput.formatBytes(bytes.sublist(start, end), columns: 0),
      mnemonic: mnemonic,
      operand: operand,
      note: note,
      isUnknown: isUnknown,
    );
  }

  static _RexPrefix? _readRexPrefix(List<int> bytes, int offset, {required bool is64}) {
    if (!is64 || offset >= bytes.length) return null;
    final value = bytes[offset];
    if (value < 0x40 || value > 0x4F) return null;
    return _RexPrefix(
      wBit: (value & 0x08) != 0,
      rExtension: (value & 0x04) != 0 ? 8 : 0,
      bExtension: (value & 0x01) != 0 ? 8 : 0,
    );
  }

  static String _regName(
    int index, {
    required bool is64Mode,
    required bool operand64,
  }) {
    const regs32 = ['eax', 'ecx', 'edx', 'ebx', 'esp', 'ebp', 'esi', 'edi'];
    const regs64 = ['rax', 'rcx', 'rdx', 'rbx', 'rsp', 'rbp', 'rsi', 'rdi'];
    if (index >= 8) {
      return operand64 ? 'r$index' : 'r${index}d';
    }
    if (!is64Mode) return regs32[index];
    return operand64 ? regs64[index] : regs32[index];
  }

  static String _conditionMnemonic(int opcode) {
    const names = {
      0x74: 'je',
      0x75: 'jne',
      0x72: 'jb',
      0x73: 'jae',
      0x76: 'jbe',
      0x77: 'ja',
      0x78: 'js',
      0x79: 'jns',
      0x7C: 'jl',
      0x7D: 'jge',
      0x7E: 'jle',
      0x7F: 'jg',
    };
    return names[opcode] ?? 'jcc';
  }

  static String _group1Mnemonic(int group) {
    return switch (group) {
      0 => 'add',
      1 => 'or',
      4 => 'and',
      5 => 'sub',
      6 => 'xor',
      7 => 'cmp',
      _ => 'grp1',
    };
  }

  static String _mnemonicForOpcode(int opcode) {
    if (opcode == 0x31 || opcode == 0x33) return 'xor';
    if (opcode == 0x89 || opcode == 0x8B) return 'mov';
    return 'db';
  }

  static int _readLe(List<int> bytes, int offset, int size) {
    var value = 0;
    for (var i = 0; i < size; i++) {
      value |= bytes[offset + i] << (i * 8);
    }
    return value;
  }

  static int _signed(int value, int bits) {
    final signBit = 1 << (bits - 1);
    return (value & signBit) == 0 ? value : value - (1 << bits);
  }

  static String _hex8(int value) => value.toRadixString(16).padLeft(2, '0').toUpperCase();

  static String _hexValue(int value, int width) {
    return value.toRadixString(16).padLeft(width, '0').toUpperCase();
  }
}

class DisasmResult {
  const DisasmResult({
    required this.mode,
    required this.byteLength,
    required this.asciiPreview,
    required this.instructions,
    required this.warnings,
  });

  final String mode;
  final int byteLength;
  final String asciiPreview;
  final List<DisasmInstruction> instructions;
  final List<String> warnings;
}

class DisasmInstruction {
  const DisasmInstruction({
    required this.offset,
    required this.bytes,
    required this.mnemonic,
    this.operand,
    this.note,
    this.isUnknown = false,
  });

  final int offset;
  final String bytes;
  final String mnemonic;
  final String? operand;
  final String? note;
  final bool isUnknown;

  String get prettyLine {
    final address = offset.toRadixString(16).padLeft(4, '0').toUpperCase();
    final operandText = operand == null || operand!.isEmpty ? '' : ' $operand';
    final noteText = note == null || note!.isEmpty ? '' : ' ; $note';
    return '0x$address  ${bytes.padRight(23)}  $mnemonic$operandText$noteText';
  }
}

class _RexPrefix {
  const _RexPrefix({
    required this.wBit,
    required this.rExtension,
    required this.bExtension,
  });

  final bool wBit;
  final int rExtension;
  final int bExtension;
}

class _DecodedRegisterInstruction {
  const _DecodedRegisterInstruction({
    required this.mnemonic,
    required this.operand,
    this.note,
    this.isUnknown = false,
  });

  final String mnemonic;
  final String operand;
  final String? note;
  final bool isUnknown;
}
