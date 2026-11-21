import 'package:flutter_test/flutter_test.dart';
import 'package:raabta/features/quick_actions/climate_navigator/services/climate_workload_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('ClimateWorkloadPreferences', () {
    test('defaults to unset with no stored key', () async {
      final prefs = await ClimateWorkloadPreferences.load();
      expect(prefs.category, ClimateWorkloadCategory.unset);
    });

    test('save persists selected category', () async {
      final ok = await ClimateWorkloadPreferences.save(
        ClimateWorkloadCategory.moderate,
      );
      expect(ok, isTrue);
      final loaded = await ClimateWorkloadPreferences.load();
      expect(loaded.category, ClimateWorkloadCategory.moderate);
    });

    test('clear removes stored category', () async {
      await ClimateWorkloadPreferences.save(ClimateWorkloadCategory.light);
      final ok = await ClimateWorkloadPreferences.clear();
      expect(ok, isTrue);
      final loaded = await ClimateWorkloadPreferences.load();
      expect(loaded.category, ClimateWorkloadCategory.unset);
    });

    test('unknown stored value falls back to unset', () async {
      SharedPreferences.setMockInitialValues({
        'climate_workload_category_v1': 'not_a_category',
      });
      final loaded = await ClimateWorkloadPreferences.load();
      expect(loaded.category, ClimateWorkloadCategory.unset);
    });
  });
}
