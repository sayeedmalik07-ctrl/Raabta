import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raabta/features/quick_actions/climate_navigator/models/qatar_weather.dart';
import 'package:raabta/features/quick_actions/climate_navigator/services/climate_heat_reminder_scheduler.dart';
import 'package:raabta/features/quick_actions/climate_navigator/services/hydration_reminder_preferences.dart';
import 'package:raabta/services/notifications/notification_service.dart';

void main() {
  QatarWeather liveWeather({
    double tempC = 40,
    double heatIndexC = 45,
    bool cached = false,
    bool dataAvailable = true,
  }) {
    return QatarWeather(
      tempC: tempC,
      feelsLikeC: tempC + 5,
      humidity: 70,
      description: 'Hot',
      heatIndexC: heatIndexC,
      uvIndex: 9,
      windSpeedMs: 2,
      isPeakHeat: true,
      dataAvailable: dataAvailable,
      isFallback: false,
      cached: cached,
      cloudCover: 10,
      fetchedAt: DateTime.utc(2026, 7, 10, 6),
    );
  }

  group('canScheduleHeatReminders', () {
    test('fallback is not schedulable', () {
      expect(QatarWeather.fallback().canScheduleHeatReminders, isFalse);
    });

    test('unavailable data is not schedulable', () {
      expect(
        liveWeather(dataAvailable: false).canScheduleHeatReminders,
        isFalse,
      );
    });

    test('live and cached backend snapshot is schedulable', () {
      expect(liveWeather(cached: true).canScheduleHeatReminders, isTrue);
    });
  });

  group('legacyDailyAlertWouldSchedule', () {
    test('blocked when weather not schedulable', () {
      expect(
        ClimateHeatReminderScheduler.legacyDailyAlertWouldSchedule(
          QatarWeather.fallback(),
          reference: DateTime(2026, 7, 10),
        ),
        isFalse,
      );
    });

    test('allowed in summer when heat index high and data live', () {
      expect(
        ClimateHeatReminderScheduler.legacyDailyAlertWouldSchedule(
          liveWeather(heatIndexC: 45),
          reference: DateTime(2026, 7, 10),
        ),
        isTrue,
      );
    });

    test('blocked off-season', () {
      expect(
        ClimateHeatReminderScheduler.legacyDailyAlertWouldSchedule(
          liveWeather(heatIndexC: 45),
          reference: DateTime(2026, 3, 10),
        ),
        isFalse,
      );
    });
  });

  group('planReminderSlots', () {
    test('returns no slots when weather is fallback/unavailable', () {
      final weather = QatarWeather.fallback();
      final prefs = const ClimateHeatReminderPreferences(
        enabled: true,
        activeStart: TimeOfDay(hour: 6, minute: 0),
        activeEnd: TimeOfDay(hour: 22, minute: 0),
        quietStart: TimeOfDay(hour: 22, minute: 0),
        quietEnd: TimeOfDay(hour: 5, minute: 0),
        beforeShiftEnabled: false,
      );
      final slots = ClimateHeatReminderScheduler.planReminderSlots(
        weather: weather,
        prefs: prefs,
        locale: 'English',
        nowUtc: DateTime.utc(2026, 7, 10, 3),
      );
      expect(slots, isEmpty);
    });

    test('caps during-window slots at 48', () {
      final weather = liveWeather(tempC: 42);
      final prefs = const ClimateHeatReminderPreferences(
        enabled: true,
        activeStart: TimeOfDay(hour: 0, minute: 0),
        activeEnd: TimeOfDay(hour: 23, minute: 59),
        quietStart: TimeOfDay(hour: 23, minute: 59),
        quietEnd: TimeOfDay(hour: 0, minute: 0),
        beforeShiftEnabled: false,
      );
      final slots = ClimateHeatReminderScheduler.planReminderSlots(
        weather: weather,
        prefs: prefs,
        locale: 'English',
        nowUtc: DateTime.utc(2026, 7, 10, 0),
      );
      final during = slots
          .where((s) => s.id < NotificationIds.climateHeatBeforeShiftEveningId())
          .toList();
      expect(during.length, lessThanOrEqualTo(48));
      expect(during.length, greaterThanOrEqualTo(45));
    });
  });
}
