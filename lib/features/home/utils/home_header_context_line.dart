import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/features/home/l10n/home_profile_strings.dart';
import 'package:raabta/features/quick_actions/climate_navigator/models/qatar_weather.dart';

/// Structured place line for the Home header (country, optional temp, optional area).
class HomeHeaderPlaceParts {
  const HomeHeaderPlaceParts({
    this.country,
    this.temperatureC,
    this.area,
  });

  final String? country;
  final String? temperatureC;
  final String? area;

  bool get hasContent =>
      _has(country) || _has(temperatureC) || _has(area);

  static bool _has(String? value) =>
      value != null && value.trim().isNotEmpty;

  /// Segments for a single muted line (skips empty; no dash placeholders).
  List<String> visibleSegments({required String locale}) {
    final parts = <String>[];
    if (_has(country)) parts.add(country!.trim());
    if (_has(temperatureC)) {
      final suffix = locale == 'Arabic' ? '°م' : '°C';
      parts.add('${temperatureC!.trim()}$suffix');
    }
    if (_has(area)) parts.add(area!.trim());
    return parts;
  }
}

/// Kit §10 header context: country, optional live temp, optional preferred area.
abstract final class HomeHeaderContextLine {
  HomeHeaderContextLine._();

  static final _placeholderPattern = RegExp(r'^[\-–—.\s]+$');

  @visibleForTesting
  static bool isMeaningfulPlacePart(String? value) {
    if (value == null) return false;
    final trimmed = value.trim();
    if (trimmed.isEmpty) return false;
    if (_placeholderPattern.hasMatch(trimmed)) return false;
    return true;
  }

  /// Never shows fallback or placeholder temperatures.
  @visibleForTesting
  static HomeHeaderPlaceParts? composeParts({
    required String locale,
    String? preferredArea,
    QatarWeather? weather,
  }) {
    final country = HomeProfileStrings.t('header_country_qatar', locale);
    final area = isMeaningfulPlacePart(preferredArea) ? preferredArea!.trim() : null;
    final liveWeather = weather != null &&
            weather.dataAvailable &&
            !weather.isFallback
        ? weather
        : null;
    final temp = liveWeather?.tempC.round().toString();

    final parts = HomeHeaderPlaceParts(
      country: country,
      temperatureC: isMeaningfulPlacePart(temp) ? temp : null,
      area: area,
    );
    return parts.hasContent ? parts : null;
  }

  /// @deprecated Use [placePartsFromProviderState] for rendering.
  static String? compose({
    required String locale,
    String? preferredArea,
    QatarWeather? weather,
  }) {
    final parts = composeParts(
      locale: locale,
      preferredArea: preferredArea,
      weather: weather,
    );
    if (parts == null) return null;
    return parts.visibleSegments(locale: locale).join(' · ');
  }

  static HomeHeaderPlaceParts? placePartsFromProviderState({
    required String locale,
    String? preferredArea,
    required AsyncValue<QatarWeather> weatherAsync,
  }) {
    return weatherAsync.when(
      data: (weather) => composeParts(
        locale: locale,
        preferredArea: preferredArea,
        weather: weather,
      ),
      loading: () => composeParts(
        locale: locale,
        preferredArea: preferredArea,
        weather: null,
      ),
      error: (Object error, StackTrace stackTrace) => composeParts(
        locale: locale,
        preferredArea: preferredArea,
        weather: null,
      ),
    );
  }

  static String? fromProviderState({
    required String locale,
    String? preferredArea,
    required AsyncValue<QatarWeather> weatherAsync,
  }) {
    final parts = placePartsFromProviderState(
      locale: locale,
      preferredArea: preferredArea,
      weatherAsync: weatherAsync,
    );
    if (parts == null) return null;
    return parts.visibleSegments(locale: locale).join(' · ');
  }
}
