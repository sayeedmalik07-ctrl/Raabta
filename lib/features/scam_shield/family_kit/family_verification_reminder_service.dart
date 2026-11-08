import 'dart:convert';

import 'package:raabta/features/scam_shield/family_kit/family_verification_prefs_repository.dart';
import 'package:raabta/features/scam_shield/presentation/l10n/family_verification_kit_strings.dart';
import 'package:raabta/models/notification_models.dart';
import 'package:raabta/services/notification_background.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Opt-in 6-month local reminder — no secret word in notification body.
class FamilyVerificationReminderService {
  FamilyVerificationReminderService(
    this._prefs, {
    DateTime Function()? clock,
    Future<void> Function()? initializeNotifications,
    Future<void> Function({
      required int id,
      required String title,
      required String body,
      required DateTime scheduledDate,
      String? payload,
    })? scheduleNotification,
    Future<void> Function(int id)? cancelNotification,
  })  : _clock = clock ?? DateTime.now,
        _initializeNotifications =
            initializeNotifications ?? _defaultInitialize,
        _scheduleNotification =
            scheduleNotification ?? _defaultSchedule,
        _cancelNotification = cancelNotification ?? _defaultCancel;

  static const notificationId = 8829101;
  static const payloadType = 'ss_family_verification_reminder';
  static const intervalDays = 180;
  static const nextAtKey = 'ss_family_verification_reminder_next_at';

  final SharedPreferences _prefs;
  final DateTime Function() _clock;
  final Future<void> Function() _initializeNotifications;
  final Future<void> Function({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) _scheduleNotification;
  final Future<void> Function(int id) _cancelNotification;

  bool get isEnabled =>
      _prefs.getBool(FamilyVerificationPrefsRepository.reminderKey) ?? false;

  Future<void> reconcile({required String locale}) async {
    await _initializeNotifications();
    if (!isEnabled) {
      await _cancelNotification(notificationId);
      await _prefs.remove(nextAtKey);
      return;
    }

    final now = _clock();
    var next = _readNextAt();
    next ??= now.add(const Duration(days: intervalDays));
    if (!next.isAfter(now)) {
      next = now.add(const Duration(days: intervalDays));
    }

    final title = FamilyVerificationKitStrings.t(
      'ss_fvk_reminder_title',
      locale,
    );
    final body = FamilyVerificationKitStrings.t(
      'ss_fvk_reminder_body',
      locale,
    );

    await _scheduleNotification(
      id: notificationId,
      title: title,
      body: body,
      scheduledDate: next,
      payload: jsonEncode({
        'route': '/scam-shield/family-verification',
        'type': payloadType,
      }),
    );
    await _prefs.setString(nextAtKey, next.toIso8601String());
  }

  Future<void> setEnabled({
    required bool enabled,
    required String locale,
  }) async {
    await _prefs.setBool(
      FamilyVerificationPrefsRepository.reminderKey,
      enabled,
    );
    if (enabled) {
      await reconcile(locale: locale);
    } else {
      await _cancelNotification(notificationId);
      await _prefs.remove(nextAtKey);
    }
  }

  DateTime? _readNextAt() {
    return DateTime.tryParse(_prefs.getString(nextAtKey) ?? '');
  }

  static Future<void> _defaultInitialize() async {
    await RaabtaLocalNotifications.instance.initialize();
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
