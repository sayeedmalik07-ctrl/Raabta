import 'package:flutter/material.dart';

enum PersonalBudgetCategory {
  rent,
  food,
  transport,
  utilities,
  family,
  remittance,
  other,
}

enum BudgetPressureBand {
  comfortable,
  moderate,
  high,
  critical,
  unknown,
}

class PersonalBudgetInputs {
  const PersonalBudgetInputs({
    this.salary = 0,
    this.rent = 0,
    this.food = 0,
    this.transport = 0,
    this.utilities = 0,
    this.family = 0,
    this.remittance = 0,
    this.other = 0,
  });

  final double salary;
  final double rent;
  final double food;
  final double transport;
  final double utilities;
  final double family;
  final double remittance;
  final double other;

  PersonalBudgetInputs copyWith({
    double? salary,
    double? rent,
    double? food,
    double? transport,
    double? utilities,
    double? family,
    double? remittance,
    double? other,
  }) {
    return PersonalBudgetInputs(
      salary: salary ?? this.salary,
      rent: rent ?? this.rent,
      food: food ?? this.food,
      transport: transport ?? this.transport,
      utilities: utilities ?? this.utilities,
      family: family ?? this.family,
      remittance: remittance ?? this.remittance,
      other: other ?? this.other,
    );
  }

  double amountFor(PersonalBudgetCategory category) {
    return switch (category) {
      PersonalBudgetCategory.rent => rent,
      PersonalBudgetCategory.food => food,
      PersonalBudgetCategory.transport => transport,
      PersonalBudgetCategory.utilities => utilities,
      PersonalBudgetCategory.family => family,
      PersonalBudgetCategory.remittance => remittance,
      PersonalBudgetCategory.other => other,
    };
  }
}

class PersonalBudgetBreakdownSegment {
  const PersonalBudgetBreakdownSegment({
    required this.category,
    required this.labelKey,
    required this.amount,
    required this.color,
  });

  final PersonalBudgetCategory category;
  final String labelKey;
  final double amount;
  final Color color;
}

class PersonalBudgetAttentionInsight {
  const PersonalBudgetAttentionInsight({
    required this.category,
    required this.labelKey,
    required this.sharePercent,
  });

  final PersonalBudgetCategory category;
  final String labelKey;
  final double sharePercent;
}

class PersonalBudgetResult {
  const PersonalBudgetResult({
    required this.monthlyCost,
    required this.annualCost,
    required this.savingsRatePercent,
    required this.budgetPressurePercent,
    required this.pressureBand,
    required this.potentialSavings,
    required this.annualPotentialSavings,
    required this.salarySet,
    required this.segments,
    this.attentionInsight,
  });

  final double monthlyCost;
  final double annualCost;

  /// Null when salary is zero or unset.
  final double? savingsRatePercent;

  /// Null when salary is zero or unset.
  final double? budgetPressurePercent;
  final BudgetPressureBand pressureBand;
  final double potentialSavings;
  final double annualPotentialSavings;
  final bool salarySet;
  final List<PersonalBudgetBreakdownSegment> segments;
  final PersonalBudgetAttentionInsight? attentionInsight;
}
