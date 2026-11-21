import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/home/widgets/home_icon_badge.dart';
import 'package:raabta/features/personal_budget/presentation/l10n/personal_budget_strings.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PersonalBudgetLinkCard extends ConsumerWidget {
  const PersonalBudgetLinkCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(userLanguageProvider);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: GlassCard(
        onTap: () => context.push('/money-services/personal-budget'),
        padding: const EdgeInsets.all(AppSpacing.lg),
        borderRadius: AppSpacing.radiusLg,
        glowColor: AppColors.emeraldGlow,
        glowIntensity: 0.15,
        child: Row(
          children: [
            const HomeIconBadge(
              icon: Icons.account_balance_wallet_outlined,
              accentColor: AppColors.emeraldGlow,
              size: 44,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    PersonalBudgetStrings.t('pb_link_from_col', locale),
                    style: AppTypography.title,
                  ),
                  Text(
                    PersonalBudgetStrings.t('pb_link_from_col_sub', locale),
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textOnGlassMuted,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
