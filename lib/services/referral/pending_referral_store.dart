import 'package:shared_preferences/shared_preferences.dart';

/// Holds a referral code from an invite link until the user signs in.
abstract final class PendingReferralStore {
  static const _key = 'pending_referral_code';

  static Future<void> save(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, code.trim().toUpperCase());
  }

  static Future<String?> peek() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key);
  }

  static Future<String?> consume() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_key);
    if (code != null) await prefs.remove(_key);
    return code;
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
