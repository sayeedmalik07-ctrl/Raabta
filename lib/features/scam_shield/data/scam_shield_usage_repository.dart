import 'package:shared_preferences/shared_preferences.dart';
import 'package:raabta/features/scam_shield/scam_shield_config.dart';

/// Client-side monthly AI usage tracker — complements server Firestore cap.
class ScamShieldUsageRepository {
  ScamShieldUsageRepository(this._prefs);

  final SharedPreferences _prefs;
  static const _countPrefix = 'scam_shield_ai_count_';
  static const _webRiskCountPrefix = 'scam_shield_web_risk_count_';
  static const _webRiskMonthPrefix = 'scam_shield_web_risk_month_';
  static const _monthPrefix = 'scam_shield_ai_month_';

  String _monthKey() {
    final now = DateTime.now().toUtc();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}';
  }

  int getLocalMonthlyCount() {
    final month = _monthKey();
    final storedMonth = _prefs.getString(_monthPrefix) ?? '';
    if (storedMonth != month) return 0;
    return _prefs.getInt(_countPrefix) ?? 0;
  }

  Future<void> incrementLocalMonthlyCount() async {
    final month = _monthKey();
    final storedMonth = _prefs.getString(_monthPrefix) ?? '';
    final count = storedMonth == month ? (_prefs.getInt(_countPrefix) ?? 0) : 0;
    await _prefs.setString(_monthPrefix, month);
    await _prefs.setInt(_countPrefix, count + 1);
  }

  bool canUseAiLocally({required bool isPremium}) {
    final limit =
        isPremium ? ScamShieldConfig.premiumMonthlyAiLimit : ScamShieldConfig.freeMonthlyAiLimit;
    return getLocalMonthlyCount() < limit;
  }

  int getLocalWebRiskCount() {
    final month = _monthKey();
    final storedMonth = _prefs.getString(_webRiskMonthPrefix) ?? '';
    if (storedMonth != month) return 0;
    return _prefs.getInt(_webRiskCountPrefix) ?? 0;
  }

  Future<void> incrementLocalWebRiskCount([int amount = 1]) async {
    final month = _monthKey();
    final storedMonth = _prefs.getString(_webRiskMonthPrefix) ?? '';
    final count =
        storedMonth == month ? (_prefs.getInt(_webRiskCountPrefix) ?? 0) : 0;
    await _prefs.setString(_webRiskMonthPrefix, month);
    await _prefs.setInt(_webRiskCountPrefix, count + amount);
  }
}
