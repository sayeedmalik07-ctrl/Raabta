import 'package:flutter_test/flutter_test.dart';
import 'package:raabta/features/quick_actions/climate_navigator/data/acgih_heat_reference_education.dart';
import 'package:raabta/features/quick_actions/climate_navigator/services/climate_workload_preferences.dart';

void main() {
  group('AcgihHeatReferenceEducation', () {
    test('light screening values match Table 2', () {
      final ref = AcgihHeatReferenceEducation.screeningReferenceFor(
        ClimateWorkloadCategory.light,
      );
      expect(ref, isNotNull);
      expect(ref!.actionLimitC, 28.0);
      expect(ref.tlvC, 31.0);
    });

    test('moderate screening values match Table 2', () {
      final ref = AcgihHeatReferenceEducation.screeningReferenceFor(
        ClimateWorkloadCategory.moderate,
      );
      expect(ref, isNotNull);
      expect(ref!.actionLimitC, 25.0);
      expect(ref.tlvC, 28.0);
    });

    test('heavy and very heavy have no continuous screening values', () {
      for (final cat in [
        ClimateWorkloadCategory.heavy,
        ClimateWorkloadCategory.veryHeavy,
      ]) {
        expect(
          AcgihHeatReferenceEducation.screeningReferenceFor(cat),
          isNull,
        );
        expect(
          AcgihHeatReferenceEducation.showsNoContinuousScreening(cat),
          isTrue,
        );
      }
    });

    test('unset has no screening reference', () {
      expect(
        AcgihHeatReferenceEducation.screeningReferenceFor(
          ClimateWorkloadCategory.unset,
        ),
        isNull,
      );
    });
  });
}
