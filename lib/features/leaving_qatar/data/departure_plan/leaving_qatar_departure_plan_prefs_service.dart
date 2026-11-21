import 'package:raabta/features/leaving_qatar/data/departure_plan/leaving_qatar_departure_plan_codec.dart';
import 'package:raabta/features/leaving_qatar/data/departure_plan/leaving_qatar_departure_plan_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Local-only Departure Plan persistence — isolated from Firestore checklist & close-out.
class LeavingQatarDeparturePlanPrefsService {
  static const prefsKey = 'leaving_qatar_departure_plan_v1';

  Future<LeavingQatarDeparturePlanState> load() async {
    final prefs = await SharedPreferences.getInstance();
    return LeavingQatarDeparturePlanCodec.decode(prefs.getString(prefsKey));
  }

  Future<void> save(LeavingQatarDeparturePlanState state) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(prefsKey, LeavingQatarDeparturePlanCodec.encode(state));
  }

  Future<void> setItemCompleted({
    required String itemId,
    required bool completed,
  }) async {
    final current = await load();
    final updated = Map<String, bool>.from(current.completedByItemId);
    updated[itemId] = completed;
    await save(current.copyWith(completedByItemId: updated));
  }

  /// Sets or clears the optional planned departure date (`YYYY-MM-DD`).
  ///
  /// Pass null to clear. Invalid strings are ignored (state unchanged).
  Future<void> setPlannedDepartureDate(String? yyyyMmDd) async {
    if (yyyyMmDd != null &&
        !LeavingQatarDeparturePlanDate.isValidIsoDate(yyyyMmDd)) {
      return;
    }
    final current = await load();
    if (yyyyMmDd == null) {
      await save(current.copyWith(clearPlannedDepartureDate: true));
      return;
    }
    await save(current.copyWith(plannedDepartureDate: yyyyMmDd));
  }

  /// Removes departure date and all plan completion ticks.
  Future<void> clearPlan() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(prefsKey);
  }
}
