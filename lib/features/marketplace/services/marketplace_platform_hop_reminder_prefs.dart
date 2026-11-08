import 'package:shared_preferences/shared_preferences.dart';

/// Per-listing reminder state — "already shown", not a risk judgment.
abstract final class MarketplacePlatformHopReminderPrefs {
  static String prefsKey(String listingId) =>
      'mp_platform_hop_reminder_shown_$listingId';

  static Future<bool> isShown(String listingId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(prefsKey(listingId)) ?? false;
  }

  static Future<void> markShown(String listingId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(prefsKey(listingId), true);
  }
}
