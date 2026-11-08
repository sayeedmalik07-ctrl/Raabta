import 'package:raabta/features/prayer_mosque/data/islamic_faq_catalog.dart';
import 'package:raabta/features/prayer_mosque/data/islamic_faq_config.dart';
import 'package:raabta/features/prayer_mosque/data/islamic_faq_strings.dart';
import 'package:raabta/features/prayer_mosque/domain/models/islamic_faq_entry.dart';
import 'package:raabta/features/prayer_mosque/domain/models/prayer_assistant_reply.dart';

/// Result of matching a user question against the static FAQ catalog.
class IslamicFaqMatch {
  const IslamicFaqMatch({
    required this.entry,
    required this.confidence,
  });

  final IslamicFaqEntry entry;
  final double confidence;

  bool get meetsThreshold =>
      confidence >= IslamicFaqConfig.matchConfidenceThreshold;

  PrayerAssistantReply toReply(String locale) {
    return PrayerAssistantReply(
      text: IslamicFaqStrings.t(entry.answerKey, locale),
      source: PrayerReplySource.faq,
      deepLinkRoute: entry.deepLinkRoute,
      deepLinkLabelKey: entry.deepLinkLabelKey,
    );
  }
}

/// Lightweight keyword/intent matcher — conservative by design.
abstract final class IslamicFaqMatcher {
  static const _nuancedSignals = [
    'my case',
    'my situation',
    'specifically for me',
    'in my country',
    'legally',
    ' divorce',
    'inheritance',
    'business deal',
    'stock',
    'crypto',
    'medical advice',
    'doctor said',
    'حالتي',
    'حالت خاص',
    'فتوى شخصية',
  ];

  /// Returns the best FAQ match, or null when confidence is too low/ambiguous.
  static IslamicFaqMatch? tryMatch(String question, String locale) {
    final normalized = _normalize(question);
    if (normalized.length < 4) return null;
    if (_looksNuanced(normalized)) return null;

    IslamicFaqEntry? bestEntry;
    var bestScore = 0.0;
    var secondScore = 0.0;

    for (final entry in IslamicFaqCatalog.entries) {
      final score = _scoreEntry(normalized, entry, locale);
      if (score > bestScore) {
        secondScore = bestScore;
        bestScore = score;
        bestEntry = entry;
      } else if (score > secondScore) {
        secondScore = score;
      }
    }

    if (bestEntry == null || bestScore < IslamicFaqConfig.matchConfidenceThreshold) {
      return null;
    }

    if (secondScore >= 0.45 &&
        (bestScore - secondScore) < IslamicFaqConfig.ambiguityGap) {
      return null;
    }

    return IslamicFaqMatch(entry: bestEntry, confidence: bestScore);
  }

  static double bestEffortScore(String question, String locale) {
    final normalized = _normalize(question);
    var best = 0.0;
    for (final entry in IslamicFaqCatalog.entries) {
      final score = _scoreEntry(normalized, entry, locale);
      if (score > best) best = score;
    }
    return best;
  }

  static String sanitizeForLog(String question) {
    final cleaned = question
        .toLowerCase()
        .replaceAll(RegExp(r'[\n\r\t]+'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    if (cleaned.length <= 80) return cleaned;
    return '${cleaned.substring(0, 80)}…';
  }

  static double _scoreEntry(
    String normalizedQuestion,
    IslamicFaqEntry entry,
    String locale,
  ) {
    var score = 0.0;
    var phraseHit = false;

    for (final keyword in entry.keywordsFor(locale)) {
      final normalizedKeyword = _normalize(keyword);
      if (normalizedKeyword.length < 3) continue;

      if (normalizedQuestion.contains(normalizedKeyword)) {
        final weight = normalizedKeyword.contains(' ')
            ? 0.55
            : 0.28;
        score += weight;
        if (normalizedKeyword.length >= 12) phraseHit = true;
      }
    }

    if (phraseHit && score >= 0.5) {
      score = score.clamp(0.75, 1.0);
    }

    return score.clamp(0.0, 1.0);
  }

  static bool _looksNuanced(String normalized) {
    for (final signal in _nuancedSignals) {
      if (normalized.contains(_normalize(signal))) return true;
    }
    return false;
  }

  static String _normalize(String input) {
    return input
        .toLowerCase()
        .replaceAll("'", '')
        .replaceAll('’', '')
        .replaceAll(RegExp(r'[^\p{L}\p{N}\s]', unicode: true), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}
