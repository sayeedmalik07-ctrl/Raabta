import 'package:shared_preferences/shared_preferences.dart';

/// One time Home AI orb coach mark dismissal (device local).
abstract final class HomeAiOrbCoachMarkPrefs {
  static const dismissedKey = 'home_ai_orb_coach_mark_dismissed';

  static Future<bool> isDismissed() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(dismissedKey) ?? false;
  }

  static Future<void> dismiss() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(dismissedKey, true);
  }
}
