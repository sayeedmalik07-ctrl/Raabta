import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/prayer_mosque/presentation/l10n/prayer_strings.dart';
import 'package:raabta/features/prayer_mosque/services/prayer_location_service.dart';

class LiveLocationBanner extends StatelessWidget {
  const LiveLocationBanner({
    super.key,
    required this.locale,
    required this.isActive,
    required this.location,
    this.locationUpdatedAt,
    this.onRefresh,
  });

  final String locale;
  final bool isActive;
  final PrayerLocationResult? location;
  final DateTime? locationUpdatedAt;
  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    final source = location?.source;
    final label = location?.label ?? PrayerStrings.t('prayer_live_location_off', locale);
    final statusKey = isActive && source == PrayerLocationSource.gps
        ? 'prayer_live_location_active'
        : source == PrayerLocationSource.manual
            ? 'prayer_manual_location'
            : 'prayer_live_location_off';

    return GlassCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      glowColor: isActive ? AppColors.emeraldGlow : AppColors.glassBorder,
      glowIntensity: isActive ? 0.12 : 0,
      child: Row(
        children: [
          Icon(
            isActive ? Icons.gps_fixed : Icons.location_searching,
            color: isActive ? AppColors.emeraldGlow : AppColors.textSecondary,
            size: 20,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  PrayerStrings.t(statusKey, locale),
                  style: AppTypography.caption.copyWith(
                    color: isActive
                        ? AppColors.emeraldGlow
                        : AppColors.textSecondary,
                  ),
                ),
                Text(label, style: AppTypography.bodySmall, maxLines: 1),
              ],
            ),
          ),
          if (onRefresh != null)
            IconButton(
              tooltip: PrayerStrings.t('prayer_refresh_location', locale),
              onPressed: onRefresh,
              icon: const Icon(Icons.my_location, size: 20),
            ),
        ],
      ),
    );
  }
}
