import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/services/ai/user_profile_ai_service.dart';
import 'package:raabta/core/colors/app_colors.dart';

// ---------------------------------------------------------------------------
// Models
// ---------------------------------------------------------------------------

class HousingMatchResult {
  const HousingMatchResult({
    required this.listingId,
    required this.matchScore,
    required this.matchLabel,
    required this.matchColor,
    required this.explanation,
    required this.tags,
    required this.valueScore,
    this.breakdown,
  });

  final String listingId;
  final int matchScore;
  final String matchLabel;
  final Color matchColor;
  final String explanation;
  final List<String> tags;
  final String valueScore;
  final Map<String, int>? breakdown;

  Map<String, dynamic> toJson() => {
        'listingId': listingId,
        'matchScore': matchScore,
        'matchLabel': matchLabel,
        'matchColor': matchColor.toARGB32(),
        'explanation': explanation,
        'tags': tags,
        'valueScore': valueScore,
        if (breakdown != null) 'breakdown': breakdown,
      };
}

class RankedHousingMatch {
  const RankedHousingMatch({
    required this.listing,
    required this.result,
  });

  final Map<String, dynamic> listing;
  final HousingMatchResult result;
}

// ---------------------------------------------------------------------------
// Service
// ---------------------------------------------------------------------------

class HousingMatchService {
  static const Color _perfectColor = AppColors.quickActionGreen;
  static const Color _highlyRecommendedColor = AppColors.quickActionCyan;
  static const Color _aiRecommendedColor = Color(0xFF60A5FA);
  static const Color _goodOptionColor = Color(0xFF818CF8);
  static const Color _considerColor = Color(0xFF6B7280);

  static const Color _tagBudgetGreen = AppColors.quickActionGreen;
  static const Color _tagNearYouCyan = AppColors.quickActionCyan;
  static const Color _tagFamilyBlue = Color(0xFF60A5FA);
  static const Color _tagBestValueGold = Color(0xFFFFB800);
  static const Color _tagJustListedAmber = AppColors.quickActionYellow;

  static const Map<String, List<String>> _cityGroups = {
    'doha': [
      'doha',
      'west bay',
      'the pearl',
      'lusail',
      'al sadd',
      'al waab',
      'industrial area',
      'muaither',
    ],
    'al khor': ['al khor', 'ras laffan', 'al dhakhira'],
    'al wakrah': ['al wakrah', 'wakrah'],
  };

  static const Map<String, List<String>> _nearbyCityPairs = {
    'doha': ['al wakrah', 'lusail'],
    'al khor': ['ras laffan', 'al dhakhira'],
    'al wakrah': ['doha'],
  };

  static const Map<String, List<String>> _relatedPropertyTypes = {
    'studio': ['1bhk', '1 bhk', 'room', 'sharing', 'bed space'],
    '1bhk': ['studio', '2bhk', '1 bhk', 'apartment'],
    '2bhk': ['1bhk', '3bhk', '2 bhk', 'apartment', 'villa'],
    '3bhk': ['2bhk', '4bhk', 'villa', 'family'],
    'villa': ['3bhk', '4bhk', 'family', 'compound'],
    'sharing': ['studio', 'room', 'bed space', 'partition'],
    'room': ['sharing', 'studio', 'partition', 'bed space'],
    'apartment': ['1bhk', '2bhk', '3bhk', 'flat'],
  };

  static const List<String> _trackedAmenities = [
    'wifi',
    'ac',
    'parking',
    'gym',
    'pool',
  ];

  /// Calculates a full housing match result for a single listing.
  HousingMatchResult calculateMatch(
    Map<String, dynamic> listing,
    UserAIProfile profile, {
    String? preferredPropertyType,
  }) {
    final listingId = _extractListingId(listing);
    final price = _extractPrice(listing);
    final area = _extractArea(listing);
    final propertyType = _extractPropertyType(listing);
    final bedrooms = _extractBedrooms(listing);
    final amenities = _extractAmenities(listing);

    final breakdown = {
      'budget': _scoreBudgetMatch(price, profile),
      'location': _scoreLocationMatch(area, profile),
      'propertyType': _scorePropertyTypeMatch(
        propertyType,
        preferredPropertyType ?? _inferPreferredTypeFromInterests(profile),
      ),
      'familyStatus': _scoreFamilyStatusMatch(
        profile.familyStatus,
        propertyType,
        bedrooms,
      ),
      'amenities': _scoreAmenitiesMatch(amenities, profile),
    };

    final score =
        breakdown.values.fold<int>(0, (sum, s) => sum + s).clamp(0, 100);

    final withinBudget = _isWithinBudget(price, profile);
    final inPreferredArea = _isPreferredArea(area, profile);
    final isFamilyFriendly = _isFamilyFriendly(propertyType, bedrooms);
    final isNewListing = _isNewListing(listing);
    final isBestValue = _isBestValue(price, profile, amenities, score);

    final tags = _buildSmartTags(
      withinBudget: withinBudget,
      inPreferredArea: inPreferredArea,
      isFamilyFriendly: isFamilyFriendly,
      userIsFamily: profile.familyStatus.toLowerCase() == 'family',
      isBestValue: isBestValue,
      isNewListing: isNewListing,
    );

    final valueScore = _resolveValueScore(price, profile, amenities);
    final labelInfo = _resolveMatchLabel(score);

    final result = HousingMatchResult(
      listingId: listingId,
      matchScore: score,
      matchLabel: labelInfo.label,
      matchColor: labelInfo.color,
      explanation: '',
      tags: tags,
      valueScore: valueScore,
      breakdown: breakdown,
    );

    return HousingMatchResult(
      listingId: listingId,
      matchScore: score,
      matchLabel: labelInfo.label,
      matchColor: labelInfo.color,
      explanation: _generateExplanation(
        result,
        listing,
        profile,
        withinBudget: withinBudget,
        inPreferredArea: inPreferredArea,
        amenities: amenities,
      ),
      tags: tags,
      valueScore: valueScore,
      breakdown: breakdown,
    );
  }

  /// Ranks listings by match score descending.
  List<RankedHousingMatch> rankListings(
    List<Map<String, dynamic>> listings,
    UserAIProfile profile,
  ) {
    final preferredType = _inferPreferredPropertyType(
      listings,
      profile.viewedHousingIds,
    );

    final ranked = listings
        .map(
          (listing) => RankedHousingMatch(
            listing: listing,
            result: calculateMatch(
              listing,
              profile,
              preferredPropertyType: preferredType,
            ),
          ),
        )
        .toList()
      ..sort((a, b) => b.result.matchScore.compareTo(a.result.matchScore));

    return ranked;
  }

  // -------------------------------------------------------------------------
  // Scoring
  // -------------------------------------------------------------------------

  int _scoreBudgetMatch(num? price, UserAIProfile profile) {
    if (price == null) return 15;

    final minBudget = (profile.budgetRange['min'] ?? 0).toDouble();
    final maxBudget = (profile.budgetRange['max'] ?? 5000).toDouble();
    final p = price.toDouble();

    if (p >= minBudget && p <= maxBudget) return 35;
    if (p > maxBudget && p <= maxBudget * 1.1) return 25;
    if (p > maxBudget && p <= maxBudget * 1.2) return 15;
    if (p > maxBudget * 1.2) return 5;
    if (p < minBudget) return 20;
    return 5;
  }

  int _scoreLocationMatch(String area, UserAIProfile profile) {
    final listingArea = area.toLowerCase().trim();
    final preferred = profile.preferredArea.toLowerCase().trim();

    if (listingArea.isEmpty || preferred.isEmpty) return 8;

    if (listingArea == preferred) return 25;

    if (_sameCityGroup(listingArea, preferred)) return 15;

    if (_isNearbyCity(listingArea, preferred)) return 8;

    return 3;
  }

  int _scorePropertyTypeMatch(String listingType, String? preferredType) {
    if (preferredType == null || preferredType.isEmpty) return 12;

    final normalizedListing = _normalizePropertyType(listingType);
    final normalizedPreferred = _normalizePropertyType(preferredType);

    if (normalizedListing == normalizedPreferred) return 20;

    final related = _relatedPropertyTypes[normalizedPreferred] ?? [];
    if (related.contains(normalizedListing) ||
        (_relatedPropertyTypes[normalizedListing] ?? [])
            .contains(normalizedPreferred)) {
      return 12;
    }

    return 5;
  }

  int _scoreFamilyStatusMatch(
    String familyStatus,
    String propertyType,
    int bedrooms,
  ) {
    final status = familyStatus.toLowerCase().trim();
    final type = _normalizePropertyType(propertyType);
    final isStudioOrSharing =
        type == 'studio' || type == 'sharing' || type == 'room';
    final isLargeFamilyHome = bedrooms >= 3 || type == 'villa';
    final isMidSize = bedrooms >= 1 && bedrooms <= 2;

    switch (status) {
      case 'family':
        if (isLargeFamilyHome || bedrooms >= 3) return 10;
        if (isStudioOrSharing) return 2;
        return 6;
      case 'single':
        if (isStudioOrSharing) return 10;
        if (isLargeFamilyHome) return 5;
        return 7;
      case 'couple':
        if (isMidSize && !isLargeFamilyHome) return 10;
        if (isStudioOrSharing) return 8;
        return 5;
      default:
        return 6;
    }
  }

  int _scoreAmenitiesMatch(List<String> amenities, UserAIProfile profile) {
    if (amenities.isEmpty) return 0;

    final interests = profile.interests.map((i) => i.toLowerCase()).toSet();
    var points = 0;

    for (final amenity in amenities) {
      final normalized = amenity.toLowerCase();
      final matched = interests.any(
        (interest) =>
            interest.contains(normalized) || normalized.contains(interest),
      );
      if (matched || interests.isEmpty) {
        points += 2;
      }
    }

    return points.clamp(0, 10);
  }

  // -------------------------------------------------------------------------
  // Labels, tags, value score
  // -------------------------------------------------------------------------

  ({String label, Color color}) _resolveMatchLabel(int score) {
    if (score >= 90) {
      return (label: 'Perfect Match 🎯', color: _perfectColor);
    }
    if (score >= 80) {
      return (label: 'Highly Recommended ⭐', color: _highlyRecommendedColor);
    }
    if (score >= 70) {
      return (label: 'AI Recommended 🤖', color: _aiRecommendedColor);
    }
    if (score >= 60) {
      return (label: 'Good Option 👍', color: _goodOptionColor);
    }
    return (label: 'Consider', color: _considerColor);
  }

  List<String> _buildSmartTags({
    required bool withinBudget,
    required bool inPreferredArea,
    required bool isFamilyFriendly,
    required bool userIsFamily,
    required bool isBestValue,
    required bool isNewListing,
  }) {
    final tags = <String>[];
    if (withinBudget) tags.add('Within Budget ✓');
    if (inPreferredArea) tags.add('Near You ✓');
    if (isFamilyFriendly && userIsFamily) tags.add('Family Friendly ✓');
    if (isBestValue) tags.add('Best Value 🏆');
    if (isNewListing) tags.add('Just Listed 🆕');
    return tags;
  }

  String _resolveValueScore(
    num? price,
    UserAIProfile profile,
    List<String> amenities,
  ) {
    if (price == null) return 'Good Value';

    final maxBudget = (profile.budgetRange['max'] ?? 5000).toDouble();
    final p = price.toDouble();
    final amenityCount = amenities.length;

    if (p <= maxBudget * 0.75 && amenityCount >= 3) return 'Best Value';
    if (p > maxBudget * 1.15 || amenityCount >= 4 && p > maxBudget) {
      return 'Premium';
    }
    return 'Good Value';
  }

  String _generateExplanation(
    HousingMatchResult result,
    Map<String, dynamic> listing,
    UserAIProfile profile, {
    required bool withinBudget,
    required bool inPreferredArea,
    required List<String> amenities,
  }) {
    final score = result.matchScore;
    final area = _extractArea(listing);
    final price = _extractPrice(listing);
    final priceLabel = price != null ? '${price.round()} QR/month' : 'your budget';
    final topAmenity = amenities.isNotEmpty ? amenities.first : 'key amenities';
    final matchCount = _countPreferenceMatches(
      withinBudget: withinBudget,
      inPreferredArea: inPreferredArea,
      amenities: amenities,
      profile: profile,
      listing: listing,
    );
    final topMatches = _topMatchPhrases(
      withinBudget: withinBudget,
      inPreferredArea: inPreferredArea,
      amenities: amenities,
    );

    if (score >= 95) {
      return 'Perfect match! This property is within your budget in your '
          'preferred area with all key amenities.';
    }
    if (score >= 80) {
      return 'Highly recommended. Matches $matchCount of your key preferences '
          'including $topMatches.';
    }
    if (score >= 70) {
      return 'Good option in $area. $priceLabel fits your budget and '
          'includes $topAmenity.';
    }

    final relevantPoint = withinBudget
        ? 'Within your budget range.'
        : inPreferredArea
            ? 'Located in your preferred area.'
            : amenities.isNotEmpty
                ? 'Includes $topAmenity.'
                : 'Worth exploring for your housing search.';

    return 'Available in $area at $priceLabel. $relevantPoint';
  }

  // -------------------------------------------------------------------------
  // Inference helpers
  // -------------------------------------------------------------------------

  String? _inferPreferredPropertyType(
    List<Map<String, dynamic>> listings,
    List<String> viewedIds,
  ) {
    if (viewedIds.isEmpty) return null;

    final typeCounts = <String, int>{};
    for (final listing in listings) {
      final id = _extractListingId(listing);
      if (!viewedIds.contains(id)) continue;
      final type = _normalizePropertyType(_extractPropertyType(listing));
      if (type.isEmpty) continue;
      typeCounts[type] = (typeCounts[type] ?? 0) + 1;
    }

    if (typeCounts.isEmpty) return null;

    return typeCounts.entries
        .reduce((a, b) => a.value >= b.value ? a : b)
        .key;
  }

  String? _inferPreferredTypeFromInterests(UserAIProfile profile) {
    for (final interest in profile.interests) {
      final lower = interest.toLowerCase();
      for (final type in [
        'studio',
        '1bhk',
        '2bhk',
        '3bhk',
        'villa',
        'sharing',
        'apartment',
      ]) {
        if (lower.contains(type)) return type;
      }
    }
    return null;
  }

  bool _isWithinBudget(num? price, UserAIProfile profile) {
    if (price == null) return false;
    final minBudget = (profile.budgetRange['min'] ?? 0).toDouble();
    final maxBudget = (profile.budgetRange['max'] ?? 5000).toDouble();
    final p = price.toDouble();
    return p >= minBudget && p <= maxBudget;
  }

  bool _isPreferredArea(String area, UserAIProfile profile) {
    if (area.isEmpty || profile.preferredArea.isEmpty) return false;
    return area.toLowerCase().trim() == profile.preferredArea.toLowerCase().trim();
  }

  bool _isFamilyFriendly(String propertyType, int bedrooms) {
    final type = _normalizePropertyType(propertyType);
    return bedrooms >= 3 || type == 'villa' || type.contains('family');
  }

  bool _isNewListing(Map<String, dynamic> listing) {
    final daysAgo = listing['daysAgo'];
    if (daysAgo is num) return daysAgo < 1;

    final postedAt = listing['postedAt'] ?? listing['createdAt'];
    if (postedAt is DateTime) {
      return DateTime.now().difference(postedAt).inHours < 24;
    }
    if (postedAt is String) {
      final parsed = DateTime.tryParse(postedAt);
      if (parsed != null) {
        return DateTime.now().difference(parsed).inHours < 24;
      }
    }

    final isNew = listing['isNew'];
    if (isNew is bool) return isNew;

    return false;
  }

  bool _isBestValue(
    num? price,
    UserAIProfile profile,
    List<String> amenities,
    int score,
  ) {
    if (price == null) return false;
    final maxBudget = (profile.budgetRange['max'] ?? 5000).toDouble();
    return price <= maxBudget * 0.8 &&
        amenities.length >= 3 &&
        score >= 70;
  }

  int _countPreferenceMatches({
    required bool withinBudget,
    required bool inPreferredArea,
    required List<String> amenities,
    required UserAIProfile profile,
    required Map<String, dynamic> listing,
  }) {
    var count = 0;
    if (withinBudget) count++;
    if (inPreferredArea) count++;
    if (amenities.isNotEmpty) count++;
    if (_scoreFamilyStatusMatch(
          profile.familyStatus,
          _extractPropertyType(listing),
          _extractBedrooms(listing),
        ) >=
        8) {
      count++;
    }
    return count;
  }

  String _topMatchPhrases({
    required bool withinBudget,
    required bool inPreferredArea,
    required List<String> amenities,
  }) {
    final phrases = <String>[];
    if (withinBudget) phrases.add('budget');
    if (inPreferredArea) phrases.add('location');
    if (amenities.isNotEmpty) phrases.add(amenities.first);
    if (phrases.isEmpty) return 'your search criteria';
    return phrases.take(2).join(' and ');
  }

  // -------------------------------------------------------------------------
  // Extraction helpers
  // -------------------------------------------------------------------------

  String _extractListingId(Map<String, dynamic> listing) {
    for (final key in ['id', 'listingId', '_id']) {
      final value = listing[key];
      if (value != null && value.toString().isNotEmpty) {
        return value.toString();
      }
    }
    return '';
  }

  num? _extractPrice(Map<String, dynamic> listing) {
    for (final key in ['pricePerMonth', 'price', 'rent', 'monthlyRent']) {
      final value = listing[key];
      if (value is num) return value;
      if (value is String) {
        final parsed = num.tryParse(value.replaceAll(RegExp(r'[^\d.]'), ''));
        if (parsed != null) return parsed;
      }
    }
    return null;
  }

  String _extractArea(Map<String, dynamic> listing) {
    for (final key in ['area', 'location', 'city', 'preferredArea']) {
      final value = listing[key];
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
    }
    return '';
  }

  String _extractPropertyType(Map<String, dynamic> listing) {
    for (final key in ['type', 'propertyType', 'listingType', 'roomType']) {
      final value = listing[key];
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
    }

    final bedrooms = _extractBedrooms(listing);
    if (bedrooms == 0) return 'studio';
    if (bedrooms == 1) return '1bhk';
    if (bedrooms == 2) return '2bhk';
    if (bedrooms >= 3) return '3bhk';

    return '';
  }

  int _extractBedrooms(Map<String, dynamic> listing) {
    final bedrooms = listing['bedrooms'] ?? listing['bedroomCount'];
    if (bedrooms is num) return bedrooms.round();
    if (bedrooms is String) return int.tryParse(bedrooms) ?? 1;
    return 1;
  }

  List<String> _extractAmenities(Map<String, dynamic> listing) {
    final amenities = listing['amenities'];
    if (amenities is List) {
      return amenities.map((e) => e.toString()).where((e) => e.isNotEmpty).toList();
    }

    final found = <String>[];
    final blob = [
      listing['description'],
      listing['title'],
      ...(amenities is String ? [amenities] : []),
    ].whereType<String>().join(' ').toLowerCase();

    for (final amenity in _trackedAmenities) {
      if (blob.contains(amenity)) found.add(amenity);
    }

    return found;
  }

  String _normalizePropertyType(String type) {
    final lower = type.toLowerCase().trim();
    if (lower.contains('studio')) return 'studio';
    if (lower.contains('sharing') || lower.contains('bed space')) return 'sharing';
    if (lower.contains('villa')) return 'villa';
    if (lower.contains('3') && lower.contains('bhk')) return '3bhk';
    if (lower.contains('2') && lower.contains('bhk')) return '2bhk';
    if (lower.contains('1') && lower.contains('bhk')) return '1bhk';
    if (lower.contains('apartment') || lower.contains('flat')) return 'apartment';
    if (lower.contains('room')) return 'room';
    return lower.replaceAll(' ', '');
  }

  bool _sameCityGroup(String areaA, String areaB) {
    for (final group in _cityGroups.values) {
      final aIn = group.any((g) => areaA.contains(g) || g.contains(areaA));
      final bIn = group.any((g) => areaB.contains(g) || g.contains(areaB));
      if (aIn && bIn) return true;
    }
    return false;
  }

  bool _isNearbyCity(String areaA, String areaB) {
    for (final entry in _nearbyCityPairs.entries) {
      final city = entry.key;
      final nearby = entry.value;
      final aInCity = areaA.contains(city) || city.contains(areaA);
      final bInCity = areaB.contains(city) || city.contains(areaB);
      final aNearby = nearby.any((n) => areaA.contains(n) || n.contains(areaA));
      final bNearby = nearby.any((n) => areaB.contains(n) || n.contains(areaB));
      if ((aInCity && bNearby) || (bInCity && aNearby)) return true;
    }
    return false;
  }

  /// Tag color lookup for UI layers.
  Color tagColor(String tag) {
    if (tag.contains('Within Budget')) return _tagBudgetGreen;
    if (tag.contains('Near You')) return _tagNearYouCyan;
    if (tag.contains('Family Friendly')) return _tagFamilyBlue;
    if (tag.contains('Best Value')) return _tagBestValueGold;
    if (tag.contains('Just Listed')) return _tagJustListedAmber;
    return _considerColor;
  }
}

// ---------------------------------------------------------------------------
// Riverpod
// ---------------------------------------------------------------------------

final housingMatchServiceProvider = Provider<HousingMatchService>((ref) {
  return HousingMatchService();
});
