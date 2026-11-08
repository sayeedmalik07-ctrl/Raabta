import 'dart:convert';

import 'package:raabta/features/leaving_qatar/data/departure_plan/leaving_qatar_departure_plan_models.dart';
import 'package:raabta/features/leaving_qatar/data/departure_plan/leaving_qatar_departure_plan_notification_ids.dart';
import 'package:raabta/features/leaving_qatar/data/departure_plan/leaving_qatar_departure_plan_reminder_engine.dart';
import 'package:raabta/features/leaving_qatar/presentation/l10n/leaving_qatar_strings.dart';
import 'package:raabta/models/notification_models.dart';
import 'package:raabta/services/notification_repository.dart';
import 'package:raabta/services/notification_background.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Lightweight pending row for reconcile (mirrors plugin pending requests).
class DeparturePlanPendingNotification {
  const DeparturePlanPendingNotification({
    required this.id,
    this.payload,
  });

  final int id;
  final String? payload;
}

/// Opt-in local reminders for the Departure Plan — isolated IDs and prefs.
class LeavingQatarDeparturePlanReminderService {
  LeavingQatarDeparturePlanReminderService(
    this._prefs, {
    DateTime Function()? clock,
    Future<NotificationSettings> Function()? loadSettings,
    Future<void> Function()? initializeNotifications,
    Future<void> Function({
      required int id,
      required String title,
      required String body,
      required DateTime scheduledDate,
      String? payload,
    })? scheduleNotification,
    Future<void> Function(int id)? cancelNotification,
    Future<List<DeparturePlanPendingNotification>> Function()? pendingNotifications,
  })  : _clock = clock ?? DateTime.now,
        _loadSettings = loadSettings ?? _defaultLoadSettings,
        _initializeNotifications =
            initializeNotifications ?? _defaultInitialize,
        _scheduleNotification =
            scheduleNotification ?? _defaultSchedule,
        _cancelNotification = cancelNotification ?? _defaultCancel,
        _pendingNotifications =
            pendingNotifications ?? _defaultPendingNotifications;

  final SharedPreferences _prefs;
  final DateTime Function() _clock;
  final Future<NotificationSettings> Function() _loadSettings;
  final Future<void> Function() _initializeNotifications;
  final Future<void> Function({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) _scheduleNotification;
  final Future<void> Function(int id) _cancelNotification;
  final Future<List<DeparturePlanPendingNotification>> Function()
      _pendingNotifications;

  static const optInKey = 'leaving_qatar_departure_plan_reminders_enabled';
  static const scheduledDateKeysPref =
      'leaving_qatar_departure_plan_reminder_dates_v1';

  bool get isEnabled => _prefs.getBool(optInKey) ?? false;

  Future<void> setEnabled({
    required bool enabled,
    required LeavingQatarDeparturePlanState plan,
    required String locale,
  }) async {
    await _prefs.setBool(optInKey, enabled);
    if (enabled) {
      await reconcile(plan: plan, locale: locale);
    } else {
      await cancelAllScheduled();
    }
  }

  Future<void> reconcile({
    required LeavingQatarDeparturePlanState plan,
    required String locale,
  }) async {
    await _initializeNotifications();

    if (!isEnabled) {
      await _cancelAllOwnedPending();
      await _cancelLegacyTrackedKeys();
      await _persistScheduledDateKeys(const []);
      return;
    }

    if (plan.plannedDepartureDate == null) {
      await _cancelAllOwnedPending();
      await _cancelLegacyTrackedKeys();
      await _persistScheduledDateKeys(const []);
      return;
    }

    final settings = await _loadSettings();
    final days = LeavingQatarDeparturePlanReminderEngine.buildSchedule(
      plan: plan,
      clock: _clock,
      settings: settings,
    );

    if (days.isEmpty) {
      await _cancelAllOwnedPending();
      await _cancelLegacyTrackedKeys();
      await _persistScheduledDateKeys(const []);
      return;
    }

    final idByDateKey = LeavingQatarDeparturePlanNotificationIds.assignDistinctIds(
      days.map((d) => d.qatarDateKey),
    );
    final desiredIds = idByDateKey.values.toSet();

    await _cancelLegacyTrackedKeys();

    final pending = await _pendingNotifications();
    final pendingById = {
      for (final p in pending) p.id: p,
    };

    for (final p in pending) {
      if (!_shouldCancelOwnedPending(p, desiredIds)) continue;
      try {
        await _cancelNotification(p.id);
      } catch (_) {
        // Continue reconcile; next run retries cleanup.
      }
    }

    final scheduledKeys = <String>[];
    for (final day in days) {
      final id = idByDateKey[day.qatarDateKey]!;
      final existing = pendingById[id];
      if (existing != null &&
          LeavingQatarDeparturePlanNotificationIds.isDeparturePlanPayload(
            existing.payload,
          )) {
        scheduledKeys.add(day.qatarDateKey);
        continue;
      }

      final title = LeavingQatarStrings.t('lq_dp_reminder_title', locale);
      final body = LeavingQatarStrings.tf(
        'lq_dp_reminder_body',
        locale,
        {'count': '${day.itemCount}'},
      );
      try {
        await _scheduleNotification(
          id: id,
          title: title,
          body: body,
          scheduledDate: day.scheduledAt,
          payload: jsonEncode({
            'route': '/leaving-qatar',
            'type': LeavingQatarDeparturePlanNotificationIds.payloadType,
          }),
        );
        scheduledKeys.add(day.qatarDateKey);
      } catch (_) {
        if (existing != null &&
            LeavingQatarDeparturePlanNotificationIds.isDeparturePlanPayload(
              existing.payload,
            )) {
          scheduledKeys.add(day.qatarDateKey);
        }
      }
    }

    await _persistScheduledDateKeys(scheduledKeys);
  }

  Future<void> cancelAllScheduled() async {
    await _initializeNotifications();
    await _cancelAllOwnedPending();
    await _cancelLegacyTrackedKeys();
    await _persistScheduledDateKeys(const []);
  }

  bool _shouldCancelOwnedPending(
    DeparturePlanPendingNotification pending,
    Set<int> desiredIds,
  ) {
    if (!LeavingQatarDeparturePlanNotificationIds.isOwned(pending.id)) {
      return false;
    }
    if (!LeavingQatarDeparturePlanNotificationIds.isDeparturePlanPayload(
      pending.payload,
    )) {
      return false;
    }
    return !desiredIds.contains(pending.id);
  }

  Future<void> _cancelAllOwnedPending() async {
    final pending = await _pendingNotifications();
    for (final p in pending) {
      if (!LeavingQatarDeparturePlanNotificationIds.isOwned(p.id)) continue;
      if (!LeavingQatarDeparturePlanNotificationIds.isDeparturePlanPayload(
        p.payload,
      )) {
        continue;
      }
      try {
        await _cancelNotification(p.id);
      } catch (_) {
        // Next reconcile retries.
      }
    }
  }

  Future<void> _cancelLegacyTrackedKeys() async {
    for (final key in _readScheduledDateKeys()) {
      try {
        await _cancelNotification(
          LeavingQatarDeparturePlanNotificationIds.legacyNotificationIdForDateKey(
            key,
          ),
        );
      } catch (_) {}
    }
  }

  List<String> _readScheduledDateKeys() {
    final raw = _prefs.getStringList(scheduledDateKeysPref);
    return raw ?? const [];
  }

  Future<void> _persistScheduledDateKeys(List<String> keys) async {
    await _prefs.setStringList(scheduledDateKeysPref, keys);
  }

  static Future<NotificationSettings> _defaultLoadSettings() async {
    final repo = await createNotificationRepository();
    return repo.getSettings();
  }

  static Future<void> _defaultInitialize() async {
    await RaabtaLocalNotifications.instance.initialize();
  }

  static Future<List<DeparturePlanPendingNotification>>
      _defaultPendingNotifications() async {
    final pending =
        await RaabtaLocalNotifications.instance.pendingNotificationRequests();
    return pending
        .map(
          (p) => DeparturePlanPendingNotification(
            id: p.id,
            payload: p.payload,
          ),
        )
        .toList();
  }

  static Future<void> _defaultSchedule({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    await RaabtaLocalNotifications.instance.schedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduledDate,
      notificationType: NotificationType.general,
      payload: payload,
    );
  }

  static Future<void> _defaultCancel(int id) async {
    await RaabtaLocalNotifications.instance.cancel(id);
  }
}
