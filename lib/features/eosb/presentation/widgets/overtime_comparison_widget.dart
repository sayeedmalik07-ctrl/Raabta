import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/eosb/domain/models/overtime_truth_models.dart';
import 'package:raabta/features/eosb/presentation/l10n/eosb_strings.dart';

class OvertimeComparisonWidget extends StatelessWidget {
  const OvertimeComparisonWidget({
    super.key,
    required this.comparison,
    required this.locale,
    this.showRoundingLink = false,
    this.onRoundingTap,
  });

  final OvertimeEmployerComparison comparison;
  final String locale;
  final bool showRoundingLink;
  final VoidCallback? onRoundingTap;

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
          _Row(
            label: EosbStrings.t('ot_legal_owed', locale),
            amount: comparison.legalOwed,
            color: AppColors.info,
          ),
          const SizedBox(height: AppSpacing.sm),
          _Row(
            label: EosbStrings.t('ot_employer_paid', locale),
            amount: comparison.employerPaid,
            color: AppColors.textSecondary,
          ),
          const Divider(height: AppSpacing.lg),
          _Row(
            label: EosbStrings.t('ot_unpaid_gap', locale),
            amount: comparison.unpaidGap,
            color: accent,
            bold: true,
          ),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
            child: LinearProgressIndicator(
              value: comparison.legalOwed > 0
                  ? (comparison.employerPaid / comparison.legalOwed)
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
                ? EosbStrings.t('ot_payment_fair', locale)
                : EosbStrings.t('ot_payment_short', locale)
                    .replaceAll(
                      '{percent}',
                      (100 - comparison.paymentCoveragePercent)
                          .toStringAsFixed(0),
                    ),
            style: AppTypography.bodySmall.copyWith(color: accent),
          ),
          if (comparison.hoursGap > 0) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              EosbStrings.t('ot_hours_gap', locale).replaceAll(
                '{hours}',
                comparison.hoursGap.toStringAsFixed(1),
              ),
              style: AppTypography.caption.copyWith(color: AppColors.warning),
            ),
          ],
          if (showRoundingLink && onRoundingTap != null) ...[
            const SizedBox(height: AppSpacing.sm),
            TextButton(
              onPressed: onRoundingTap,
              child: Text(EosbStrings.t('ot_rounding_check_link', locale)),
            ),
          ],
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
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
        Expanded(child: Text(label, style: AppTypography.body)),
        Text(
          formatEosbCurrency(amount),
          style: (bold ? AppTypography.headline2 : AppTypography.title)
              .copyWith(color: color, fontSize: bold ? 22 : 16),
        ),
      ],
    );
  }
}

class OvertimeBreakdownRow extends StatelessWidget {
  const OvertimeBreakdownRow({
    super.key,
    required this.item,
    required this.locale,
    this.onExpand,
  });

  final OvertimeLineItem item;
  final String locale;
  final VoidCallback? onExpand;

  String get _title {
    return switch (item.category) {
      OvertimeRateCategory.weekdayExtra =>
        EosbStrings.t('ot_cat_weekday', locale),
      OvertimeRateCategory.restDay => EosbStrings.t('ot_cat_restday', locale),
      OvertimeRateCategory.publicHoliday =>
        EosbStrings.t('ot_cat_holiday', locale),
      OvertimeRateCategory.nightShift =>
        EosbStrings.t('ot_cat_night', locale),
      OvertimeRateCategory.emergency =>
        EosbStrings.t('ot_cat_emergency', locale),
      OvertimeRateCategory.standby =>
        EosbStrings.t('ot_cat_standby', locale),
      OvertimeRateCategory.custom => EosbStrings.t('ot_cat_custom', locale),
    };
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onExpand,
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_title, style: AppTypography.title.copyWith(fontSize: 14)),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${item.hours.toStringAsFixed(1)}h × '
                  '${(item.rateMultiplier * 100).toStringAsFixed(0)}%',
                  style: AppTypography.bodySmall,
                ),
                Text(
                  EosbStrings.t(item.ruleKey, locale),
                  style: AppTypography.caption,
                ),
              ],
            ),
          ),
          Text(
            formatEosbCurrency(item.amount),
            style: AppTypography.title.copyWith(color: AppColors.cyanGlow),
          ),
          if (onExpand != null) ...[
            const SizedBox(width: AppSpacing.xs),
            IconButton(
              icon: const Icon(Icons.info_outline, size: AppSpacing.iconSm),
              color: AppColors.info,
              onPressed: onExpand,
              visualDensity: VisualDensity.compact,
            ),
          ],
        ],
      ),
    );
  }
}

void showOvertimeBreakdownSheet(
  BuildContext context, {
  required OvertimeLineItem item,
  required String locale,
}) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusLg)),
    ),
    builder: (ctx) => Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            EosbStrings.t(
              switch (item.category) {
                OvertimeRateCategory.weekdayExtra => 'ot_cat_weekday',
                OvertimeRateCategory.restDay => 'ot_cat_restday',
                OvertimeRateCategory.publicHoliday => 'ot_cat_holiday',
                OvertimeRateCategory.nightShift => 'ot_cat_night',
                OvertimeRateCategory.emergency => 'ot_cat_emergency',
                OvertimeRateCategory.standby => 'ot_cat_standby',
                OvertimeRateCategory.custom => 'ot_cat_custom',
              },
              locale,
            ),
            style: AppTypography.headline2,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            formatEosbCurrency(item.amount),
            style: AppTypography.display.copyWith(
              color: AppColors.cyanGlow,
              fontSize: 28,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            EosbStrings.t('ot_formula_label', locale),
            style: AppTypography.title,
          ),
          Text(EosbStrings.t(item.formulaKey, locale), style: AppTypography.body),
          const SizedBox(height: AppSpacing.md),
          Text(
            EosbStrings.t('ot_rule_label', locale),
            style: AppTypography.title,
          ),
          Text(EosbStrings.t(item.ruleKey, locale), style: AppTypography.bodySmall),
          if (item.articleRef.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              EosbStrings.t('ot_law_reference', locale),
              style: AppTypography.title,
            ),
            Text(item.articleRef, style: AppTypography.bodySmall),
          ],
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    ),
  );
}

class OvertimeAlertBanner extends StatelessWidget {
  const OvertimeAlertBanner({
    super.key,
    required this.alert,
    required this.locale,
  });

  final OvertimeAlert alert;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final color = switch (alert.severity) {
      'high' => AppColors.errorBright,
      'medium' => AppColors.warning,
      _ => AppColors.info,
    };

    return GlassCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      glowColor: color,
      glowIntensity: 0.12,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: color, size: AppSpacing.iconMd),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  EosbStrings.t(alert.titleKey, locale),
                  style: AppTypography.title.copyWith(fontSize: 14),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  EosbStrings.t(alert.bodyKey, locale),
                  style: AppTypography.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
