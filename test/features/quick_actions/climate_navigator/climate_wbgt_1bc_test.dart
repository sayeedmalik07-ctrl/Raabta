import 'package:flutter_test/flutter_test.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/features/quick_actions/climate_navigator/data/qatar_outdoor_work_rules.dart';
import 'package:raabta/features/quick_actions/climate_navigator/data/wbgt_estimate_uncertainty.dart';
import 'package:raabta/features/quick_actions/climate_navigator/l10n/climate_strings.dart';
import 'package:raabta/features/quick_actions/climate_navigator/models/climate_wbgt_meter_reading.dart';
import 'package:raabta/features/quick_actions/climate_navigator/services/climate_wbgt_meter_repository.dart';
import 'package:raabta/features/quick_actions/climate_navigator/services/heat_risk_calculator.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('uncertainty margin 2.0°C', () {
    test('approximate range uses provisional margin', () {
      final range = WbgtEstimateUncertainty.approximateRange(28.4);
      expect(range.low, closeTo(26.4, 0.01));
      expect(range.high, closeTo(30.4, 0.01));
      expect(WbgtEstimateUncertainty.provisionalMarginC, 2.0);
    });

    test('band boundaries for close-to escalation', () {
      expect(
        WbgtEstimateUncertainty.closeToNonLegalBandKey(24.0),
        'moderate',
      );
      expect(
        WbgtEstimateUncertainty.closeToNonLegalBandKey(26.0),
        'high',
      );
      expect(
        WbgtEstimateUncertainty.closeToNonLegalBandKey(28.0),
        'extreme',
      );
    });

    test('no close-to when already at upper non-legal band', () {
      expect(WbgtEstimateUncertainty.closeToNonLegalBandKey(30.0), isNull);
    });

    test('never close-to work_stop via margin', () {
      expect(WbgtEstimateUncertainty.closeToNonLegalBandKey(31.0), isNull);
      expect(WbgtEstimateUncertainty.upperBandKey(31.0), 'work_stop');
    });

    test('legal threshold unchanged at 32.1', () {
      expect(HeatRiskCalculator.requiresWorkStop(32.1), isFalse);
      expect(HeatRiskCalculator.requiresWorkStop(32.15), isTrue);
      expect(QatarOutdoorWorkRules.wbgtWorkStopThresholdC, 32.1);
    });
  });

  group('meter validation', () {
    test('accepts 20 and 45 inclusive', () {
      expect(ClimateWbgtMeterValidation.parseWbgtInput('20'), 20);
      expect(ClimateWbgtMeterValidation.parseWbgtInput('45'), 45);
    });

    test('rejects out of range and non-finite', () {
      expect(ClimateWbgtMeterValidation.parseWbgtInput('19.9'), isNull);
      expect(ClimateWbgtMeterValidation.parseWbgtInput('45.1'), isNull);
      expect(ClimateWbgtMeterValidation.parseWbgtInput('abc'), isNull);
    });

    test('rejects double infinity and nan via isValidWbgtValue', () {
      expect(ClimateWbgtMeterValidation.isValidWbgtValue(double.infinity), isFalse);
      expect(
        ClimateWbgtMeterValidation.isValidWbgtValue(double.negativeInfinity),
        isFalse,
      );
      expect(ClimateWbgtMeterValidation.isValidWbgtValue(double.nan), isFalse);
    });

    test('rejects phone and name notes', () {
      expect(ClimateWbgtMeterValidation.isNoteAllowed('55123456'), isFalse);
      expect(ClimateWbgtMeterValidation.isNoteAllowed('John Smith'), isFalse);
      expect(ClimateWbgtMeterValidation.isNoteAllowed('warehouse bay 3'), isTrue);
    });
  });

  group('meter persistence', () {
    test('append stores estimate snapshot and retains 48', () async {
      final many = List.generate(
        50,
        (i) => ClimateWbgtMeterReading(
          recordedAt: DateTime.utc(2026, 1, 1, 0, i),
          meterWbgtC: 30.0 + i * 0.01,
          estimateWbgtC: 29.0,
          estimateBandKey: 'high',
        ),
      );
      await ClimateWbgtMeterRepository.replaceAllForTest(many);
      final loaded = await ClimateWbgtMeterRepository.loadAll();
      expect(loaded.length, 48);

      await ClimateWbgtMeterRepository.append(
        meterWbgtC: 33.0,
        estimateWbgtC: 31.5,
        estimateBandKey: 'extreme',
        note: 'roof level',
      );
      final latest = await ClimateWbgtMeterRepository.latest();
      expect(latest!.meterWbgtC, 33.0);
      expect(latest.estimateBandKey, 'extreme');
      expect(latest.recordedAt.isAfter(DateTime.utc(2026, 1, 1)), isTrue);
    });

    test('49 sequential append calls retain exactly newest 48', () async {
      const lastIndex = 48;
      const lastMeter = 20.0 + lastIndex * 0.1;
      for (var i = 0; i < 49; i++) {
        await ClimateWbgtMeterRepository.append(
          meterWbgtC: 20.0 + i * 0.1,
          estimateWbgtC: 28.0 + i * 0.01,
          estimateBandKey: i == lastIndex ? 'extreme' : 'high',
        );
      }

      final all = await ClimateWbgtMeterRepository.loadAll();
      expect(all.length, 48);

      final latest = await ClimateWbgtMeterRepository.latest();
      expect(latest!.meterWbgtC, closeTo(lastMeter, 0.05));
      expect(latest.estimateWbgtC, 28.5);
      expect(latest.estimateBandKey, 'extreme');
    });
  });

  group('meter share text', () {
    test('buildShareText includes meter, estimate, diff, time and disclaimer', () {
      const locale = 'English';
      final recordedAt = DateTime.utc(2026, 7, 4, 14, 30);
      final reading = ClimateWbgtMeterReading(
        recordedAt: recordedAt,
        meterWbgtC: 33.2,
        estimateWbgtC: 31.0,
        estimateBandKey: 'extreme',
      );
      final text = ClimateWbgtMeterRepository.buildShareText(
        reading,
        (k) => ClimateStrings.t(k, locale),
        (k, p) => ClimateStrings.format(k, locale, params: p),
      );

      expect(text, contains('33.2'));
      expect(text, contains('31.0'));
      expect(text, contains('+2.2'));
      expect(text, contains(recordedAt.toIso8601String()));
      expect(
        text,
        contains(ClimateStrings.t('meter_not_legal_record', locale)),
      );
    });
  });

  group('meter caution vs estimate band', () {
    test('higher meter raises caution band', () {
      expect(
        WbgtEstimateUncertainty.meterCautionBandKey(
          meterWbgtC: 31.0,
          estimateBandKey: 'high',
        ),
        'extreme',
      );
    });

    test('lower meter never lowers band', () {
      expect(
        WbgtEstimateUncertainty.meterCautionBandKey(
          meterWbgtC: 25.0,
          estimateBandKey: 'high',
        ),
        isNull,
      );
    });
  });

  group('localization part 1B/1C keys', () {
    const keys = [
      'uncertainty_approx_range',
      'uncertainty_site_variation_note',
      'uncertainty_close_to_title',
      'uncertainty_provisional_margin_note',
      'meter_section_title',
      'meter_not_legal_record',
      'meter_share_body',
    ];

    test('nine locales non-empty and not key echo', () {
      for (final key in keys) {
        for (final locale in AppLocale.supportedLocales) {
          final value = ClimateStrings.t(key, locale);
          expect(value, isNotEmpty);
          expect(value, isNot(key));
        }
      }
    });
  });
}
