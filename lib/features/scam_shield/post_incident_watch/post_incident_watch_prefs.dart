import 'package:shared_preferences/shared_preferences.dart';

abstract final class PostIncidentWatchPrefs {
  static const reminderEnabledKey = 'ss_post_incident_watch_reminder_enabled';
  static const permanentlyDismissedKey =
      'ss_post_incident_watch_permanently_dismissed';

  static Future<bool> isReminderEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(reminderEnabledKey) ?? true;
  }

  static Future<void> setReminderEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(reminderEnabledKey, value);
  }

  static Future<bool> isPermanentlyDismissed() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(permanentlyDismissedKey) ?? false;
  }

  static Future<void> setPermanentlyDismissed(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(permanentlyDismissedKey, value);
  }
}
