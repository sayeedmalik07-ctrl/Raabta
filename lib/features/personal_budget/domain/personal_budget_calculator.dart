import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/features/personal_budget/domain/personal_budget_models.dart';

/// Pure deterministic personal budget math — no AI, no side effects.
abstract final class PersonalBudgetCalculator {
  static const _expenseCategories = PersonalBudgetCategory.values;

  static PersonalBudgetResult compute(PersonalBudgetInputs inputs) {
    final monthlyCost = inputs.rent +
        inputs.food +
        inputs.transport +
        inputs.utilities +
        inputs.family +
        inputs.remittance +
        inputs.other;

    final annualCost = monthlyCost * 12;
    final salarySet = inputs.salary > 0;

    double? savingsRatePercent;
    double? budgetPressurePercent;
    BudgetPressureBand pressureBand = BudgetPressureBand.unknown;
    final potentialSavings =
        salarySet ? inputs.salary - monthlyCost : 0.0;
    final annualPotentialSavings = potentialSavings * 12;

    if (salarySet) {
      savingsRatePercent =
          ((inputs.salary - monthlyCost) / inputs.salary) * 100;
      budgetPressurePercent = (monthlyCost / inputs.salary) * 100;
      pressureBand = _bandFor(budgetPressurePercent);
    }

    final segments = <PersonalBudgetBreakdownSegment>[];
    for (final category in _expenseCategories) {
      final amount = inputs.amountFor(category);
      if (amount <= 0) continue;
      segments.add(
        PersonalBudgetBreakdownSegment(
          category: category,
          labelKey: _labelKeyFor(category),
          amount: amount,
          color: _colorFor(category),
        ),
      );
    }

    final attentionInsight = _attentionInsight(
      inputs: inputs,
      monthlyCost: monthlyCost,
      pressureBand: pressureBand,
      salarySet: salarySet,
    );

    return PersonalBudgetResult(
      monthlyCost: monthlyCost,
      annualCost: annualCost,
      savingsRatePercent: savingsRatePercent,
      budgetPressurePercent: budgetPressurePercent,
      pressureBand: pressureBand,
      potentialSavings: potentialSavings,
      annualPotentialSavings: annualPotentialSavings,
      salarySet: salarySet,
      segments: segments,
      attentionInsight: attentionInsight,
    );
  }

  static PersonalBudgetAttentionInsight? _attentionInsight({
    required PersonalBudgetInputs inputs,
    required double monthlyCost,
    required BudgetPressureBand pressureBand,
    required bool salarySet,
  }) {
    if (!salarySet || monthlyCost <= 0) return null;
    if (pressureBand != BudgetPressureBand.high &&
        pressureBand != BudgetPressureBand.critical) {
      return null;
    }

    PersonalBudgetCategory? topCategory;
    var topAmount = 0.0;
    for (final category in _expenseCategories) {
      final amount = inputs.amountFor(category);
      if (amount > topAmount) {
        topAmount = amount;
        topCategory = category;
      }
    }

    if (topCategory == null || topAmount <= 0) return null;

    return PersonalBudgetAttentionInsight(
      category: topCategory,
      labelKey: _labelKeyFor(topCategory),
      sharePercent: (topAmount / monthlyCost) * 100,
    );
  }

  static BudgetPressureBand _bandFor(double pressurePercent) {
    if (pressurePercent < 50) return BudgetPressureBand.comfortable;
    if (pressurePercent < 70) return BudgetPressureBand.moderate;
    if (pressurePercent < 90) return BudgetPressureBand.high;
    return BudgetPressureBand.critical;
  }

  static String _labelKeyFor(PersonalBudgetCategory category) {
    return switch (category) {
      PersonalBudgetCategory.rent => 'pb_cat_rent',
      PersonalBudgetCategory.food => 'pb_cat_food',
      PersonalBudgetCategory.transport => 'pb_cat_transport',
      PersonalBudgetCategory.utilities => 'pb_cat_utilities',
      PersonalBudgetCategory.family => 'pb_cat_family',
      PersonalBudgetCategory.remittance => 'pb_cat_remittance',
      PersonalBudgetCategory.other => 'pb_cat_other',
    };
  }

  static Color _colorFor(PersonalBudgetCategory category) {
    return switch (category) {
      PersonalBudgetCategory.rent => AppColors.chipLease,
      PersonalBudgetCategory.food => AppColors.chipFood,
      PersonalBudgetCategory.transport => AppColors.chipTrip,
      PersonalBudgetCategory.utilities => AppColors.chipClimate,
      PersonalBudgetCategory.family => AppColors.chipCommunity,
      PersonalBudgetCategory.remittance => AppColors.chipWage,
      PersonalBudgetCategory.other => AppColors.chipQueue,
    };
  }
}
