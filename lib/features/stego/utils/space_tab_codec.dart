import 'dart:convert';

class SpaceTabCodec {
  static String encode(String text) {
    if (text.isEmpty) {
      throw const FormatException('输入不能为空');
    }
    final bytes = utf8.encode(text);
    return bytes.map((byte) => byte.toRadixString(2).padLeft(8, '0').replaceAll('0', ' ').replaceAll('1', '\t')).join('\n');
  }

  static String decode(String text) {
    final lines = text.split('\n').map((line) => line.replaceAll(RegExp(r'[^ \t]'), '')).where((line) => line.isNotEmpty).toList();
    if (lines.isEmpty) {
      throw const FormatException('未检测到空格/Tab 载荷');
    }
    final bytes = <int>[];
    for (final line in lines) {
      if (line.length != 8) {
        throw const FormatException('每一行载荷都需要 8 个空白字符');
      }
      final bits = line.replaceAll(' ', '0').replaceAll('\t', '1');
      bytes.add(int.parse(bits, radix: 2));
    }
    return utf8.decode(bytes, allowMalformed: true);
  }

  static String inspect(String text) {
    var spaces = 0;
    var tabs = 0;
    for (final char in text.split('')) {
      if (char == ' ') {
        spaces++;
      } else if (char == '\t') {
        tabs++;
      }
    }
    return 'Spaces: $spaces\nTabs: $tabs\nEstimated Bytes: ${(spaces + tabs) ~/ 8}';
  }
}
