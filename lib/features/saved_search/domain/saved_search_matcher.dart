import 'package:raabta/features/saved_search/domain/saved_search_criteria.dart';
import 'package:raabta/features/saved_search/domain/saved_search_vertical.dart';

/// Deterministic saved-search matching — mirrors browse filter logic.
abstract final class SavedSearchMatcher {
  static bool matches({
    required SavedSearchVertical vertical,
    required SavedSearchCriteria criteria,
    required Map<String, dynamic> listing,
  }) {
    final values = criteria.values;
    if (values.isEmpty) return true;

    return switch (vertical) {
      SavedSearchVertical.housing => _matchesHousing(values, listing),
      SavedSearchVertical.jobs => _matchesJobs(values, listing),
      SavedSearchVertical.business => _matchesBusiness(values, listing),
      SavedSearchVertical.services => _matchesServices(values, listing),
      SavedSearchVertical.marketplace => _matchesMarketplace(values, listing),
    };
  }

  static bool _matchesHousing(
    Map<String, dynamic> c,
    Map<String, dynamic> listing,
  ) {
    final area = c['area']?.toString();
    if (area != null &&
        area.isNotEmpty &&
        !_containsIgnoreCase(listing['area']?.toString(), area)) {
      return false;
    }

    final propertyType = c['propertyType']?.toString();
    if (propertyType != null &&
        propertyType.isNotEmpty &&
        listing['propertyType']?.toString() != propertyType &&
        listing['type']?.toString() != propertyType) {
      return false;
    }

    final price = _readNum(listing['pricePerMonth'] ?? listing['price']);
    final minPrice = _readNum(c['minPrice']);
    final maxPrice = _readNum(c['maxPrice']);
    if (minPrice != null && price != null && price < minPrice) return false;
    if (maxPrice != null && price != null && price > maxPrice) return false;

    final bedrooms = _readNum(c['bedrooms']);
    final listingBedrooms = _readNum(listing['bedrooms']);
    if (bedrooms != null &&
        listingBedrooms != null &&
        listingBedrooms < bedrooms) {
      return false;
    }

    final gender = c['gender']?.toString();
    if (gender != null &&
        gender.isNotEmpty &&
        listing['genderPreference']?.toString() != gender) {
      return false;
    }

    final nationality = c['nationality']?.toString();
    if (nationality != null &&
        nationality.isNotEmpty &&
        listing['nationalityPreference']?.toString() != nationality) {
      return false;
    }

    return _matchesTextQuery(c['query']?.toString(), listing, [
      'title',
      'area',
      'description',
    ]);
  }

  static bool _matchesJobs(Map<String, dynamic> c, Map<String, dynamic> listing) {
    final area = c['area']?.toString();
    if (area != null &&
        area.isNotEmpty &&
        !_containsIgnoreCase(listing['location']?.toString(), area)) {
      return false;
    }

    final category = c['category']?.toString() ?? c['jobCategory']?.toString();
    if (category != null &&
        category.isNotEmpty &&
        listing['category']?.toString() != category) {
      return false;
    }

    final employmentType = c['employmentType']?.toString();
    if (employmentType != null &&
        employmentType.isNotEmpty &&
        listing['employmentType']?.toString() != employmentType &&
        listing['jobType']?.toString() != employmentType) {
      return false;
    }

    final maxSalary = _readNum(c['maxSalary']);
    final minSalary = _readNum(c['minSalary']);
    final listingSalary = _readSalaryFromString(listing['salary']?.toString());
    if (maxSalary != null &&
        listingSalary != null &&
        listingSalary > maxSalary) {
      return false;
    }
    if (minSalary != null &&
        listingSalary != null &&
        listingSalary < minSalary) {
      return false;
    }

    final query = c['query']?.toString() ?? c['jobQuery']?.toString();
    return _matchesTextQuery(query, listing, [
      'title',
      'company',
      'category',
      'location',
      'description',
    ]);
  }

  static bool _matchesBusiness(
    Map<String, dynamic> c,
    Map<String, dynamic> listing,
  ) {
    final area = c['area']?.toString();
    if (area != null &&
        area.isNotEmpty &&
        !_containsIgnoreCase(listing['area']?.toString(), area)) {
      return false;
    }

    final businessTag = c['businessTag']?.toString();
    if (businessTag == 'ramadan_iftar') {
      final tags = listing['tags'];
      if (tags is List &&
          !tags.map((e) => e.toString()).contains('ramadan_iftar')) {
        return false;
      }
    }

    final category = c['category']?.toString();
    if (category != null &&
        category.isNotEmpty &&
        listing['category']?.toString() != category) {
      return false;
    }

    final query = c['query']?.toString() ?? c['businessQuery']?.toString();
    return _matchesTextQuery(query, listing, [
      'name',
      'title',
      'category',
      'area',
      'description',
      'tags',
    ]);
  }

  static bool _matchesServices(
    Map<String, dynamic> c,
    Map<String, dynamic> listing,
  ) {
    final area = c['area']?.toString();
    if (area != null &&
        area.isNotEmpty &&
        !_containsIgnoreCase(listing['area']?.toString(), area)) {
      return false;
    }

    final categoryId = c['categoryId']?.toString();
    if (categoryId != null &&
        categoryId.isNotEmpty &&
        listing['categoryId']?.toString() != categoryId) {
      return false;
    }

    final listingType = c['listingType']?.toString();
    if (listingType != null &&
        listingType.isNotEmpty &&
        listing['listingType']?.toString() != listingType) {
      return false;
    }

    final subService = c['subService']?.toString();
    if (subService != null &&
        subService.isNotEmpty &&
        !_containsIgnoreCase(listing['serviceName']?.toString(), subService)) {
      return false;
    }

    final query = c['query']?.toString() ?? c['serviceTrade']?.toString();
    return _matchesTextQuery(query, listing, [
      'title',
      'displayTitle',
      'serviceName',
      'categoryId',
      'area',
      'description',
    ]);
  }

  static bool _matchesMarketplace(
    Map<String, dynamic> c,
    Map<String, dynamic> listing,
  ) {
    if (c['leavingQatar'] == true) {
      final groups = listing['relevantGroupIds'];
      if (groups is! List ||
          !groups.map((e) => e.toString()).contains('leaving_qatar')) {
        return false;
      }
    }

    final categoryId = c['categoryId']?.toString();
    if (categoryId != null &&
        categoryId.isNotEmpty &&
        listing['categoryId']?.toString() != categoryId) {
      return false;
    }

    return _matchesTextQuery(c['query']?.toString(), listing, [
      'title',
      'area',
      'price',
      'description',
    ]);
  }

  static bool _matchesTextQuery(
    String? query,
    Map<String, dynamic> listing,
    List<String> fields,
  ) {
    if (query == null || query.trim().isEmpty) return true;
    final normalized = query.trim().toLowerCase();
    for (final field in fields) {
      final value = listing[field];
      if (value == null) continue;
      if (value is List) {
        if (value.map((e) => e.toString().toLowerCase()).any(
              (v) => v.contains(normalized),
            )) {
          return true;
        }
      } else if (value.toString().toLowerCase().contains(normalized)) {
        return true;
      }
    }
    return false;
  }

  static bool _containsIgnoreCase(String? haystack, String needle) {
    if (haystack == null) return false;
    return haystack.toLowerCase().contains(needle.toLowerCase());
  }

  static num? _readNum(dynamic raw) {
    if (raw is num) return raw;
    return num.tryParse(raw?.toString() ?? '');
  }

  static int? _readSalaryFromString(String? salary) {
    if (salary == null || salary.isEmpty) return null;
    final matches = RegExp(r'([\d,]+)').allMatches(salary);
    if (matches.isEmpty) return null;
    final values = matches
        .map((m) => int.tryParse(m.group(1)!.replaceAll(',', '')))
        .whereType<int>()
        .toList();
    if (values.isEmpty) return null;
    return values.reduce((a, b) => a > b ? a : b);
  }
}
