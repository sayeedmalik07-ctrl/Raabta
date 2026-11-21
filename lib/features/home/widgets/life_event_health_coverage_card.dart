import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/l10n/app_shell_strings.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_primary_button.dart';
import 'package:raabta/features/home/providers/life_events_providers.dart';
import 'package:raabta/features/home/widgets/home_card_tiers.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:raabta/services/life_events_correlation_service.dart';

/// Calm, factual Life Events v1 card — Job Transition ↔ Health Insurance gap.
class LifeEventHealthCoverageCard extends ConsumerWidget {
  const LifeEventHealthCoverageCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(userLanguageProvider);
    if (ref.watch(lifeEventHealthCoverageDismissedProvider)) {
      return const SizedBox.shrink();
    }

    final correlation = ref.watch(lifeEventHealthCoverageActiveProvider);
    if (correlation == null) return const SizedBox.shrink();

    final engineLabel = correlation.engineLabel(locale);
    final headline =
        AppShellStrings.t('life_event_health_coverage_card_headline', locale);
    final body = AppShellStrings.format(
      'life_event_health_coverage_card_body',
      locale,
      params: {'engine': engineLabel},
    );
    final cta =
        AppShellStrings.t('life_event_health_coverage_card_cta', locale);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: GlassCard(
        padding: const EdgeInsets.all(AppSpacing.lg),
        borderRadius: HomeCardTier.homeCardRadius,
        glowColor: AppColors.chipHealthInsurance,
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
                  onPressed: () => dismissLifeEventHealthCoverageCard(ref),
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
              accentColor: AppColors.chipHealthInsurance,
              onPressed: () => context.push(
                LifeEventsCorrelationService.healthInsuranceRoute,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
