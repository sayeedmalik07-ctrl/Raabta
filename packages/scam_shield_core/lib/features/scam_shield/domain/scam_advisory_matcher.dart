import 'package:scam_shield_core/features/scam_shield/domain/scam_advisory_models.dart';

/// Deterministic advisory matching for scan evidence (Phase 12).
abstract final class ScamAdvisoryMatcher {
  static List<ScamAdvisoryMatch> match({
    required String text,
    required List<String> claimedEntityIds,
    required String locale,
    required List<ScamAdvisory> activeAdvisories,
  }) {
    if (text.trim().isEmpty || activeAdvisories.isEmpty) return const [];

    final normalizedText = _normalize(text);
    final claimed = claimedEntityIds.map(_normalize).toSet();
    final hits = <String, int>{};

    for (final advisory in activeAdvisories) {
      if (!advisory.isActive) continue;

      var score = 0;

      final entityOverlap = advisory.claimedEntityIds
          .where((id) => claimed.contains(_normalize(id)))
          .length;
      if (entityOverlap > 0) {
        score += 100 * entityOverlap;
      }

      final phrases = advisory.phrasesForLocale(locale);
      var distinctPhraseHits = 0;
      for (final phrase in phrases) {
        final p = _normalize(phrase);
        if (p.length < 3) continue;
        if (_containsPhrase(normalizedText, p)) {
          distinctPhraseHits++;
        }
      }
      if (distinctPhraseHits >= 2) {
        score += 10 * distinctPhraseHits;
      }

      if (score > 0) {
        hits[advisory.id] = score;
      }
    }

    if (hits.isEmpty) return const [];

    final sorted = hits.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted
        .take(2)
        .map(
          (e) => ScamAdvisoryMatch(advisoryId: e.key, score: e.value),
        )
        .toList(growable: false);
  }

  static bool _containsPhrase(String normalizedText, String phrase) {
    if (RegExp(r'[\u0600-\u06FF]').hasMatch(phrase)) {
      return normalizedText.contains(phrase);
    }
    if (phrase.length < 4) {
      return RegExp('\\b${RegExp.escape(phrase)}\\b', unicode: true)
          .hasMatch(normalizedText);
    }
    return normalizedText.contains(phrase);
  }

  static String _normalize(String input) {
    var s = input.toLowerCase();
    s = s.replaceAll(RegExp(r'[\u064B-\u065F\u0670]'), '');
    s = s.replaceAll('أ', 'ا').replaceAll('إ', 'ا').replaceAll('آ', 'ا');
    s = s.replaceAll('ى', 'ي').replaceAll('ة', 'ه');
    return s.trim();
  }
}
