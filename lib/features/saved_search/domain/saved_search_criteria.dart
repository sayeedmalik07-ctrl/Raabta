import 'package:raabta/data/categories/business_categories.dart';
import 'package:raabta/data/categories/job_categories.dart';
import 'package:raabta/features/global_search/domain/search_route_parameters.dart';
import 'package:raabta/features/saved_search/domain/saved_search_vertical.dart';
import 'package:raabta/models/housing_models.dart';
import 'package:raabta/screens/services/models/service_listing.dart';

/// Serializable snapshot of browse filter state — stored in Firestore as a map.
class SavedSearchCriteria {
  const SavedSearchCriteria(this.values);

  final Map<String, dynamic> values;

  bool get isEmpty => values.isEmpty;

  Map<String, dynamic> toJson() => Map.unmodifiable(values);

  factory SavedSearchCriteria.fromJson(Map<String, dynamic>? raw) {
    if (raw == null || raw.isEmpty) return const SavedSearchCriteria({});
    return SavedSearchCriteria(Map<String, dynamic>.from(raw));
  }

  factory SavedSearchCriteria.fromHousingFilters(HousingFilters filters) {
    final map = <String, dynamic>{};
    final query = filters.searchQuery.trim();
    if (query.isNotEmpty) map['query'] = query;
    if (filters.area != null && filters.area!.trim().isNotEmpty) {
      map['area'] = filters.area!.trim();
    }
    if (filters.type != ListingType.all) {
      map['propertyType'] = filters.type.name;
    }
    map['minPrice'] = filters.minPrice.round();
    map['maxPrice'] = filters.maxPrice.round();
    if (filters.minBedrooms != null && filters.minBedrooms! > 0) {
      map['bedrooms'] = filters.minBedrooms;
    }
    if (filters.gender != GenderPreference.any) {
      map['gender'] = filters.gender.name;
    }
    if (filters.nationality != NationalityPreference.any) {
      map['nationality'] = filters.nationality.name;
    }
    return SavedSearchCriteria(map);
  }

  factory SavedSearchCriteria.fromJobsBrowse({
    required String query,
    required int selectedCategoryIndex,
    SearchRouteParameters? routeFilters,
  }) {
    final map = <String, dynamic>{};
    final trimmed = query.trim();
    if (trimmed.isNotEmpty) map['query'] = trimmed.toLowerCase();
    final category = kJobCategories[selectedCategoryIndex];
    if (category != 'All') map['category'] = category;
    if (routeFilters != null) {
      if (routeFilters.area != null && routeFilters.area!.trim().isNotEmpty) {
        map['area'] = routeFilters.area!.trim();
      }
      if (routeFilters.minSalary != null) {
        map['minSalary'] = routeFilters.minSalary;
      }
      if (routeFilters.maxSalary != null) {
        map['maxSalary'] = routeFilters.maxSalary;
      }
      if (routeFilters.jobCategory != null &&
          routeFilters.jobCategory!.trim().isNotEmpty) {
        map['jobCategory'] = routeFilters.jobCategory!.trim();
      }
      if (routeFilters.jobQuery != null &&
          routeFilters.jobQuery!.trim().isNotEmpty) {
        map['jobQuery'] = routeFilters.jobQuery!.trim().toLowerCase();
      }
      if (routeFilters.employmentType != null &&
          routeFilters.employmentType!.trim().isNotEmpty) {
        map['employmentType'] = routeFilters.employmentType!.trim();
      }
    }
    return SavedSearchCriteria(map);
  }

  factory SavedSearchCriteria.fromBusinessBrowse({
    required String query,
    required int selectedCategoryIndex,
    String? areaFilter,
    SearchRouteParameters? routeFilters,
  }) {
    final map = <String, dynamic>{};
    final trimmed = query.trim();
    if (trimmed.isNotEmpty) map['query'] = trimmed.toLowerCase();
    if (selectedCategoryIndex > 0) {
      final filter = kBusinessCategories[selectedCategoryIndex];
      if (filter.filter == 'ramadan_iftar') {
        map['businessTag'] = 'ramadan_iftar';
      } else if (filter.filter != null) {
        map['category'] = filter.filter!;
      }
    }
    final area = areaFilter?.trim().isNotEmpty == true
        ? areaFilter!.trim()
        : routeFilters?.area?.trim();
    if (area != null && area.isNotEmpty) map['area'] = area;
    if (routeFilters?.businessQuery != null &&
        routeFilters!.businessQuery!.trim().isNotEmpty) {
      map['businessQuery'] = routeFilters.businessQuery!.trim().toLowerCase();
    }
    if (routeFilters?.businessTag != null &&
        routeFilters!.businessTag!.trim().isNotEmpty) {
      map['businessTag'] = routeFilters.businessTag!.trim();
    }
    return SavedSearchCriteria(map);
  }

  factory SavedSearchCriteria.fromServicesBrowse({
    required String query,
    String? areaFilter,
    ServiceListingType? listingType,
    String? categoryId,
    String? subService,
    SearchRouteParameters? routeFilters,
  }) {
    final map = <String, dynamic>{};
    final trimmed = query.trim();
    if (trimmed.isNotEmpty) map['query'] = trimmed.toLowerCase();
    final area = areaFilter?.trim().isNotEmpty == true
        ? areaFilter!.trim()
        : routeFilters?.area?.trim();
    if (area != null && area.isNotEmpty) map['area'] = area;
    if (listingType != null) map['listingType'] = listingType.name;
    if (categoryId != null && categoryId.isNotEmpty) {
      map['categoryId'] = categoryId;
    }
    if (subService != null && subService.isNotEmpty) {
      map['subService'] = subService;
    }
    if (routeFilters?.serviceTrade != null &&
        routeFilters!.serviceTrade!.trim().isNotEmpty) {
      map['serviceTrade'] = routeFilters.serviceTrade!.trim().toLowerCase();
    }
    return SavedSearchCriteria(map);
  }

  factory SavedSearchCriteria.fromMarketplaceBrowse({
    required String query,
    bool leavingQatarFilter = false,
    String? categoryId,
  }) {
    final map = <String, dynamic>{};
    final trimmed = query.trim();
    if (trimmed.isNotEmpty) map['query'] = trimmed.toLowerCase();
    if (leavingQatarFilter) map['leavingQatar'] = true;
    if (categoryId != null && categoryId.isNotEmpty) {
      map['categoryId'] = categoryId;
    }
    return SavedSearchCriteria(map);
  }

  String defaultName(SavedSearchVertical vertical) {
    final parts = <String>[];
    final query = values['query']?.toString();
    if (query != null && query.isNotEmpty) parts.add(query);
    final area = values['area']?.toString();
    if (area != null && area.isNotEmpty) parts.add(area);
    final category =
        values['category']?.toString() ?? values['categoryId']?.toString();
    if (category != null && category.isNotEmpty) parts.add(category);
    if (parts.isEmpty) return vertical.storageValue;
    return parts.take(3).join(' · ');
  }
}
