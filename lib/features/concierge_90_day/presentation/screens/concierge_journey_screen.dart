import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/features/concierge_90_day/data/models/journey_milestone.dart';
import 'package:raabta/features/concierge_90_day/presentation/l10n/concierge_strings.dart';
import 'package:raabta/features/concierge_90_day/presentation/providers/concierge_providers.dart';
import 'package:raabta/features/concierge_90_day/presentation/widgets/concierge_widgets.dart';
import 'package:raabta/providers/visa_providers.dart';

class ConciergeJourneyScreen extends ConsumerStatefulWidget {
  const ConciergeJourneyScreen({super.key});

  @override
  ConsumerState<ConciergeJourneyScreen> createState() =>
      _ConciergeJourneyScreenState();
}

class _ConciergeJourneyScreenState extends ConsumerState<ConciergeJourneyScreen> {
  Future<void> _pickArrivalDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2010),
      lastDate: DateTime.now(),
    );
    if (picked == null) return;
    await ref.read(conciergeNotifierProvider).setArrivalDate(picked);
  }

  Future<void> _confirmSettled() async {
    // Snapshot when dialog opens — confirm copy matches locale at dialog show time.
    final locale = ref.read(userLanguageProvider);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(ConciergeStrings.t('concierge_settled_cta', locale)),
        content: Text(ConciergeStrings.t('concierge_card_subtitle', locale)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('OK'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await ref.read(conciergeNotifierProvider).disableConcierge();
      if (mounted) context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(userLanguageProvider);
    final asyncState = ref.watch(conciergeStateProvider);

    return GlassScreenScaffold(
      title: ConciergeStrings.t('concierge_journey_title', locale),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.pop(),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      body: asyncState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => const Center(child: Text('Unable to load journey')),
        data: (state) {
          final snapshot = state.snapshot;
          if (snapshot == null) return const SizedBox.shrink();

          final progress = state.progress;
          final showArrivalPrompt = progress.arrivalDate == null &&
              !progress.arrivalDateSkipped;

          final grouped = <ConciergePhase, List<JourneyMilestone>>{};
          for (final m in JourneyMilestoneCatalog.all) {
            grouped.putIfAbsent(m.phase, () => []).add(m);
          }

          return ListView(
            children: [
              if (showArrivalPrompt) ...[
                Text(
                  ConciergeStrings.t('concierge_arrival_prompt', locale),
                  style: AppTypography.body,
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    OutlinedButton(
                      onPressed: _pickArrivalDate,
                      child: const Text('Set arrival date'),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    TextButton(
                      onPressed: () => ref
                          .read(conciergeNotifierProvider)
                          .setArrivalDate(null, skipped: true),
                      child: Text(
                        ConciergeStrings.t('concierge_arrival_skip', locale),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
              Text(
                ConciergeStrings.t('concierge_day_label', locale).replaceAll(
                  '{day}',
                  '${snapshot.dayOnTimeline}',
                ),
                style: AppTypography.title,
              ),
              Text(
                ConciergeStrings.phaseLabel(snapshot.currentPhase, locale),
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.cyanGlow,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              for (final phase in ConciergePhase.values) ...[
                if (grouped[phase]?.isNotEmpty == true) ...[
                  Text(
                    ConciergeStrings.phaseLabel(phase, locale),
                    style: AppTypography.overline.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  for (final m in grouped[phase]!)
                    if (snapshot.dayOnTimeline >= m.dayStart ||
                        progress.statusFor(m.id) !=
                            MilestoneStatus.pending)
                      ConciergeMilestoneTile(
                        milestone: m,
                        status: progress.statusFor(m.id),
                        locale: locale,
                        isCurrent: snapshot.nextMilestone?.id == m.id,
                      ),
                  const SizedBox(height: AppSpacing.md),
                ],
              ],
              TextButton(
                onPressed: _confirmSettled,
                child: Text(
                  ConciergeStrings.t('concierge_settled_cta', locale),
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
