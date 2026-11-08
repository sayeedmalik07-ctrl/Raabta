import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/exchange_locator/presentation/l10n/exchange_locator_strings.dart';
import 'package:raabta/providers/visa_providers.dart';

/// Navigates to the existing live exchange rates screen at `/money` — do not duplicate rate logic.
class LiveRatesLinkButton extends ConsumerWidget {
  const LiveRatesLinkButton({
    super.key,
    this.compact = false,
  });

  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(userLanguageProvider);
    final a11y = ExchangeLocatorStrings.t('live_rates_a11y', locale);

    if (compact) {
      return Semantics(
        button: true,
        label: a11y,
        child: TextButton.icon(
          onPressed: () => context.push('/money?tab=0'),
          icon: const Icon(Icons.trending_up, size: 18),
          label: Text(ExchangeLocatorStrings.t('live_rates_short', locale)),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.goldFamilyMain,
            minimumSize: const Size(44, 44),
          ),
        ),
      );
    }

    return Semantics(
      button: true,
      label: a11y,
      child: GlassCard(
        onTap: () => context.push('/money?tab=0'),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        glowColor: AppColors.goldFamilyMain,
        glowIntensity: 0.12,
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.goldFamilyMain.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: Icon(Icons.currency_exchange, color: AppColors.goldFamilyMain),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ExchangeLocatorStrings.t('live_rates_title', locale),
                    style: AppTypography.title,
                  ),
                  Text(
                    ExchangeLocatorStrings.t('live_rates_subtitle', locale),
                    style: AppTypography.bodySmall,
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.goldFamilyMain),
          ],
        ),
      ),
    );
  }
}
