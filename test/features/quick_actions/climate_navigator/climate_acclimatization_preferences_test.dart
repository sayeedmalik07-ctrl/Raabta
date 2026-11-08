import 'package:flutter_test/flutter_test.dart';
import 'package:raabta/features/quick_actions/climate_navigator/services/climate_acclimatization_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('ClimateAcclimatizationPreferences', () {
    test('defaults to inactive with no stored fields', () async {
      final prefs = await ClimateAcclimatizationPreferences.load();
      expect(prefs.status, ClimateAcclimatizationStatus.inactive);
      expect(prefs.outdoorEligibility, ClimateOutdoorEligibility.unset);
      expect(prefs.type, isNull);
      expect(prefs.startDate, isNull);
      expect(prefs.isActive, isFalse);
    });

    test('saveActivePlan persists type and Qatar calendar start', () async {
      final start = DateTime.utc(2026, 7, 4, 21, 0);
      final ok = await ClimateAcclimatizationPreferences.saveActivePlan(
        type: ClimateAcclimatizationType.returningAfterLeave,
        startDate: start,
      );
      expect(ok, isTrue);
      final loaded = await ClimateAcclimatizationPreferences.load();
      expect(loaded.status, ClimateAcclimatizationStatus.active);
      expect(loaded.outdoorEligibility, ClimateOutdoorEligibility.eligible);
      expect(loaded.type, ClimateAcclimatizationType.returningAfterLeave);
      expect(loaded.startDate, DateTime(2026, 7, 5));
      expect(loaded.isActive, isTrue);
    });

    test('re-saving the same Qatar calendar day is idempotent', () async {
      await ClimateAcclimatizationPreferences.saveActivePlan(
        type: ClimateAcclimatizationType.newToQatarHeat,
        startDate: DateTime(2026, 6, 1, 8),
      );
      await ClimateAcclimatizationPreferences.saveActivePlan(
        type: ClimateAcclimatizationType.newToQatarHeat,
        startDate: DateTime(2026, 6, 1, 22),
      );
      final loaded = await ClimateAcclimatizationPreferences.load();
      expect(loaded.startDate, DateTime(2026, 6, 1));
    });

    test('setWorksOutdoorInHeat(false) persists ineligible and clears plan', () async {
      await ClimateAcclimatizationPreferences.saveActivePlan(
        type: ClimateAcclimatizationType.newToQatarHeat,
        startDate: DateTime(2026, 8, 1),
      );
      final ok = await ClimateAcclimatizationPreferences.setWorksOutdoorInHeat(
        false,
      );
      expect(ok, isTrue);
      final loaded = await ClimateAcclimatizationPreferences.load();
      expect(loaded.isActive, isFalse);
      expect(loaded.outdoorEligibility, ClimateOutdoorEligibility.ineligible);
      expect(loaded.shouldHideAcclimatizationSection, isTrue);
    });

    test('clearActivePlan resets plan and outdoor eligibility', () async {
      await ClimateAcclimatizationPreferences.saveActivePlan(
        type: ClimateAcclimatizationType.newToQatarHeat,
        startDate: DateTime(2026, 8, 1),
      );
      await ClimateAcclimatizationPreferences.clearActivePlan();
      final loaded = await ClimateAcclimatizationPreferences.load();
      expect(loaded.isActive, isFalse);
      expect(loaded.outdoorEligibility, ClimateOutdoorEligibility.unset);
    });

    test('malformed active plan without date is repaired on load', () async {
      SharedPreferences.setMockInitialValues({
        'climate_acclimat_status_v1': 'active',
        'climate_acclimat_type_v1': 'newToQatarHeat',
      });
      final loaded = await ClimateAcclimatizationPreferences.load();
      expect(loaded.isActive, isFalse);
      expect(loaded.type, isNull);
    });

    test('invalid type name is repaired on load', () async {
      SharedPreferences.setMockInitialValues({
        'climate_acclimat_status_v1': 'active',
        'climate_acclimat_type_v1': 'bogus',
        'climate_acclimat_start_date_v1': 20260701,
      });
      final loaded = await ClimateAcclimatizationPreferences.load();
      expect(loaded.isActive, isFalse);
    });

    test('pack and unpack round-trip', () {
      const packed = 20260704;
      final unpacked = ClimateAcclimatizationPreferences.unpackDate(packed);
      expect(unpacked, DateTime(2026, 7, 4));
      expect(
        ClimateAcclimatizationPreferences.packDate(unpacked),
        packed,
      );
    });
  });

  group('qatarCalendarDate', () {
    test('UTC instant maps to Qatar calendar day', () {
      final utc = DateTime.utc(2026, 6, 30, 21, 30);
      final qatarDay = ClimateAcclimatizationPreferences.qatarCalendarDate(utc);
      expect(qatarDay, DateTime(2026, 7, 1));
    });

    test('local picker midnight maps through Qatar offset', () {
      final local = DateTime(2026, 7, 4);
      final qatarDay =
          ClimateAcclimatizationPreferences.qatarCalendarDate(local);
      expect(qatarDay.year, 2026);
      expect(qatarDay.month, 7);
      expect(qatarDay.day, 4);
    });
  });
}
