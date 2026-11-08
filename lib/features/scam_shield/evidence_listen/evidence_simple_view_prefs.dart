import 'package:shared_preferences/shared_preferences.dart';

abstract final class EvidenceSimpleViewPrefs {
  static const key = 'ss_evidence_simple_view_enabled';

  static Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key) ?? false;
  }

  static Future<void> setEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }
}
