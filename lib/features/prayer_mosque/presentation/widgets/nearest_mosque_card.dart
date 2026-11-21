import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/prayer_mosque/domain/models/mosque.dart';
import 'package:raabta/features/prayer_mosque/presentation/l10n/prayer_strings.dart';

class NearestMosqueCard extends StatelessWidget {
  const NearestMosqueCard({
    super.key,
    required this.mosque,
    required this.locale,
    required this.onTap,
  });

  final MosquePlace mosque;
  final String locale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final distanceKm = (mosque.distanceMeters ?? 0) / 1000;

    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      glowColor: AppColors.chipPrayer,
      glowIntensity: 0.15,
      child: Row(
        children: [
          Text(
            '🕌',
            style: AppTypography.headline2.copyWith(fontSize: 28),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  PrayerStrings.t('prayer_nearest', locale),
                  style: AppTypography.caption,
                ),
                Text(mosque.name, style: AppTypography.title),
                Text(
                  '${distanceKm.toStringAsFixed(1)} km · '
                  '${mosque.walkMinutes ?? '—'} min walk',
                  style: AppTypography.bodySmall,
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right),
        ],
      ),
    );
  }
}
