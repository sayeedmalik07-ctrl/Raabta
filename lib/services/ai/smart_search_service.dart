import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/services/ai/user_profile_ai_service.dart';

// ---------------------------------------------------------------------------
// Models
// ---------------------------------------------------------------------------

enum SearchIntent {
  findJob,
  findHousing,
  findBusiness,
  findDoctor,
  checkRate,
  visaQuestion,
  communityQuestion,
  unknown,
}

class SmartSearchResult {
  const SmartSearchResult({
    required this.intent,
    required this.filters,
    required this.displayQuery,
    required this.confidence,
  });

  final SearchIntent intent;
  final Map<String, dynamic> filters;
  final String displayQuery;
  final double confidence;

  Map<String, dynamic> toJson() => {
        'intent': intent.name,
        'filters': filters,
        'displayQuery': displayQuery,
        'confidence': confidence,
      };

  factory SmartSearchResult.fromJson(Map<String, dynamic> json) {
    return SmartSearchResult(
      intent: SearchIntent.values.firstWhere(
        (i) => i.name == json['intent'],
        orElse: () => SearchIntent.unknown,
      ),
      filters: Map<String, dynamic>.from(json['filters'] as Map? ?? {}),
      displayQuery: json['displayQuery'] as String? ?? '',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0,
    );
  }
}

// ---------------------------------------------------------------------------
// Service
// ---------------------------------------------------------------------------

class SmartSearchService {
  static const List<String> _jobKeywords = [
    'job',
    'jobs',
    'work',
    'hiring',
    'vacancy',
    'vacancies',
    'position',
    'positions',
    'career',
    'employment',
    'officer',
    'manager',
    'engineer',
    'driver',
    'supervisor',
    'technician',
    'nurse',
    'teacher',
  ];

  static const List<String> _housingKeywords = [
    'room',
    'flat',
    'apartment',
    'villa',
    'rent',
    'accommodation',
    'housing',
    'sharing',
    'studio',
    'bhk',
    '1bhk',
    '2bhk',
    '3bhk',
    'bedroom',
    'bedrooms',
    'partition',
  ];

  static const List<String> _businessKeywords = [
    'restaurant',
    'salon',
    'gym',
    'shop',
    'clinic',
    'service',
    'repair',
    'grocery',
    'indian food',
    'pakistani food',
    'cafe',
    'bakery',
    'store',
    'market',
  ];

  static const List<String> _doctorKeywords = [
    'doctor',
    'physician',
    'dentist',
    'pediatrician',
    'hospital',
    'medical',
    'healthcare',
    'clinic',
  ];

  static const List<String> _rateKeywords = [
    'rate',
    'rates',
    'exchange',
    'inr',
    'pkr',
    'bdt',
    'npr',
    'php',
    'transfer',
    'send money',
    'remittance',
    'qr',
  ];

  static const List<String> _visaKeywords = [
    'visa',
    'iqama',
    'qid',
    'permit',
    'residency',
    'sponsor',
    'exit',
    'renewal',
    'work permit',
  ];

  static const List<String> _communityKeywords = [
    'community',
    'group',
    'event',
    'meetup',
    'forum',
    'ask',
    'question',
    'discussion',
    'expat',
  ];

  static const List<String> _qatarAreas = [
    'Al Khor',
    'Doha',
    'Lusail',
    'The Pearl',
    'Al Wakrah',
    'Mesaieed',
    'Ras Laffan',
    'Madinat Khalifa',
    'West Bay',
    'Old Airport',
    'Industrial Area',
    'Al Duhail',
  ];

  static const Map<String, String> _cuisineMap = {
    'indian': 'Indian',
    'pakistani': 'Pakistani',
    'filipino': 'Filipino',
    'bangladeshi': 'Bangladeshi',
    'nepali': 'Nepali',
    'arabic': 'Arabic',
    'chinese': 'Chinese',
    'italian': 'Italian',
  };

  static const Map<String, String> _jobCategoryMap = {
    'safety officer': 'HSE/Safety',
    'hse officer': 'HSE/Safety',
    'safety manager': 'HSE/Safety',
    'hse': 'HSE/Safety',
    'nebosh': 'HSE/Safety',
    'engineer': 'Engineering',
    'driver': 'Transport',
    'nurse': 'Healthcare',
    'teacher': 'Education',
    'accountant': 'Finance',
    'chef': 'Hospitality',
  };

  static const List<String> _baseSuggestions = [
    'HSE Officer jobs in Ras Laffan',
    'Rooms in Al Khor under QAR 1500',
    'Best Indian restaurants in Doha',
    'INR exchange rate today',
    'Iqama renewal requirements',
    'Family friendly 2BHK apartment Doha',
    'Safety Manager jobs Doha',
    'Rooms near Industrial Area Al Khor under 2000',
    'Pakistani restaurants near me',
    'Find a room in Lusail under 2000 QR',
    'Engineer jobs in West Bay',
    'How to renew QID in Qatar',
  ];

  /// Parses a natural language query into structured search filters.
  SmartSearchResult parseQuery(String query, {UserAIProfile? profile}) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      return const SmartSearchResult(
        intent: SearchIntent.unknown,
        filters: {},
        displayQuery: '',
        confidence: 0,
      );
    }

    final lower = trimmed.toLowerCase();
    final intentScores = _scoreIntents(lower);
    final intent = _resolveIntent(intentScores);
    final confidence = _resolveConfidence(intentScores, intent);

    final filters = <String, dynamic>{};

    final area = _extractArea(trimmed);
    if (area != null) filters['area'] = area;

    if (_containsNearMe(lower)) {
      filters['nearMe'] = true;
      if (profile != null && profile.preferredArea.isNotEmpty) {
        filters['area'] ??= profile.preferredArea;
      }
    }

    final priceFilters = _extractPriceFilters(lower);
    filters.addAll(priceFilters);

    switch (intent) {
      case SearchIntent.findJob:
        filters.addAll(_extractJobFilters(trimmed, lower));
      case SearchIntent.findHousing:
        filters.addAll(_extractHousingFilters(trimmed, lower));
      case SearchIntent.findBusiness:
        filters.addAll(_extractBusinessFilters(trimmed, lower));
      case SearchIntent.findDoctor:
        filters.addAll(_extractDoctorFilters(trimmed, lower));
      case SearchIntent.checkRate:
        filters.addAll(_extractRateFilters(lower));
      case SearchIntent.visaQuestion:
        filters.addAll(_extractVisaFilters(trimmed, lower));
      case SearchIntent.communityQuestion:
        filters['query'] = trimmed;
      case SearchIntent.unknown:
        filters['query'] = trimmed;
    }

    if (_containsBest(lower) &&
        (intent == SearchIntent.findBusiness || intent == SearchIntent.findDoctor)) {
      filters['sortBy'] = 'rating';
    }

    return SmartSearchResult(
      intent: intent,
      filters: filters,
      displayQuery: trimmed,
      confidence: confidence,
    );
  }

  /// Returns up to 5 smart query suggestions.
  List<String> getSuggestions(String partialQuery, [UserAIProfile? profile]) {
    final partial = partialQuery.trim().toLowerCase();
    final suggestions = <String>{};

    if (profile != null) {
      for (final template in _profileSuggestions(profile)) {
        if (partial.isEmpty || template.toLowerCase().contains(partial)) {
          suggestions.add(template);
        }
      }

      for (final history in profile.searchHistory.take(10)) {
        if (partial.isEmpty || history.toLowerCase().contains(partial)) {
          suggestions.add(history);
        }
      }
    }

    for (final base in _baseSuggestions) {
      if (partial.isEmpty || base.toLowerCase().contains(partial)) {
        suggestions.add(base);
      }
    }

    if (partial.isNotEmpty) {
      final parsed = parseQuery(partialQuery, profile: profile);
      suggestions.add(_buildSuggestionFromResult(parsed, profile));
    }

    return suggestions.take(5).toList();
  }

  // -------------------------------------------------------------------------
  // Intent detection
  // -------------------------------------------------------------------------

  Map<SearchIntent, int> _scoreIntents(String lower) {
    return {
      SearchIntent.findJob: _keywordScore(lower, _jobKeywords),
      SearchIntent.findHousing: _keywordScore(lower, _housingKeywords),
      SearchIntent.findBusiness: _keywordScore(lower, _businessKeywords),
      SearchIntent.findDoctor: _keywordScore(lower, _doctorKeywords),
      SearchIntent.checkRate: _keywordScore(lower, _rateKeywords),
      SearchIntent.visaQuestion: _keywordScore(lower, _visaKeywords),
      SearchIntent.communityQuestion: _keywordScore(lower, _communityKeywords),
    };
  }

  int _keywordScore(String lower, List<String> keywords) {
    var score = 0;
    for (final keyword in keywords) {
      if (lower.contains(keyword)) score++;
    }
    return score;
  }

  SearchIntent _resolveIntent(Map<SearchIntent, int> scores) {
    var bestIntent = SearchIntent.unknown;
    var bestScore = 0;

    for (final entry in scores.entries) {
      if (entry.value > bestScore) {
        bestScore = entry.value;
        bestIntent = entry.key;
      }
    }

    if (bestScore == 0) return SearchIntent.unknown;

    final doctorScore = scores[SearchIntent.findDoctor] ?? 0;
    final businessScore = scores[SearchIntent.findBusiness] ?? 0;
    if (doctorScore > 0 && doctorScore >= businessScore) {
      return SearchIntent.findDoctor;
    }

    return bestIntent;
  }

  double _resolveConfidence(Map<SearchIntent, int> scores, SearchIntent intent) {
    if (intent == SearchIntent.unknown) return 0.2;

    final top = scores[intent] ?? 0;
    if (top == 0) return 0.3;

    final sorted = scores.values.where((s) => s > 0).toList()..sort();
    if (sorted.length >= 2 && sorted.last == sorted[sorted.length - 2]) {
      return 0.55;
    }

    return (0.45 + (top * 0.12)).clamp(0.0, 1.0);
  }

  // -------------------------------------------------------------------------
  // Filter extractors
  // -------------------------------------------------------------------------

  Map<String, dynamic> _extractJobFilters(String query, String lower) {
    final filters = <String, dynamic>{};

    final jobTitle = _extractJobTitle(query, lower);
    if (jobTitle != null) {
      filters['jobTitle'] = jobTitle;
      final category = _mapJobCategory(jobTitle.toLowerCase());
      if (category != null) filters['category'] = category;
    }

    if (lower.contains('near')) filters['proximity'] = 'near';
    return filters;
  }

  Map<String, dynamic> _extractHousingFilters(String query, String lower) {
    final filters = <String, dynamic>{};

    final propertyType = _extractPropertyType(lower);
    if (propertyType != null) filters['propertyType'] = propertyType;

    final bedrooms = _extractBedrooms(lower);
    if (bedrooms != null) filters['bedrooms'] = bedrooms;

    if (_containsFamilyFriendly(lower)) {
      filters['familyFriendly'] = true;
    }

    return filters;
  }

  Map<String, dynamic> _extractBusinessFilters(String query, String lower) {
    final filters = <String, dynamic>{};

    final cuisine = _extractCuisine(lower);
    if (cuisine != null) filters['cuisine'] = cuisine;

    filters['category'] = _extractBusinessCategory(lower);
    return filters;
  }

  Map<String, dynamic> _extractDoctorFilters(String query, String lower) {
    return {
      ..._extractBusinessFilters(query, lower),
      'category': 'Medical',
    };
  }

  Map<String, dynamic> _extractRateFilters(String lower) {
    final filters = <String, dynamic>{};

    for (final currency in ['inr', 'pkr', 'bdt', 'npr', 'php', 'usd', 'eur']) {
      if (lower.contains(currency)) {
        filters['currency'] = currency.toUpperCase();
        break;
      }
    }

    filters['currency'] ??= 'INR';
    return filters;
  }

  Map<String, dynamic> _extractVisaFilters(String query, String lower) {
    final filters = <String, dynamic>{'query': query};

    if (lower.contains('iqama')) filters['topic'] = 'iqama';
    if (lower.contains('qid')) filters['topic'] = 'qid';
    if (lower.contains('exit')) filters['topic'] = 'exit_permit';
    if (lower.contains('renewal') || lower.contains('renew')) {
      filters['topic'] = 'renewal';
    }

    return filters;
  }

  String? _extractArea(String query) {
    final lower = query.toLowerCase();
    for (final area in _qatarAreas) {
      if (lower.contains(area.toLowerCase())) return area;
    }

    if (lower.contains('ras laffan')) return 'Ras Laffan';
    if (lower.contains('industrial area')) return 'Industrial Area';
    if (lower.contains('west bay')) return 'West Bay';
    if (lower.contains('old airport')) return 'Old Airport';
    if (lower.contains('the pearl')) return 'The Pearl';
    if (lower.contains('al khor')) return 'Al Khor';
    if (lower.contains('al wakrah')) return 'Al Wakrah';

    return null;
  }

  Map<String, dynamic> _extractPriceFilters(String lower) {
    final filters = <String, dynamic>{};

    final rangeMatch = RegExp(
      r'(\d[\d,]*)\s*(?:to|-)\s*(\d[\d,]*)',
    ).firstMatch(lower);
    if (rangeMatch != null) {
      filters['minPrice'] = _parseNumber(rangeMatch.group(1)!);
      filters['maxPrice'] = _parseNumber(rangeMatch.group(2)!);
      return filters;
    }

    final underMatch = RegExp(
      r'(?:under|below|less than|max|upto|up to)\s*(?:qar\s*)?(\d[\d,]*)',
    ).firstMatch(lower);
    if (underMatch != null) {
      filters['maxPrice'] = _parseNumber(underMatch.group(1)!);
      return filters;
    }

    final aroundMatch = RegExp(
      r'around\s*(?:qar\s*)?(\d[\d,]*)',
    ).firstMatch(lower);
    if (aroundMatch != null) {
      final center = _parseNumber(aroundMatch.group(1)!);
      filters['minPrice'] = (center * 0.8).round();
      filters['maxPrice'] = (center * 1.2).round();
      return filters;
    }

    final qrMatch = RegExp(r'(?:qar\s*)?(\d[\d,]*)\s*(?:qr|qar)').firstMatch(lower);
    if (qrMatch != null && !filters.containsKey('maxPrice')) {
      filters['maxPrice'] = _parseNumber(qrMatch.group(1)!);
    }

    return filters;
  }

  String? _extractJobTitle(String query, String lower) {
    for (final title in _jobCategoryMap.keys) {
      if (lower.contains(title)) {
        return _titleCase(title);
      }
    }

    final jobsMatch = RegExp(
      r'(?:find|show|search for|looking for)\s+(?:me\s+)?(.+?)\s+(?:jobs?|work|vacancies)',
      caseSensitive: false,
    ).firstMatch(query);
    if (jobsMatch != null) {
      return _cleanPhrase(jobsMatch.group(1)!);
    }

    final nearMatch = RegExp(
      r'(.+?)\s+(?:jobs?|vacancies)\s+near',
      caseSensitive: false,
    ).firstMatch(query);
    if (nearMatch != null) {
      return _cleanPhrase(nearMatch.group(1)!);
    }

    return null;
  }

  String? _extractPropertyType(String lower) {
    if (lower.contains('studio')) return 'studio';
    if (RegExp(r'\b1\s*bhk\b|\b1bhk\b').hasMatch(lower)) return '1BHK';
    if (RegExp(r'\b2\s*bhk\b|\b2bhk\b').hasMatch(lower)) return '2BHK';
    if (RegExp(r'\b3\s*bhk\b|\b3bhk\b').hasMatch(lower)) return '3BHK';
    if (lower.contains('villa')) return 'villa';
    if (lower.contains('apartment') || lower.contains('flat')) return 'flat';
    if (lower.contains('sharing') || lower.contains('partition')) {
      return 'sharing';
    }
    if (lower.contains('room')) return 'room';
    return null;
  }

  int? _extractBedrooms(String lower) {
    if (RegExp(r'\b1\s*bhk\b|\b1bhk\b').hasMatch(lower)) return 1;
    if (RegExp(r'\b2\s*bhk\b|\b2bhk\b').hasMatch(lower)) return 2;
    if (RegExp(r'\b3\s*bhk\b|\b3bhk\b').hasMatch(lower)) return 3;

    final bedMatch = RegExp(r'(\d)\s*bed(room)?s?').firstMatch(lower);
    if (bedMatch != null) return int.tryParse(bedMatch.group(1)!);

    return null;
  }

  String? _extractCuisine(String lower) {
    for (final entry in _cuisineMap.entries) {
      if (lower.contains(entry.key)) return entry.value;
    }
    return null;
  }

  String _extractBusinessCategory(String lower) {
    if (lower.contains('restaurant') || lower.contains('food')) {
      return 'Restaurant';
    }
    if (lower.contains('salon')) return 'Salon';
    if (lower.contains('gym')) return 'Gym';
    if (lower.contains('grocery') || lower.contains('supermarket')) {
      return 'Grocery';
    }
    if (lower.contains('clinic') || lower.contains('doctor')) {
      return 'Medical';
    }
    if (lower.contains('repair')) return 'Repair';
    return 'Service';
  }

  String? _mapJobCategory(String jobTitleLower) {
    for (final entry in _jobCategoryMap.entries) {
      if (jobTitleLower.contains(entry.key)) return entry.value;
    }
    return null;
  }

  // -------------------------------------------------------------------------
  // Suggestion helpers
  // -------------------------------------------------------------------------

  List<String> _profileSuggestions(UserAIProfile profile) {
    final area = profile.preferredArea.isNotEmpty
        ? profile.preferredArea
        : 'Al Khor';
    final profession = profile.profession.isNotEmpty
        ? profile.profession
        : 'HSE Officer';
    final maxBudget = profile.budgetRange['max'] ?? 2000;

    return [
      '$profession jobs in $area',
      '$profession jobs in Ras Laffan',
      'Safety Manager jobs Doha',
      'Rooms in $area under QAR $maxBudget',
      'Rooms near Industrial Area $area under $maxBudget',
      'Best Indian restaurants in $area',
      'Family friendly 2BHK apartment Doha',
      'INR exchange rate today',
    ];
  }

  String _buildSuggestionFromResult(
    SmartSearchResult result,
    UserAIProfile? profile,
  ) {
    final area = result.filters['area']?.toString() ??
        profile?.preferredArea ??
        'Al Khor';
    final profession = profile?.profession.isNotEmpty == true
        ? profile!.profession
        : 'HSE Officer';
    switch (result.intent) {
      case SearchIntent.findJob:
        final title =
            result.filters['jobTitle']?.toString() ?? profession;
        return '$title jobs in $area';
      case SearchIntent.findHousing:
        final type = result.filters['propertyType']?.toString() ?? 'room';
        final max = result.filters['maxPrice'];
        return max != null
            ? '${type}s in $area under QAR $max'
            : '$type in $area';
      case SearchIntent.findBusiness:
        final cuisine = result.filters['cuisine']?.toString() ?? '';
        return cuisine.isNotEmpty
            ? 'Best $cuisine restaurants in $area'
            : 'Best services in $area';
      case SearchIntent.checkRate:
        final currency = result.filters['currency']?.toString() ?? 'INR';
        return '$currency exchange rate today';
      case SearchIntent.visaQuestion:
        return result.displayQuery;
      case SearchIntent.findDoctor:
        return 'Doctors in $area';
      case SearchIntent.communityQuestion:
        return 'Ask Qatar: ${result.displayQuery}';
      case SearchIntent.unknown:
        return result.displayQuery;
    }
  }

  // -------------------------------------------------------------------------
  // Utility
  // -------------------------------------------------------------------------

  bool _containsNearMe(String lower) =>
      lower.contains('near me') || lower.contains('nearby');

  bool _containsBest(String lower) => lower.contains('best');

  bool _containsFamilyFriendly(String lower) =>
      lower.contains('family friendly') ||
      lower.contains('family-friendly') ||
      lower.contains('family home');

  int _parseNumber(String raw) =>
      int.tryParse(raw.replaceAll(',', '')) ?? 0;

  String _cleanPhrase(String value) {
    return value
        .replaceAll(RegExp(r'\b(a|an|the|me|some|any)\b', caseSensitive: false), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  String _titleCase(String value) {
    return value
        .split(' ')
        .map(
          (word) => word.isEmpty
              ? word
              : '${word[0].toUpperCase()}${word.substring(1)}',
        )
        .join(' ');
  }
}

// ---------------------------------------------------------------------------
// Riverpod
// ---------------------------------------------------------------------------

final smartSearchServiceProvider = Provider<SmartSearchService>((ref) {
  return SmartSearchService();
});

final smartSearchResultProvider = Provider.family<
    SmartSearchResult,
    ({String query, UserAIProfile? profile})>((ref, params) {
  final service = ref.watch(smartSearchServiceProvider);
  return service.parseQuery(params.query, profile: params.profile);
});

final smartSearchSuggestionsProvider = Provider.family<
    List<String>,
    ({String partialQuery, UserAIProfile? profile})>((ref, params) {
  final service = ref.watch(smartSearchServiceProvider);
  return service.getSuggestions(params.partialQuery, params.profile);
});
