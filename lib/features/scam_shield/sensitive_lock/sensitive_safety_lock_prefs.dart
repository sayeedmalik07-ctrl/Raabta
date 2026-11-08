import 'package:shared_preferences/shared_preferences.dart';
import 'package:raabta/features/scam_shield/sensitive_lock/sensitive_safety_lock_constants.dart';

abstract final class SensitiveSafetyLockPrefs {
  static Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(SensitiveSafetyLockConstants.prefsEnabledKey) ?? false;
  }

  static Future<void> setEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(SensitiveSafetyLockConstants.prefsEnabledKey, value);
  }

  static Future<bool> offerShown() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(SensitiveSafetyLockConstants.prefsOfferShownKey) ??
        false;
  }

  static Future<void> markOfferShown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(SensitiveSafetyLockConstants.prefsOfferShownKey, true);
  }
}
