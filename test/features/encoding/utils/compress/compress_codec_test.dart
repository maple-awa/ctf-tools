import 'package:ctf_tools/features/encoding/utils/compress/compress_codec.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CompressCodec', () {
    const plainText = 'hello ctf tools';

    test('gzip: raw -> base64 -> raw', () {
      final compressed = CompressCodec.compress(
        input: plainText,
        algorithm: CompressAlgorithm.gzip,
        inputFormat: CompressDataFormat.raw,
        outputFormat: CompressDataFormat.base64,
      );
      final decompressed = CompressCodec.decompress(
        input: compressed,
        algorithm: CompressAlgorithm.gzip,
        inputFormat: CompressDataFormat.base64,
        outputFormat: CompressDataFormat.raw,
      );
      expect(decompressed, plainText);
    });

    test('zlib: raw -> hex -> raw', () {
      final compressed = CompressCodec.compress(
        input: plainText,
        algorithm: CompressAlgorithm.zlib,
        inputFormat: CompressDataFormat.raw,
        outputFormat: CompressDataFormat.hex,
      );
      final decompressed = CompressCodec.decompress(
        input: compressed,
        algorithm: CompressAlgorithm.zlib,
        inputFormat: CompressDataFormat.hex,
        outputFormat: CompressDataFormat.raw,
      );
      expect(decompressed, plainText);
    });

    test('gzip supports hex input with spaces and 0x prefix', () {
      final compressed = CompressCodec.compress(
        input: '0x68 0x65 0x6c 0x6c 0x6f',
        algorithm: CompressAlgorithm.gzip,
        inputFormat: CompressDataFormat.hex,
        outputFormat: CompressDataFormat.base64,
      );
      final decompressed = CompressCodec.decompress(
        input: compressed,
        algorithm: CompressAlgorithm.gzip,
        inputFormat: CompressDataFormat.base64,
        outputFormat: CompressDataFormat.raw,
      );
      expect(decompressed, 'hello');
    });

    test('invalid hex should throw', () {
      expect(
        () => CompressCodec.compress(
          input: 'ABC',
          algorithm: CompressAlgorithm.gzip,
          inputFormat: CompressDataFormat.hex,
          outputFormat: CompressDataFormat.base64,
        ),
        throwsA(isA<FormatException>()),
      );
    });

    test('invalid level should throw', () {
      expect(
        () => CompressCodec.compress(
          input: plainText,
          algorithm: CompressAlgorithm.zlib,
          inputFormat: CompressDataFormat.raw,
          outputFormat: CompressDataFormat.base64,
          level: 99,
        ),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
