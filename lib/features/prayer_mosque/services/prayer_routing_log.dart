import 'package:flutter/foundation.dart';

/// Cost-visibility logging for Islamic Q&A routing.
abstract final class PrayerRoutingLog {
  static void faqHit({
    required String entryId,
    required String category,
    required double confidence,
  }) {
    debugPrint(
      '[PrayerAnalytics] prayerFaqHit '
      'id=$entryId category=$category confidence=${confidence.toStringAsFixed(2)}',
    );
  }

  /// [sanitizedQuestion] must contain no user-identifying data.
  static void claudeFallback({
    required String sanitizedQuestion,
    String? reason,
    double? bestFaqScore,
  }) {
    debugPrint(
      '[PrayerAnalytics] prayerClaudeFallback '
      'q="$sanitizedQuestion"'
      '${reason != null ? ' reason=$reason' : ''}'
      '${bestFaqScore != null ? ' bestFaqScore=${bestFaqScore.toStringAsFixed(2)}' : ''}',
    );
  }
}
