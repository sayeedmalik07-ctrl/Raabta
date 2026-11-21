import 'package:scam_shield_core/features/scam_shield/domain/scam_signal_detector.dart';

/// Shared text-normalization helpers for dictionary matching.
abstract final class ScamMultilingualMatcher {
  static bool containsPattern(String text, String pattern) {
    return normalize(text).contains(normalize(pattern));
  }

  static String normalize(String text) => text.toLowerCase().trim();

  static List<String> matchedPatterns(String text, List<String> patterns) {
    final matches = <String>[];
    for (final pattern in patterns) {
      if (containsPattern(text, pattern)) {
        matches.add(pattern);
      }
    }
    return matches;
  }

  static List<ScamDetectedSignal> detectFromPatternMap({
    required String text,
    required Map<dynamic, List<String>> patternMap,
    required ScamDetectedSignal Function(dynamic key, String pattern) build,
  }) {
    final found = <dynamic, ScamDetectedSignal>{};
    for (final entry in patternMap.entries) {
      for (final pattern in entry.value) {
        if (containsPattern(text, pattern)) {
          found.putIfAbsent(entry.key, () => build(entry.key, pattern));
          break;
        }
      }
    }
    return found.values.toList();
  }
}
