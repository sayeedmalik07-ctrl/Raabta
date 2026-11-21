import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/features/quick_actions/climate_navigator/l10n/climate_strings.dart';
import 'package:raabta/features/quick_actions/climate_navigator/services/climate_acclimatization_preferences.dart';
import 'package:raabta/features/quick_actions/climate_navigator/services/climate_acclimatization_schedule.dart';
import 'package:raabta/features/quick_actions/climate_navigator/widgets/acclimatization_schedule_panel.dart';

void main() {
  final start = DateTime(2026, 7, 10);

  AcclimatizationScheduleSnapshot snapOn(DateTime qatarToday) {
    return ClimateAcclimatizationSchedule.snapshot(
      startDate: start,
      referenceNow: qatarToday,
    );
  }

  group('exposurePercentForPlanDay', () {
    test('days 1-5 follow NIOSH 20% ladder', () {
      expect(ClimateAcclimatizationSchedule.exposurePercentForPlanDay(1), 20);
      expect(ClimateAcclimatizationSchedule.exposurePercentForPlanDay(2), 40);
      expect(ClimateAcclimatizationSchedule.exposurePercentForPlanDay(3), 60);
      expect(ClimateAcclimatizationSchedule.exposurePercentForPlanDay(4), 80);
      expect(ClimateAcclimatizationSchedule.exposurePercentForPlanDay(5), 100);
    });

    test('days 6-14 remain at 100%', () {
      for (var day = 6; day <= 14; day++) {
        expect(
          ClimateAcclimatizationSchedule.exposurePercentForPlanDay(day),
          100,
        );
      }
    });

    test('future plan day has no percent', () {
      expect(ClimateAcclimatizationSchedule.exposurePercentForPlanDay(0), isNull);
      expect(ClimateAcclimatizationSchedule.exposurePercentForPlanDay(-3), isNull);
    });
  });

  group('plan day from Qatar calendar', () {
    test('day 1 on start date', () {
      final s = snapOn(DateTime(2026, 7, 10));
      expect(s.planDay, 1);
      expect(s.exposurePercent, 20);
      expect(s.phase, AcclimatizationSchedulePhase.ramp);
    });

    test('Qatar UTC boundary rolls calendar day', () {
      final s = snapOn(DateTime.utc(2026, 7, 9, 21, 0));
      expect(s.planDay, 1);
    });

    test('future start yields notStarted', () {
      final s = snapOn(DateTime(2026, 7, 9));
      expect(s.planDay, 0);
      expect(s.phase, AcclimatizationSchedulePhase.notStarted);
      expect(s.exposurePercent, isNull);
    });

    test('day 5 ramp completes at 100%', () {
      final s = snapOn(DateTime(2026, 7, 14));
      expect(s.planDay, 5);
      expect(s.exposurePercent, 100);
      expect(s.phase, AcclimatizationSchedulePhase.fullExposureSupervision);
    });

    test('days 6-14 supervision window', () {
      for (var d = 6; d <= 14; d++) {
        final s = snapOn(DateTime(2026, 7, 9 + d));
        expect(s.planDay, d);
        expect(s.exposurePercent, 100);
        expect(s.withinSupervisionWindow, isTrue);
        expect(s.phase, AcclimatizationSchedulePhase.fullExposureSupervision);
      }
    });

    test('day 15 keeps 100% cap after reference supervision period', () {
      final s = snapOn(DateTime(2026, 7, 24));
      expect(s.planDay, 15);
      expect(s.exposurePercent, 100);
      expect(s.withinSupervisionWindow, isFalse);
      expect(s.phase, AcclimatizationSchedulePhase.afterSupervisionWindow);
    });
  });

  group('both A1 types share schedule', () {
    test('type does not change percent math', () {
      for (final type in ClimateAcclimatizationType.values) {
        expect(type.name, isNotEmpty);
      }
      expect(snapOn(DateTime(2026, 7, 11)).exposurePercent, 40);
    });
  });

  group('invalid packed dates', () {
    test('unpack rejects malformed packed values', () {
      expect(
        () => ClimateAcclimatizationPreferences.unpackDate(0),
        throwsFormatException,
      );
      expect(
        ClimateAcclimatizationPreferences.isPlanMalformed(
          status: ClimateAcclimatizationStatus.active,
          type: ClimateAcclimatizationType.newToQatarHeat,
          typeName: 'newToQatarHeat',
          startDate: null,
          packed: 20261399,
        ),
        isTrue,
      );
    });
  });

  const scheduleLocaleKeys = [
    'acclimat_schedule_disclaimer_occupational',
    'acclimat_schedule_disclaimer_not_proof',
    'acclimat_schedule_disclaimer_risk',
    'acclimat_schedule_plan_day',
    'acclimat_schedule_exposure_cap',
    'acclimat_schedule_baseline_explainer',
    'acclimat_schedule_guidance_ramp',
    'acclimat_schedule_guidance_supervision',
    'acclimat_schedule_guidance_after_supervision',
    'acclimat_schedule_guidance_not_started',
    'acclimat_schedule_not_started',
    'acclimat_schedule_source',
  ];

  test('schedule strings cover all nine locales', () {
    final report = ClimateStrings.localeCoverageReport;
    for (final key in scheduleLocaleKeys) {
      expect(report[key], isNull, reason: 'Missing locales for $key');
    }
    for (final key in scheduleLocaleKeys) {
      for (final locale in AppLocale.supportedLocales) {
        expect(ClimateStrings.t(key, locale).trim(), isNotEmpty);
      }
    }
  });

  testWidgets('schedule panel shows plan day and percent', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: AcclimatizationSchedulePanel(
              locale: 'English',
              startDate: start,
              referenceNow: DateTime(2026, 7, 12),
            ),
          ),
        ),
      ),
    );
    expect(find.textContaining('Plan day 3'), findsOneWidget);
    expect(find.textContaining('60%'), findsNWidgets(2));
    expect(find.textContaining('not proof'), findsOneWidget);
    expect(find.textContaining('50%'), findsNothing);
  });

  testWidgets('day 15+ guidance keeps 100% cap and employer programme', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: AcclimatizationSchedulePanel(
              locale: 'English',
              startDate: start,
              referenceNow: DateTime(2026, 7, 24),
            ),
          ),
        ),
      ),
    );
    expect(find.textContaining('Plan day 15'), findsOneWidget);
    expect(find.textContaining('100%'), findsWidgets);
    final englishGuidance = ClimateStrings.t(
      'acclimat_schedule_guidance_after_supervision',
      'English',
    );
    expect(englishGuidance.toLowerCase(), isNot(contains('ended')));
    expect(englishGuidance.toLowerCase(), isNot(contains('window has')));
    expect(
      find.textContaining('employer\'s supervision and heat-control'),
      findsOneWidget,
    );
    expect(find.textContaining('remains 100%'), findsOneWidget);
  });

  testWidgets('RTL Urdu layout has no overflow', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: MediaQuery(
            data: const MediaQueryData(size: Size(320, 700)),
            child: Scaffold(
              body: SingleChildScrollView(
                child: AcclimatizationSchedulePanel(
                  locale: 'Urdu',
                  startDate: start,
                  referenceNow: DateTime(2026, 7, 10),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
