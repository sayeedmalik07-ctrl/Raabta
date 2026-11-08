import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/health_insurance/data/models/compliance_check_model.dart';
import 'package:raabta/features/health_insurance/domain/models/health_compliance_enums.dart';
import 'package:raabta/features/health_insurance/presentation/l10n/health_insurance_strings.dart';
import 'package:raabta/features/truth_engine/presentation/truth_engine_status_colors.dart';

/// Compact compliance posture summary — uses existing checker outcomes only.
class ComplianceResultSummaryCard extends StatelessWidget {
  const ComplianceResultSummaryCard({
    super.key,
    required this.result,
    required this.locale,
    required this.overview,
  });

  final ComplianceCheckResult result;
  final String locale;
  final String overview;

  static int violationCount(ComplianceCheckResult result) =>
      result.items.where((i) => i.status == HealthComplianceStatus.violation).length;

  static int needsVerificationCount(ComplianceCheckResult result) => result.items
      .where((i) => i.status == HealthComplianceStatus.needsVerification)
      .length;

  static ({String label, Color color}) postureBadge(
    ComplianceCheckResult result,
    String locale,
  ) {
    if (result.isExemptSession) {
      return (
        label: HealthInsuranceStrings.t('hi_status_informational', locale),
        color: AppColors.textSecondary,
      );
    }
    if (violationCount(result) > 0) {
      return (
        label: HealthInsuranceStrings.t('hi_status_violation', locale),
        color: AppColors.errorBright,
      );
    }
    if (needsVerificationCount(result) > 0) {
      return (
        label: HealthInsuranceStrings.t('hi_status_needs_verification', locale),
        color: TruthEngineStatusColors.needsVerification,
      );
    }
    return (
      label: HealthInsuranceStrings.t('hi_status_compliant', locale),
      color: AppColors.successBright,
    );
  }

  @override
  Widget build(BuildContext context) {
    final badge = postureBadge(result, locale);

    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      glowColor: badge.color,
      glowIntensity: 0.12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            HealthInsuranceStrings.t('hi_results_summary_heading', locale),
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: Text(
                  overview,
                  style: AppTypography.subtitle.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: badge.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  border: Border.all(color: badge.color.withValues(alpha: 0.4)),
                ),
                child: Text(
                  badge.label,
                  style: AppTypography.caption.copyWith(
                    color: badge.color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
