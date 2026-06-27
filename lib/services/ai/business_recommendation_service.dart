import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/services/ai/user_profile_ai_service.dart';

// ---------------------------------------------------------------------------
// Models
// ---------------------------------------------------------------------------

class BusinessRecommendation {
  const BusinessRecommendation({
    required this.businessId,
    required this.recommendationScore,
    required this.recommendationReason,
    required this.tags,
    required this.isPersonalized,
    required this.isTrending,
    required this.isNearby,
    this.breakdown,
  });

  final String businessId;
  final double recommendationScore;
  final String recommendationReason;
  final List<String> tags;
  final bool isPersonalized;
  final bool isTrending;
  final bool isNearby;
  final Map<String, double>? breakdown;

  Map<String, dynamic> toJson() => {
        'businessId': businessId,
        'recommendationScore': recommendationScore,
        'recommendationReason': recommendationReason,
        'tags': tags,
        'isPersonalized': isPersonalized,
        'isTrending': isTrending,
        'isNearby': isNearby,
        if (breakdown != null) 'breakdown': breakdown,
      };
}

class ScoredBusinessRecommendation {
  const ScoredBusinessRecommendation({
    required this.business,
    required this.recommendation,
  });

  final Map<String, dynamic> business;
  final BusinessRecommendation recommendation;
}

class BusinessRecommendationInput {
  const BusinessRecommendationInput({
    required this.businesses,
    required this.profile,
  });

  final List<Map<String, dynamic>> businesses;
  final UserAIProfile profile;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BusinessRecommendationInput &&
          _listEquals(businesses, other.businesses) &&
          profile.uid == other.profile.uid &&
          profile.lastUpdated == other.profile.lastUpdated;

  @override
  int get hashCode => Object.hash(
        businesses.length,
        profile.uid,
        profile.lastUpdated,
      );

  static bool _listEquals(
    List<Map<String, dynamic>> a,
    List<Map<String, dynamic>> b,
  ) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i]['id']?.toString() != b[i]['id']?.toString()) return false;
    }
    return true;
  }
}

// ---------------------------------------------------------------------------
// Service
// ---------------------------------------------------------------------------

class BusinessRecommendationService {
  static const Map<String, List<String>> _cityGroups = {
    'doha': [
      'doha',
      'west bay',
      'the pearl',
      'lusail',
      'al sadd',
      'industrial area',
    ],
    'al khor': ['al khor', 'ras laffan', 'al dhakhira'],
    'al wakrah': ['al wakrah', 'wakrah'],
  };

  static const Map<String, List<String>> _nationalityCategoryBoosts = {
    'indian': [
      'indian restaurant',
      'indian',
      'pakistani restaurant',
      'pakistani',
      'grocery',
      'supermarket',
      'south asian',
      'halal',
    ],
    'pakistani': [
      'pakistani restaurant',
      'pakistani',
      'indian restaurant',
      'indian',
      'halal',
      'butcher',
      'grocery',
    ],
    'filipino': [
      'filipino',
      'asian',
      'restaurant',
      'community',
      'grocery',
      'bakery',
    ],
    'bangladeshi': [
      'bangladeshi',
      'indian',
      'halal',
      'grocery',
      'restaurant',
    ],
    'nepali': [
      'nepali',
      'indian',
      'restaurant',
      'grocery',
    ],
    'kenyan': [
      'african',
      'restaurant',
      'grocery',
      'community',
    ],
  };

  /// Scores a business against a user profile (0–100).
  double scoreBusiness(
    Map<String, dynamic> business,
    UserAIProfile profile,
  ) {
    final breakdown = _calculateBreakdown(business, profile);
    final total = breakdown.values.fold<double>(0, (sum, score) => sum + score);
    return total.clamp(0, 100).toDouble();
  }

  /// Builds a full recommendation with reason, tags, and flags.
  BusinessRecommendation recommendBusiness(
    Map<String, dynamic> business,
    UserAIProfile profile, {
    bool isPersonalized = false,
    bool forceTrending = false,
  }) {
    final businessId = _extractBusinessId(business);
    final breakdown = _calculateBreakdown(business, profile);
    final score = breakdown.values
        .fold<double>(0, (sum, s) => sum + s)
        .clamp(0, 100)
        .toDouble();

    final area = _extractArea(business);
    final isNearby = _isSameArea(area, profile.preferredArea);
    final weeklyViews = _extractViewCount(business);
    final isTrending = forceTrending || weeklyViews >= _trendingThreshold(business);

    final rec = BusinessRecommendation(
      businessId: businessId,
      recommendationScore: score,
      recommendationReason: '',
      tags: _buildTags(business, profile, breakdown, isNearby, isTrending),
      isPersonalized: isPersonalized,
      isTrending: isTrending,
      isNearby: isNearby,
      breakdown: breakdown,
    );

    return BusinessRecommendation(
      businessId: businessId,
      recommendationScore: score,
      recommendationReason: generateReason(rec, profile, business),
      tags: rec.tags,
      isPersonalized: isPersonalized,
      isTrending: isTrending,
      isNearby: isNearby,
      breakdown: breakdown,
    );
  }

  /// Generates a human-readable recommendation reason.
  String generateReason(
    BusinessRecommendation rec,
    UserAIProfile profile, [
    Map<String, dynamic>? business,
  ]) {
    final breakdown = rec.breakdown ?? {};
    final languageScore = breakdown['language'] ?? 0;
    final ratingScore = breakdown['rating'] ?? 0;
    final distanceScore = breakdown['distance'] ?? 0;
    final nationalityScore = breakdown['nationality'] ?? 0;
    final interestScore = breakdown['interest'] ?? 0;

    final language = _displayLanguage(profile.language);
    final nationality = _displayNationality(profile.nationality);
    final area = business != null
        ? _extractArea(business)
        : profile.preferredArea;
    final rating = business != null ? _extractRating(business) : 0.0;
    final category = business != null ? _primaryCategory(business) : 'local services';

    if (rec.isTrending && rec.recommendationScore < 75) {
      return 'Trending this week among expats in $area.';
    }

    if (languageScore >= 18 && nationality.isNotEmpty) {
      return 'Highly recommended — staff speak $language and it\'s popular '
          'among $nationality expats.';
    }

    if (ratingScore >= 20 && distanceScore >= 15 && rating >= 4.5) {
      final ratingLabel = rating.toStringAsFixed(1);
      return 'Top-rated business near you. $ratingLabel★ with excellent '
          'community reviews.';
    }

    if (interestScore >= 10) {
      return 'Matches your interest in $category. Frequently visited by users '
          'with similar profiles.';
    }

    if (nationalityScore >= 12 && nationality.isNotEmpty) {
      return 'Popular with $nationality expats in $area. Great fit for your '
          'community preferences.';
    }

    if (rec.isNearby) {
      return 'Conveniently located in $area, close to your preferred neighbourhood.';
    }

    return 'Recommended based on your Raabta profile and community ratings.';
  }

  /// Returns top 5 personalized business recommendations.
  List<ScoredBusinessRecommendation> getRecommendedForYou(
    List<Map<String, dynamic>> businesses,
    UserAIProfile profile,
  ) {
    final scored = businesses
        .map(
          (business) => ScoredBusinessRecommendation(
            business: business,
            recommendation: recommendBusiness(
              business,
              profile,
              isPersonalized: true,
            ),
          ),
        )
        .toList()
      ..sort(
        (a, b) => b.recommendation.recommendationScore
            .compareTo(a.recommendation.recommendationScore),
      );

    return scored.take(5).toList();
  }

  /// Returns businesses trending by weekly view count.
  List<ScoredBusinessRecommendation> getTrending(
    List<Map<String, dynamic>> businesses, [
    UserAIProfile? profile,
  ]) {
    final fallbackProfile = profile ?? UserAIProfile.defaultProfile('guest');

    final scored = businesses
        .map(
          (business) => ScoredBusinessRecommendation(
            business: business,
            recommendation: recommendBusiness(
              business,
              fallbackProfile,
              forceTrending: true,
            ),
          ),
        )
        .toList()
      ..sort(
        (a, b) =>
            _extractViewCount(b.business).compareTo(_extractViewCount(a.business)),
      );

    return scored;
  }

  /// Returns businesses in preferred area sorted by rating.
  List<ScoredBusinessRecommendation> getNearby(
    List<Map<String, dynamic>> businesses,
    UserAIProfile profile,
  ) {
    final preferred = profile.preferredArea.toLowerCase().trim();

    final nearby = businesses.where((business) {
      final area = _extractArea(business).toLowerCase().trim();
      if (area.isEmpty || preferred.isEmpty) return false;
      return area == preferred || _sameCityGroup(area, preferred);
    }).toList();

    final scored = nearby
        .map(
          (business) => ScoredBusinessRecommendation(
            business: business,
            recommendation: recommendBusiness(business, profile),
          ),
        )
        .toList()
      ..sort(
        (a, b) =>
            _extractRating(b.business).compareTo(_extractRating(a.business)),
      );

    return scored;
  }

  // -------------------------------------------------------------------------
  // Breakdown
  // -------------------------------------------------------------------------

  Map<String, double> _calculateBreakdown(
    Map<String, dynamic> business,
    UserAIProfile profile,
  ) {
    return {
      'distance': _scoreDistance(business, profile).toDouble(),
      'rating': _scoreRating(business).toDouble(),
      'language': _scoreLanguage(business, profile).toDouble(),
      'nationality': _scoreNationality(business, profile).toDouble(),
      'interest': _scoreInterest(business, profile).toDouble(),
    };
  }

  int _scoreDistance(Map<String, dynamic> business, UserAIProfile profile) {
    final area = _extractArea(business).toLowerCase().trim();
    final preferred = profile.preferredArea.toLowerCase().trim();

    if (area.isEmpty || preferred.isEmpty) return 8;

    if (area == preferred) return 25;

    if (_sameCityGroup(area, preferred)) return 15;

    return 5;
  }

  int _scoreRating(Map<String, dynamic> business) {
    final rating = _extractRating(business);
    if (rating >= 4.8) return 25;
    if (rating >= 4.5) return 20;
    if (rating >= 4.0) return 15;
    if (rating >= 3.5) return 10;
    return 5;
  }

  int _scoreLanguage(Map<String, dynamic> business, UserAIProfile profile) {
    final languages = _extractLanguages(business);
    if (languages.isEmpty) return 10;

    final profileLang = profile.language.toLowerCase().trim();
    final normalized = languages.map((l) => l.toLowerCase().trim()).toList();

    if (normalized.any(
      (lang) => lang.contains(profileLang) || profileLang.contains(lang),
    )) {
      return 20;
    }

    if (normalized.any((lang) => lang.contains('english') || lang == 'en')) {
      return 10;
    }

    return 2;
  }

  int _scoreNationality(Map<String, dynamic> business, UserAIProfile profile) {
    final nationality = profile.nationality.toLowerCase().trim();
    if (nationality.isEmpty) return 5;

    final key = _nationalityKey(nationality);
    final boosts = _nationalityCategoryBoosts[key];
    if (boosts == null) return 5;

    final categories = _extractCategories(business);
    final blob = categories.join(' ').toLowerCase();

    var matches = 0;
    for (final boost in boosts) {
      if (blob.contains(boost)) matches++;
    }

    if (matches >= 3) return 15;
    if (matches == 2) return 12;
    if (matches == 1) return 8;
    return 3;
  }

  int _scoreInterest(Map<String, dynamic> business, UserAIProfile profile) {
    if (profile.interests.isEmpty) return 0;

    final categories = _extractCategories(business);
    final blob = categories.join(' ').toLowerCase();
    var points = 0;

    for (final interest in profile.interests) {
      final normalized = interest.toLowerCase().trim();
      if (normalized.isEmpty) continue;
      if (blob.contains(normalized) || normalized.contains(blob)) {
        points += 5;
      }
    }

    return points.clamp(0, 15);
  }

  // -------------------------------------------------------------------------
  // Tags & helpers
  // -------------------------------------------------------------------------

  List<String> _buildTags(
    Map<String, dynamic> business,
    UserAIProfile profile,
    Map<String, double> breakdown,
    bool isNearby,
    bool isTrending,
  ) {
    final tags = <String>[];

    if (isNearby) tags.add('Near You');
    if (isTrending) tags.add('Trending');
    if ((breakdown['rating'] ?? 0) >= 20) tags.add('Top Rated');
    if ((breakdown['language'] ?? 0) >= 18) {
      tags.add('Speaks ${_displayLanguage(profile.language)}');
    }
    if ((breakdown['nationality'] ?? 0) >= 12 &&
        profile.nationality.isNotEmpty) {
      tags.add('Popular with ${_displayNationality(profile.nationality)}');
    }
    if ((breakdown['interest'] ?? 0) >= 10) {
      tags.add('Matches Your Interests');
    }

    final category = _primaryCategory(business);
    if (category.isNotEmpty && !tags.contains('Matches Your Interests')) {
      tags.add(category);
    }

    return tags;
  }

  int _trendingThreshold(Map<String, dynamic> business) {
    final views = _extractViewCount(business);
    if (views <= 0) return 999999;
    return (views * 0.6).round().clamp(20, 500);
  }

  String _nationalityKey(String nationality) {
    final lower = nationality.toLowerCase();
    if (lower.contains('india')) return 'indian';
    if (lower.contains('pakistan')) return 'pakistani';
    if (lower.contains('filipino') || lower.contains('philippine')) {
      return 'filipino';
    }
    if (lower.contains('bangladesh')) return 'bangladeshi';
    if (lower.contains('nepal')) return 'nepali';
    if (lower.contains('kenya')) return 'kenyan';
    return lower;
  }

  String _displayLanguage(String language) {
    const map = {
      'en': 'English',
      'hi': 'Hindi',
      'ur': 'Urdu',
      'ar': 'Arabic',
      'tl': 'Tagalog',
      'bn': 'Bengali',
    };
    return map[language.toLowerCase()] ?? language;
  }

  String _displayNationality(String nationality) {
    if (nationality.isEmpty) return '';
    return nationality.replaceAll(RegExp(r'[^\w\s]'), '').trim();
  }

  bool _isSameArea(String area, String preferred) {
    if (area.isEmpty || preferred.isEmpty) return false;
    return area.toLowerCase().trim() == preferred.toLowerCase().trim();
  }

  bool _sameCityGroup(String areaA, String areaB) {
    for (final group in _cityGroups.values) {
      final aIn = group.any((g) => areaA.contains(g) || g.contains(areaA));
      final bIn = group.any((g) => areaB.contains(g) || g.contains(areaB));
      if (aIn && bIn) return true;
    }
    return false;
  }

  String _extractBusinessId(Map<String, dynamic> business) {
    for (final key in ['id', 'businessId', '_id']) {
      final value = business[key];
      if (value != null && value.toString().isNotEmpty) {
        return value.toString();
      }
    }
    return '';
  }

  String _extractArea(Map<String, dynamic> business) {
    for (final key in ['area', 'location', 'city', 'preferredArea']) {
      final value = business[key];
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
    }
    return '';
  }

  double _extractRating(Map<String, dynamic> business) {
    final rating = business['rating'];
    if (rating is num) return rating.toDouble();
    if (rating is String) return double.tryParse(rating) ?? 0;
    return 0;
  }

  int _extractViewCount(Map<String, dynamic> business) {
    for (final key in ['viewCount', 'weeklyViews', 'views']) {
      final value = business[key];
      if (value is num) return value.round();
      if (value is String) return int.tryParse(value) ?? 0;
    }
    return 0;
  }

  List<String> _extractLanguages(Map<String, dynamic> business) {
    final languages = business['languages'];
    if (languages is List) {
      return languages.map((e) => e.toString()).where((e) => e.isNotEmpty).toList();
    }
    if (languages is String && languages.isNotEmpty) {
      return languages.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
    }
    return const [];
  }

  List<String> _extractCategories(Map<String, dynamic> business) {
    final categories = business['categories'];
    if (categories is List) {
      return categories.map((e) => e.toString()).where((e) => e.isNotEmpty).toList();
    }

    final items = <String>[];
    for (final key in ['category', 'cuisine', 'speciality', 'specialty', 'type']) {
      final value = business[key];
      if (value is String && value.trim().isNotEmpty) {
        items.add(value.trim());
      }
    }
    return items;
  }

  String _primaryCategory(Map<String, dynamic> business) {
    final categories = _extractCategories(business);
    return categories.isNotEmpty ? categories.first : '';
  }
}

// ---------------------------------------------------------------------------
// Riverpod
// ---------------------------------------------------------------------------

final businessRecommendationServiceProvider =
    Provider<BusinessRecommendationService>((ref) {
  return BusinessRecommendationService();
});

final recommendedForYouProvider = Provider.family<
    List<ScoredBusinessRecommendation>,
    BusinessRecommendationInput>((ref, input) {
  final service = ref.watch(businessRecommendationServiceProvider);
  return service.getRecommendedForYou(input.businesses, input.profile);
});

final trendingBusinessesProvider = Provider.family<
    List<ScoredBusinessRecommendation>,
    List<Map<String, dynamic>>>((ref, businesses) {
  final service = ref.watch(businessRecommendationServiceProvider);
  return service.getTrending(businesses);
});

final nearbyBusinessesProvider = Provider.family<
    List<ScoredBusinessRecommendation>,
    BusinessRecommendationInput>((ref, input) {
  final service = ref.watch(businessRecommendationServiceProvider);
  return service.getNearby(input.businesses, input.profile);
});
