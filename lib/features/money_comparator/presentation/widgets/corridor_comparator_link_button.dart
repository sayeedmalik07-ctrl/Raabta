import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/money_comparator/presentation/l10n/money_comparator_strings.dart';
import 'package:raabta/providers/visa_providers.dart';

/// Entry from Money Hub → Corridor Comparator (does not duplicate live rates).
class CorridorComparatorLinkButton extends ConsumerWidget {
  const CorridorComparatorLinkButton({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(userLanguageProvider);

    if (compact) {
      return SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: () => context.push('/money-services/corridor-comparator'),
          icon: const Icon(Icons.compare_arrows, size: 20),
          label: Text(MoneyComparatorStrings.t('mc_compare_remittance', locale)),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.brandFamilyMain,
            foregroundColor:
                AppColors.isLight ? AppColors.surface : Colors.white,
            padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.md,
              horizontal: AppSpacing.lg,
            ),
          ),
        ),
      );
    }

    return GlassCard(
      onTap: () => context.push('/money-services/corridor-comparator'),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      glowColor: AppColors.amberGlow,
      glowIntensity: 0.12,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.amberGlow.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: const Icon(Icons.compare_arrows, color: AppColors.amberGlow),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  MoneyComparatorStrings.t('mc_link_title', locale),
                  style: AppTypography.title,
                ),
                Text(
                  MoneyComparatorStrings.t('mc_link_subtitle', locale),
                  style: AppTypography.bodySmall,
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.amberGlow),
        ],
      ),
    );
  }
}
