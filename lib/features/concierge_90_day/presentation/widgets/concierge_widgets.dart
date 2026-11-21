import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/concierge_90_day/data/models/journey_milestone.dart';
import 'package:raabta/features/concierge_90_day/presentation/l10n/concierge_strings.dart';
import 'package:raabta/features/concierge_90_day/presentation/providers/concierge_providers.dart';
import 'package:raabta/features/home/widgets/home_card_tiers.dart';
import 'package:raabta/providers/visa_providers.dart';

/// Lightweight home card — calm concierge tone, one next step.
class ConciergeHomeCard extends ConsumerWidget {
  const ConciergeHomeCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(userLanguageProvider);
    final asyncState = ref.watch(conciergeStateProvider);

    return asyncState.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (state) {
        if (!state.shouldShowConcierge) return const SizedBox.shrink();
        final snapshot = state.snapshot;
        final next = snapshot?.nextMilestone;
        if (next == null) return const SizedBox.shrink();

        final dayLabel = ConciergeStrings.t('concierge_day_label', locale)
            .replaceAll('{day}', '${snapshot?.dayOnTimeline ?? 1}');
        final phase = snapshot != null
            ? ConciergeStrings.phaseLabel(snapshot.currentPhase, locale)
            : '';

        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
          child: GlassCard(
            onTap: () => context.push('/concierge-90-day'),
            padding: const EdgeInsets.all(AppSpacing.lg),
            borderRadius: HomeCardTier.homeCardRadius,
            glowColor: AppColors.cyanGlow,
            glowIntensity: HomeCardTier.homeCardGlowIntensity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ConciergeStrings.t('concierge_card_overline', locale),
                  style: AppTypography.overline.copyWith(
                    color: AppColors.cyanGlow,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  ConciergeStrings.t('concierge_card_title', locale),
                  style: AppTypography.title,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  ConciergeStrings.t('concierge_card_subtitle', locale),
                  style: AppTypography.bodySmall,
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.cyanGlow.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(dayLabel, style: AppTypography.caption),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(phase, style: AppTypography.caption),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  ConciergeStrings.t(next.titleKey, locale),
                  style: AppTypography.subtitle,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  ConciergeStrings.t(next.descriptionKey, locale),
                  style: AppTypography.bodySmall,
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    TextButton(
                      onPressed: () async {
                        final route = await ref
                            .read(conciergeNotifierProvider)
                            .resolveRoute(next);
                        if (context.mounted) context.push(route);
                      },
                      child: Text(
                        ConciergeStrings.t(next.actionKey, locale),
                        style: AppTypography.link,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => context.push('/concierge-90-day'),
                      child: Text(
                        ConciergeStrings.t('concierge_view_journey', locale),
                        style: AppTypography.link.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class ConciergeMilestoneTile extends ConsumerWidget {
  const ConciergeMilestoneTile({
    super.key,
    required this.milestone,
    required this.status,
    required this.locale,
    required this.isCurrent,
  });

  final JourneyMilestone milestone;
  final MilestoneStatus status;
  final String locale;
  final bool isCurrent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(conciergeNotifierProvider);
    final done = status == MilestoneStatus.completed;
    final na = status == MilestoneStatus.notApplicable;

    Color accent = AppColors.cyanGlow;
    if (done) accent = AppColors.chipEosb;
    if (na) accent = AppColors.textSecondary;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: GlassCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        glowColor: isCurrent ? accent : null,
        glowIntensity: isCurrent ? 0.14 : 0.04,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  done
                      ? Icons.check_circle_outline
                      : na
                          ? Icons.remove_circle_outline
                          : Icons.radio_button_unchecked,
                  color: accent,
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    ConciergeStrings.t(milestone.titleKey, locale),
                    style: AppTypography.subtitle,
                  ),
                ),
              ],
            ),
            if (!done && !na) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                ConciergeStrings.t(milestone.descriptionKey, locale),
                style: AppTypography.bodySmall,
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.xs,
                children: [
                  TextButton(
                    onPressed: () async {
                      final route = await notifier.resolveRoute(milestone);
                      if (context.mounted) context.push(route);
                    },
                    child: Text(ConciergeStrings.t(milestone.actionKey, locale)),
                  ),
                  TextButton(
                    onPressed: () => notifier.markDone(milestone.id),
                    child: Text(
                      ConciergeStrings.t('concierge_mark_done', locale),
                    ),
                  ),
                  if (milestone.optionalRelevance)
                    TextButton(
                      onPressed: () => notifier.markNotApplicable(milestone.id),
                      child: Text(
                        ConciergeStrings.t('concierge_not_applicable', locale),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
