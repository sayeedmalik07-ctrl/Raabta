/// Immutable device location snapshot for Global Search proximity (S6).
///
/// Platform-independent — no Flutter or geolocator types in domain code.
class SearchLocationContext {
  const SearchLocationContext({
    required this.latitude,
    required this.longitude,
    required this.capturedAt,
    this.accuracyMeters,
  });

  final double latitude;
  final double longitude;
  final double? accuracyMeters;
  final DateTime capturedAt;
}
