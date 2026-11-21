import 'package:shared_preferences/shared_preferences.dart';

abstract final class BuddyEntryCardPrefs {
  static const _dismissKey = 'buddy_find_entry_dismissed';

  static Future<bool> isDismissed() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_dismissKey) ?? false;
  }

  static Future<void> dismiss() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_dismissKey, true);
  }
}
