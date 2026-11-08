import 'package:flutter/material.dart';
import 'package:raabta/features/personal_budget/domain/personal_budget_models.dart';
import 'package:raabta/features/personal_budget/presentation/l10n/personal_budget_strings.dart';
import 'package:raabta/features/personal_budget/presentation/widgets/personal_budget_pressure_badge.dart';
import 'package:raabta/services/sharing/models/shareable_card_data.dart';
import 'package:raabta/services/sharing/widgets/share_card_sheet.dart';

PersonalBudgetCardData buildPersonalBudgetShareCardData({
  required PersonalBudgetInputs inputs,
  required PersonalBudgetResult result,
  required String locale,
}) {
  final segments = result.segments.map((seg) {
    final pct = result.monthlyCost > 0
        ? (seg.amount / result.monthlyCost) * 100
        : 0.0;
    return PersonalBudgetSegmentRow(
      label: PersonalBudgetStrings.t(seg.labelKey, locale),
      amount: seg.amount,
      percent: pct,
      color: seg.color,
    );
  }).toList();

  return PersonalBudgetCardData(
    monthlyCost: result.monthlyCost,
    salary: inputs.salary > 0 ? inputs.salary : null,
    savingsRatePercent: result.savingsRatePercent,
    pressureLabel: PersonalBudgetStrings.t(
      pressureBandLabelKey(result.pressureBand),
      locale,
    ),
    pressureColor: pressureBandColor(result.pressureBand),
    segments: segments,
    generatedAt: DateTime.now(),
    shareCaption:
        'My Qatar budget snapshot — QAR ${result.monthlyCost.toStringAsFixed(0)}/month on RAABTA',
  );
}

void showPersonalBudgetShareCard(
  BuildContext context, {
  required PersonalBudgetInputs inputs,
  required PersonalBudgetResult result,
  required String locale,
}) {
  ShareCardSheet.show(
    context,
    buildPersonalBudgetShareCardData(
      inputs: inputs,
      result: result,
      locale: locale,
    ),
  );
}
