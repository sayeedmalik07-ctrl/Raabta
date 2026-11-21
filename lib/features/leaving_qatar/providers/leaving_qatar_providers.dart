import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/features/leaving_qatar/data/departure_plan/leaving_qatar_departure_plan_models.dart';
import 'package:raabta/features/leaving_qatar/data/departure_plan/leaving_qatar_departure_plan_prefs_service.dart';
import 'package:raabta/features/leaving_qatar/data/leaving_qatar_checklist_service.dart';
import 'package:raabta/features/leaving_qatar/data/leaving_qatar_closeout_prefs_service.dart';
import 'package:raabta/features/leaving_qatar/data/models/leaving_qatar_models.dart';
import 'package:raabta/features/leaving_qatar/services/leaving_qatar_departure_bundle_service.dart';
import 'package:raabta/features/leaving_qatar/services/leaving_qatar_departure_plan_export_service.dart';
import 'package:raabta/features/leaving_qatar/services/leaving_qatar_departure_plan_pdf_service.dart';
import 'package:raabta/features/leaving_qatar/services/leaving_qatar_departure_plan_reminder_service.dart';
import 'package:raabta/providers/auth_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _leavingQatarEngagedAtKey = 'leaving_qatar_last_engaged_at_ms';
const leavingQatarEngagementWindow = Duration(days: 14);

final leavingQatarCategoryProvider =
    StateProvider<LeavingQatarWorkerCategory?>(
  (ref) => LeavingQatarWorkerCategory.standardPrivateSector,
);

/// True when the user opened Leaving Qatar Mode within [leavingQatarEngagementWindow].
final leavingQatarRecentlyEngagedProvider =
    FutureProvider<bool>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  final raw = prefs.getInt(_leavingQatarEngagedAtKey);
  if (raw == null) return false;
  final engagedAt = DateTime.fromMillisecondsSinceEpoch(raw);
  return DateTime.now().difference(engagedAt) <= leavingQatarEngagementWindow;
});

Future<void> markLeavingQatarEngaged() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt(
    _leavingQatarEngagedAtKey,
    DateTime.now().millisecondsSinceEpoch,
  );
}

final leavingQatarChecklistServiceProvider =
    Provider((ref) => LeavingQatarChecklistService());

final leavingQatarCloseoutPrefsServiceProvider =
    Provider((ref) => LeavingQatarCloseoutPrefsService());

final leavingQatarCloseoutCompletionProvider =
    FutureProvider<Map<String, bool>>((ref) async {
  return ref.watch(leavingQatarCloseoutPrefsServiceProvider).load();
});

final leavingQatarDepartureBundleServiceProvider =
    Provider((ref) => LeavingQatarDepartureBundleService());

final leavingQatarChecklistCompletionProvider =
    StreamProvider<Map<String, bool>>((ref) async* {
  final uid = ref.watch(currentUserProvider)?.uid;
  if (uid == null) {
    yield const {};
    return;
  }
  final service = ref.watch(leavingQatarChecklistServiceProvider);
  yield await service.load(uid);
  yield* service.watch(uid);
});

final leavingQatarDeparturePlanPrefsServiceProvider =
    Provider((ref) => LeavingQatarDeparturePlanPrefsService());

final leavingQatarDeparturePlanExportServiceProvider =
    Provider((ref) {
  return LeavingQatarDeparturePlanExportService(
    LeavingQatarDeparturePlanPdfService(),
  );
});

final leavingQatarDeparturePlanReminderServiceProvider =
    FutureProvider<LeavingQatarDeparturePlanReminderService>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return LeavingQatarDeparturePlanReminderService(prefs);
});

final leavingQatarDeparturePlanProvider =
    FutureProvider<LeavingQatarDeparturePlanState>((ref) async {
  return ref.watch(leavingQatarDeparturePlanPrefsServiceProvider).load();
});

class LeavingQatarDeparturePlanController
    extends AsyncNotifier<LeavingQatarDeparturePlanState> {
  @override
  Future<LeavingQatarDeparturePlanState> build() {
    return ref.read(leavingQatarDeparturePlanPrefsServiceProvider).load();
  }

  Future<bool> setItemCompleted({
    required String itemId,
    required bool completed,
    required String locale,
  }) async {
    final service = ref.read(leavingQatarDeparturePlanPrefsServiceProvider);
    try {
      await service.setItemCompleted(itemId: itemId, completed: completed);
      final loaded = await service.load();
      state = AsyncData(loaded);
      ref.invalidate(leavingQatarDeparturePlanProvider);
      await _reconcileReminders(plan: loaded, locale: locale);
      return true;
    } catch (_) {
      state = AsyncData(await service.load());
      ref.invalidate(leavingQatarDeparturePlanProvider);
      return false;
    }
  }

  Future<bool> setPlannedDepartureDate(
    String? yyyyMmDd, {
    required String locale,
  }) async {
    final service = ref.read(leavingQatarDeparturePlanPrefsServiceProvider);
    try {
      await service.setPlannedDepartureDate(yyyyMmDd);
      final loaded = await service.load();
      state = AsyncData(loaded);
      ref.invalidate(leavingQatarDeparturePlanProvider);
      await _reconcileReminders(plan: loaded, locale: locale);
      return true;
    } catch (_) {
      state = AsyncData(await service.load());
      ref.invalidate(leavingQatarDeparturePlanProvider);
      return false;
    }
  }

  Future<void> _reconcileReminders({
    required LeavingQatarDeparturePlanState plan,
    required String locale,
  }) async {
    final reminderSvc =
        await ref.read(leavingQatarDeparturePlanReminderServiceProvider.future);
    await reminderSvc.reconcile(plan: plan, locale: locale);
  }
}

final leavingQatarDeparturePlanControllerProvider =
    AsyncNotifierProvider<
        LeavingQatarDeparturePlanController,
        LeavingQatarDeparturePlanState>(
  LeavingQatarDeparturePlanController.new,
);
