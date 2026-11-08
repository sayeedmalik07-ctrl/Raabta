import 'package:raabta/features/trip_planner/domain/models/catalog_place.dart';
import 'package:raabta/features/trip_planner/domain/models/trip_enums.dart';
import 'package:raabta/features/trip_planner/domain/models/trip_plan.dart';
import 'package:raabta/features/trip_planner/presentation/l10n/trip_strings.dart';

/// Curated Qatar places — expandable to other countries via countryCode.
class QatarPlacesCatalog {
  static const attractions = [
    _PlaceSeed(
      id: 'national_museum',
      titleKey: 'place_national_museum_title',
      description:
          'Stunning desert rose architecture showcasing Qatar\'s heritage.',
      entryFee: 50,
      rating: 4.8,
      openingHours: '9:00 AM – 7:00 PM',
      lat: 25.2867,
      lng: 51.5494,
      address: 'Museum Park St, Doha',
      familyFriendly: true,
      wheelchairAccessible: true,
      styles: [TripTravelStyle.culture, TripTravelStyle.history],
      durationMinutes: 120,
      bestVisitTime: 'Morning',
    ),
    _PlaceSeed(
      id: 'mia',
      titleKey: 'place_mia_title',
      description: 'World-class Islamic art collection on the Corniche.',
      entryFee: 0,
      rating: 4.9,
      openingHours: '9:00 AM – 7:00 PM',
      lat: 25.2954,
      lng: 51.5394,
      address: 'Corniche, Doha',
      familyFriendly: true,
      wheelchairAccessible: true,
      styles: [TripTravelStyle.culture, TripTravelStyle.photography],
      durationMinutes: 90,
    ),
    _PlaceSeed(
      id: 'souq_waqif',
      titleKey: 'place_souq_waqif_title',
      description: 'Historic market with spices, falcons, and local crafts.',
      entryFee: 0,
      rating: 4.7,
      openingHours: '10:00 AM – 12:00 AM',
      lat: 25.2889,
      lng: 51.5328,
      address: 'Souq Waqif, Doha',
      familyFriendly: true,
      styles: [
        TripTravelStyle.shopping,
        TripTravelStyle.foodLover,
        TripTravelStyle.culture,
      ],
      durationMinutes: 150,
      bestVisitTime: 'After sunset',
    ),
    _PlaceSeed(
      id: 'mia_park',
      titleKey: 'place_mia_park_title',
      description: 'Waterfront park with skyline views and outdoor art.',
      entryFee: 0,
      rating: 4.6,
      lat: 25.2968,
      lng: 51.5401,
      address: 'MIA Park, Doha',
      familyFriendly: true,
      styles: [TripTravelStyle.nature, TripTravelStyle.photography],
      durationMinutes: 60,
      bestVisitTime: 'Evening',
    ),
    _PlaceSeed(
      id: 'katara',
      titleKey: 'place_katara_title',
      description: 'Amphitheater, galleries, beach, and dining.',
      entryFee: 0,
      rating: 4.7,
      lat: 25.3596,
      lng: 51.5272,
      address: 'Katara, Doha',
      styles: [TripTravelStyle.culture, TripTravelStyle.photography],
      durationMinutes: 120,
    ),
    _PlaceSeed(
      id: 'katara_beach',
      titleKey: 'place_katara_beach_title',
      description: 'Public beach with water sports and family areas.',
      entryFee: 0,
      rating: 4.5,
      lat: 25.3612,
      lng: 51.5248,
      address: 'Katara Beach, Doha',
      familyFriendly: true,
      kidsFriendly: true,
      styles: [TripTravelStyle.nature, TripTravelStyle.family],
      durationMinutes: 120,
      bestVisitTime: 'Morning or evening',
    ),
    _PlaceSeed(
      id: 'the_pearl',
      titleKey: 'place_pearl_title',
      description: 'Luxury marina, dining, and Mediterranean vibes.',
      entryFee: 0,
      rating: 4.5,
      lat: 25.3714,
      lng: 51.5548,
      address: 'The Pearl, Doha',
      styles: [TripTravelStyle.luxury, TripTravelStyle.shopping],
      durationMinutes: 120,
    ),
    _PlaceSeed(
      id: 'desert_safari',
      titleKey: 'place_desert_safari_title',
      description: 'Dune bashing, camel rides, and Bedouin camp.',
      entryFee: 350,
      rating: 4.8,
      lat: 25.0833,
      lng: 51.1833,
      address: 'Inland Sea, Qatar',
      styles: [TripTravelStyle.adventure, TripTravelStyle.nature],
      durationMinutes: 240,
      bestVisitTime: 'Afternoon',
    ),
    _PlaceSeed(
      id: 'education_city',
      titleKey: 'place_education_city_mosque_title',
      description: 'Stunning modern mosque open to visitors.',
      entryFee: 0,
      rating: 4.7,
      lat: 25.3147,
      lng: 51.4247,
      address: 'Education City, Al Rayyan',
      styles: [TripTravelStyle.culture, TripTravelStyle.photography],
      durationMinutes: 45,
    ),
    _PlaceSeed(
      id: 'aspire_park',
      titleKey: 'place_aspire_park_title',
      description: 'Green oasis perfect for families and picnics.',
      entryFee: 0,
      rating: 4.5,
      lat: 25.2631,
      lng: 51.4412,
      address: 'Aspire Zone, Doha',
      familyFriendly: true,
      kidsFriendly: true,
      styles: [TripTravelStyle.nature, TripTravelStyle.family],
      durationMinutes: 90,
    ),
    _PlaceSeed(
      id: 'sealine_beach',
      titleKey: 'place_sealine_beach_title',
      description: 'Desert-meets-sea beach popular for camping and dune views.',
      entryFee: 0,
      rating: 4.6,
      lat: 24.8333,
      lng: 51.4167,
      address: 'Sealine, Mesaieed',
      familyFriendly: true,
      styles: [TripTravelStyle.nature, TripTravelStyle.adventure],
      durationMinutes: 180,
    ),
    _PlaceSeed(
      id: 'fire_station',
      titleKey: 'place_fire_station_title',
      description: 'Contemporary art gallery in a converted fire station.',
      entryFee: 0,
      rating: 4.4,
      lat: 25.3180,
      lng: 51.5120,
      address: 'Fire Station, Doha',
      styles: [TripTravelStyle.culture, TripTravelStyle.photography],
      durationMinutes: 60,
    ),
  ];

  static const restaurants = [
    _PlaceSeed(
      id: 'parisa_souq',
      titleKey: 'place_parisa_title',
      description: 'Persian cuisine in a beautiful traditional setting.',
      entryFee: 0,
      estimatedMeal: 120,
      rating: 4.6,
      lat: 25.2895,
      lng: 51.5335,
      address: 'Souq Waqif, Doha',
      cuisine: 'Persian',
      halal: true,
      styles: [TripTravelStyle.foodLover, TripTravelStyle.luxury],
      durationMinutes: 75,
      kind: CatalogPlaceKind.restaurant,
    ),
    _PlaceSeed(
      id: 'al_manchab',
      titleKey: 'place_al_manchab_title',
      description: 'Authentic Qatari dishes and machboos.',
      estimatedMeal: 80,
      rating: 4.5,
      lat: 25.2880,
      lng: 51.5310,
      address: 'Souq Waqif, Doha',
      cuisine: 'Qatari',
      halal: true,
      styles: [TripTravelStyle.foodLover, TripTravelStyle.budget],
      durationMinutes: 60,
      kind: CatalogPlaceKind.restaurant,
    ),
    _PlaceSeed(
      id: 'sushi_samba',
      titleKey: 'place_sushisamba_title',
      description: 'Fusion dining with Corniche views.',
      estimatedMeal: 250,
      rating: 4.4,
      lat: 25.3234,
      lng: 51.5301,
      address: 'West Bay, Doha',
      cuisine: 'Fusion',
      halal: true,
      styles: [TripTravelStyle.luxury, TripTravelStyle.foodLover],
      durationMinutes: 90,
      kind: CatalogPlaceKind.restaurant,
    ),
    _PlaceSeed(
      id: 'karak_stop',
      titleKey: 'place_karak_snacks_title',
      description: 'Budget-friendly local tea and snacks.',
      estimatedMeal: 15,
      rating: 4.3,
      lat: 25.2850,
      lng: 51.5350,
      address: 'Doha',
      cuisine: 'Local',
      halal: true,
      styles: [TripTravelStyle.budget, TripTravelStyle.foodLover],
      durationMinutes: 20,
      kind: CatalogPlaceKind.restaurant,
    ),
  ];

  static const shopping = [
    'Souq Waqif — handicrafts & spices',
    'Place Vendôme — Parisian-style luxury',
    'Doha Festival City — family mall',
    'Villaggio Mall — Venetian theme',
    'Mall of Qatar — entertainment & brands',
  ];

  static List<CatalogPlace> allPlaces([String locale = 'English']) =>
      [...attractions, ...restaurants]
          .map((p) => p.toCatalogPlace(locale))
          .toList();

  static CatalogPlace? catalogById(String id, [String locale = 'English']) =>
      byId(id)?.toCatalogPlace(locale);

  static List<CatalogPlace> placesForCategory(
    ExploreCategory category, [
    String locale = 'English',
  ]) {
    switch (category) {
      case ExploreCategory.restaurants:
        return restaurants.map((p) => p.toCatalogPlace(locale)).toList();
      case ExploreCategory.topAttractions:
        return [...attractions]
            .map((p) => p.toCatalogPlace(locale))
            .toList()
          ..sort((a, b) => b.rating.compareTo(a.rating));
      case ExploreCategory.hiddenGems:
        return attractions
            .where((p) =>
                p.id == 'fire_station' ||
                p.id == 'education_city' ||
                p.id == 'katara_beach')
            .map((p) => p.toCatalogPlace(locale))
            .toList();
      case ExploreCategory.beaches:
        return attractions
            .where((p) => p.id.contains('beach') || p.id == 'sealine_beach')
            .map((p) => p.toCatalogPlace(locale))
            .toList();
      case ExploreCategory.family:
        return attractions
            .where((p) => p.familyFriendly || p.kidsFriendly)
            .map((p) => p.toCatalogPlace(locale))
            .toList();
      case ExploreCategory.museums:
        return attractions
            .where((p) =>
                p.id.contains('museum') ||
                p.id == 'mia' ||
                p.id == 'fire_station')
            .map((p) => p.toCatalogPlace(locale))
            .toList();
      case ExploreCategory.shopping:
        return attractions
            .where((p) => p.styles.contains(TripTravelStyle.shopping))
            .map((p) => p.toCatalogPlace(locale))
            .toList();
      case ExploreCategory.adventure:
        return attractions
            .where((p) => p.styles.contains(TripTravelStyle.adventure))
            .map((p) => p.toCatalogPlace(locale))
            .toList();
      case ExploreCategory.nature:
        return attractions
            .where((p) => p.styles.contains(TripTravelStyle.nature))
            .map((p) => p.toCatalogPlace(locale))
            .toList();
      case ExploreCategory.luxury:
        return allPlaces(locale)
            .where((p) => p.styles.contains(TripTravelStyle.luxury))
            .toList();
      case ExploreCategory.food:
        return allPlaces(locale)
            .where((p) =>
                p.kind == CatalogPlaceKind.restaurant ||
                p.styles.contains(TripTravelStyle.foodLover))
            .toList();
      case ExploreCategory.photography:
        return attractions
            .where((p) => p.styles.contains(TripTravelStyle.photography))
            .map((p) => p.toCatalogPlace(locale))
            .toList();
      case ExploreCategory.culture:
        return attractions
            .where((p) => p.styles.contains(TripTravelStyle.culture))
            .map((p) => p.toCatalogPlace(locale))
            .toList();
      case ExploreCategory.history:
        return attractions
            .where((p) => p.styles.contains(TripTravelStyle.history))
            .map((p) => p.toCatalogPlace(locale))
            .toList();
    }
  }

  static List<CatalogPlace> search(String query, [String locale = 'English']) {
    final q = query.toLowerCase().trim();
    if (q.isEmpty) return [];
    return [...attractions, ...restaurants]
        .where((p) => _matchesSearch(p, q, locale))
        .map((p) => p.toCatalogPlace(locale))
        .toList();
  }

  static bool _matchesSearch(_PlaceSeed place, String q, String locale) {
    final titleEn = TripStrings.t(place.titleKey, 'English').toLowerCase();
    final titleLoc = TripStrings.t(place.titleKey, locale).toLowerCase();
    return titleEn.contains(q) ||
        titleLoc.contains(q) ||
        place.description.toLowerCase().contains(q) ||
        (place.address?.toLowerCase().contains(q) ?? false) ||
        (place.cuisine?.toLowerCase().contains(q) ?? false);
  }

  static List<_PlaceSeed> attractionsForStyles(List<TripTravelStyle> styles) {
    if (styles.isEmpty) return attractions;
    return attractions.where((a) {
      return a.styles.any(styles.contains) ||
          styles.contains(TripTravelStyle.culture);
    }).toList();
  }

  static _PlaceSeed? byId(String id) {
    for (final p in [...attractions, ...restaurants]) {
      if (p.id == id) return p;
    }
    return null;
  }
}

class _PlaceSeed {
  const _PlaceSeed({
    required this.id,
    required this.titleKey,
    required this.description,
    this.entryFee = 0,
    this.estimatedMeal = 0,
    this.rating = 4.5,
    this.openingHours,
    this.lat = 25.2854,
    this.lng = 51.5310,
    this.address,
    this.familyFriendly = true,
    this.wheelchairAccessible = false,
    this.kidsFriendly = false,
    this.styles = const [],
    this.durationMinutes = 60,
    this.bestVisitTime,
    this.cuisine,
    this.halal = true,
    this.vegetarianOptions = false,
    this.kind = CatalogPlaceKind.attraction,
  });

  final String id;
  final String titleKey;
  final String description;
  final double entryFee;
  final double estimatedMeal;
  final double rating;
  final String? openingHours;
  final double lat;
  final double lng;
  final String? address;
  final bool familyFriendly;
  final bool wheelchairAccessible;
  final bool kidsFriendly;
  final List<TripTravelStyle> styles;
  final int durationMinutes;
  final String? bestVisitTime;
  final String? cuisine;
  final bool halal;
  final bool vegetarianOptions;
  final CatalogPlaceKind kind;

  String localizedTitle(String locale) => TripStrings.t(titleKey, locale);

  CatalogPlace toCatalogPlace(String locale) => CatalogPlace(
        id: id,
        title: localizedTitle(locale),
        description: description,
        kind: kind == CatalogPlaceKind.restaurant ||
                estimatedMeal > 0 && entryFee == 0 && cuisine != null
            ? CatalogPlaceKind.restaurant
            : CatalogPlaceKind.attraction,
        entryFee: entryFee,
        estimatedMeal: estimatedMeal,
        rating: rating,
        openingHours: openingHours,
        lat: lat,
        lng: lng,
        address: address,
        familyFriendly: familyFriendly,
        wheelchairAccessible: wheelchairAccessible,
        kidsFriendly: kidsFriendly,
        styles: styles,
        durationMinutes: durationMinutes,
        bestVisitTime: bestVisitTime,
        cuisine: cuisine,
        halal: halal,
        vegetarianOptions: vegetarianOptions,
      );

  TripActivity toActivity({
    required String startTime,
    required TripActivityType type,
    required TripTimeSlot slot,
    required String locale,
  }) {
    return toCatalogPlace(locale).toActivity(
      startTime: startTime,
      type: type,
      slot: slot,
    );
  }
}
