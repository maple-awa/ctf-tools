import 'dart:math';

import 'package:ctf_tools/features/crypto/utils/xor_codec.dart';

class XorBruteforceCandidate {
  const XorBruteforceCandidate({
    required this.key,
    required this.preview,
    required this.score,
  });

  final String key;
  final String preview;
  final double score;
}

class CryptoAnalysisTools {
  static List<XorBruteforceCandidate> bruteForceSingleByte(String hexInput) {
    final candidates = <XorBruteforceCandidate>[];
    for (var key = 0; key < 256; key++) {
      final keyChar = String.fromCharCode(key);
      final preview = XorCodec.decodeHex(hexInput, keyChar);
      final score = _englishScore(preview);
      candidates.add(XorBruteforceCandidate(key: '0x${key.toRadixString(16).padLeft(2, '0')}', preview: preview, score: score));
    }
    candidates.sort((left, right) => right.score.compareTo(left.score));
    return candidates.take(8).toList();
  }

  static String frequencyAnalysis(String input) {
    final counts = <String, int>{};
    for (final char in input.toUpperCase().replaceAll(RegExp(r'[^A-Z]'), '').split('')) {
      counts.update(char, (value) => value + 1, ifAbsent: () => 1);
    }
    final total = counts.values.fold<int>(0, (sum, value) => sum + value);
    final entries = counts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return entries.map((entry) {
      final ratio = total == 0 ? 0.0 : (entry.value / total * 100);
      return '${entry.key}: ${entry.value} (${ratio.toStringAsFixed(2)}%)';
    }).join('\n');
  }

  static String suggestSubstitution(String input) {
    const english = 'ETAOINSHRDLCUMWFGYPBVKJXQZ';
    final cleaned = input.toUpperCase().replaceAll(RegExp(r'[^A-Z]'), '');
    final counts = <String, int>{};
    for (final char in cleaned.split('')) {
      counts.update(char, (value) => value + 1, ifAbsent: () => 1);
    }
    final ranked = counts.keys.toList()..sort((a, b) => counts[b]!.compareTo(counts[a]!));
    final lines = <String>[];
    for (var index = 0; index < ranked.length && index < english.length; index++) {
      lines.add('${ranked[index]} -> ${english[index]}');
    }
    return lines.join('\n');
  }

  static double _englishScore(String text) {
    const favored = ' ETAOINSHRDLUetaoinshrdlu';
    var score = 0.0;
    for (final rune in text.runes) {
      final char = String.fromCharCode(rune);
      if (favored.contains(char)) {
        score += 2;
      } else if (rune >= 32 && rune <= 126) {
        score += 0.5;
      } else {
        score -= 2;
      }
    }
    return score - (max(0, text.length - 64) * 0.01);
  }
}
