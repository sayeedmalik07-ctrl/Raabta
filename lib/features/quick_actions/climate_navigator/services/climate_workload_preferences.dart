import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Local workload category for educational ACGIH reference (not health data).
enum ClimateWorkloadCategory {
  unset,
  light,
  moderate,
  heavy,
  veryHeavy,
}

class ClimateWorkloadPreferences {
  const ClimateWorkloadPreferences({required this.category});

  final ClimateWorkloadCategory category;

  static const _categoryKey = 'climate_workload_category_v1';

  static Future<ClimateWorkloadPreferences> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final name = prefs.getString(_categoryKey);
      return ClimateWorkloadPreferences(category: _parseCategory(name));
    } catch (e, st) {
      debugPrint('ClimateWorkloadPreferences.load failed: $e\n$st');
      return const ClimateWorkloadPreferences(
        category: ClimateWorkloadCategory.unset,
      );
    }
  }

  static Future<bool> save(ClimateWorkloadCategory category) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (category == ClimateWorkloadCategory.unset) {
        await prefs.remove(_categoryKey);
      } else {
        await prefs.setString(_categoryKey, category.name);
      }
      return true;
    } catch (e, st) {
      debugPrint('ClimateWorkloadPreferences.save failed: $e\n$st');
      return false;
    }
  }

  static Future<bool> clear() => save(ClimateWorkloadCategory.unset);

  static ClimateWorkloadCategory _parseCategory(String? name) {
    if (name == null) return ClimateWorkloadCategory.unset;
    for (final value in ClimateWorkloadCategory.values) {
      if (value.name == name) return value;
    }
    return ClimateWorkloadCategory.unset;
  }
}
