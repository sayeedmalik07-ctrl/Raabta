import 'package:raabta/features/global_search/domain/global_search_models.dart';
import 'package:raabta/features/global_search/domain/search_analysis.dart';
import 'package:raabta/features/global_search/domain/search_distance_calculator.dart';
import 'package:raabta/features/global_search/domain/search_location_context.dart';

/// Bounded proximity bonus for nearMe ranking (S6).
abstract final class SearchProximityRanker {
  static const maxProximityBonus = 20;

  static bool shouldApply(SearchAnalysis analysis) => analysis.nearMe;

  static int proximityBonusForMeters(double? distanceMeters) {
    if (distanceMeters == null || !distanceMeters.isFinite) return 0;
    final km = distanceMeters / 1000;
    if (km <= 1) return 20;
    if (km <= 3) return 16;
    if (km <= 5) return 12;
    if (km <= 10) return 8;
    if (km <= 20) return 4;
    return 0;
  }

  static int? distanceMetersForItem({
    required GlobalSearchResultItem item,
    required SearchLocationContext location,
  }) {
    final lat = item.listingLatitude;
    final lng = item.listingLongitude;
    if (lat == null || lng == null) return null;

    final meters = SearchDistanceCalculator.distanceMeters(
      userLatitude: location.latitude,
      userLongitude: location.longitude,
      listingLatitude: lat,
      listingLongitude: lng,
    );
    if (meters == null) return null;
    return meters.round();
  }

  static int proximityBonusForItem({
    required GlobalSearchResultItem item,
    required SearchLocationContext location,
  }) {
    final meters = distanceMetersForItem(item: item, location: location);
    return proximityBonusForMeters(meters?.toDouble());
  }

  static bool isGeographicCandidate(GlobalSearchResultItem item) {
    if (_isGenericHub(item)) return false;
    return item.category == GlobalSearchCategory.services &&
        item.listingLatitude != null &&
        item.listingLongitude != null &&
        SearchDistanceCalculator.isValidCoordinate(
          item.listingLatitude!,
          item.listingLongitude!,
        );
  }

  static bool _isGenericHub(GlobalSearchResultItem item) {
    final path = item.routePath.split('?').first;
    return const {
      '/services',
      '/jobs',
      '/housing',
      '/businesses',
      '/visa',
      '/money',
    }.contains(path);
  }
}
