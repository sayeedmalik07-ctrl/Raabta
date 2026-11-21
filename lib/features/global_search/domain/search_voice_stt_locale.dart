import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/features/quick_actions/landmark_translator/landmark_stt_locale.dart';

/// Maps app locale → speech-to-text BCP-47 locale for Global Search voice (S11).
abstract final class SearchVoiceSttLocale {
  static String forAppLocale(String locale) {
    return LandmarkSttLocale.forAppLocale(locale);
  }

  /// Hinglish and unsupported locales fall back to English STT; S7 handles text.
  static String resolve(String locale) {
    final normalized = AppLocale.normalize(locale);
    if (normalized == 'English') return 'en-US';
    final mapped = forAppLocale(locale);
    if (mapped.isEmpty) return 'en-US';
    return mapped;
  }
}
