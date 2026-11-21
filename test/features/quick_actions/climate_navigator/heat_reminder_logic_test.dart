import 'package:flutter_test/flutter_test.dart';
import 'package:raabta/features/quick_actions/climate_navigator/data/climate_heat_reminder_constants.dart';
import 'package:raabta/features/quick_actions/climate_navigator/services/heat_risk_calculator.dart';

void main() {
  const activeStart = 6 * 60;
  const activeEnd = 18 * 60;
  const quietStart = 22 * 60;
  const quietEnd = 5 * 60;

  ClimateHeatReminderDecision eval({
    required String band,
    required DateTime qatarLocal,
    ClimateHeatReminderKind kind = ClimateHeatReminderKind.duringActiveWindow,
    int? interval,
  }) {
    return HeatRiskCalculator.evaluateHeatReminderDue(
      wbgtRiskLevelKey: band,
      qatarLocal: qatarLocal,
      activeStartMinute: activeStart,
      activeEndMinute: activeEnd,
      quietStartMinute: quietStart,
      quietEndMinute: quietEnd,
      kind: kind,
      reminderIntervalMinutes:
          interval ?? ClimateHeatReminderConstants.intervalMinutesForBand(band),
    );
  }

  DateTime qatar(int year, int month, int day, int hour, [int minute = 0]) {
    return DateTime(year, month, day, hour, minute);
  }

  group('heat band', () {
    test('lower band never due', () {
      final r = eval(
        band: 'lower',
        qatarLocal: qatar(2026, 7, 10, 12),
      );
      expect(r.isDue, isFalse);
    });

    test('moderate band due on interval inside active window', () {
      final r = eval(
        band: 'moderate',
        qatarLocal: qatar(2026, 7, 10, 8),
      );
      expect(r.isDue, isTrue);
      expect(r.bodyKey, 'heat_reminder_body');
    });

    test('high band uses shorter interval', () {
      final notYet = eval(band: 'high', qatarLocal: qatar(2026, 7, 10, 6, 30));
      expect(notYet.isDue, isFalse);
      final due = eval(band: 'high', qatarLocal: qatar(2026, 7, 10, 7, 30));
      expect(due.isDue, isTrue);
    });
  });

  group('active window', () {
    test('outside active window not due', () {
      final r = eval(
        band: 'high',
        qatarLocal: qatar(2026, 7, 10, 5, 30),
      );
      expect(r.isDue, isFalse);
    });
  });

  group('quiet hours', () {
    test('during quiet hours not due', () {
      final r = eval(
        band: 'extreme',
        qatarLocal: qatar(2026, 7, 10, 23),
      );
      expect(r.isDue, isFalse);
    });
  });

  group('restricted hours variant', () {
    test('June restricted window uses restricted copy', () {
      final r = eval(
        band: 'high',
        qatarLocal: qatar(2026, 7, 10, 12),
        interval: 60,
      );
      expect(r.isDue, isTrue);
      expect(r.bodyKey, 'heat_reminder_body_restricted');
    });

    test('outside June 1–Sep 15 uses standard copy at noon', () {
      final r = eval(
        band: 'high',
        qatarLocal: qatar(2026, 5, 20, 12),
        interval: 60,
      );
      expect(r.isDue, isTrue);
      expect(r.bodyKey, 'heat_reminder_body');
    });
  });

  group('before shift', () {
    test('evening slot fires once at 20:00', () {
      final due = eval(
        band: 'high',
        qatarLocal: qatar(2026, 7, 9, 20),
        kind: ClimateHeatReminderKind.beforeShiftEvening,
      );
      expect(due.isDue, isTrue);
      expect(due.bodyKey, 'heat_reminder_before_shift_body');

      final notDue = eval(
        band: 'high',
        qatarLocal: qatar(2026, 7, 9, 19, 59),
        kind: ClimateHeatReminderKind.beforeShiftEvening,
      );
      expect(notDue.isDue, isFalse);
    });

    test('lead slot 30 minutes before active start', () {
      final due = eval(
        band: 'high',
        qatarLocal: qatar(2026, 7, 10, 5, 30),
        kind: ClimateHeatReminderKind.beforeShiftLead,
      );
      expect(due.isDue, isTrue);
    });

    test('skipped when no active window', () {
      final r = HeatRiskCalculator.evaluateHeatReminderDue(
        wbgtRiskLevelKey: 'high',
        qatarLocal: qatar(2026, 7, 9, 20),
        activeStartMinute: 18 * 60,
        activeEndMinute: 6 * 60,
        quietStartMinute: quietStart,
        quietEndMinute: quietEnd,
        kind: ClimateHeatReminderKind.beforeShiftEvening,
        reminderIntervalMinutes: 90,
      );
      expect(r.isDue, isFalse);
    });

    test('skipped inside quiet hours', () {
      final r = eval(
        band: 'high',
        qatarLocal: qatar(2026, 7, 9, 23),
        kind: ClimateHeatReminderKind.beforeShiftEvening,
      );
      expect(r.isDue, isFalse);
    });

    test('fires when heat band is lower (not band-gated)', () {
      final due = eval(
        band: 'lower',
        qatarLocal: qatar(2026, 7, 9, 20),
        kind: ClimateHeatReminderKind.beforeShiftEvening,
        interval: 0,
      );
      expect(due.isDue, isTrue);
    });
  });

  group('work stop threshold', () {
    test('requiresWorkStop above 32.1', () {
      expect(HeatRiskCalculator.requiresWorkStop(32.2), isTrue);
      expect(HeatRiskCalculator.requiresWorkStop(32.1), isFalse);
    });
  });
}
