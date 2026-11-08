import 'package:flutter/foundation.dart';
import 'package:raabta/features/quick_actions/climate_navigator/data/climate_heat_reminder_constants.dart';
import 'package:raabta/features/quick_actions/climate_navigator/l10n/climate_strings.dart';
import 'package:raabta/features/quick_actions/climate_navigator/models/qatar_weather.dart';
import 'package:raabta/features/quick_actions/climate_navigator/services/heat_risk_calculator.dart';
import 'package:raabta/features/quick_actions/climate_navigator/services/hydration_reminder_preferences.dart';
import 'package:raabta/services/notifications/notification_service.dart';

/// Schedules / cancels Climate Navigator heat reminders from cached weather.
abstract final class ClimateHeatReminderScheduler {
  /// Opt-in sync: band reminders + legacy daily heat alert (same toggle).
  static Future<void> syncFromWeather({
    required QatarWeather weather,
    required String locale,
  }) async {
    final prefs = await ClimateHeatReminderPreferences.load();
    await NotificationService.cancelHeatSafetyAlert();
    await NotificationService.cancelClimateHeatReminders();

    if (!prefs.enabled) return;
    if (!weather.canScheduleHeatReminders) return;

    await NotificationService.scheduleHeatSafetyAlert(
      heatIndexC: weather.heatIndexC,
      heatRiskLabel:
          ClimateStrings.heatIndexRiskLabel(weather.heatIndexC, locale),
    );

    final slots = planReminderSlots(
      weather: weather,
      prefs: prefs,
      locale: locale,
      nowUtc: DateTime.now().toUtc(),
    );

    await NotificationService.scheduleClimateHeatReminders(
      slots: slots
          .map(
            (s) => (
              id: s.id,
              whenUtc: s.whenUtc,
              title: s.title,
              body: s.body,
            ),
          )
          .toList(),
    );
  }

  @Deprecated('Use syncFromWeather')
  static Future<void> reschedule({
    required QatarWeather weather,
    required String locale,
  }) =>
      syncFromWeather(weather: weather, locale: locale);

  /// Whether the legacy daily alert would be scheduled for [weather] when opt-in is on.
  @visibleForTesting
  static bool legacyDailyAlertWouldSchedule(
    QatarWeather weather, {
    DateTime? reference,
  }) {
    if (!weather.canScheduleHeatReminders) return false;
    final month = (reference ?? DateTime.now()).month;
    final isPeakSummer = month >= 5 && month <= 9;
    if (!isPeakSummer) return false;
    return weather.heatIndexC >= 38;
  }

  @visibleForTesting
  static List<PlannedHeatReminderSlot> planReminderSlots({
    required QatarWeather weather,
    required ClimateHeatReminderPreferences prefs,
    required String locale,
    required DateTime nowUtc,
  }) {
    if (!weather.canScheduleHeatReminders) return const [];

    final band = weather.wbgtRiskLevelKey;
    final interval = ClimateHeatReminderConstants.intervalMinutesForBand(band);
    final nowQatar = HeatRiskCalculator.toQatarLocal(nowUtc);
    final slots = <PlannedHeatReminderSlot>[];
    var slotIndex = 0;

    if (interval > 0 && prefs.hasActiveWindow) {
      var cursor = nowQatar;
      final horizon = nowQatar.add(const Duration(hours: 36));
      while (cursor.isBefore(horizon) &&
          slotIndex < ClimateHeatReminderConstants.maxDuringWindowSlots) {
        final decision = HeatRiskCalculator.evaluateHeatReminderDue(
          wbgtRiskLevelKey: band,
          qatarLocal: cursor,
          activeStartMinute: prefs.activeStartMinute,
          activeEndMinute: prefs.activeEndMinute,
          quietStartMinute: prefs.quietStartMinute,
          quietEndMinute: prefs.quietEndMinute,
          kind: ClimateHeatReminderKind.duringActiveWindow,
          reminderIntervalMinutes: interval,
        );
        if (decision.isDue) {
          final whenUtc = HeatRiskCalculator.qatarWallToUtcInstant(cursor);
          if (whenUtc.isAfter(nowUtc.subtract(const Duration(minutes: 1)))) {
            slots.add(
              PlannedHeatReminderSlot(
                id: NotificationIds.climateHeatDuringSlotId(slotIndex),
                whenUtc: whenUtc,
                title: ClimateStrings.t(decision.titleKey!, locale),
                body: ClimateStrings.t(decision.bodyKey!, locale),
              ),
            );
            slotIndex++;
          }
        }
        cursor = cursor.add(const Duration(minutes: 1));
      }
    }

    if (prefs.beforeShiftEnabled && prefs.hasActiveWindow) {
      for (final kind in [
        ClimateHeatReminderKind.beforeShiftEvening,
        ClimateHeatReminderKind.beforeShiftLead,
      ]) {
        final candidate = _nextBeforeShiftInstant(nowQatar, kind, prefs);
        if (candidate == null) continue;
        final decision = HeatRiskCalculator.evaluateHeatReminderDue(
          wbgtRiskLevelKey: band,
          qatarLocal: candidate,
          activeStartMinute: prefs.activeStartMinute,
          activeEndMinute: prefs.activeEndMinute,
          quietStartMinute: prefs.quietStartMinute,
          quietEndMinute: prefs.quietEndMinute,
          kind: kind,
          reminderIntervalMinutes: interval,
        );
        if (!decision.isDue) continue;
        final whenUtc = HeatRiskCalculator.qatarWallToUtcInstant(candidate);
        if (whenUtc.isBefore(nowUtc.subtract(const Duration(minutes: 1)))) {
          continue;
        }
        slots.add(
          PlannedHeatReminderSlot(
            id: kind == ClimateHeatReminderKind.beforeShiftEvening
                ? NotificationIds.climateHeatBeforeShiftEveningId()
                : NotificationIds.climateHeatBeforeShiftLeadId(),
            whenUtc: whenUtc,
            title: ClimateStrings.t(decision.titleKey!, locale),
            body: ClimateStrings.t(decision.bodyKey!, locale),
          ),
        );
      }
    }

    return slots;
  }

  static DateTime? _nextBeforeShiftInstant(
    DateTime nowQatar,
    ClimateHeatReminderKind kind,
    ClimateHeatReminderPreferences prefs,
  ) {
    for (var dayOffset = 0; dayOffset < 2; dayOffset++) {
      final day = DateTime(
        nowQatar.year,
        nowQatar.month,
        nowQatar.day + dayOffset,
      );
      late DateTime candidate;
      if (kind == ClimateHeatReminderKind.beforeShiftEvening) {
        candidate = DateTime(
          day.year,
          day.month,
          day.day,
          ClimateHeatReminderConstants.beforeShiftEveningHour,
          ClimateHeatReminderConstants.beforeShiftEveningMinute,
        );
      } else {
        final lead = prefs.activeStartMinute -
            ClimateHeatReminderConstants.beforeShiftLeadMinutes;
        if (lead < 0) return null;
        candidate = DateTime(
          day.year,
          day.month,
          day.day,
          lead ~/ 60,
          lead % 60,
        );
      }
      if (!candidate.isBefore(nowQatar)) return candidate;
    }
    return null;
  }
}

@immutable
class PlannedHeatReminderSlot {
  const PlannedHeatReminderSlot({
    required this.id,
    required this.whenUtc,
    required this.title,
    required this.body,
  });

  final int id;
  final DateTime whenUtc;
  final String title;
  final String body;
}
