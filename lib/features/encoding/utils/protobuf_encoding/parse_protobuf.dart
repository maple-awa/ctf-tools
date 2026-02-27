import 'dart:convert';
import 'dart:typed_data';

import 'package:convert/convert.dart';

/// 输入格式。
enum ProtobufDataFormat { hex, base64 }

/// ProtoBuf 解析与编码工具。
class ParseProtobuf {
  /// 无 proto 的硬解码。
  static Map<String, dynamic> hardDecode(
    String input, {
    ProtobufDataFormat inputFormat = ProtobufDataFormat.hex,
  }) {
    final bytes = _parseInputBytes(input, inputFormat);
    final fields = _decodeFields(bytes, allowNestedGuess: true);
    return {'mode': 'hard_decode', 'length': bytes.length, 'fields': fields};
  }

  /// 有 proto 的解码。
  static Map<String, dynamic> decodeWithProto(
    String input,
    String protoSchema, {
    String? rootMessage,
    ProtobufDataFormat inputFormat = ProtobufDataFormat.hex,
  }) {
    final schema = _ProtoSchema.parse(protoSchema, rootMessage: rootMessage);
    final bytes = _parseInputBytes(input, inputFormat);
    final decoded = _decodeBySchema(bytes, schema, schema.rootMessage);
    return {
      'mode': 'schema_decode',
      'message': schema.rootMessage,
      'length': bytes.length,
      'data': decoded,
    };
  }

  /// 有 proto 的编码。
  static String encodeWithProto(
    String jsonInput,
    String protoSchema, {
    String? rootMessage,
    ProtobufDataFormat outputFormat = ProtobufDataFormat.hex,
  }) {
    final schema = _ProtoSchema.parse(protoSchema, rootMessage: rootMessage);
    final dynamic parsed = jsonDecode(jsonInput);
    if (parsed is! Map) {
      throw const FormatException('JSON 输入必须是对象，例如 {"id":1}.');
    }

    final bytes = _encodeBySchema(
      _toStringDynamicMap(parsed),
      schema,
      schema.rootMessage,
    );
    if (outputFormat == ProtobufDataFormat.base64) {
      return base64.encode(bytes);
    }
    return _toHex(bytes);
  }

  /// 便捷格式化输出为 JSON 文本。
  static String prettyJson(Map<String, dynamic> value) {
    return const JsonEncoder.withIndent('  ').convert(value);
  }

  static List<int> _parseInputBytes(String input, ProtobufDataFormat format) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) {
      return <int>[];
    }

    if (format == ProtobufDataFormat.base64) {
      return base64.decode(trimmed);
    }

    final normalized = trimmed
        .replaceAll(RegExp(r'0x', caseSensitive: false), '')
        .replaceAll(RegExp(r'[^0-9a-fA-F]'), '');

    if (normalized.isEmpty) {
      return <int>[];
    }
    if (normalized.length.isOdd) {
      throw const FormatException('HEX 字符长度必须为偶数。');
    }
    return hex.decode(normalized);
  }

  static String _toHex(List<int> bytes) {
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ');
  }

  static List<Map<String, dynamic>> _decodeFields(
    List<int> bytes, {
    bool allowNestedGuess = false,
  }) {
    final result = <Map<String, dynamic>>[];
    int offset = 0;

    while (offset < bytes.length) {
      final keyRead = _readVarint(bytes, offset);
      final key = keyRead.value;
      offset = keyRead.nextOffset;

      if (key == 0) {
        throw FormatException('非法 field key=0, offset=$offset');
      }

      final fieldNumber = key >> 3;
      final wireType = key & 0x07;

      switch (wireType) {
        case 0:
          final valueRead = _readVarint(bytes, offset);
          offset = valueRead.nextOffset;
          result.add({
            'field': fieldNumber,
            'wire_type': wireType,
            'type': 'varint',
            'value': valueRead.value,
          });
          break;

        case 1:
          if (offset + 8 > bytes.length) {
            throw FormatException('fixed64 越界, field=$fieldNumber');
          }
          final raw = bytes.sublist(offset, offset + 8);
          offset += 8;
          final fixed = _littleEndianToInt(raw);
          result.add({
            'field': fieldNumber,
            'wire_type': wireType,
            'type': 'fixed64',
            'value': fixed,
            'hex': _toHex(raw),
          });
          break;

        case 2:
          final lenRead = _readVarint(bytes, offset);
          final length = lenRead.value;
          offset = lenRead.nextOffset;
          if (length < 0 || offset + length > bytes.length) {
            throw FormatException('length-delimited 越界, field=$fieldNumber');
          }
          final raw = bytes.sublist(offset, offset + length);
          offset += length;

          final fieldValue = <String, dynamic>{
            'field': fieldNumber,
            'wire_type': wireType,
            'type': 'length_delimited',
            'length': length,
            'bytes_hex': _toHex(raw),
            'bytes_base64': base64.encode(raw),
          };

          final maybeUtf8 = _tryUtf8(raw);
          if (maybeUtf8 != null) {
            fieldValue['utf8'] = maybeUtf8;
          }

          if (allowNestedGuess && raw.isNotEmpty) {
            try {
              final nested = _decodeFields(raw, allowNestedGuess: false);
              if (nested.isNotEmpty) {
                fieldValue['nested_message'] = nested;
              }
            } catch (_) {
              // 忽略嵌套猜测失败。
            }
          }

          result.add(fieldValue);
          break;

        case 5:
          if (offset + 4 > bytes.length) {
            throw FormatException('fixed32 越界, field=$fieldNumber');
          }
          final raw = bytes.sublist(offset, offset + 4);
          offset += 4;
          final fixed = _littleEndianToInt(raw);
          result.add({
            'field': fieldNumber,
            'wire_type': wireType,
            'type': 'fixed32',
            'value': fixed,
            'hex': _toHex(raw),
          });
          break;

        default:
          throw FormatException('不支持的 wire type=$wireType, field=$fieldNumber');
      }
    }

    return result;
  }

  static Map<String, dynamic> _decodeBySchema(
    List<int> bytes,
    _ProtoSchema schema,
    String messageName,
  ) {
    final msg = schema.messages[messageName];
    if (msg == null) {
      throw FormatException('未找到 message: $messageName');
    }

    final out = <String, dynamic>{};
    int offset = 0;

    while (offset < bytes.length) {
      final keyRead = _readVarint(bytes, offset);
      final key = keyRead.value;
      offset = keyRead.nextOffset;

      if (key == 0) {
        throw FormatException('非法 field key=0, offset=$offset');
      }

      final fieldNumber = key >> 3;
      final wireType = key & 0x07;
      final def = msg.fieldByNumber[fieldNumber];

      if (def == null) {
        offset = _skipUnknownField(bytes, offset, wireType);
        continue;
      }

      final value = _decodeOneValueByType(bytes, offset, wireType, def, schema);
      offset = value.nextOffset;

      final oldValue = out[def.name];
      if (def.repeated) {
        final list = (oldValue is List) ? oldValue : <dynamic>[];
        if (value.value is List && def.packed) {
          list.addAll(value.value as List<dynamic>);
        } else {
          list.add(value.value);
        }
        out[def.name] = list;
      } else {
        out[def.name] = value.value;
      }
    }

    return out;
  }

  static List<int> _encodeBySchema(
    Map<String, dynamic> data,
    _ProtoSchema schema,
    String messageName,
  ) {
    final msg = schema.messages[messageName];
    if (msg == null) {
      throw FormatException('未找到 message: $messageName');
    }

    final out = <int>[];

    for (final field in msg.fields) {
      final value = data[field.name];
      if (value == null) {
        continue;
      }

      if (field.repeated) {
        if (value is! List) {
          throw FormatException('字段 ${field.name} 需要数组值。');
        }
        if (field.packed && _isPackable(field.typeName)) {
          out.addAll(_encodePackedField(field, value, schema));
        } else {
          for (final item in value) {
            out.addAll(_encodeSingleField(field, item, schema));
          }
        }
      } else {
        out.addAll(_encodeSingleField(field, value, schema));
      }
    }

    return out;
  }

  static _DecodedValue _decodeOneValueByType(
    List<int> bytes,
    int offset,
    int wireType,
    _ProtoFieldDef def,
    _ProtoSchema schema,
  ) {
    final type = def.typeName;

    if (_varintTypes.contains(type)) {
      if (wireType != 0) {
        throw FormatException('字段 ${def.name} 期望 varint, 实际 wire=$wireType');
      }
      final read = _readVarint(bytes, offset);
      final raw = read.value;
      final value = _decodeVarintByType(raw, type);
      return _DecodedValue(value, read.nextOffset);
    }

    if (_fixed32Types.contains(type)) {
      if (wireType != 5) {
        throw FormatException('字段 ${def.name} 期望 fixed32, 实际 wire=$wireType');
      }
      if (offset + 4 > bytes.length) {
        throw FormatException('字段 ${def.name} fixed32 越界');
      }
      final raw = bytes.sublist(offset, offset + 4);
      final val = _decodeFixed32ByType(raw, type);
      return _DecodedValue(val, offset + 4);
    }

    if (_fixed64Types.contains(type)) {
      if (wireType != 1) {
        throw FormatException('字段 ${def.name} 期望 fixed64, 实际 wire=$wireType');
      }
      if (offset + 8 > bytes.length) {
        throw FormatException('字段 ${def.name} fixed64 越界');
      }
      final raw = bytes.sublist(offset, offset + 8);
      final val = _decodeFixed64ByType(raw, type);
      return _DecodedValue(val, offset + 8);
    }

    if (wireType != 2) {
      throw FormatException(
        '字段 ${def.name} 期望 length-delimited, 实际 wire=$wireType',
      );
    }

    final lenRead = _readVarint(bytes, offset);
    final length = lenRead.value;
    int next = lenRead.nextOffset;
    if (length < 0 || next + length > bytes.length) {
      throw FormatException('字段 ${def.name} length-delimited 越界');
    }
    final raw = bytes.sublist(next, next + length);
    next += length;

    if (def.repeated && def.packed && _isPackable(type)) {
      final packed = _decodePackedValues(raw, def);
      return _DecodedValue(packed, next);
    }

    if (type == 'string') {
      return _DecodedValue(utf8.decode(raw), next);
    }
    if (type == 'bytes') {
      return _DecodedValue(_toHex(raw), next);
    }

    if (schema.messages.containsKey(type)) {
      final nested = _decodeBySchema(raw, schema, type);
      return _DecodedValue(nested, next);
    }

    throw FormatException('不支持的字段类型: $type');
  }

  static List<dynamic> _decodePackedValues(List<int> raw, _ProtoFieldDef def) {
    final values = <dynamic>[];
    int offset = 0;

    while (offset < raw.length) {
      if (_varintTypes.contains(def.typeName)) {
        final read = _readVarint(raw, offset);
        offset = read.nextOffset;
        values.add(_decodeVarintByType(read.value, def.typeName));
      } else if (_fixed32Types.contains(def.typeName)) {
        if (offset + 4 > raw.length) {
          throw FormatException('packed fixed32 越界: ${def.name}');
        }
        final chunk = raw.sublist(offset, offset + 4);
        offset += 4;
        values.add(_decodeFixed32ByType(chunk, def.typeName));
      } else if (_fixed64Types.contains(def.typeName)) {
        if (offset + 8 > raw.length) {
          throw FormatException('packed fixed64 越界: ${def.name}');
        }
        final chunk = raw.sublist(offset, offset + 8);
        offset += 8;
        values.add(_decodeFixed64ByType(chunk, def.typeName));
      } else {
        throw FormatException('字段 ${def.name} 不是可 packed 类型');
      }
    }

    return values;
  }

  static List<int> _encodePackedField(
    _ProtoFieldDef field,
    List<dynamic> values,
    _ProtoSchema schema,
  ) {
    final payload = <int>[];
    for (final item in values) {
      payload.addAll(_encodePackedValue(field, item, schema));
    }

    final out = <int>[];
    out.addAll(_encodeVarint((field.number << 3) | 2));
    out.addAll(_encodeVarint(payload.length));
    out.addAll(payload);
    return out;
  }

  static List<int> _encodePackedValue(
    _ProtoFieldDef field,
    dynamic value,
    _ProtoSchema schema,
  ) {
    final type = field.typeName;
    if (_varintTypes.contains(type)) {
      final intVal = _normalizeInt(value, field.name);
      return _encodeVarint(_encodeVarintByType(intVal, type));
    }
    if (_fixed32Types.contains(type)) {
      final intVal = _normalizeNum(value, field.name);
      return _encodeFixed32(type, intVal);
    }
    if (_fixed64Types.contains(type)) {
      final numVal = _normalizeNum(value, field.name);
      return _encodeFixed64(type, numVal);
    }
    throw FormatException('字段 ${field.name} 不是可 packed 类型');
  }

  static List<int> _encodeSingleField(
    _ProtoFieldDef field,
    dynamic value,
    _ProtoSchema schema,
  ) {
    final type = field.typeName;
    final out = <int>[];

    if (_varintTypes.contains(type)) {
      out.addAll(_encodeVarint((field.number << 3) | 0));
      final intVal = _normalizeInt(value, field.name);
      out.addAll(_encodeVarint(_encodeVarintByType(intVal, type)));
      return out;
    }

    if (_fixed64Types.contains(type)) {
      out.addAll(_encodeVarint((field.number << 3) | 1));
      final numVal = _normalizeNum(value, field.name);
      out.addAll(_encodeFixed64(type, numVal));
      return out;
    }

    if (_fixed32Types.contains(type)) {
      out.addAll(_encodeVarint((field.number << 3) | 5));
      final numVal = _normalizeNum(value, field.name);
      out.addAll(_encodeFixed32(type, numVal));
      return out;
    }

    if (type == 'string') {
      final str = value.toString();
      final payload = utf8.encode(str);
      out.addAll(_encodeVarint((field.number << 3) | 2));
      out.addAll(_encodeVarint(payload.length));
      out.addAll(payload);
      return out;
    }

    if (type == 'bytes') {
      final payload = _parseBytesValue(value);
      out.addAll(_encodeVarint((field.number << 3) | 2));
      out.addAll(_encodeVarint(payload.length));
      out.addAll(payload);
      return out;
    }

    if (schema.messages.containsKey(type)) {
      if (value is! Map<String, dynamic>) {
        throw FormatException('字段 ${field.name} 需要对象值。');
      }
      final payload = _encodeBySchema(value, schema, type);
      out.addAll(_encodeVarint((field.number << 3) | 2));
      out.addAll(_encodeVarint(payload.length));
      out.addAll(payload);
      return out;
    }

    throw FormatException('不支持的字段类型: $type');
  }

  static List<int> _parseBytesValue(dynamic value) {
    if (value is List) {
      return value.map((e) => _normalizeInt(e, 'bytes')).toList();
    }

    final text = value.toString().trim();
    if (text.startsWith('base64:')) {
      return base64.decode(text.substring('base64:'.length));
    }

    final normalized = text
        .replaceAll(RegExp(r'0x', caseSensitive: false), '')
        .replaceAll(RegExp(r'[^0-9a-fA-F]'), '');

    if (normalized.isNotEmpty && normalized.length.isEven) {
      return hex.decode(normalized);
    }

    return utf8.encode(text);
  }

  static dynamic _decodeVarintByType(int raw, String type) {
    switch (type) {
      case 'bool':
        return raw != 0;
      case 'sint32':
      case 'sint64':
        return _zigzagDecode(raw);
      case 'int32':
        return _toSigned(raw, 32);
      case 'int64':
        return _toSigned(raw, 64);
      case 'uint32':
      case 'uint64':
      default:
        return raw;
    }
  }

  static int _encodeVarintByType(int value, String type) {
    switch (type) {
      case 'bool':
        return value == 0 ? 0 : 1;
      case 'sint32':
      case 'sint64':
        return _zigzagEncode(value);
      case 'int32':
        return value.toUnsigned(32).toUnsigned(64);
      case 'int64':
        return value.toUnsigned(64);
      case 'uint32':
        return value.toUnsigned(32);
      case 'uint64':
      default:
        return value;
    }
  }

  static dynamic _decodeFixed32ByType(List<int> raw, String type) {
    final value = _littleEndianToInt(raw);
    if (type == 'float') {
      final bd = ByteData.sublistView(Uint8List.fromList(raw));
      return bd.getFloat32(0, Endian.little);
    }
    if (type == 'sfixed32') {
      return _toSigned(value, 32);
    }
    return value;
  }

  static dynamic _decodeFixed64ByType(List<int> raw, String type) {
    final value = _littleEndianToInt(raw);
    if (type == 'double') {
      final bd = ByteData.sublistView(Uint8List.fromList(raw));
      return bd.getFloat64(0, Endian.little);
    }
    if (type == 'sfixed64') {
      return _toSigned(value, 64);
    }
    return value;
  }

  static List<int> _encodeFixed32(String type, num value) {
    final bd = ByteData(4);
    if (type == 'float') {
      bd.setFloat32(0, value.toDouble(), Endian.little);
    } else {
      final intVal = value.toInt();
      final write = type == 'sfixed32' ? intVal.toUnsigned(32) : intVal;
      bd.setUint32(0, write, Endian.little);
    }
    return bd.buffer.asUint8List();
  }

  static List<int> _encodeFixed64(String type, num value) {
    final bd = ByteData(8);
    if (type == 'double') {
      bd.setFloat64(0, value.toDouble(), Endian.little);
    } else {
      final intVal = value.toInt();
      final write = type == 'sfixed64' ? intVal.toUnsigned(64) : intVal;
      bd.setUint64(0, write, Endian.little);
    }
    return bd.buffer.asUint8List();
  }

  static int _skipUnknownField(List<int> bytes, int offset, int wireType) {
    switch (wireType) {
      case 0:
        return _readVarint(bytes, offset).nextOffset;
      case 1:
        if (offset + 8 > bytes.length) {
          throw const FormatException('skip unknown fixed64 越界');
        }
        return offset + 8;
      case 2:
        final lenRead = _readVarint(bytes, offset);
        final length = lenRead.value;
        final next = lenRead.nextOffset + length;
        if (next > bytes.length) {
          throw const FormatException('skip unknown length-delimited 越界');
        }
        return next;
      case 5:
        if (offset + 4 > bytes.length) {
          throw const FormatException('skip unknown fixed32 越界');
        }
        return offset + 4;
      default:
        throw FormatException('不支持的未知 wire type=$wireType');
    }
  }

  static _VarintRead _readVarint(List<int> bytes, int offset) {
    int shift = 0;
    int result = 0;
    int cursor = offset;

    while (cursor < bytes.length && shift < 70) {
      final b = bytes[cursor];
      result |= (b & 0x7f) << shift;
      cursor++;
      if ((b & 0x80) == 0) {
        return _VarintRead(result, cursor);
      }
      shift += 7;
    }

    throw FormatException('varint 解析失败, offset=$offset');
  }

  static List<int> _encodeVarint(int value) {
    if (value < 0) {
      throw FormatException('varint 不支持负数: $value');
    }

    var v = value;
    final out = <int>[];
    while (v >= 0x80) {
      out.add((v & 0x7f) | 0x80);
      v = v >> 7;
    }
    out.add(v);
    return out;
  }

  static int _littleEndianToInt(List<int> raw) {
    int result = 0;
    for (int i = 0; i < raw.length; i++) {
      result |= (raw[i] & 0xff) << (8 * i);
    }
    return result;
  }

  static String? _tryUtf8(List<int> bytes) {
    try {
      final text = utf8.decode(bytes);
      if (text.runes.any(
        (r) => r < 0x20 && r != 0x09 && r != 0x0A && r != 0x0D,
      )) {
        return null;
      }
      return text;
    } catch (_) {
      return null;
    }
  }

  static int _zigzagDecode(int value) {
    return (value >> 1) ^ (-(value & 1));
  }

  static int _zigzagEncode(int value) {
    return (value << 1) ^ (value >> 63);
  }

  static int _toSigned(int value, int bits) {
    final signBit = 1 << (bits - 1);
    final mask = (1 << bits) - 1;
    final masked = value & mask;
    if ((masked & signBit) != 0) {
      return masked - (1 << bits);
    }
    return masked;
  }

  static int _normalizeInt(dynamic value, String fieldName) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is bool) {
      return value ? 1 : 0;
    }
    final parsed = int.tryParse(value.toString());
    if (parsed == null) {
      throw FormatException('字段 $fieldName 需要整数值。');
    }
    return parsed;
  }

  static num _normalizeNum(dynamic value, String fieldName) {
    if (value is num) {
      return value;
    }
    final parsed = num.tryParse(value.toString());
    if (parsed == null) {
      throw FormatException('字段 $fieldName 需要数值。');
    }
    return parsed;
  }

  static Map<String, dynamic> _toStringDynamicMap(Map<dynamic, dynamic> value) {
    final map = <String, dynamic>{};
    for (final entry in value.entries) {
      final key = entry.key.toString();
      final raw = entry.value;
      if (raw is Map) {
        map[key] = _toStringDynamicMap(raw);
      } else if (raw is List) {
        map[key] = raw.map((item) {
          if (item is Map) {
            return _toStringDynamicMap(item);
          }
          return item;
        }).toList();
      } else {
        map[key] = raw;
      }
    }
    return map;
  }

  static bool _isPackable(String type) {
    return _varintTypes.contains(type) ||
        _fixed32Types.contains(type) ||
        _fixed64Types.contains(type);
  }

  static const Set<String> _varintTypes = {
    'int32',
    'int64',
    'uint32',
    'uint64',
    'sint32',
    'sint64',
    'bool',
  };

  static const Set<String> _fixed32Types = {'fixed32', 'sfixed32', 'float'};

  static const Set<String> _fixed64Types = {'fixed64', 'sfixed64', 'double'};
}

class _VarintRead {
  const _VarintRead(this.value, this.nextOffset);

  final int value;
  final int nextOffset;
}

class _DecodedValue {
  const _DecodedValue(this.value, this.nextOffset);

  final dynamic value;
  final int nextOffset;
}

class _ProtoSchema {
  _ProtoSchema({required this.messages, required this.rootMessage});

  final Map<String, _ProtoMessageDef> messages;
  final String rootMessage;

  static _ProtoSchema parse(String protoText, {String? rootMessage}) {
    final cleaned = _removeComments(protoText);
    final messages = <String, _ProtoMessageDef>{};

    final messageReg = RegExp(r'message\s+(\w+)\s*\{', multiLine: true);
    final starts = messageReg.allMatches(cleaned).toList();
    for (final match in starts) {
      final name = match.group(1)!;
      final bodyStart = match.end;
      final bodyEnd = _findMatchingBrace(cleaned, bodyStart - 1);
      if (bodyEnd <= bodyStart) {
        throw FormatException('message $name 花括号不匹配');
      }
      final body = cleaned.substring(bodyStart, bodyEnd);
      messages[name] = _ProtoMessageDef(name: name, fields: _parseFields(body));
    }

    if (messages.isEmpty) {
      throw const FormatException('未在 schema 中找到 message 定义。');
    }

    final root = rootMessage?.trim().isNotEmpty == true
        ? rootMessage!.trim()
        : messages.keys.first;

    if (!messages.containsKey(root)) {
      throw FormatException('root message 不存在: $root');
    }

    return _ProtoSchema(messages: messages, rootMessage: root);
  }

  static String _removeComments(String source) {
    var out = source.replaceAll(RegExp(r'/\*.*?\*/', dotAll: true), '');
    out = out.replaceAll(RegExp(r'//.*?$', multiLine: true), '');
    return out;
  }

  static int _findMatchingBrace(String text, int openBraceIndex) {
    int depth = 0;
    for (int i = openBraceIndex; i < text.length; i++) {
      final ch = text[i];
      if (ch == '{') {
        depth++;
      } else if (ch == '}') {
        depth--;
        if (depth == 0) {
          return i;
        }
      }
    }
    return -1;
  }

  static List<_ProtoFieldDef> _parseFields(String body) {
    final lines = body.split(';');
    final fields = <_ProtoFieldDef>[];
    final fieldReg = RegExp(
      r'^\s*(repeated\s+)?(\w+)\s+(\w+)\s*=\s*(\d+)\s*(\[[^\]]+\])?\s*$',
      multiLine: true,
    );

    for (final raw in lines) {
      final line = raw.trim();
      if (line.isEmpty) {
        continue;
      }
      final match = fieldReg.firstMatch(line);
      if (match == null) {
        continue;
      }

      final repeated = (match.group(1) ?? '').trim().isNotEmpty;
      final typeName = match.group(2)!;
      final name = match.group(3)!;
      final number = int.parse(match.group(4)!);
      final options = match.group(5) ?? '';
      final packed = options.contains('packed=true');

      fields.add(
        _ProtoFieldDef(
          name: name,
          typeName: typeName,
          number: number,
          repeated: repeated,
          packed: packed,
        ),
      );
    }

    return fields;
  }
}

class _ProtoMessageDef {
  _ProtoMessageDef({required this.name, required this.fields});

  final String name;
  final List<_ProtoFieldDef> fields;

  Map<int, _ProtoFieldDef> get fieldByNumber {
    final map = <int, _ProtoFieldDef>{};
    for (final field in fields) {
      map[field.number] = field;
    }
    return map;
  }
}

class _ProtoFieldDef {
  const _ProtoFieldDef({
    required this.name,
    required this.typeName,
    required this.number,
    required this.repeated,
    required this.packed,
  });

  final String name;
  final String typeName;
  final int number;
  final bool repeated;
  final bool packed;
}
