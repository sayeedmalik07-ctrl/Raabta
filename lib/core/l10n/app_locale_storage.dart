import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/screens/language_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Read persisted app locale outside Riverpod (e.g. notification services).
abstract final class AppLocaleStorage {
  static Future<String> readNormalized() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return AppLocale.normalize(prefs.getString(LanguageScreen.languageKey));
    } catch (_) {
      return 'English';
    }
  }
}
