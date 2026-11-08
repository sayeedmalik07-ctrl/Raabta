import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/home/l10n/home_ramadan_strings.dart';
import 'package:raabta/features/home/widgets/home_card_tiers.dart';
import 'package:raabta/features/home/widgets/home_icon_badge.dart';
import 'package:raabta/features/ramadan/hijri_calendar.dart';
import 'package:raabta/features/ramadan/ramadan_season.dart';
import 'package:raabta/providers/visa_providers.dart';

/// Compact seasonal Ramadan card — personalized Home area only.
class HomeRamadanSeasonalCard extends ConsumerWidget {
  const HomeRamadanSeasonalCard({super.key, this.reference});

  /// Optional reference date for tests.
  final DateTime? reference;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = reference ?? DateTime.now();
    if (!RamadanSeason.isSeasonalPeriod(now)) {
      return const SizedBox.shrink();
    }

    final locale = ref.watch(userLanguageProvider);
    final during = isDuringRamadan(now);
    final hijri = gregorianToHijri(now);

    final title = during
        ? HomeRamadanStrings.t('home_ramadan_during_title', locale)
        : HomeRamadanStrings.t('home_ramadan_pre_title', locale);

    final subtitle = during
        ? HomeRamadanStrings.format(
            'home_ramadan_during_subtitle',
            locale,
            params: {
              'day': '${hijri.day}',
              'year': '${hijri.year}',
            },
          )
        : _preRamadanSubtitle(locale, now);

    final daysUntil = RamadanSeason.daysUntilRamadan(now);
    final glowColor = during ? AppColors.amberGlow : AppColors.purpleGlow;

    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      borderRadius: AppSpacing.radiusSm,
      glowColor: glowColor,
      glowIntensity: HomeCardTier.standardGlowIntensity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HomeIconBadge(
                icon: Icons.nightlight_round,
                accentColor: glowColor,
                size: 40,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      HomeRamadanStrings.t('home_ramadan_overline', locale),
                      style: AppTypography.caption.copyWith(
                        color: AppColors.cyanGlow,
                        fontWeight: FontWeight.w600,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      title,
                      style: AppTypography.title.copyWith(fontSize: 16),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      subtitle,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textOnGlassMuted,
                      ),
                    ),
                  ],
                ),
              ),
              if (!during && daysUntil > 1)
                _CountdownBadge(days: daysUntil, locale: locale),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: _RamadanActionButton(
                  label: HomeRamadanStrings.t('home_ramadan_cta_primary', locale),
                  accentColor: glowColor,
                  primary: true,
                  onTap: () => context.push('/ramadan'),
                ),
              ),
              if (during) ...[
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _RamadanActionButton(
                    label:
                        HomeRamadanStrings.t('home_ramadan_cta_zakat', locale),
                    accentColor: AppColors.cyanGlow,
                    primary: false,
                    onTap: () => context.push('/ramadan/zakat'),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  String _preRamadanSubtitle(String locale, DateTime now) {
    final days = RamadanSeason.daysUntilRamadan(now);
    if (days <= 1) {
      return HomeRamadanStrings.t('home_ramadan_pre_tomorrow', locale);
    }
    return HomeRamadanStrings.format(
      'home_ramadan_pre_countdown',
      locale,
      params: {'days': '$days'},
    );
  }
}

class _CountdownBadge extends StatelessWidget {
  const _CountdownBadge({required this.days, required this.locale});

  final int days;
  final String locale;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: AppColors.purpleGlow.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        border: Border.all(color: AppColors.purpleGlow.withValues(alpha: 0.35)),
      ),
      child: Text(
        HomeRamadanStrings.format(
          'home_ramadan_countdown_badge',
          locale,
          params: {'days': '$days'},
        ),
        style: AppTypography.caption.copyWith(
          color: AppColors.amberGlow,
          fontWeight: FontWeight.w700,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}

class _RamadanActionButton extends StatelessWidget {
  const _RamadanActionButton({
    required this.label,
    required this.accentColor,
    required this.primary,
    required this.onTap,
  });

  final String label;
  final Color accentColor;
  final bool primary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: primary
          ? accentColor.withValues(alpha: 0.18)
          : AppColors.cyanGlow.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  label,
                  style: AppTypography.caption.copyWith(
                    color: primary ? accentColor : AppColors.cyanGlow,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
