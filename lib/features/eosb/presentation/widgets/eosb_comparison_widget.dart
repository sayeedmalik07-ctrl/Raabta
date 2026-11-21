import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/eosb/domain/models/eosb_result.dart';
import 'package:raabta/features/eosb/presentation/l10n/eosb_strings.dart';

class EosbComparisonWidget extends StatelessWidget {
  const EosbComparisonWidget({
    super.key,
    required this.comparison,
    required this.locale,
  });

  final EmployerComparison comparison;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final fair = !comparison.isUnderpaid;
    final accent = fair ? AppColors.successBright : AppColors.errorBright;

    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      glowColor: accent,
      glowIntensity: 0.18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _CompareRow(
            label: 'Employer Offer',
            amount: comparison.employerOffer,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: AppSpacing.sm),
          _CompareRow(
            label: EosbStrings.t('eosb_your_estimate', locale),
            amount: comparison.legalEstimate,
            color: AppColors.info,
          ),
          const Divider(height: AppSpacing.lg),
          _CompareRow(
            label: EosbStrings.t('eosb_difference', locale),
            amount: comparison.difference,
            color: accent,
            bold: true,
          ),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
            child: LinearProgressIndicator(
              value: comparison.legalEstimate > 0
                  ? (comparison.employerOffer / comparison.legalEstimate)
                      .clamp(0.0, 1.0)
                  : 0,
              minHeight: 8,
              backgroundColor: AppColors.surfaceElevated,
              color: accent,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            fair
                ? 'Offer appears close to estimate'
                : '${comparison.differencePercent.toStringAsFixed(0)}% below estimate',
            style: AppTypography.bodySmall.copyWith(color: accent),
          ),
        ],
      ),
    );
  }
}

class _CompareRow extends StatelessWidget {
  const _CompareRow({
    required this.label,
    required this.amount,
    required this.color,
    this.bold = false,
  });

  final String label;
  final double amount;
  final Color color;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTypography.body),
        Text(
          formatEosbCurrency(amount),
          style: (bold ? AppTypography.headline2 : AppTypography.title)
              .copyWith(color: color),
        ),
      ],
    );
  }
}
