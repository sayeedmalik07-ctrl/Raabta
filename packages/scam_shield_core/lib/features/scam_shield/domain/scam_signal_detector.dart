import 'package:scam_shield_core/features/scam_shield/data/scam_multilingual_dictionary_config.dart';
import 'package:scam_shield_core/features/scam_shield/domain/scam_multilingual_matcher.dart';
import 'package:scam_shield_core/features/scam_shield/domain/scam_risk_signal.dart';

class ScamDetectedSignal {
  const ScamDetectedSignal({
    required this.signal,
    this.matchedTerm,
  });

  final ScamRiskSignal signal;
  final String? matchedTerm;
}

/// Deterministic pattern detection — no AI. Phase 6: multilingual dictionary.
abstract final class ScamSignalDetector {
  static List<ScamDetectedSignal> detect(String text) {
    final found = <ScamRiskSignal, ScamDetectedSignal>{};

    for (final entry in ScamMultilingualDictionaryConfig.signalPatterns.entries) {
      for (final pattern in entry.value) {
        if (ScamMultilingualMatcher.containsPattern(text, pattern)) {
          found.putIfAbsent(
            entry.key,
            () => ScamDetectedSignal(signal: entry.key, matchedTerm: pattern),
          );
          break;
        }
      }
    }

    return found.values.toList()
      ..sort((a, b) => a.signal.index.compareTo(b.signal.index));
  }

  static Set<ScamRiskSignal> mergeWithLegacyFlags(
    List<ScamDetectedSignal> detected,
    List<String> legacyFlags,
  ) {
    final signals = detected.map((d) => d.signal).toSet();
    for (final flag in legacyFlags) {
      signals.addAll(ScamRiskSignalX.fromLegacyFlag(flag));
    }
    return signals;
  }
}
