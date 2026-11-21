import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/features/prayer_mosque/domain/models/mosque.dart';
import 'package:raabta/features/prayer_mosque/providers/prayer_providers.dart';

/// Query key for shared nearby-mosque lookups (Trip Map, Climate, Finder).
class NearbyMosquesQuery {
  const NearbyMosquesQuery({
    required this.latitude,
    required this.longitude,
    this.query = '',
  });

  final double latitude;
  final double longitude;
  final String query;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NearbyMosquesQuery &&
          latitude == other.latitude &&
          longitude == other.longitude &&
          query == other.query;

  @override
  int get hashCode => Object.hash(latitude, longitude, query);
}

/// Centralized mosque query — reads [MosqueDataSource] only, no duplicate dataset.
final nearbyMosquesProvider = FutureProvider.autoDispose
    .family<List<MosquePlace>, NearbyMosquesQuery>((ref, query) {
  return ref.read(mosqueDataSourceProvider).nearbyLive(
        latitude: query.latitude,
        longitude: query.longitude,
        query: query.query,
      );
});
