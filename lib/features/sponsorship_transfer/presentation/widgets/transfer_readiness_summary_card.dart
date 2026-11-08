import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/sponsorship_transfer/domain/models/sponsorship_transfer_enums.dart';
import 'package:raabta/features/sponsorship_transfer/domain/models/transfer_readiness_models.dart';
import 'package:raabta/features/sponsorship_transfer/presentation/l10n/sponsorship_transfer_strings.dart';

/// Compact transfer-readiness summary from existing checker output.
class TransferReadinessSummaryCard extends StatelessWidget {
  const TransferReadinessSummaryCard({
    super.key,
    required this.result,
    required this.locale,
  });

  final TransferReadinessResult result;
  final String locale;

  static ({String label, Color color}) postureBadge(
    TransferReadinessResult result,
    String locale,
  ) {
    if (result.hasCriticalIssue) {
      return (
        label: SponsorshipTransferStrings.t('st_status_critical', locale),
        color: AppColors.errorBright,
      );
    }
    if (result.hasWarning) {
      return (
        label: SponsorshipTransferStrings.t('st_status_warning', locale),
        color: AppColors.accentGold,
      );
    }
    if (result.items.any(
      (i) => i.status == TransferReadinessStatus.needsVerification,
    )) {
      return (
        label: SponsorshipTransferStrings.t(
          'st_status_needs_verification',
          locale,
        ),
        color: AppColors.cyanGlow,
      );
    }
    return (
      label: SponsorshipTransferStrings.t('st_status_compliant', locale),
      color: AppColors.successBright,
    );
  }

  static String summaryLine(TransferReadinessResult result, String locale) {
    if (result.hasCriticalIssue) {
      return SponsorshipTransferStrings.t('st_history_summary_critical', locale);
    }
    if (result.hasWarning) {
      return SponsorshipTransferStrings.t('st_history_summary_warning', locale);
    }
    final needsVerify = result.items.where(
      (i) => i.status == TransferReadinessStatus.needsVerification,
    );
    if (needsVerify.isNotEmpty) {
      return SponsorshipTransferStrings.t(needsVerify.first.titleKey, locale);
    }
    return SponsorshipTransferStrings.t('st_history_summary_compliant', locale);
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
            SponsorshipTransferStrings.t('st_result_summary_heading', locale),
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
