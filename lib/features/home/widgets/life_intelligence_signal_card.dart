import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/l10n/app_shell_strings.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_primary_button.dart';
import 'package:raabta/features/home/providers/life_intelligence_providers.dart';
import 'package:raabta/features/home/widgets/home_card_tiers.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:raabta/services/life_intelligence_signals_service.dart';

/// Calm, factual Life Intelligence V1 card — deterministic cross-engine nudges.
class LifeIntelligenceSignalCard extends ConsumerWidget {
  const LifeIntelligenceSignalCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(userLanguageProvider);
    final signal = ref.watch(lifeIntelligenceActiveSignalProvider);
    if (signal == null) return const SizedBox.shrink();

    final headline = AppShellStrings.t(signal.headlineKey, locale);
    final body = AppShellStrings.t(signal.bodyKey, locale);
    final cta = AppShellStrings.t(signal.ctaKey, locale);
    final accentColor = switch (signal.type) {
      LifeIntelligenceSignalType.employerTransferStarted =>
        AppColors.chipEosb,
      LifeIntelligenceSignalType.employerNameMismatch =>
        AppColors.chipHealthInsurance,
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: GlassCard(
        padding: const EdgeInsets.all(AppSpacing.lg),
        borderRadius: HomeCardTier.homeCardRadius,
        glowColor: accentColor,
        glowIntensity: HomeCardTier.contextualGlowIntensity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    headline,
                    style: AppTypography.title,
                  ),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: Icon(
                    Icons.close_rounded,
                    size: AppSpacing.iconSm,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6),
                  ),
                  onPressed: () => dismissLifeIntelligenceSignal(ref),
                  tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              body,
              style: AppTypography.bodySmall,
            ),
            const SizedBox(height: AppSpacing.lg),
            GlassPrimaryButton(
              label: cta,
              expand: true,
              accentColor: accentColor,
              onPressed: () => context.push(signal.route),
            ),
          ],
        ),
      ),
    );
  }
}
