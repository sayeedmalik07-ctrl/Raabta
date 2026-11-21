import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/eosb/domain/models/eosb_result.dart';
import 'package:raabta/features/eosb/presentation/l10n/eosb_strings.dart';

class EosbBreakdownRow extends StatelessWidget {
  const EosbBreakdownRow({
    super.key,
    required this.item,
    required this.locale,
    this.onExpand,
  });

  final EntitlementBreakdownItem item;
  final String locale;
  final VoidCallback? onExpand;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onExpand,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  EosbStrings.t(item.titleKey, locale),
                  style: AppTypography.title.copyWith(fontSize: 14),
                ),
                if (item.amount > 0)
                  Text(
                    EosbStrings.t(item.formulaKey, locale),
                    style: AppTypography.caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          Text(
            formatEosbCurrency(item.amount),
            style: AppTypography.title.copyWith(
              color: item.amount > 0
                  ? AppColors.successBright
                  : AppColors.textSecondary,
            ),
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

void showEosbBreakdownSheet(
  BuildContext context, {
  required EntitlementBreakdownItem item,
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
            EosbStrings.t(item.titleKey, locale),
            style: AppTypography.headline2,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            formatEosbCurrency(item.amount),
            style: AppTypography.display.copyWith(
              color: AppColors.successBright,
              fontSize: 28,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(EosbStrings.t('ot_formula_label', locale), style: AppTypography.title),
          Text(EosbStrings.t(item.formulaKey, locale), style: AppTypography.body),
          const SizedBox(height: AppSpacing.md),
          Text(EosbStrings.t('ot_rule_label', locale), style: AppTypography.title),
          Text(EosbStrings.t(item.ruleKey, locale), style: AppTypography.bodySmall),
          const SizedBox(height: AppSpacing.md),
          Text(EosbStrings.t('eosb_example_label', locale), style: AppTypography.title),
          Text(EosbStrings.t(item.exampleKey, locale), style: AppTypography.bodySmall),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    ),
  );
}
