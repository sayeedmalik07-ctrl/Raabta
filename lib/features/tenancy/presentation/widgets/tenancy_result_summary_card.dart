import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/tenancy/domain/models/tenancy_compliance_models.dart';
import 'package:raabta/features/tenancy/domain/models/tenancy_enums.dart';
import 'package:raabta/features/tenancy/presentation/l10n/tenancy_strings.dart';

/// Aggregate lease-position summary from existing compliance checker output.
class TenancyResultSummaryCard extends StatelessWidget {
  const TenancyResultSummaryCard({
    super.key,
    required this.result,
    required this.locale,
  });

  final TenancyComplianceResult result;
  final String locale;

  static ({String label, Color color}) postureBadge(
    TenancyComplianceResult result,
    String locale,
  ) {
    if (result.hasCriticalIssue) {
      return (
        label: TenancyStrings.t('tenancy_status_critical', locale),
        color: AppColors.errorBright,
      );
    }
    if (result.hasViolation) {
      return (
        label: TenancyStrings.t('tenancy_status_violation', locale),
        color: AppColors.accentGold,
      );
    }
    if (result.items.any(
      (i) => i.status == TenancyComplianceStatus.needsVerification,
    )) {
      return (
        label: TenancyStrings.t('tenancy_status_needs_verification', locale),
        color: AppColors.cyanGlow,
      );
    }
    return (
      label: TenancyStrings.t('tenancy_status_compliant', locale),
      color: AppColors.successBright,
    );
  }

  static String summaryLine(TenancyComplianceResult result, String locale) {
    final primary = result.primaryCritical;
    if (primary != null) {
      return TenancyStrings.t(primary.titleKey, locale);
    }
    if (result.hasCriticalIssue) {
      return TenancyStrings.t('tenancy_history_summary_critical', locale);
    }
    if (result.hasViolation) {
      final violation = result.items.firstWhere(
        (item) => item.status == TenancyComplianceStatus.violation,
        orElse: () => result.items.first,
      );
      return TenancyStrings.t(violation.titleKey, locale);
    }
    final needsVerify = result.items.where(
      (i) => i.status == TenancyComplianceStatus.needsVerification,
    );
    if (needsVerify.isNotEmpty) {
      return TenancyStrings.t(needsVerify.first.titleKey, locale);
    }
    return TenancyStrings.t('tenancy_history_summary_compliant', locale);
  }

  @override
  Widget build(BuildContext context) {
    final badge = postureBadge(result, locale);
    final summary = summaryLine(result, locale);

    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      glowColor: badge.color,
      glowIntensity: 0.12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            TenancyStrings.t('tenancy_result_summary_heading', locale),
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  summary,
                  style: AppTypography.subtitle.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
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
