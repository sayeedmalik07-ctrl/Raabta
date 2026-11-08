import 'package:shared_preferences/shared_preferences.dart';

/// Re-prompt for optional providers at most once per 90 days.
abstract final class PersonalContextPromptPrefs {
  static const _declinedAtKey = 'ss_personal_context_declined_at_v1';
  static const declineCooldownDays = 90;

  static Future<bool> mayShowPrompt() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_declinedAtKey);
    if (raw == null || raw.isEmpty) return true;
    final declined = DateTime.tryParse(raw);
    if (declined == null) return true;
    return DateTime.now().toUtc().difference(declined.toUtc()).inDays >=
        declineCooldownDays;
  }

  static Future<void> recordDeclined() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _declinedAtKey,
      DateTime.now().toUtc().toIso8601String(),
    );
  }

  static Future<void> clearDeclined() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_declinedAtKey);
  }
}
