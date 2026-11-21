import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:raabta/features/prayer_mosque/domain/models/mosque.dart';
import 'package:raabta/features/prayer_mosque/services/prayer_location_service.dart';

/// Curated Qatar mosques + optional Google Places live search.
class MosqueDataSource {
  MosqueDataSource();

  static const googlePlacesApiKey = String.fromEnvironment(
    'GOOGLE_PLACES_API_KEY',
    defaultValue: '',
  );

  final Map<String, MosquePlace> _dynamicPlaces = {};

  static const _curated = [
    MosquePlace(
      id: 'state_grand_mosque',
      name: 'State Grand Mosque',
      latitude: 25.3167,
      longitude: 51.5300,
      address: 'Jahhaniya St, Doha',
      description:
          'One of Qatar\'s largest mosques with stunning architecture.',
      phone: '+974 4444 4444',
      rating: 4.8,
      reviewCount: 2400,
      jumuahTime: '12:15 PM',
      khutbahTime: '12:00 PM',
      prayerCapacity: 30000,
      facilities: MosqueFacilities(
        wheelchairAccess: true,
        parking: true,
        ablution: true,
        airConditioning: true,
        womensPrayerArea: true,
        jumuahAvailable: true,
      ),
    ),
    MosquePlace(
      id: 'katara_mosque',
      name: 'Katara Mosque',
      latitude: 25.3596,
      longitude: 51.5272,
      address: 'Katara Cultural Village, Doha',
      description: 'Beautiful blue-tiled mosque in Katara.',
      rating: 4.9,
      reviewCount: 1800,
      jumuahTime: '12:30 PM',
      facilities: MosqueFacilities(
        parking: true,
        ablution: true,
        airConditioning: true,
        womensPrayerArea: true,
        jumuahAvailable: true,
      ),
    ),
    MosquePlace(
      id: 'education_city_mosque',
      name: 'Education City Mosque',
      latitude: 25.3147,
      longitude: 51.4247,
      address: 'Education City, Al Rayyan',
      rating: 4.7,
      reviewCount: 920,
      jumuahTime: '12:20 PM',
      facilities: MosqueFacilities(
        wheelchairAccess: true,
        parking: true,
        ablution: true,
        airConditioning: true,
        womensPrayerArea: true,
        jumuahAvailable: true,
      ),
    ),
    MosquePlace(
      id: 'fanar_mosque',
      name: 'Fanar Qatar Islamic Cultural Center',
      latitude: 25.2895,
      longitude: 51.5412,
      address: 'Corniche, Doha',
      description: 'Spiral minaret and Islamic cultural programs.',
      rating: 4.6,
      reviewCount: 1100,
      type: MosqueType.islamicCenter,
      jumuahTime: '12:15 PM',
      facilities: MosqueFacilities(
        parking: true,
        ablution: true,
        airConditioning: true,
        womensPrayerArea: true,
        jumuahAvailable: true,
      ),
    ),
    MosquePlace(
      id: 'aspire_zone_mosque',
      name: 'Aspire Zone Mosque',
      latitude: 25.2631,
      longitude: 51.4412,
      address: 'Aspire Zone, Baaya',
      rating: 4.5,
      reviewCount: 640,
      jumuahTime: '12:10 PM',
      facilities: MosqueFacilities(
        parking: true,
        ablution: true,
        airConditioning: true,
        jumuahAvailable: true,
      ),
    ),
    MosquePlace(
      id: 'al_wakrah_mosque',
      name: 'Al Wakrah Grand Mosque',
      latitude: 25.1789,
      longitude: 51.5998,
      address: 'Al Wakrah',
      rating: 4.4,
      reviewCount: 380,
      jumuahTime: '12:15 PM',
      facilities: MosqueFacilities(
        parking: true,
        ablution: true,
        womensPrayerArea: true,
        jumuahAvailable: true,
      ),
    ),
    MosquePlace(
      id: 'lusail_mosque',
      name: 'Lusail Grand Mosque',
      latitude: 25.4244,
      longitude: 51.5075,
      address: 'Lusail City',
      rating: 4.6,
      reviewCount: 510,
      jumuahTime: '12:15 PM',
      facilities: MosqueFacilities(
        parking: true,
        ablution: true,
        airConditioning: true,
        womensPrayerArea: true,
        jumuahAvailable: true,
      ),
    ),
    MosquePlace(
      id: 'al_khor_mosque',
      name: 'Al Khor Mosque',
      latitude: 25.6804,
      longitude: 51.4969,
      address: 'Al Khor',
      rating: 4.3,
      reviewCount: 210,
      jumuahTime: '12:10 PM',
      facilities: MosqueFacilities(
        parking: true,
        ablution: true,
        jumuahAvailable: true,
      ),
    ),
    MosquePlace(
      id: 'msheireb_mosque',
      name: 'Msheireb Downtown Mosque',
      latitude: 25.2867,
      longitude: 51.5294,
      address: 'Msheireb Downtown Doha',
      rating: 4.7,
      reviewCount: 520,
      type: MosqueType.prayerHall,
      jumuahTime: '12:25 PM',
      facilities: MosqueFacilities(
        wheelchairAccess: true,
        ablution: true,
        airConditioning: true,
        jumuahAvailable: true,
      ),
    ),
    MosquePlace(
      id: 'souq_waqif_mosque',
      name: 'Souq Waqif Mosque',
      latitude: 25.2889,
      longitude: 51.5328,
      address: 'Souq Waqif, Doha',
      rating: 4.6,
      reviewCount: 890,
      jumuahTime: '12:20 PM',
      facilities: MosqueFacilities(
        ablution: true,
        jumuahAvailable: true,
      ),
    ),
    MosquePlace(
      id: 'industrial_area_mosque',
      name: 'Industrial Area Mosque',
      latitude: 25.1680,
      longitude: 51.4560,
      address: 'Industrial Area, Doha',
      rating: 4.2,
      reviewCount: 180,
      jumuahTime: '12:05 PM',
      facilities: MosqueFacilities(
        parking: true,
        ablution: true,
        jumuahAvailable: true,
      ),
    ),
    MosquePlace(
      id: 'pearl_qatar_mosque',
      name: 'The Pearl Qatar Mosque',
      latitude: 25.3680,
      longitude: 51.5470,
      address: 'The Pearl-Qatar, Doha',
      rating: 4.5,
      reviewCount: 340,
      jumuahTime: '12:20 PM',
      facilities: MosqueFacilities(
        parking: true,
        ablution: true,
        airConditioning: true,
        womensPrayerArea: true,
        jumuahAvailable: true,
      ),
    ),
    MosquePlace(
      id: 'hamad_airport_prayer',
      name: 'Hamad International Airport Prayer Room',
      latitude: 25.2731,
      longitude: 51.6080,
      address: 'Hamad International Airport, Doha',
      description: 'Multi-faith and Muslim prayer rooms in all concourses.',
      rating: 4.8,
      reviewCount: 1200,
      type: MosqueType.prayerHall,
      facilities: MosqueFacilities(
        wheelchairAccess: true,
        ablution: true,
        airConditioning: true,
        womensPrayerArea: true,
      ),
    ),
    MosquePlace(
      id: 'city_center_prayer',
      name: 'City Center Mall Prayer Room',
      latitude: 25.3238,
      longitude: 51.5305,
      address: 'City Center Mall, West Bay',
      description: 'Prayer room on upper level near food court.',
      rating: 4.5,
      reviewCount: 420,
      type: MosqueType.prayerHall,
      facilities: MosqueFacilities(
        ablution: true,
        airConditioning: true,
        womensPrayerArea: true,
      ),
    ),
    MosquePlace(
      id: 'villaggio_prayer',
      name: 'Villaggio Mall Prayer Room',
      latitude: 25.2447,
      longitude: 51.4444,
      address: 'Villaggio Mall, Aspire Zone',
      rating: 4.4,
      reviewCount: 310,
      type: MosqueType.prayerHall,
      facilities: MosqueFacilities(
        ablution: true,
        airConditioning: true,
        womensPrayerArea: true,
      ),
    ),
    MosquePlace(
      id: 'sheraton_prayer',
      name: 'Sheraton Grand Doha Prayer Room',
      latitude: 25.3193,
      longitude: 51.5361,
      address: 'West Bay, Doha',
      description: 'Hotel prayer room for guests and visitors.',
      rating: 4.3,
      reviewCount: 95,
      type: MosqueType.prayerHall,
      facilities: MosqueFacilities(
        ablution: true,
        airConditioning: true,
      ),
    ),
  ];

  List<MosquePlace> nearby({
    required double latitude,
    required double longitude,
    String query = '',
    double radiusKm = 60,
  }) {
    final lower = query.toLowerCase();
    final enriched = <MosquePlace>[];
    for (final m in _curated) {
      final km = PrayerLocationService.haversineKm(
        latitude,
        longitude,
        m.latitude,
        m.longitude,
      );
      if (radiusKm > 0 && km > radiusKm) continue;
      enriched.add(
        m.copyWith(
          distanceMeters: km * 1000,
          walkMinutes: PrayerLocationService.estimateWalkMinutes(km),
          driveMinutes: PrayerLocationService.estimateDriveMinutes(km),
        ),
      );
    }
    enriched.sort(
      (a, b) => (a.distanceMeters ?? 0).compareTo(b.distanceMeters ?? 0),
    );

    if (lower.isEmpty) return enriched;
    return enriched
        .where(
          (m) =>
              m.name.toLowerCase().contains(lower) ||
              m.address.toLowerCase().contains(lower),
        )
        .toList();
  }

  /// Curated list + optional Google Places results sorted by live distance.
  Future<List<MosquePlace>> nearbyLive({
    required double latitude,
    required double longitude,
    String query = '',
    double radiusKm = 60,
  }) async {
    final curated = nearby(
      latitude: latitude,
      longitude: longitude,
      query: '',
      radiusKm: radiusKm,
    );
    final places = await _fetchGooglePlaces(
      latitude: latitude,
      longitude: longitude,
      radiusMeters: (radiusKm * 1000).round().clamp(1000, 50000),
    );
    final merged = _mergeMosques(curated, places);

    if (query.trim().isEmpty) return merged;
    final lower = query.toLowerCase();
    return merged
        .where(
          (m) =>
              m.name.toLowerCase().contains(lower) ||
              m.address.toLowerCase().contains(lower),
        )
        .toList();
  }

  List<MosquePlace> _mergeMosques(
    List<MosquePlace> curated,
    List<MosquePlace> places,
  ) {
    final merged = List<MosquePlace>.from(curated);
    for (final place in places) {
      final duplicate = merged.any(
        (existing) =>
            PrayerLocationService.haversineKm(
              existing.latitude,
              existing.longitude,
              place.latitude,
              place.longitude,
            ) <
            0.12,
      );
      if (!duplicate) merged.add(place);
    }
    merged.sort(
      (a, b) => (a.distanceMeters ?? 0).compareTo(b.distanceMeters ?? 0),
    );
    return merged;
  }

  Future<List<MosquePlace>> _fetchGooglePlaces({
    required double latitude,
    required double longitude,
    required int radiusMeters,
  }) async {
    if (googlePlacesApiKey.isEmpty) return const [];

    try {
      final uri = Uri.https(
        'maps.googleapis.com',
        '/maps/api/place/nearbysearch/json',
        {
          'location': '$latitude,$longitude',
          'radius': '$radiusMeters',
          'type': 'mosque',
          'key': googlePlacesApiKey,
        },
      );
      final response = await http.get(uri).timeout(const Duration(seconds: 12));
      if (response.statusCode != 200) return const [];

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (body['status'] != 'OK' && body['status'] != 'ZERO_RESULTS') {
        return const [];
      }

      final results = body['results'] as List? ?? const [];
      final places = <MosquePlace>[];
      for (final raw in results) {
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
        final mosque = MosquePlace(
          id: 'places_$placeId',
          placeId: placeId,
          name: map['name'] as String? ?? 'Mosque',
          latitude: lat,
          longitude: lng,
          address: map['vicinity'] as String? ?? 'Qatar',
          rating: (map['rating'] as num?)?.toDouble() ?? 0,
          reviewCount: (map['user_ratings_total'] as num?)?.toInt() ?? 0,
          isOpen: (map['opening_hours'] as Map?)?['open_now'] as bool? ?? true,
          distanceMeters: km * 1000,
          walkMinutes: PrayerLocationService.estimateWalkMinutes(km),
          driveMinutes: PrayerLocationService.estimateDriveMinutes(km),
          facilities: const MosqueFacilities(
            ablution: true,
            jumuahAvailable: true,
          ),
        );
        _dynamicPlaces[mosque.id] = mosque;
        places.add(mosque);
      }
      return places;
    } catch (_) {
      return const [];
    }
  }

  MosquePlace? byId(String id) {
    final dynamicPlace = _dynamicPlaces[id];
    if (dynamicPlace != null) return dynamicPlace;
    try {
      return _curated.firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }
}
