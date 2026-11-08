import 'package:geolocator/geolocator.dart';
import 'package:raabta/features/global_search/domain/search_distance_calculator.dart';
import 'package:raabta/features/global_search/domain/search_location_context.dart';

/// Short-lived in-memory location cache for Global Search (S6).
class SearchLocationCache {
  SearchLocationCache({Duration ttl = const Duration(minutes: 5)}) : _ttl = ttl;

  final Duration _ttl;
  SearchLocationContext? _cached;
  DateTime? _cachedAt;

  SearchLocationContext? read() {
    if (_cached == null || _cachedAt == null) return null;
    if (DateTime.now().difference(_cachedAt!) > _ttl) {
      clear();
      return null;
    }
    return _cached;
  }

  void write(SearchLocationContext context) {
    _cached = context;
    _cachedAt = DateTime.now();
  }

  void clear() {
    _cached = null;
    _cachedAt = null;
  }
}

/// Lazy device location access for nearMe searches (S6).
abstract class SearchLocationReader {
  Future<SearchLocationContext?> getCurrentLocation();
}

class SearchLocationProvider implements SearchLocationReader {
  SearchLocationProvider({SearchLocationCache? cache})
      : _cache = cache ?? SearchLocationCache();

  final SearchLocationCache _cache;

  @override
  Future<SearchLocationContext?> getCurrentLocation() async {
    final cached = _cache.read();
    if (cached != null) return cached;

    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) return null;

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission != LocationPermission.always &&
          permission != LocationPermission.whileInUse) {
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      if (!SearchDistanceCalculator.isValidCoordinate(
        position.latitude,
        position.longitude,
      )) {
        return null;
      }

      final context = SearchLocationContext(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracyMeters: position.accuracy,
        capturedAt: DateTime.now(),
      );
      _cache.write(context);
      return context;
    } catch (_) {
      return null;
    }
  }
}

/// Test double — never touches platform location APIs.
class FakeSearchLocationProvider implements SearchLocationReader {
  FakeSearchLocationProvider(this._location);

  SearchLocationContext? _location;
  int requestCount = 0;

  void setLocation(SearchLocationContext? location) => _location = location;

  @override
  Future<SearchLocationContext?> getCurrentLocation() async {
    requestCount++;
    return _location;
  }
}
