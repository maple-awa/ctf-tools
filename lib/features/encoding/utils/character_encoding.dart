import 'dart:convert';
import 'dart:core';
import 'package:charset/charset.dart';

/// 字符编码辅助工具。
class CharacterEncoding {
  /// 支持的字符编码名称列表（按常用度排序）。
  static const List<String> characterEncodingList = [
    // ===== 现代主流 =====
    'utf-8',
    'utf8',
    'utf-16',
    'utf16',
    'utf-16le',
    'utf-16be',
    'utf-32',
    'utf32',
    // ===== 中文环境（高优先）=====
    'gbk',
    'gb2312',
    'gb18030',
    'cp936',
    'windows-936',
    'big5',
    // ===== 日文 =====
    'shift-jis',
    'shiftjis',
    'shift_jis',
    'euc-jp',
    'eucjp',
    // ===== 韩文 =====
    'euc-kr',
    'euckr',
    'cp949',
    'ms949',
    'windows949',
    // ===== Windows 常见 =====
    'windows-1252',
    'cp1252',
    '1252',
    'windows-1251',
    'cp1251',
    'windows-1250',
    'cp1250',
    'windows-1254',
    'cp1254',
    'windows-1256',
    'cp1256',
    'windows-1257',
    'cp1257',
    'windows-1258',
    'cp1258',
    // ===== ISO Latin =====
    'iso-8859-1',
    'latin1',
    'iso-8859-2',
    'latin2',
    'iso-8859-5',
    'cyrillic',
    'iso-8859-7',
    'greek',
    'iso-8859-9',
    'latin5',
    'iso-8859-15',
    // ===== 俄语常见 =====
    'koi8-r',
    // ===== 其他 ISO =====
    'iso-8859-3',
    'iso-8859-4',
    'iso-8859-6',
    'iso-8859-8',
    'iso-8859-10',
    'iso-8859-13',
    'iso-8859-14',
    'iso-8859-16',
    // ===== CP 系列（低优先）=====
    'cp850',
    'cp852',
    'cp855',
    'cp857',
    'cp858',
    'cp866',
    '437',
    'cp437',
    '737',
    '775',
    '860',
    '861',
    '862',
    '863',
    '864',
    '865',
    '869',
    'cp874',
    'cp922',
    'cp1046',
    'cp1124',
    'cp1125',
    'cp1129',
    'cp1133',
    'cp1161',
    'cp1162',
    'cp1163',
  ];

  /// 将 [bytes] 从指定 [encodingName] 解码后再编码为 UTF-8。
  ///
  /// 当编码名不受支持时抛出 [Exception]。
  static List<int> convertToUtf8(List<int> bytes, String encodingName) {
    final charset = Charset.getByName(encodingName);

    if (charset == null) {
      throw Exception('不支持的编码: $encodingName');
    }

    // 按原解码
    String decoded = charset.decode(bytes);

    // 转成 UTF-8 字节
    return utf8.encode(decoded);
  }
}
