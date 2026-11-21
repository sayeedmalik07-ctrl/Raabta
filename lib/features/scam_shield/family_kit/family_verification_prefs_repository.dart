import 'package:shared_preferences/shared_preferences.dart';
import 'package:raabta/features/scam_shield/family_kit/family_verification_models.dart';

class FamilyVerificationPrefsRepository {
  FamilyVerificationPrefsRepository(this._prefs);

  static const reminderKey = 'ss_family_verification_reminder_enabled';
  static const knownNumbersKey = 'ss_family_verification_known_numbers_enabled';

  final SharedPreferences _prefs;

  FamilyVerificationPrefs load() {
    return FamilyVerificationPrefs(
      reminderEnabled: _prefs.getBool(reminderKey) ?? false,
      knownNumbersEnabled: _prefs.getBool(knownNumbersKey) ?? false,
    );
  }

  Future<void> setReminderEnabled(bool value) async {
    await _prefs.setBool(reminderKey, value);
  }

  Future<void> setKnownNumbersEnabled(bool value) async {
    await _prefs.setBool(knownNumbersKey, value);
  }
}
