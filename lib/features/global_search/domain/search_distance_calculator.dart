import 'dart:math' as math;

/// Pure geographic distance utilities for Global Search (S6).
abstract final class SearchDistanceCalculator {
  static const earthRadiusMeters = 6371000.0;

  static bool isValidLatitude(double value) =>
      value.isFinite && value >= -90 && value <= 90;

  static bool isValidLongitude(double value) =>
      value.isFinite && value >= -180 && value <= 180;

  static bool isValidCoordinate(double latitude, double longitude) {
    return isValidLatitude(latitude) && isValidLongitude(longitude);
  }

  /// Haversine distance in meters. Returns null for invalid coordinates.
  static double? distanceMeters({
    required double userLatitude,
    required double userLongitude,
    required double listingLatitude,
    required double listingLongitude,
  }) {
    if (!isValidCoordinate(userLatitude, userLongitude) ||
        !isValidCoordinate(listingLatitude, listingLongitude)) {
      return null;
    }

    final lat1 = _toRadians(userLatitude);
    final lat2 = _toRadians(listingLatitude);
    final dLat = _toRadians(listingLatitude - userLatitude);
    final dLng = _toRadians(listingLongitude - userLongitude);

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1) *
            math.cos(lat2) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    final meters = earthRadiusMeters * c;
    if (!meters.isFinite || meters < 0) return null;
    return meters;
  }

  static double _toRadians(double degrees) => degrees * math.pi / 180;
}
