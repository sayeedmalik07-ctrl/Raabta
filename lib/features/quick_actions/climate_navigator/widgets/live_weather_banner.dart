import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:raabta/core/colors/app_colors.dart';
import '../l10n/climate_strings.dart';
import '../models/qatar_weather.dart';

class LiveWeatherBanner extends StatelessWidget {
  final QatarWeather weather;
  final String locale;

  const LiveWeatherBanner({
    super.key,
    required this.weather,
    this.locale = 'English',
  });

  @override
  Widget build(BuildContext context) {
    final wbgt = weather.wbgtEstimateC;
    final wbgtLabel =
        ClimateStrings.wbgtRiskLabel(weather.wbgtRiskLevelKey, locale);
    final wbgtColor = weather.wbgtAccentColor;
    final heatRiskLabel =
        ClimateStrings.heatIndexRiskLabel(weather.heatIndexC, locale);
    final uvLabel = ClimateStrings.uvLabelFor(weather.uvIndex, locale);
    final outdoorAdvice =
        ClimateStrings.outdoorAdviceFor(weather.heatIndexC, locale);
    final description =
        ClimateStrings.localizedDescription(weather.description, locale);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: wbgtColor.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: wbgtColor.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(
                weather.isPeakHeat ? '🌡️' : '🌤️',
                style: const TextStyle(fontSize: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ClimateStrings.t('banner_wbgt_primary_label', locale),
                      style: TextStyle(
                        color: AppColors.isLight
                            ? AppColors.textOnGlassSecondary
                            : Colors.white.withValues(alpha: 0.5),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '${wbgt.toStringAsFixed(1)}°C',
                          style: TextStyle(
                            color: wbgtColor,
                            fontWeight: FontWeight.w900,
                            fontSize: 28,
                            height: 1,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: wbgtColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              wbgtLabel,
                              style: TextStyle(
                                color: wbgtColor,
                                fontWeight: FontWeight.w800,
                                fontSize: 10,
                                letterSpacing: 0.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
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
                      style: TextStyle(
                        color: AppColors.isLight
                            ? AppColors.textOnGlassSecondary
                            : Colors.white.withValues(alpha: 0.55),
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      ClimateStrings.format(
                        'banner_heat_index_line',
                        locale,
                        params: {
                          'index': weather.heatIndexC.toStringAsFixed(0),
                          'label': heatRiskLabel,
                        },
                      ),
                      style: TextStyle(
                        color: AppColors.isLight
                            ? AppColors.textOnGlassMuted
                            : Colors.white.withValues(alpha: 0.45),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: wbgtColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'UV',
                          style: TextStyle(
                            color: AppColors.isLight
                                ? AppColors.textOnGlassMuted
                                : Colors.white.withValues(alpha: 0.4),
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '${weather.uvIndex}',
                          style: TextStyle(
                            color: wbgtColor,
                            fontWeight: FontWeight.w900,
                            fontSize: 20,
                            height: 1.1,
                          ),
                        ),
                        Text(
                          uvLabel,
                          style: TextStyle(
                            color: wbgtColor.withValues(alpha: 0.7),
                            fontSize: 8,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (weather.heatIndexC > weather.tempC + 2) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.wb_sunny_outlined,
                    color: Colors.white.withValues(alpha: 0.5),
                    size: 13,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      description,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: wbgtColor.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              outdoorAdvice,
              style: TextStyle(
                color: AppColors.isLight
                    ? AppColors.textPrimary
                    : Colors.white.withValues(alpha: 0.7),
                fontSize: 11,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            ClimateStrings.t('wbgt_approx_note', locale),
            style: TextStyle(
              color: AppColors.textSecondary.withValues(alpha: 0.7),
              fontSize: 9,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: weather.dataAvailable
                      ? const Color(0xFF2DC653)
                      : (AppColors.isLight
                          ? AppColors.textTertiary
                          : Colors.white24),
                ),
              ),
              const SizedBox(width: 5),
              Text(
                _statusLabel(),
                style: TextStyle(
                  color: AppColors.isLight
                      ? AppColors.textOnGlassMuted
                      : Colors.white.withValues(alpha: 0.25),
                  fontSize: 9,
                ),
              ),
            ],
          ),
        ],
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
}
