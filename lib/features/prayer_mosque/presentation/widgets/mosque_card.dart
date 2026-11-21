import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_tag.dart';
import 'package:raabta/features/prayer_mosque/domain/models/mosque.dart';
import 'package:raabta/features/prayer_mosque/presentation/l10n/prayer_strings.dart';

class MosqueCard extends StatelessWidget {
  const MosqueCard({
    super.key,
    required this.mosque,
    required this.locale,
    required this.isFavorite,
    required this.onTap,
    required this.onFavorite,
    required this.onDirections,
  });

  final MosquePlace mosque;
  final String locale;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onFavorite;
  final VoidCallback onDirections;

  @override
  Widget build(BuildContext context) {
    final distanceKm = (mosque.distanceMeters ?? 0) / 1000;
    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      glowColor: AppColors.chipPrayer,
      glowIntensity: 0.08,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                    Text(mosque.name, style: AppTypography.title),
                    Text(
                      mosque.address,
                      style: AppTypography.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onFavorite,
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? AppColors.roseGlow : AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              GlassTag(
                label: '${distanceKm.toStringAsFixed(1)} km',
                icon: Icons.near_me_outlined,
                accentColor: AppColors.chipPrayer,
                filled: false,
              ),
              if (mosque.walkMinutes != null) ...[
                const SizedBox(width: AppSpacing.xs),
                GlassTag(
                  label: '${mosque.walkMinutes} min walk',
                  icon: Icons.directions_walk,
                  accentColor: AppColors.chipPrayer,
                  filled: false,
                ),
              ],
              if (mosque.driveMinutes != null) ...[
                const SizedBox(width: AppSpacing.xs),
                GlassTag(
                  label: '${mosque.driveMinutes} min drive',
                  icon: Icons.directions_car_outlined,
                  accentColor: AppColors.chipPrayer,
                  filled: false,
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              if (mosque.facilities.jumuahAvailable)
                _Fac(PrayerStrings.t('fac_jumuah', locale)),
              if (mosque.facilities.parking)
                _Fac(PrayerStrings.t('fac_parking', locale)),
              if (mosque.facilities.womensPrayerArea)
                _Fac(PrayerStrings.t('fac_women', locale)),
              if (mosque.facilities.wheelchairAccess)
                _Fac(PrayerStrings.t('fac_wheelchair', locale)),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              if (mosque.rating > 0)
                Row(
                  children: [
                    const Icon(Icons.star, size: 16, color: AppColors.amberGlow),
                    Text(
                      ' ${mosque.rating.toStringAsFixed(1)}',
                      style: AppTypography.bodySmall,
                    ),
                    const SizedBox(width: AppSpacing.md),
                  ],
                ),
              TextButton.icon(
                onPressed: onDirections,
                icon: const Icon(Icons.directions, size: 18),
                label: Text(PrayerStrings.t('prayer_navigate', locale)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Fac extends StatelessWidget {
  const _Fac(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return GlassTag(
      label: label,
      accentColor: AppColors.chipPrayer,
    );
  }
}

class PrayerStatsRing extends StatelessWidget {
  const PrayerStatsRing({
    super.key,
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 72,
          height: 72,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: value.clamp(0, 1),
                strokeWidth: 6,
                backgroundColor: AppColors.glassBorder,
                color: color,
              ),
              Text(
                '${(value * 100).round()}%',
                style: AppTypography.caption.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          label,
          style: AppTypography.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
