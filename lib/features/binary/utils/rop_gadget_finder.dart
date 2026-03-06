import 'package:ctf_tools/shared/utils/hex_input.dart';

class RopGadgetResult {
  const RopGadgetResult({required this.gadgets, required this.summary});

  final List<String> gadgets;
  final List<String> summary;
}

class RopGadgetFinder {
  static RopGadgetResult findHex(String input) {
    final bytes = HexInput.parseBytes(input, minBytes: 1, errorMessage: '请输入机器码十六进制数据');
    final gadgets = <String>[];
    for (var index = 0; index < bytes.length; index++) {
      if (bytes[index] == 0xC3) {
        gadgets.add('0x${index.toRadixString(16).padLeft(4, '0')}: ret');
      }
      if (index + 1 < bytes.length && bytes[index] == 0x5F && bytes[index + 1] == 0xC3) {
        gadgets.add('0x${index.toRadixString(16).padLeft(4, '0')}: pop rdi ; ret');
      }
      if (index + 1 < bytes.length && bytes[index] == 0x5E && bytes[index + 1] == 0xC3) {
        gadgets.add('0x${index.toRadixString(16).padLeft(4, '0')}: pop rsi ; ret');
      }
      if (index + 1 < bytes.length && bytes[index] == 0x5A && bytes[index + 1] == 0xC3) {
        gadgets.add('0x${index.toRadixString(16).padLeft(4, '0')}: pop rdx ; ret');
      }
      if (index + 2 < bytes.length && bytes[index] == 0x58 && bytes[index + 1] == 0x58 && bytes[index + 2] == 0xC3) {
        gadgets.add('0x${index.toRadixString(16).padLeft(4, '0')}: pop rax ; pop rax ; ret');
      }
      if (index + 2 < bytes.length && bytes[index] == 0x31 && bytes[index + 1] == 0xC0 && bytes[index + 2] == 0xC3) {
        gadgets.add('0x${index.toRadixString(16).padLeft(4, '0')}: xor eax, eax ; ret');
      }
      if (index + 1 < bytes.length && bytes[index] == 0x0F && bytes[index + 1] == 0x05) {
        gadgets.add('0x${index.toRadixString(16).padLeft(4, '0')}: syscall');
      }
    }
    return RopGadgetResult(
      gadgets: gadgets,
      summary: [
        'Bytes: ${bytes.length}',
        'Gadgets Found: ${gadgets.length}',
      ],
    );
  }
}
