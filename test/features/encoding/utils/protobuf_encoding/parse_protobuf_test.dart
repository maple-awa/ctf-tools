import 'package:ctf_tools/features/encoding/utils/protobuf_encoding/parse_protobuf.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ParseProtobuf', () {
    test('hard decode should parse varint and string', () {
      final result = ParseProtobuf.hardDecode('08 96 01 12 02 68 69');
      final fields = result['fields'] as List<dynamic>;

      expect(fields.length, 2);
      expect(fields[0]['field'], 1);
      expect(fields[0]['type'], 'varint');
      expect(fields[0]['value'], 150);

      expect(fields[1]['field'], 2);
      expect(fields[1]['type'], 'length_delimited');
      expect(fields[1]['utf8'], 'hi');
    });

    test('schema decode should map by field name', () {
      const schema = '''
syntax = "proto3";

message User {
  uint32 id = 1;
  string name = 2;
  repeated uint32 tags = 3;
}
''';

      final result = ParseProtobuf.decodeWithProto(
        '08 07 12 05 61 6c 69 63 65 18 01 18 02',
        schema,
        rootMessage: 'User',
      );

      final data = result['data'] as Map<String, dynamic>;
      expect(data['id'], 7);
      expect(data['name'], 'alice');
      expect(data['tags'], [1, 2]);
    });

    test('schema encode then decode should round trip', () {
      const schema = '''
syntax = "proto3";

message User {
  uint32 id = 1;
  string name = 2;
  repeated uint32 tags = 3;
}
''';

      final encoded = ParseProtobuf.encodeWithProto(
        '{"id":7,"name":"alice","tags":[1,2]}',
        schema,
        rootMessage: 'User',
      );

      final decoded = ParseProtobuf.decodeWithProto(
        encoded,
        schema,
        rootMessage: 'User',
      );

      final data = decoded['data'] as Map<String, dynamic>;
      expect(data['id'], 7);
      expect(data['name'], 'alice');
      expect(data['tags'], [1, 2]);
    });
  });
}
