import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/prayer_mosque/domain/models/prayer_schedule.dart';
import 'package:raabta/features/prayer_mosque/domain/services/iqama_time_service.dart';
import 'package:raabta/features/prayer_mosque/presentation/l10n/prayer_strings.dart';

class PrayerTimeCard extends StatelessWidget {
  const PrayerTimeCard({
    super.key,
    required this.entry,
    required this.locale,
    required this.use24Hour,
    required this.isNext,
    required this.isCompleted,
    required this.notifyEnabled,
    required this.onToggleCompleted,
    required this.onToggleNotify,
  });

  final PrayerScheduleEntry entry;
  final String locale;
  final bool use24Hour;
  final bool isNext;
  final bool isCompleted;
  final bool notifyEnabled;
  final VoidCallback onToggleCompleted;
  final ValueChanged<bool> onToggleNotify;

  @override
  Widget build(BuildContext context) {
    final timeFormat = use24Hour ? DateFormat.Hm() : DateFormat.jm();
    final now = DateTime.now();
    final progress = entry.time.isAfter(now)
        ? 0.0
        : (isCompleted ? 1.0 : 0.65);

    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      glowColor: isNext ? AppColors.amberGlow : null,
      glowIntensity: isNext ? 0.15 : 0,
      child: Column(
        children: [
          Row(
            children: [
              Text(entry.emoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      PrayerStrings.t(entry.labelKey, locale),
                      style: AppTypography.title,
                    ),
                    Text(
                      '${PrayerStrings.t('prayer_adhan_label', locale)}: ${timeFormat.format(entry.time)}',
                      style: AppTypography.headline2.copyWith(
                        fontSize: 18,
                        color: isNext ? AppColors.amberGlow : null,
                      ),
                    ),
                    if (IqamaTimeService.estimatedCongregationAt(entry) !=
                        null) ...[
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        PrayerStrings.t('prayer_iqama_estimated_long', locale)
                            .replaceAll(
                          '{time}',
                          timeFormat.format(
                            IqamaTimeService.estimatedCongregationAt(entry)!,
                          ),
                        ),
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                tooltip: PrayerStrings.t('prayer_completed', locale),
                onPressed: entry.isSunrise ? null : onToggleCompleted,
                icon: Icon(
                  isCompleted
                      ? Icons.check_circle
                      : Icons.check_circle_outline,
                  color: isCompleted
                      ? AppColors.success
                      : AppColors.textSecondary,
                ),
              ),
              Switch(
                value: notifyEnabled,
                onChanged: entry.isSunrise ? null : onToggleNotify,
                activeThumbColor: AppColors.cyanGlow,
              ),
            ],
          ),
          if (!entry.isSunrise) ...[
            const SizedBox(height: AppSpacing.sm),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 4,
                backgroundColor: AppColors.glassBorder,
                color: isCompleted ? AppColors.success : AppColors.cyanGlow,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class IslamicContentCard extends StatelessWidget {
  const IslamicContentCard({
    super.key,
    required this.title,
    required this.body,
    this.emoji = '📿',
  });

  final String title;
  final String body;
  final String emoji;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      glowColor: AppColors.purpleGlow,
      glowIntensity: 0.1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(title, style: AppTypography.title),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(body, style: AppTypography.body),
        ],
      ),
    );
  }
}
