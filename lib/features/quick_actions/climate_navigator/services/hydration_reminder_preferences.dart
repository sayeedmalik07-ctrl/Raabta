import 'package:shared_preferences/shared_preferences.dart';

/// Opt-in hydration / rest break reminders for Climate Navigator.
abstract final class HydrationReminderPreferences {
  static const _enabledKey = 'climate_hydration_reminder_v1';

  static Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_enabledKey) ?? false;
  }

  static Future<void> setEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledKey, enabled);
  }
}
