import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:raabta/features/prayer_mosque/data/mosque_data_source.dart';
import 'package:raabta/features/prayer_mosque/domain/models/mosque.dart';
import 'package:raabta/features/prayer_mosque/services/prayer_location_service.dart';
import 'package:raabta/features/quick_actions/climate_navigator/data/cooling_resource_classification.dart';
import 'package:raabta/features/quick_actions/climate_navigator/data/cooling_resources_catalog.dart';
import 'package:raabta/features/quick_actions/climate_navigator/models/cooling_resource.dart';

/// Combines curated cooling spots with Mosque Finder data.
///
/// Live Google Places search uses the same legacy Nearby Search endpoint and
/// API key as [MosqueDataSource]. Per Google's March 2025 pricing change, the
/// old shared \$200 monthly credit was replaced by per-SKU free monthly caps
/// (Essentials ~10k, Pro ~5k, Enterprise ~1k billable events). Legacy Nearby
/// Search bills separately — only call [searchGooglePlacesNearby] on explicit
/// user action, never automatically.
class CoolingResourcesService {
  CoolingResourcesService({MosqueDataSource? mosqueDataSource})
      : _mosqueDataSource = mosqueDataSource ?? MosqueDataSource();

  final MosqueDataSource _mosqueDataSource;

  static const googlePlacesApiKey = String.fromEnvironment(
    'GOOGLE_PLACES_API_KEY',
    defaultValue: '',
  );

  /// Verified curated list + mosques from Mosque Finder, sorted by distance.
  List<CoolingResource> verifiedNearby({
    required double latitude,
    required double longitude,
    double radiusKm = 60,
    String? typeFilter,
    String? capabilityFilter,
  }) {
    final catalog = _withDistance(
      CoolingResourcesCatalog.verified,
      latitude,
      longitude,
      radiusKm,
    ).map(CoolingResourceClassification.enrichCatalogEntry).toList();

    final mosquePlaces = _mosqueDataSource.nearby(
      latitude: latitude,
      longitude: longitude,
      radiusKm: radiusKm,
    );
    final mosques = mosquePlaces
        .map((m) => CoolingResourceClassification.enrichFromMosque(
              _mosqueToCoolingResource(m),
              m,
            ))
        .toList();

    var merged = _mergeByProximity([...catalog, ...mosques]);

    if (typeFilter != null && typeFilter.isNotEmpty) {
      merged = merged.where((r) => r.type == typeFilter).toList();
    }
    merged = CoolingResourceClassification.applyCapabilityFilter(
      merged,
      capabilityFilter: capabilityFilter,
    );
    return merged;
  }

  /// Closest repo-documented public-access stop with AC/shade classification.
  CoolingResource? nearestPublicAccessStop({
    required double latitude,
    required double longitude,
    double radiusKm = 60,
    String? typeFilter,
    String? capabilityFilter,
  }) {
    final nearby = verifiedNearby(
      latitude: latitude,
      longitude: longitude,
      radiusKm: radiusKm,
      typeFilter: typeFilter,
      capabilityFilter: capabilityFilter,
    );
    return CoolingResourceClassification.nearestPublicAccessStop(nearby);
  }

  /// Optional live search — unverified Google Places results only.
  /// Fires up to three Nearby Search requests (mall, hospital, library).
  Future<List<CoolingResource>> searchGooglePlacesNearby({
    required double latitude,
    required double longitude,
    double radiusKm = 15,
  }) async {
    if (googlePlacesApiKey.isEmpty) return const [];

    const types = ['shopping_mall', 'hospital', 'library'];
    final radiusMeters = (radiusKm * 1000).round().clamp(1000, 50000);
    final results = <CoolingResource>[];

    for (final type in types) {
      final batch = await _fetchPlacesType(
        latitude: latitude,
        longitude: longitude,
        radiusMeters: radiusMeters,
        type: type,
      );
      results.addAll(batch);
    }

    return _mergeByProximity(results);
  }

  Future<List<CoolingResource>> _fetchPlacesType({
    required double latitude,
    required double longitude,
    required int radiusMeters,
    required String type,
  }) async {
    try {
      final uri = Uri.https(
        'maps.googleapis.com',
        '/maps/api/place/nearbysearch/json',
        {
          'location': '$latitude,$longitude',
          'radius': '$radiusMeters',
          'type': type,
          'key': googlePlacesApiKey,
        },
      );
      final response =
          await http.get(uri).timeout(const Duration(seconds: 12));
      if (response.statusCode != 200) return const [];

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (body['status'] != 'OK' && body['status'] != 'ZERO_RESULTS') {
        return const [];
      }

      final coolingType = _placesTypeToCoolingType(type);
      final rawResults = body['results'] as List? ?? const [];
      final places = <CoolingResource>[];

      for (final raw in rawResults) {
        final map = Map<String, dynamic>.from(raw as Map);
        final geometry = map['geometry'] as Map?;
        final location = geometry?['location'] as Map?;
        if (location == null) continue;

        final lat = (location['lat'] as num).toDouble();
        final lng = (location['lng'] as num).toDouble();
        if (!PrayerLocationService.isWithinQatar(lat, lng)) continue;

        final placeId = map['place_id'] as String? ?? '';
        if (placeId.isEmpty) continue;

        final km = PrayerLocationService.haversineKm(
          latitude,
          longitude,
          lat,
          lng,
        );

        places.add(
          CoolingResource(
            id: 'places_$placeId',
            name: map['name'] as String? ?? 'Place',
            type: coolingType,
            latitude: lat,
            longitude: lng,
            address: map['vicinity'] as String? ?? 'Qatar',
            is24Hour:
                (map['opening_hours'] as Map?)?['open_now'] as bool? ?? false,
            isVerified: false,
            distanceMeters: km * 1000,
          ),
        );
      }
      return places;
    } catch (_) {
      return const [];
    }
  }

  static String _placesTypeToCoolingType(String placesType) {
    switch (placesType) {
      case 'shopping_mall':
        return 'mall';
      case 'hospital':
        return 'hospital';
      case 'library':
        return 'library';
      default:
        return 'mall';
    }
  }

  static CoolingResource _mosqueToCoolingResource(MosquePlace mosque) {
    return CoolingResource(
      id: mosque.id,
      name: mosque.name,
      type: 'mosque',
      latitude: mosque.latitude,
      longitude: mosque.longitude,
      address: mosque.address,
      is24Hour: false,
      isVerified: true,
      distanceMeters: mosque.distanceMeters,
    );
  }

  static List<CoolingResource> _withDistance(
    List<CoolingResource> resources,
    double latitude,
    double longitude,
    double radiusKm,
  ) {
    final enriched = <CoolingResource>[];
    for (final resource in resources) {
      final km = PrayerLocationService.haversineKm(
        latitude,
        longitude,
        resource.latitude,
        resource.longitude,
      );
      if (radiusKm > 0 && km > radiusKm) continue;
      enriched.add(resource.copyWith(distanceMeters: km * 1000));
    }
    enriched.sort(
      (a, b) => (a.distanceMeters ?? 0).compareTo(b.distanceMeters ?? 0),
    );
    return enriched;
  }

  static List<CoolingResource> _mergeByProximity(
    List<CoolingResource> resources,
  ) {
    final merged = <CoolingResource>[];
    for (final resource in resources) {
      final duplicate = merged.any(
        (existing) =>
            PrayerLocationService.haversineKm(
              existing.latitude,
              existing.longitude,
              resource.latitude,
              resource.longitude,
            ) <
            0.12,
      );
      if (!duplicate) merged.add(resource);
    }
    merged.sort(
      (a, b) => (a.distanceMeters ?? 0).compareTo(b.distanceMeters ?? 0),
    );
    return merged;
  }
}
