import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/personal_budget/domain/personal_budget_models.dart';
import 'package:raabta/features/personal_budget/presentation/l10n/personal_budget_strings.dart';

String pressureBandLabelKey(BudgetPressureBand band) {
  return switch (band) {
    BudgetPressureBand.comfortable => 'pb_pressure_comfortable',
    BudgetPressureBand.moderate => 'pb_pressure_moderate',
    BudgetPressureBand.high => 'pb_pressure_high',
    BudgetPressureBand.critical => 'pb_pressure_critical',
    BudgetPressureBand.unknown => 'pb_enter_salary',
  };
}

Color pressureBandColor(BudgetPressureBand band) {
  return switch (band) {
    BudgetPressureBand.comfortable => AppColors.successBright,
    BudgetPressureBand.moderate => AppColors.accentGold,
    BudgetPressureBand.high => AppColors.chipLease,
    BudgetPressureBand.critical => AppColors.errorBright,
    BudgetPressureBand.unknown => AppColors.textTertiary,
  };
}

class PersonalBudgetPressureBadge extends StatelessWidget {
  const PersonalBudgetPressureBadge({
    super.key,
    required this.band,
    required this.locale,
    this.percent,
  });

  final BudgetPressureBand band;
  final String locale;
  final double? percent;

  @override
  Widget build(BuildContext context) {
    final color = pressureBandColor(band);
    final label = PersonalBudgetStrings.t(pressureBandLabelKey(band), locale);
    final percentText = percent != null
        ? '${percent!.toStringAsFixed(1)}%'
        : null;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(color: color.withValues(alpha: 0.6)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            percentText != null ? '$label · $percentText' : label,
            style: AppTypography.chipLabel.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
