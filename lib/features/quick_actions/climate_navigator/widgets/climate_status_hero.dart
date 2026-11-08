import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/quick_actions/climate_navigator/l10n/climate_strings.dart';
import 'package:raabta/features/quick_actions/climate_navigator/models/qatar_weather.dart';
import 'package:raabta/features/quick_actions/climate_navigator/widgets/climate_primitives.dart';
import 'package:raabta/features/quick_actions/climate_navigator/widgets/hydration_reminder_toggle.dart';
import 'package:raabta/features/quick_actions/climate_navigator/widgets/outdoor_work_compliance_panel.dart';

/// Single above-the-fold climate/heat status surface for Climate Navigator.
class ClimateStatusHero extends StatelessWidget {
  const ClimateStatusHero({
    super.key,
    required this.weather,
    required this.locale,
    this.onOpenGuide,
  });

  final QatarWeather weather;
  final String locale;
  final VoidCallback? onOpenGuide;

  @visibleForTesting
  static String semanticsSummary(QatarWeather weather, String locale) {
    final wbgt = weather.wbgtEstimateC;
    final wbgtLabel = ClimateStrings.wbgtRiskLabel(weather.wbgtRiskLevelKey, locale);
    final heatLabel = ClimateStrings.heatIndexRiskLabel(weather.heatIndexC, locale);
    final advice = ClimateStrings.outdoorAdviceFor(weather.heatIndexC, locale);
    return ClimateStrings.format(
      'status_hero_semantics',
      locale,
      params: {
        'temp': weather.tempC.toStringAsFixed(0),
        'wbgt': wbgt.toStringAsFixed(1),
        'wbgtLabel': wbgtLabel,
        'heatIndex': weather.heatIndexC.toStringAsFixed(0),
        'heatLabel': heatLabel,
        'advice': advice,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final wbgt = weather.wbgtEstimateC;
    final levelKey = weather.wbgtRiskLevelKey;
    final accent = _accentForLevel(levelKey);
    final wbgtLabel = ClimateStrings.wbgtRiskLabel(levelKey, locale);
    final heatRiskLabel =
        ClimateStrings.heatIndexRiskLabel(weather.heatIndexC, locale);
    final uvLabel = ClimateStrings.uvLabelFor(weather.uvIndex, locale);
    final outdoorAdvice =
        ClimateStrings.outdoorAdviceFor(weather.heatIndexC, locale);
    final description =
        ClimateStrings.localizedDescription(weather.description, locale);
    final showWorkStop = weather.requiresWorkStop;
    final showSummerHours = weather.isSummerRestrictedNow;

    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: semanticsSummary(weather, locale),
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        borderRadius: 16,
        glowColor: accent,
        glowIntensity: showWorkStop ? 0.16 : 0.08,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  weather.isPeakHeat
                      ? Icons.thermostat_rounded
                      : Icons.wb_sunny_outlined,
                  color: accent,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ClimateStrings.t('banner_wbgt_primary_label', locale),
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '${wbgt.toStringAsFixed(1)}°C',
                            style: AppTypography.title.copyWith(
                              color: accent,
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              height: 1,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Flexible(
                            child: Text(
                              wbgtLabel,
                              style: AppTypography.caption.copyWith(
                                color: accent,
                                fontWeight: FontWeight.w800,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        ClimateStrings.format(
                          'banner_air_temp_line',
                          locale,
                          params: {
                            'temp': weather.tempC.toStringAsFixed(0),
                            'feels': weather.feelsLikeC.toStringAsFixed(0),
                            'humidity': '${weather.humidity}',
                            'wind': weather.windSpeedMs.toStringAsFixed(1),
                          },
                        ),
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        ClimateStrings.format(
                          'banner_heat_index_line',
                          locale,
                          params: {
                            'index': weather.heatIndexC.toStringAsFixed(0),
                            'label': heatRiskLabel,
                          },
                        ),
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textOnGlassMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                _UvBadge(
                  uvIndex: weather.uvIndex,
                  uvLabel: uvLabel,
                  accent: accent,
                  locale: locale,
                ),
              ],
            ),
            if (weather.heatIndexC > weather.tempC + 2) ...[
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.wb_sunny_outlined,
                    color: AppColors.textOnGlassMuted,
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      description,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textOnGlassSecondary,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: accent.withValues(alpha: 0.2)),
              ),
              child: Text(
                outdoorAdvice,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textPrimary,
                  height: 1.4,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (showWorkStop) ...[
              const SizedBox(height: 12),
              ClimateHapticOnReveal(
                child: ClimateEntranceReveal(
                  child: ClimateStatusAlertBox(
                    title: ClimateStrings.t('work_stop_alert_title', locale),
                    body: ClimateStrings.t('work_stop_alert_body', locale),
                    color: AppColors.errorBright,
                  ),
                ),
              ),
            ],
            if (showSummerHours) ...[
              const SizedBox(height: 10),
              ClimateEntranceReveal(
                delay: const Duration(milliseconds: 80),
                child: ClimateStatusAlertBox(
                  title: ClimateStrings.t('summer_hours_alert_title', locale),
                  body: ClimateStrings.t('summer_hours_alert_body', locale),
                  color: AppColors.accentGold,
                ),
              ),
            ],
            OutdoorWorkCompliancePanel(
              weather: weather,
              locale: locale,
            ),
            const SizedBox(height: 4),
            HydrationReminderToggle(locale: locale),
            if (onOpenGuide != null) ...[
              const SizedBox(height: 4),
              TextButton.icon(
                onPressed: onOpenGuide,
                icon: const Icon(Icons.menu_book_outlined, size: 18),
                label: Text(ClimateStrings.t('open_guide', locale)),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              ClimateStrings.t('wbgt_approx_note', locale),
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: weather.dataAvailable
                          ? AppColors.successBright
                          : AppColors.textTertiary,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    _statusLabel(),
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textOnGlassMuted,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            if (kDebugMode) ...[
              const SizedBox(height: 8),
              Text(
                'Debug: set HeatRiskCalculator.debugWbgtOverrideC > 32.1 to test work-stop UI',
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary.withValues(alpha: 0.6),
                  fontSize: 10,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _statusLabel() {
    final time = DateFormat.Hm().format(weather.fetchedAt.toLocal());
    if (weather.isFallback) {
      return ClimateStrings.t('weather_estimated', locale);
    }
    if (weather.cached) {
      return ClimateStrings.format(
        'weather_cached',
        locale,
        params: {'time': time},
      );
    }
    if (weather.dataAvailable) {
      return ClimateStrings.format(
        'weather_updated',
        locale,
        params: {'time': time},
      );
    }
    return ClimateStrings.format(
      'weather_cached',
      locale,
      params: {'time': time},
    );
  }

  Color _accentForLevel(String levelKey) {
    switch (levelKey) {
      case 'work_stop':
        return AppColors.errorBright;
      case 'extreme':
        return AppColors.error;
      case 'high':
        return AppColors.heatOrange;
      case 'moderate':
        return AppColors.accentGold;
      default:
        return AppColors.successBright;
    }
  }
}

class _UvBadge extends StatelessWidget {
  const _UvBadge({
    required this.uvIndex,
    required this.uvLabel,
    required this.accent,
    required this.locale,
  });

  final int uvIndex;
  final String uvLabel;
  final Color accent;
  final String locale;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: accent.withValues(alpha: 0.22)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            ClimateStrings.t('uv_badge_label', locale),
            style: AppTypography.caption.copyWith(
              color: AppColors.textOnGlassMuted,
              fontWeight: FontWeight.w700,
              fontSize: 9,
            ),
          ),
          Text(
            '$uvIndex',
            style: AppTypography.title.copyWith(
              color: accent,
              fontSize: 20,
              fontWeight: FontWeight.w900,
              height: 1.1,
            ),
          ),
          Text(
            uvLabel,
            style: AppTypography.caption.copyWith(
              color: accent.withValues(alpha: 0.75),
              fontSize: 8,
            ),
          ),
        ],
      ),
    );
  }
}

class ClimateStatusAlertBox extends StatelessWidget {
  const ClimateStatusAlertBox({
    super.key,
    required this.title,
    required this.body,
    required this.color,
  });

  final String title;
  final String body;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            style: AppTypography.caption.copyWith(
              color: AppColors.textPrimary.withValues(alpha: 0.85),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
