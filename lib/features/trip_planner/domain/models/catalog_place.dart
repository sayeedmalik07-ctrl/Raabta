import 'package:raabta/features/trip_planner/domain/models/trip_enums.dart';
import 'package:raabta/features/trip_planner/domain/models/trip_plan.dart';

/// Public catalog entry for Explore Qatar and attraction details.
class CatalogPlace {
  const CatalogPlace({
    required this.id,
    required this.title,
    required this.description,
    required this.kind,
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
  });

  final String id;
  final String title;
  final String description;
  final CatalogPlaceKind kind;
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

  TripActivity toActivity({
    required String startTime,
    required TripActivityType type,
    required TripTimeSlot slot,
  }) {
    return TripActivity(
      id: id,
      title: title,
      description: description,
      startTime: startTime,
      durationMinutes: durationMinutes,
      type: type,
      timeSlot: slot,
      entryFee: entryFee,
      estimatedCost:
          type == TripActivityType.restaurant ? estimatedMeal : entryFee,
      openingHours: openingHours,
      rating: rating,
      bestVisitTime: bestVisitTime,
      familyFriendly: familyFriendly,
      wheelchairAccessible: wheelchairAccessible,
      latitude: lat,
      longitude: lng,
      address: address,
      cuisine: cuisine,
      halal: halal,
      vegetarianOptions: vegetarianOptions,
      prayerFacilityNearby: true,
    );
  }
}

enum CatalogPlaceKind { attraction, restaurant }

enum ExploreCategory {
  topAttractions,
  hiddenGems,
  culture,
  history,
  museums,
  shopping,
  adventure,
  nature,
  beaches,
  family,
  food,
  luxury,
  photography,
  restaurants,
}

extension ExploreCategoryExt on ExploreCategory {
  String get titleKey => 'explore_$name';

  String get emoji {
    switch (this) {
      case ExploreCategory.topAttractions:
        return '⭐';
      case ExploreCategory.hiddenGems:
        return '💎';
      case ExploreCategory.culture:
        return '🕌';
      case ExploreCategory.history:
        return '🏛️';
      case ExploreCategory.museums:
        return '🖼️';
      case ExploreCategory.shopping:
        return '🛍️';
      case ExploreCategory.adventure:
        return '🏜️';
      case ExploreCategory.nature:
        return '🌳';
      case ExploreCategory.beaches:
        return '🏖️';
      case ExploreCategory.family:
        return '👨‍👩‍👧';
      case ExploreCategory.food:
        return '🍽️';
      case ExploreCategory.luxury:
        return '✨';
      case ExploreCategory.photography:
        return '📸';
      case ExploreCategory.restaurants:
        return '🥘';
    }
  }
}
