import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/prayer_mosque/data/islamic_content_repository.dart';
import 'package:raabta/features/prayer_mosque/domain/models/prayer_schedule.dart';
import 'package:raabta/features/prayer_mosque/presentation/l10n/prayer_strings.dart';
import 'package:raabta/features/prayer_mosque/providers/prayer_providers.dart';
import 'package:raabta/features/ramadan/hijri_calendar.dart';

class PrayerHeroCard extends ConsumerWidget {
  const PrayerHeroCard({
    super.key,
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
    final current = schedule.currentPrayerAt(now);
    final next = schedule.nextPrayerAt(now);
    final remaining = schedule.timeUntilNextAt(now);
    final progress = schedule.progressUntilNextAt(now);
    final hijri = gregorianToHijri(schedule.date);
    final monthName =
        IslamicContentRepository.hijriMonthNames[hijri.month] ?? '';
    final timeFormat = use24Hour ? DateFormat.Hm() : DateFormat.jm();
    final clockFormat = use24Hour
        ? DateFormat('HH:mm:ss')
        : DateFormat('h:mm:ss a');
    final gregFormat = DateFormat.yMMMMEEEEd();

    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      glowColor: AppColors.chipPrayer,
      glowIntensity: 0.22,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      PrayerStrings.t('prayer_now', locale),
                      style: AppTypography.bodySmall,
                    ),
                    Text(
                      clockFormat.format(now),
                      style: AppTypography.headline1.copyWith(
                        color: AppColors.cyanGlow,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    PrayerStrings.t('prayer_status', locale),
                    style: AppTypography.caption,
                  ),
                  Text(
                    current != null
                        ? PrayerStrings.t(current.labelKey, locale)
                        : '—',
                    style: AppTypography.title.copyWith(
                      color: AppColors.emeraldGlow,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _PrayerBlock(
                  label: PrayerStrings.t('prayer_next', locale),
                  time: next != null ? timeFormat.format(next.time) : '—',
                  emoji: next?.emoji ?? '⏳',
                  accent: AppColors.amberGlow,
                ),
              ),
              if (remaining != null)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        PrayerStrings.t('prayer_remaining', locale),
                        style: AppTypography.bodySmall,
                      ),
                      Text(
                        formatPrayerDuration(remaining),
                        style: AppTypography.headline2.copyWith(
                          color: AppColors.emeraldGlow,
                          fontFeatures: const [
                            FontFeature.tabularFigures(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          if (progress != null) ...[
            const SizedBox(height: AppSpacing.md),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: AppColors.glassBorder,
                color: AppColors.chipPrayer,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          Divider(color: AppColors.glassBorder),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '$monthName ${hijri.day}, ${hijri.year} AH',
            style: AppTypography.title,
          ),
          Text(
            gregFormat.format(schedule.date),
            style: AppTypography.bodySmall,
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 14,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: AppSpacing.xxs),
              Expanded(
                child: Text(
                  schedule.locationLabel,
                  style: AppTypography.bodySmall,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PrayerBlock extends StatelessWidget {
  const _PrayerBlock({
    required this.label,
    required this.time,
    required this.emoji,
    required this.accent,
  });

  final String label;
  final String time;
  final String emoji;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 22)),
        const SizedBox(height: AppSpacing.xxs),
        Text(label, style: AppTypography.bodySmall),
        Text(
          time,
          style: AppTypography.headline2.copyWith(color: accent),
        ),
      ],
    );
  }
}
