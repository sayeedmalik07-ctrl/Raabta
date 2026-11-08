import 'package:raabta/features/scam_shield/evidence_listen/evidence_tts_locale_config.dart';

/// Conservative on-device speak duration estimate for [ClimateStatusNarration] budgets.
abstract final class ClimateStatusNarrationDuration {
  static const speakBudgetSeconds = 15.0;

  /// Words per second at TTS speech rate 1.0 (conservative for multilingual TTS).
  static const wordsPerSecondAtRate1 = 2.35;

  static int countWords(String text) =>
      text.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;

  static double estimatedSpeakSeconds(String text, String locale) {
    final rate = EvidenceTtsLocaleConfig.speechRate(
      slow: EvidenceTtsLocaleConfig.prefersSlowSpeech(locale),
    );
    final words = countWords(text);
    if (words == 0) return 0;
    return words / (wordsPerSecondAtRate1 * rate);
  }

  static bool fitsSpeakBudget(String text, String locale) =>
      estimatedSpeakSeconds(text, locale) <= speakBudgetSeconds;
}
