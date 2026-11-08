import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/home/widgets/home_icon_badge.dart';
import 'package:raabta/features/personal_budget/domain/personal_budget_models.dart';
import 'package:raabta/features/personal_budget/presentation/l10n/personal_budget_strings.dart';

class PersonalBudgetAttentionCard extends StatelessWidget {
  const PersonalBudgetAttentionCard({
    super.key,
    required this.insight,
    required this.locale,
  });

  final PersonalBudgetAttentionInsight insight;
  final String locale;

  String get _templateKey {
    return switch (insight.category) {
      PersonalBudgetCategory.rent => 'pb_attention_rent',
      PersonalBudgetCategory.food => 'pb_attention_food',
      PersonalBudgetCategory.transport => 'pb_attention_transport',
      PersonalBudgetCategory.utilities => 'pb_attention_utilities',
      PersonalBudgetCategory.family => 'pb_attention_family',
      PersonalBudgetCategory.remittance => 'pb_attention_remittance',
      PersonalBudgetCategory.other => 'pb_attention_other',
    };
  }

  @override
  Widget build(BuildContext context) {
    final message = PersonalBudgetStrings.format(
      _templateKey,
      locale,
      params: {
        'percent': insight.sharePercent.toStringAsFixed(1),
      },
    );

    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      borderRadius: AppSpacing.radiusLg,
      glowColor: AppColors.chipLease,
      glowIntensity: 0.15,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const HomeIconBadge(
            icon: Icons.warning_amber_rounded,
            accentColor: AppColors.chipLease,
            size: 40,
            iconSize: 22,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  PersonalBudgetStrings.t('pb_attention_heading', locale),
                  style: AppTypography.subtitle,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  message,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textOnGlassMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
