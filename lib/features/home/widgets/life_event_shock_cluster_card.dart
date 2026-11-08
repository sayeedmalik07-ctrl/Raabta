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

/// Calm, factual multi-domain Life Shock cluster card (≥2 of 3 domains).
class LifeEventShockClusterCard extends ConsumerWidget {
  const LifeEventShockClusterCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(userLanguageProvider);
    final cluster = ref.watch(lifeEventShockClusterActiveProvider);
    if (!isLifeEventShockClusterCardVisible(
      healthCoverageCorrelation:
          ref.watch(lifeEventHealthCoverageActiveProvider),
      healthCoverageDismissed:
          ref.watch(lifeEventHealthCoverageDismissedProvider),
      cluster: cluster,
      clusterDismissed: ref.watch(lifeEventShockClusterDismissedProvider),
    )) {
      return const SizedBox.shrink();
    }

    final activeCluster = cluster!;
    final domainLabels = activeCluster.domainLabels(locale);
    final headline =
        AppShellStrings.t('life_event_shock_cluster_card_headline', locale);
    final body = AppShellStrings.format(
      'life_event_shock_cluster_card_body',
      locale,
      params: {'domains': domainLabels},
    );

    final orderedDomains = [
      LifeEventShockDomain.labour,
      LifeEventShockDomain.healthInsurance,
      LifeEventShockDomain.tenancy,
    ].where(activeCluster.activeDomains.contains).toList();

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: GlassCard(
        padding: const EdgeInsets.all(AppSpacing.lg),
        borderRadius: HomeCardTier.homeCardRadius,
        glowColor: AppColors.accentGold,
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
                  onPressed: () => dismissLifeEventShockClusterCard(ref),
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
            ...orderedDomains.map((domain) {
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: GlassPrimaryButton(
                  label: activeCluster.ctaLabelForDomain(domain, locale),
                  expand: true,
                  accentColor: _accentForDomain(domain),
                  onPressed: () =>
                      context.push(activeCluster.routeForDomain(domain)),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  static Color _accentForDomain(LifeEventShockDomain domain) =>
      switch (domain) {
        LifeEventShockDomain.labour => AppColors.chipEosb,
        LifeEventShockDomain.healthInsurance => AppColors.chipHealthInsurance,
        LifeEventShockDomain.tenancy => AppColors.accentGold,
      };
}
