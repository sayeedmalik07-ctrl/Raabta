import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_progress_indicator.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/features/prayer_mosque/domain/models/prayer_enums.dart';
import 'package:raabta/features/prayer_mosque/domain/models/prayer_schedule.dart';
import 'package:raabta/features/prayer_mosque/presentation/l10n/prayer_strings.dart';
import 'package:raabta/features/prayer_mosque/presentation/widgets/prayer_hero_card.dart';
import 'package:raabta/features/prayer_mosque/presentation/widgets/prayer_time_card.dart';
import 'package:raabta/features/prayer_mosque/providers/prayer_providers.dart';

class PrayerTimesScreen extends ConsumerWidget {
  const PrayerTimesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(prayerProvider);
    final now = ref.watch(prayerLiveClockProvider);
    final locale = state.settings.locale;
    final use24 = state.settings.timeFormat == PrayerTimeFormat.hour24;
    final schedule = state.schedule;

    return GlassScreenScaffold(
      title: PrayerStrings.t('prayer_times', locale),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.pop(),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      body: schedule == null
          ? const Center(child: GlassProgressIndicator())
          : ListView(
              children: [
                PrayerHeroCard(
                  schedule: schedule,
                  locale: locale,
                  use24Hour: use24,
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  PrayerStrings.t('prayer_times', locale),
                  style: AppTypography.title,
                ),
                const SizedBox(height: AppSpacing.sm),
                ...schedule.entries.map((entry) {
                  final isNext = schedule.nextPrayerAt(now)?.key == entry.key;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: PrayerTimeCard(
                      entry: entry,
                      locale: locale,
                      use24Hour: use24,
                      isNext: isNext,
                      isCompleted: state.completedToday.contains(entry.key),
                      notifyEnabled:
                          state.settings.perPrayerNotifications[entry.key] ??
                              false,
                      onToggleCompleted: () => ref
                          .read(prayerProvider.notifier)
                          .toggleCompleted(entry.key),
                      onToggleNotify: (v) async {
                        final notifications = Map<String, bool>.from(
                          state.settings.perPrayerNotifications,
                        );
                        notifications[entry.key] = v;
                        await ref.read(prayerProvider.notifier).updateSettings(
                              state.settings.copyWith(
                                perPrayerNotifications: notifications,
                              ),
                            );
                      },
                    ),
                  );
                }),
                const SizedBox(height: AppSpacing.md),
                Text(
                  PrayerStrings.t('prayer_night_times', locale),
                  style: AppTypography.title,
                ),
                const SizedBox(height: AppSpacing.sm),
                _SupplementaryTimesCard(
                  schedule: schedule,
                  locale: locale,
                  use24Hour: use24,
                ),
              ],
            ),
    );
  }
}

class _SupplementaryTimesCard extends ConsumerWidget {
  const _SupplementaryTimesCard({
    required this.schedule,
    required this.locale,
    required this.use24Hour,
  });

  final PrayerScheduleDay schedule;
  final String locale;
  final bool use24Hour;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = ref.watch(prayerLiveClockProvider);
    final clockFormat =
        use24Hour ? DateFormat('HH:mm:ss') : DateFormat('h:mm:ss a');
    final timeFormat = use24Hour ? DateFormat.Hm() : DateFormat.jm();
    final timezone = now.timeZoneName;

    final rows = <({String labelKey, String emoji, DateTime? time})>[
      (
        labelKey: 'prayer_sunset',
        emoji: '🌇',
        time: schedule.sunsetTime,
      ),
      (
        labelKey: 'prayer_midnight',
        emoji: '🌙',
        time: schedule.islamicMidnight,
      ),
      (
        labelKey: 'prayer_last_third',
        emoji: '✨',
        time: schedule.lastThirdOfNight,
      ),
    ];

    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      glowColor: AppColors.purpleGlow,
      glowIntensity: 0.08,
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.access_time, size: 18, color: AppColors.cyanGlow),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  '${clockFormat.format(now)} · $timezone',
                  style: AppTypography.bodySmall.copyWith(
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          for (final row in rows)
            if (row.time != null)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Row(
                  children: [
                    Text(row.emoji, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        PrayerStrings.t(row.labelKey, locale),
                        style: AppTypography.body,
                      ),
                    ),
                    Text(
                      timeFormat.format(row.time!),
                      style: AppTypography.title.copyWith(
                        color: AppColors.amberGlow,
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
