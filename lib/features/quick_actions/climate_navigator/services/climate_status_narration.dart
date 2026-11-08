import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:raabta/features/quick_actions/climate_navigator/data/qatar_outdoor_work_rules.dart';
import 'package:raabta/features/quick_actions/climate_navigator/l10n/climate_strings.dart';
import 'package:raabta/features/quick_actions/climate_navigator/models/qatar_weather.dart';
import 'package:raabta/features/quick_actions/climate_navigator/presentation/climate_wbgt_status_presentation.dart';
import 'package:raabta/features/quick_actions/climate_navigator/services/climate_status_narration_duration.dart';

/// On-device narration and plain-text share payloads (Parts B/C).
abstract final class ClimateStatusNarration {
  static const _forbiddenShareFragments = [
    '16008',
    'compliance_wbgt',
    'motorcycle',
    'bicycle',
    'anonymous',
    'confidential',
  ];

  static String weatherSnapshotBasisLabel(QatarWeather weather, String locale) {
    final time = DateFormat.Hm().format(weather.fetchedAt.toLocal());
    if (isStaleOrUncertainForecast(weather)) {
      return ClimateStrings.format(
        'status_weather_snapshot_stale',
        locale,
        params: {'time': time},
      );
    }
    return ClimateStrings.format(
      'status_weather_snapshot_fresh',
      locale,
      params: {'time': time},
    );
  }

  /// Stale / low-confidence weather snapshot.
  static bool isStaleOrUncertainForecast(QatarWeather weather) =>
      weather.isFallback || !weather.dataAvailable || weather.cached;

  static String staleShareNote(String locale) =>
      ClimateStrings.t('status_share_stale_snapshot_note', locale);

  @visibleForTesting
  static List<String> narrationParts({
    required QatarWeather weather,
    required String locale,
  }) {
    final levelKey = weather.wbgtRiskLevelKey;
    final band = ClimateStrings.t(
      ClimateWbgtStatusPresentation.shortLabelKeyForLevel(levelKey),
      locale,
    );
    final wbgt = weather.wbgtEstimateC.toStringAsFixed(1);
    final intro = ClimateStrings.format(
      'status_narration_intro',
      locale,
      params: {'wbgt': wbgt, 'band': band},
    );
    final guidance = ClimateStrings.t(
      ClimateWbgtStatusPresentation.narrationGuidanceKeyForLevel(levelKey),
      locale,
    );
    final parts = <String>[intro, guidance];

    if (weather.isSummerRestrictedNow) {
      parts.add(
        ClimateStrings.format(
          'status_audio_clock_ban_short',
          locale,
          params: {
            'window': QatarOutdoorWorkRules.restrictedWindowLabel,
          },
        ),
      );
    }

    parts.add(weatherSnapshotBasisLabel(weather, locale));

    return parts;
  }

  /// Fixed on-device script: band, concise WBGT guidance, optional ban, weather snapshot time.
  static String buildNarrationScript({
    required QatarWeather weather,
    required String locale,
  }) {
    return narrationParts(weather: weather, locale: locale).join(' ');
  }

  @visibleForTesting
  static double estimatedSpeakSecondsFor({
    required QatarWeather weather,
    required String locale,
  }) =>
      ClimateStatusNarrationDuration.estimatedSpeakSeconds(
        buildNarrationScript(weather: weather, locale: locale),
        locale,
      );

  static String buildShareText({
    required QatarWeather weather,
    required String locale,
  }) {
    final levelKey = weather.wbgtRiskLevelKey;
    final band = ClimateStrings.t(
      ClimateWbgtStatusPresentation.shortLabelKeyForLevel(levelKey),
      locale,
    );
    final guidance = ClimateStrings.t(
      ClimateWbgtStatusPresentation.guidanceKeyForLevel(levelKey),
      locale,
    );
    final outdoorAdvice =
        ClimateStrings.outdoorAdviceFor(weather.heatIndexC, locale);
    final wbgt = weather.wbgtEstimateC.toStringAsFixed(1);
    final lines = <String>[
      ClimateStrings.t('status_share_header', locale),
      ClimateStrings.format(
        'status_share_band_line',
        locale,
        params: {'wbgt': wbgt, 'band': band},
      ),
      ClimateStrings.t('status_share_wbgt_context_note', locale),
      guidance,
      ClimateStrings.t('status_share_heat_index_outdoor_heading', locale),
      outdoorAdvice,
      ClimateStrings.format(
        'status_share_snapshot_line',
        locale,
        params: {'basis': weatherSnapshotBasisLabel(weather, locale)},
      ),
      if (isStaleOrUncertainForecast(weather)) staleShareNote(locale),
      ClimateStrings.t('status_share_disclaimer', locale),
      ClimateStrings.t('wbgt_approx_note', locale),
    ];
    final userCopyLines = <String>[
      ClimateStrings.format(
        'status_share_band_line',
        locale,
        params: {'wbgt': wbgt, 'band': band},
      ),
      guidance,
      outdoorAdvice,
      ClimateStrings.format(
        'status_share_snapshot_line',
        locale,
        params: {'basis': weatherSnapshotBasisLabel(weather, locale)},
      ),
      if (isStaleOrUncertainForecast(weather)) staleShareNote(locale),
    ];
    assertShareSafe(userCopyLines.join('\n'));
    return lines.join('\n\n');
  }

  /// User-authored share lines only — disclaimers may negate forbidden topics.
  static void assertShareSafe(String userFacingBody) {
    final lower = userFacingBody.toLowerCase();
    for (final fragment in _forbiddenShareFragments) {
      if (lower.contains(fragment.toLowerCase())) {
        throw StateError('Unsafe share text contains: $fragment');
      }
    }
  }
}
