import 'package:shared_preferences/shared_preferences.dart';

/// Local-only UX state for Know Qatar Moments — never synced to Firestore.
class KnowQatarMomentsPrefs {
  KnowQatarMomentsPrefs(this._prefs);

  static const hiddenUntilKey = 'kq_next_step_hidden_until_ms';
  static const lastOpenedKey = 'kq_last_opened_destination_v1';

  final SharedPreferences _prefs;

  static Future<KnowQatarMomentsPrefs> load() async {
    return KnowQatarMomentsPrefs(await SharedPreferences.getInstance());
  }

  int? readNextStepHiddenUntilMs() {
    final raw = _prefs.get(hiddenUntilKey);
    if (raw is! int) {
      if (raw is String) {
        return int.tryParse(raw);
      }
      return null;
    }
    return raw;
  }

  Future<void> hideNextStepUntil(int epochMs) async {
    await _prefs.setInt(hiddenUntilKey, epochMs);
  }

  Future<void> clearNextStepHidden() async {
    await _prefs.remove(hiddenUntilKey);
  }

  String? readLastOpenedDestinationKey() {
    final value = _prefs.getString(lastOpenedKey);
    if (value == null || value.trim().isEmpty) return null;
    return value.trim();
  }

  Future<void> recordLastOpened(String destinationKey) async {
    final trimmed = destinationKey.trim();
    if (trimmed.isEmpty) return;
    await _prefs.setString(lastOpenedKey, trimmed);
  }
}
