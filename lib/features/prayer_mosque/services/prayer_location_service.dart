import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:raabta/features/ramadan/prayer_times_service.dart';

class PrayerLocationResult {
  const PrayerLocationResult({
    required this.latitude,
    required this.longitude,
    required this.label,
    required this.source,
  });

  final double latitude;
  final double longitude;
  final String label;
  final PrayerLocationSource source;
}

enum PrayerLocationSource {
  gps,
  manual,
  fallback,
}

class PrayerLocationService {
  static const qatarMinLat = 24.40;
  static const qatarMaxLat = 26.25;
  static const qatarMinLng = 50.70;
  static const qatarMaxLng = 51.75;

  static bool isWithinQatar(double latitude, double longitude) {
    return latitude >= qatarMinLat &&
        latitude <= qatarMaxLat &&
        longitude >= qatarMinLng &&
        longitude <= qatarMaxLng;
  }

  Future<bool> ensurePermission() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) return false;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  Stream<Position> watchPosition() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 30,
      ),
    );
  }

  PrayerLocationResult locationFromPosition(Position position) {
    final label = _areaLabel(
      position.latitude,
      position.longitude,
    );
    return PrayerLocationResult(
      latitude: position.latitude,
      longitude: position.longitude,
      label: label,
      source: PrayerLocationSource.gps,
    );
  }

  String _areaLabel(double latitude, double longitude) {
    if (!isWithinQatar(latitude, longitude)) {
      return 'Your location';
    }

    PrayerCityPreset? nearest;
    var nearestKm = double.infinity;
    for (final city in prayerCityPresets) {
      if (city.countryKey != 'country_qatar') continue;
      final km = haversineKm(latitude, longitude, city.latitude, city.longitude);
      if (km < nearestKm) {
        nearestKm = km;
        nearest = city;
      }
    }
    if (nearest != null && nearestKm <= 18) {
      return '${_cityDisplayName(nearest.nameKey)}, Qatar';
    }
    return 'Qatar';
  }

  String _cityDisplayName(String nameKey) {
    switch (nameKey) {
      case 'city_doha':
        return 'Doha';
      case 'city_al_wakrah':
        return 'Al Wakrah';
      case 'city_al_khor':
        return 'Al Khor';
      case 'city_lusail':
        return 'Lusail';
      default:
        return 'Qatar';
    }
  }

  Future<PrayerLocationResult> resolve({
    required bool autoLocation,
    String manualCity = 'Doha',
    double manualLatitude = PrayerTimesService.defaultLatitude,
    double manualLongitude = PrayerTimesService.defaultLongitude,
  }) async {
    if (!autoLocation) {
      return PrayerLocationResult(
        latitude: manualLatitude,
        longitude: manualLongitude,
        label: manualCity,
        source: PrayerLocationSource.manual,
      );
    }

    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) {
        return _fallback('Location off — $manualCity');
      }

      if (!await ensurePermission()) {
        return _fallback('Permission denied — $manualCity');
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
      return locationFromPosition(position);
    } catch (_) {
      return _fallback('GPS unavailable — $manualCity');
    }
  }

  PrayerLocationResult _fallback(String label) {
    return PrayerLocationResult(
      latitude: PrayerTimesService.defaultLatitude,
      longitude: PrayerTimesService.defaultLongitude,
      label: label,
      source: PrayerLocationSource.fallback,
    );
  }

  static double haversineKm(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    return Geolocator.distanceBetween(lat1, lng1, lat2, lng2) / 1000;
  }

  static int estimateWalkMinutes(double distanceKm) =>
      (distanceKm / 5 * 60).ceil().clamp(1, 999);

  static int estimateDriveMinutes(double distanceKm) =>
      (distanceKm / 40 * 60).ceil().clamp(1, 999);
}

/// GCC city presets for manual selection.
class PrayerCityPreset {
  const PrayerCityPreset({
    required this.nameKey,
    required this.latitude,
    required this.longitude,
    required this.countryKey,
  });

  final String nameKey;
  final double latitude;
  final double longitude;
  final String countryKey;
}

const prayerCityPresets = [
  PrayerCityPreset(
    nameKey: 'city_doha',
    latitude: 25.2854,
    longitude: 51.5310,
    countryKey: 'country_qatar',
  ),
  PrayerCityPreset(
    nameKey: 'city_al_wakrah',
    latitude: 25.1715,
    longitude: 51.6034,
    countryKey: 'country_qatar',
  ),
  PrayerCityPreset(
    nameKey: 'city_al_khor',
    latitude: 25.6804,
    longitude: 51.4969,
    countryKey: 'country_qatar',
  ),
  PrayerCityPreset(
    nameKey: 'city_lusail',
    latitude: 25.4244,
    longitude: 51.5075,
    countryKey: 'country_qatar',
  ),
  PrayerCityPreset(
    nameKey: 'city_dubai',
    latitude: 25.2048,
    longitude: 55.2708,
    countryKey: 'country_uae',
  ),
  PrayerCityPreset(
    nameKey: 'city_riyadh',
    latitude: 24.7136,
    longitude: 46.6753,
    countryKey: 'country_saudi',
  ),
];

String encodeLocationCache(PrayerLocationResult location) {
  return jsonEncode({
    'lat': location.latitude,
    'lng': location.longitude,
    'label': location.label,
    'source': location.source.name,
  });
}

PrayerLocationResult? decodeLocationCache(String? raw) {
  if (raw == null || raw.isEmpty) return null;
  try {
    final map = jsonDecode(raw) as Map<String, dynamic>;
    return PrayerLocationResult(
      latitude: (map['lat'] as num).toDouble(),
      longitude: (map['lng'] as num).toDouble(),
      label: map['label'] as String? ?? 'Cached',
      source: PrayerLocationSource.values.firstWhere(
        (s) => s.name == map['source'],
        orElse: () => PrayerLocationSource.fallback,
      ),
    );
  } catch (_) {
    return null;
  }
}
