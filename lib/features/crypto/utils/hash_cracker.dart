import 'package:ctf_tools/features/crypto/utils/hash_tools.dart';

class HashCrackResult {
  const HashCrackResult({required this.matches, required this.checked});

  final List<String> matches;
  final int checked;
}

class HashCracker {
  static HashCrackResult crack({
    required String algorithm,
    required String targetDigest,
    required String outputFormat,
    required String candidates,
  }) {
    final normalizedTarget = targetDigest.trim().toLowerCase().replaceAll(' ', '');
    final lines = candidates.split(RegExp(r'\r?\n')).map((line) => line.trim()).where((line) => line.isNotEmpty);
    final matches = <String>[];
    var checked = 0;
    for (final candidate in lines) {
      checked++;
      final digest = HashTools.digest(
        algorithm: algorithm,
        input: candidate,
        inputFormat: 'UTF-8',
        outputFormat: outputFormat,
      ).toLowerCase().replaceAll(' ', '');
      if (digest == normalizedTarget) {
        matches.add(candidate);
      }
    }
    return HashCrackResult(matches: matches, checked: checked);
  }
}
