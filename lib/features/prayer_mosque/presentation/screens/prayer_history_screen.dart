import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_progress_indicator.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/features/prayer_mosque/presentation/l10n/prayer_strings.dart';
import 'package:raabta/features/prayer_mosque/presentation/widgets/mosque_card.dart';
import 'package:raabta/features/prayer_mosque/providers/prayer_providers.dart';

class PrayerHistoryScreen extends ConsumerWidget {
  const PrayerHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(prayerProvider);
    final locale = state.settings.locale;
    final statsAsync = ref.watch(prayerStatsProvider);

    return GlassScreenScaffold(
      title: PrayerStrings.t('prayer_history', locale),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.pop(),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      body: statsAsync.when(
        loading: () => const Center(child: GlassProgressIndicator()),
        error: (_, _) => const Center(child: Text('Could not load stats')),
        data: (stats) => ListView(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(
                      '${stats.currentStreak}',
                      style: AppTypography.headline1.copyWith(
                        color: AppColors.amberGlow,
                      ),
                    ),
                    Text(
                      PrayerStrings.t('prayer_streak', locale),
                      style: AppTypography.bodySmall,
                    ),
                  ],
                ),
                PrayerStatsRing(
                  label: PrayerStrings.t('prayer_weekly', locale),
                  value: stats.weeklyCompletion,
                  color: AppColors.cyanGlow,
                ),
                PrayerStatsRing(
                  label: PrayerStrings.t('prayer_monthly', locale),
                  value: stats.monthlyCompletion,
                  color: AppColors.emeraldGlow,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            Text('Mark today\'s prayers on the dashboard',
                style: AppTypography.body),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Overall completion: ${(stats.prayerPercentage * 100).round()}%',
              style: AppTypography.title,
            ),
          ],
        ),
      ),
    );
  }
}
