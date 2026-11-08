import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/features/personal_budget/domain/personal_budget_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _prefsKey = 'personal_budget_inputs_v1';

class PersonalBudgetLocalStore {
  Future<PersonalBudgetInputs?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw == null) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return PersonalBudgetInputs(
        salary: (map['salary'] as num?)?.toDouble() ?? 0,
        rent: (map['rent'] as num?)?.toDouble() ?? 0,
        food: (map['food'] as num?)?.toDouble() ?? 0,
        transport: (map['transport'] as num?)?.toDouble() ?? 0,
        utilities: (map['utilities'] as num?)?.toDouble() ?? 0,
        family: (map['family'] as num?)?.toDouble() ?? 0,
        remittance: (map['remittance'] as num?)?.toDouble() ?? 0,
        other: (map['other'] as num?)?.toDouble() ?? 0,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> save(PersonalBudgetInputs inputs) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _prefsKey,
      jsonEncode({
        'salary': inputs.salary,
        'rent': inputs.rent,
        'food': inputs.food,
        'transport': inputs.transport,
        'utilities': inputs.utilities,
        'family': inputs.family,
        'remittance': inputs.remittance,
        'other': inputs.other,
      }),
    );
  }
}

final personalBudgetLocalStoreProvider =
    Provider<PersonalBudgetLocalStore>((ref) => PersonalBudgetLocalStore());
