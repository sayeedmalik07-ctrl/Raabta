import 'package:raabta/features/arabic_companion/arabic_companion_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Client-side monthly AI usage — incremented only on Claude cache misses.
class ArabicCompanionUsageRepository {
  ArabicCompanionUsageRepository(this._prefs);

  final SharedPreferences _prefs;
  static const _countPrefix = 'arabic_companion_ai_count_';
  static const _monthPrefix = 'arabic_companion_ai_month_';

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
    final count =
        storedMonth == month ? (_prefs.getInt(_countPrefix) ?? 0) : 0;
    await _prefs.setString(_monthPrefix, month);
    await _prefs.setInt(_countPrefix, count + 1);
  }

  bool canUseAiLocally({required bool isPremium}) {
    if (isPremium) return true;
    return getLocalMonthlyCount() < ArabicCompanionConfig.freeMonthlyAiLimit;
  }

  int remainingFreeCalls() {
    return (ArabicCompanionConfig.freeMonthlyAiLimit - getLocalMonthlyCount())
        .clamp(0, ArabicCompanionConfig.freeMonthlyAiLimit);
  }
}
