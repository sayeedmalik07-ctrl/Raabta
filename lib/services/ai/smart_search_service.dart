import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/features/global_search/domain/multilingual_query_normalizer.dart';
import 'package:raabta/features/global_search/domain/search_analysis.dart';
import 'package:raabta/features/global_search/domain/service_search_terminology.dart';
import 'package:raabta/services/ai/user_profile_ai_service.dart';

// ---------------------------------------------------------------------------
// Smart Search (AI intent routing — NOT app-wide Firestore content search)
//
// For cross-feature document/listing search see `GlobalSearchScreen` and
// `GlobalSearchRepository` under `lib/features/global_search/`.
// ---------------------------------------------------------------------------

enum SearchIntent {
  findJob,
  findHousing,
  findBusiness,
  findService,
  findDoctor,
  checkRate,
  visaQuestion,
  communityQuestion,
  eosbCalculator,
  prayerMosque,
  tripPlanner,
  verifyEmployer,
  verifyAgency,
  scanDocument,
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
  static const List<String> _tripKeywords = [
    'trip planner',
    'itinerary',
    'travel plan',
    'qatar trip',
    'doha trip',
    'visit qatar',
    'things to do',
    'sightseeing',
    'tourist',
    'vacation qatar',
  ];

  static const List<String> _prayerKeywords = [
    'prayer',
    'prayer time',
    'salah',
    'namaz',
    'qibla',
    'mosque',
    'masjid',
    'jumuah',
    'jummah',
    'fajr',
    'maghrib',
    'islamic calendar',
    'hijri',
  ];

  static const List<String> _eosbKeywords = [
    'eosb',
    'end of service',
    'gratuity',
    'settlement',
    'termination pay',
    'leave encashment',
    'notice period',
    'final settlement',
    'end of service benefit',
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
    'grocery',
    'indian food',
    'pakistani food',
    'cafe',
    'bakery',
    'store',
    'market',
    'company',
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

  static const List<String> _employerVerifyKeywords = [
    'verify employer',
    'check employer',
    'employer verification',
    'employer record',
    'check company',
    'verify company',
    'company record',
    'company reliable',
    'is reliable',
    'track record',
  ];

  static const List<String> _agencyVerifyKeywords = [
    'recruitment agency',
    'verify agency',
    'check agency',
    'agency verification',
    'recruitment verification',
    'verify recruitment',
    'check recruitment',
  ];

  static const List<String> _scannerKeywords = [
    'scan document',
    'document scanner',
    'scan my document',
    'scan pdf',
    'pdf scanner',
    'document scan',
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

  /// Deterministic query analysis for Global Search pre-routing (S1).
  ///
  /// Analysis only — no navigation, no network, no [BuildContext].
  SearchAnalysis analyze(String query, {UserAIProfile? profile}) {
    if (query.trim().isEmpty) return SearchAnalysis.empty();
    final normalization = MultilingualQueryNormalizer.normalize(query);
    final result = parseQuery(
      query,
      profile: profile,
      normalization: normalization,
    );
    return SearchAnalysis.fromSmartSearchResult(
      result,
      originalQuery: query,
      normalization: normalization,
    );
  }

  /// Parses a natural language query into structured search filters.
  SmartSearchResult parseQuery(
    String query, {
    UserAIProfile? profile,
    MultilingualNormalizationResult? normalization,
  }) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      return const SmartSearchResult(
        intent: SearchIntent.unknown,
        filters: {},
        displayQuery: '',
        confidence: 0,
      );
    }

    final resolvedNormalization =
        normalization ?? MultilingualQueryNormalizer.normalize(trimmed);
    final lower = resolvedNormalization.canonicalLower;
    final intentScores = _scoreIntents(lower);
    final intent = _resolveIntent(intentScores, lower);
    final confidence = _resolveConfidence(intentScores, intent);

    final filters = <String, dynamic>{};

    final area = _extractArea(resolvedNormalization.normalizedText);
    if (area != null) filters['area'] = area;

    if (_containsNearMe(lower)) {
      filters['nearMe'] = true;
      if (profile != null && profile.preferredArea.isNotEmpty) {
        filters['area'] ??= profile.preferredArea;
      }
    }

    final priceFilters = _extractPriceFilters(lower);
    filters.addAll(priceFilters);

    final employerName = extractEmployerName(trimmed);
    if (employerName != null) filters['employerName'] = employerName;

    final agencyName = extractAgencyName(trimmed);
    if (agencyName != null) filters['agencyName'] = agencyName;

    final currencyConversion = extractCurrencyConversion(trimmed);
    if (currencyConversion != null) {
      filters.addAll(currencyConversion);
    }

    switch (intent) {
      case SearchIntent.findJob:
        filters.addAll(_extractJobFilters(resolvedNormalization.normalizedText, lower));
      case SearchIntent.findHousing:
        filters.addAll(_extractHousingFilters(resolvedNormalization.normalizedText, lower));
      case SearchIntent.findBusiness:
        filters.addAll(_extractBusinessFilters(resolvedNormalization.normalizedText, lower));
      case SearchIntent.findService:
        filters.addAll(_extractServiceFilters(resolvedNormalization.normalizedText, lower));
      case SearchIntent.findDoctor:
        filters.addAll(_extractDoctorFilters(resolvedNormalization.normalizedText, lower));
      case SearchIntent.checkRate:
        filters.addAll(_extractRateFilters(lower));
      case SearchIntent.visaQuestion:
        filters.addAll(_extractVisaFilters(resolvedNormalization.normalizedText, lower));
      case SearchIntent.communityQuestion:
        filters['query'] = trimmed;
      case SearchIntent.eosbCalculator:
        filters['query'] = trimmed;
      case SearchIntent.prayerMosque:
        filters['query'] = trimmed;
      case SearchIntent.tripPlanner:
        filters['query'] = trimmed;
      case SearchIntent.verifyEmployer:
        filters['query'] = trimmed;
      case SearchIntent.verifyAgency:
        filters['query'] = trimmed;
      case SearchIntent.scanDocument:
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
    final employerScore = _employerVerifyScore(lower);
    final agencyScore = _agencyVerifyScore(lower);
    final scannerScore = _scannerScore(lower);

    return {
      SearchIntent.verifyEmployer: employerScore,
      SearchIntent.verifyAgency: agencyScore,
      SearchIntent.scanDocument: scannerScore,
      SearchIntent.findJob: _jobIntentScore(lower),
      SearchIntent.findHousing: _keywordScore(lower, _housingKeywords),
      SearchIntent.findBusiness: _businessIntentScore(lower),
      SearchIntent.findService: ServiceSearchTerminology.score(lower),
      SearchIntent.findDoctor: _keywordScore(lower, _doctorKeywords),
      SearchIntent.checkRate: _rateIntentScore(lower),
      SearchIntent.visaQuestion: _keywordScore(lower, _visaKeywords),
      SearchIntent.communityQuestion: _keywordScore(lower, _communityKeywords),
      SearchIntent.eosbCalculator: _eosbIntentScore(lower),
      SearchIntent.prayerMosque: _keywordScore(lower, _prayerKeywords),
      SearchIntent.tripPlanner: _keywordScore(lower, _tripKeywords),
    };
  }

  int _employerVerifyScore(String lower) {
    var score = _keywordScore(lower, _employerVerifyKeywords);
    if (RegExp(r'\b(check|verify)\s+.+\s+company\b').hasMatch(lower)) {
      score += 2;
    }
    if (RegExp(r'\bis\s+.+\s+company\s+(reliable|legit|safe)\b').hasMatch(lower)) {
      score += 2;
    }
    if (extractEmployerName(lower) != null) score += 2;
    return score;
  }

  int _agencyVerifyScore(String lower) {
    var score = _keywordScore(lower, _agencyVerifyKeywords);
    if (RegExp(r'\b(check|verify)\s+.+\s+recruitment\b').hasMatch(lower)) {
      score += 2;
    }
    return score;
  }

  int _scannerScore(String lower) {
    var score = _keywordScore(lower, _scannerKeywords);
    if (lower.trim() == 'scan') score += 2;
    return score;
  }

  int _rateIntentScore(String lower) {
    var score = _keywordScore(lower, _rateKeywords);
    if (extractCurrencyConversion(lower) != null) score += 3;
    return score;
  }

  int _eosbIntentScore(String lower) {
    var score = _keywordScore(lower, _eosbKeywords);
    if (_isEosbCalculatePhrase(lower)) score += 2;
    return score;
  }

  bool _isEosbCalculatePhrase(String lower) {
    const calcWords = ['calculate', 'calculator', 'compute', 'calculation'];
    const eosbWords = ['eosb', 'gratuity', 'end of service', 'gratuity benefit'];
    final hasCalc = calcWords.any(lower.contains);
    final hasEosb = eosbWords.any(lower.contains);
    return hasCalc && hasEosb;
  }

  int _jobIntentScore(String lower) {
    var score = _keywordScore(lower, ServiceSearchTerminology.jobMetaKeywords);
    if (ServiceSearchTerminology.hasStrongJobSignal(lower)) {
      score += _keywordScore(lower, _jobProfessionKeywords);
    }
    return score;
  }

  int _businessIntentScore(String lower) {
    var score = _keywordScore(lower, _businessKeywords);
    if (ServiceSearchTerminology.hasStrongBusinessSignal(lower)) {
      score += 2;
    }
    return score;
  }

  static const List<String> _jobProfessionKeywords = [
    'officer',
    'manager',
    'engineer',
    'driver',
    'supervisor',
    'technician',
    'nurse',
    'teacher',
    'electrician',
    'plumber',
  ];

  int _keywordScore(String lower, List<String> keywords) {
    var score = 0;
    for (final keyword in keywords) {
      if (lower.contains(keyword)) score++;
    }
    return score;
  }

  SearchIntent _resolveIntent(Map<SearchIntent, int> scores, String lower) {
    var bestIntent = SearchIntent.unknown;
    var bestScore = 0;

    for (final entry in scores.entries) {
      if (entry.value > bestScore) {
        bestScore = entry.value;
        bestIntent = entry.key;
      }
    }

    if (bestScore == 0) return SearchIntent.unknown;

    // Action intents take precedence when strongly matched.
    final verifyEmployer = scores[SearchIntent.verifyEmployer] ?? 0;
    final verifyAgency = scores[SearchIntent.verifyAgency] ?? 0;
    final scanDocument = scores[SearchIntent.scanDocument] ?? 0;
    if (verifyEmployer >= 2 && verifyEmployer >= bestScore) {
      return SearchIntent.verifyEmployer;
    }
    if (verifyAgency >= 2 && verifyAgency >= bestScore) {
      return SearchIntent.verifyAgency;
    }
    if (scanDocument >= 2 && scanDocument >= bestScore) {
      return SearchIntent.scanDocument;
    }

    final serviceScore = scores[SearchIntent.findService] ?? 0;
    final jobScore = scores[SearchIntent.findJob] ?? 0;
    final businessScore = scores[SearchIntent.findBusiness] ?? 0;

    if (ServiceSearchTerminology.hasStrongJobSignal(lower) && jobScore > 0) {
      return SearchIntent.findJob;
    }
    if (ServiceSearchTerminology.hasStrongBusinessSignal(lower) &&
        businessScore > 0) {
      return SearchIntent.findBusiness;
    }
    if (serviceScore > 0 &&
        serviceScore >= jobScore &&
        serviceScore >= businessScore) {
      return SearchIntent.findService;
    }

    final doctorScore = scores[SearchIntent.findDoctor] ?? 0;
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

  Map<String, dynamic> _extractServiceFilters(String query, String lower) {
    final filters = <String, dynamic>{
      'query': ServiceSearchTerminology.cleanServiceQuery(query),
    };
    final trade = ServiceSearchTerminology.extractTrade(query);
    if (trade != null) filters['serviceTrade'] = trade;
    if (_containsNearMe(lower)) filters['proximity'] = 'near';
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
    if (lower.contains('qid') || lower.contains('qatar id')) {
      filters['topic'] = 'qid';
    }
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

    const aliases = {
      'doha': 'Doha',
      'al rayyan': 'Al Rayyan',
      'rayyan': 'Al Rayyan',
      'al wakrah': 'Al Wakrah',
      'wakrah': 'Al Wakrah',
      'lusail': 'Lusail',
      'al khor': 'Al Khor',
      'umm salal': 'Umm Salal',
      'mesaieed': 'Mesaieed',
      'dukhan': 'Dukhan',
      'industrial area': 'Industrial Area',
      'old airport': 'Old Airport',
      'west bay': 'West Bay',
      'al sadd': 'Al Sadd',
      'bin mahmoud': 'Bin Mahmoud',
      'najma': 'Najma',
      'mansoura': 'Al Mansoura',
      'al mansoura': 'Al Mansoura',
      'abu hamour': 'Abu Hamour',
      'al waab': 'Al Waab',
      'barwa': 'Barwa',
      'ain khaled': 'Ain Khaled',
    };
    for (final entry in aliases.entries) {
      if (lower.contains(entry.key)) return entry.value;
    }

    if (lower.contains('ras laffan')) return 'Ras Laffan';
    if (lower.contains('the pearl')) return 'The Pearl';

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

    final aboveMatch = RegExp(
      r'(?:above|over|more than|minimum|min)\s*(?:qar\s*)?(\d[\d,]*)',
    ).firstMatch(lower);
    if (aboveMatch != null) {
      final value = _parseNumber(aboveMatch.group(1)!);
      if (lower.contains('job')) {
        filters['minSalary'] = value;
      } else {
        filters['minPrice'] = value;
      }
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

    final jobFirst = RegExp(
      r'\bjobs?\s+([a-z][\w-]+)',
      caseSensitive: false,
    ).firstMatch(lower.trim());
    if (jobFirst != null) {
      final phrase = _cleanPhrase(jobFirst.group(1)!);
      if (phrase.isNotEmpty && !_isJobTitleStopword(phrase)) return phrase;
    }

    final leadingProfession = RegExp(
      r'^([a-z][\w\s/-]{0,30}?)\s+jobs?\b',
      caseSensitive: false,
    ).firstMatch(lower.trim());
    if (leadingProfession != null) {
      final phrase = _cleanPhrase(leadingProfession.group(1)!);
      if (phrase.isNotEmpty) return phrase;
    }

    final anywhereProfession = RegExp(
      r'\b([a-z][\w\s/-]{0,30}?)\s+jobs?\b',
      caseSensitive: false,
    ).firstMatch(lower.trim());
    if (anywhereProfession != null) {
      final phrase = _cleanPhrase(anywhereProfession.group(1)!);
      if (phrase.isNotEmpty &&
          phrase.length <= 30 &&
          !_isJobTitleStopword(phrase)) {
        return phrase;
      }
    }

    return null;
  }

  bool _isJobTitleStopword(String phrase) {
    const blocked = {
      'in',
      'at',
      'on',
      'for',
      'with',
      'near',
      'above',
      'below',
      'under',
      'over',
      'around',
      'doha',
      'qatar',
    };
    return blocked.contains(phrase.toLowerCase());
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
    final area = profile.preferredArea.trim();
    final profession = profile.profession.isNotEmpty
        ? profile.profession
        : 'HSE Officer';
    final maxBudget = profile.budgetRange['max'] ?? 2000;

    if (area.isEmpty) {
      return [
        '$profession jobs in Qatar',
        'Safety Manager jobs Doha',
        'Rooms in Qatar under QAR $maxBudget',
        'Best Indian restaurants in Doha',
        'Family friendly 2BHK apartment Doha',
        'INR exchange rate today',
      ];
    }

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
    final area = _resolveAreaLabel(
      filterArea: result.filters['area']?.toString(),
      profileArea: profile?.preferredArea,
    );
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
      case SearchIntent.findService:
        final trade = result.filters['serviceTrade']?.toString() ?? 'service';
        return '$trade in $area';
      case SearchIntent.checkRate:
        final currency = result.filters['currency']?.toString() ?? 'INR';
        return '$currency exchange rate today';
      case SearchIntent.visaQuestion:
        return result.displayQuery;
      case SearchIntent.findDoctor:
        return 'Doctors in $area';
      case SearchIntent.communityQuestion:
        return 'Ask Qatar: ${result.displayQuery}';
      case SearchIntent.eosbCalculator:
        return 'Calculate EOSB / gratuity';
      case SearchIntent.prayerMosque:
        return 'Prayer times & nearby mosques';
      case SearchIntent.tripPlanner:
        return 'Plan your Qatar trip with AI';
      case SearchIntent.verifyEmployer:
        return 'Verify employer record';
      case SearchIntent.verifyAgency:
        return 'Verify recruitment agency';
      case SearchIntent.scanDocument:
        return 'Scan a document';
      case SearchIntent.unknown:
        return result.displayQuery;
    }
  }

  /// Neutral area label when profile/query has no location — matches home header.
  static String _resolveAreaLabel({
    String? filterArea,
    String? profileArea,
  }) {
    final fromFilter = filterArea?.trim();
    if (fromFilter != null && fromFilter.isNotEmpty) return fromFilter;
    final fromProfile = profileArea?.trim();
    if (fromProfile != null && fromProfile.isNotEmpty) return fromProfile;
    return 'Qatar';
  }

  // -------------------------------------------------------------------------
  // Utility
  // -------------------------------------------------------------------------

  bool _containsNearMe(String lower) =>
      MultilingualQueryNormalizer.containsNearMe(lower);

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

  // -------------------------------------------------------------------------
  // S2 entity extraction (deterministic, testable)
  // -------------------------------------------------------------------------

  /// Extracts employer/company name from verification-style queries.
  String? extractEmployerName(String query) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return null;

    final patterns = [
      RegExp(
        r'(?:check|verify)\s+(?:employer\s+)?(.+?)(?:\s+company)?$',
        caseSensitive: false,
      ),
      RegExp(
        r'(?:check|verify)\s+(.+?)\s+company\b',
        caseSensitive: false,
      ),
      RegExp(
        r'\bis\s+(.+?)\s+company\s+(?:reliable|legit|safe|trustworthy)\b',
        caseSensitive: false,
      ),
      RegExp(
        r'(?:employer|company)\s+(?:check|verify)\s+(.+?)$',
        caseSensitive: false,
      ),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(trimmed);
      if (match == null) continue;
      final name = _cleanEmployerEntity(match.group(1)!);
      if (_isValidEmployerName(name)) return name;
    }
    return null;
  }

  /// Extracts recruitment agency name when present.
  String? extractAgencyName(String query) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return null;

    final patterns = [
      RegExp(
        r'(?:check|verify)\s+(.+?)\s+recruitment(?:\s+agency)?\b',
        caseSensitive: false,
      ),
      RegExp(
        r'(?:check|verify)\s+(.+?)\s+agency\b',
        caseSensitive: false,
      ),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(trimmed);
      if (match == null) continue;
      final name = _cleanEmployerEntity(match.group(1)!);
      if (_isValidAgencyName(name)) return name;
    }
    return null;
  }

  /// Parses currency conversion patterns such as "500 QAR to INR".
  Map<String, dynamic>? extractCurrencyConversion(String query) {
    final normalized = MultilingualQueryNormalizer.normalize(query);
    final lower = normalized.canonicalLower.trim();
    if (lower.isEmpty) return null;

    final amountPair = RegExp(
      r'(\d[\d,]*(?:\.\d+)?)\s*(qar|inr|pkr|bdt|npr|php|usd|eur|riyal|rial)\s*(?:to|→)\s*(qar|inr|pkr|bdt|npr|php|usd|eur)',
      caseSensitive: false,
    ).firstMatch(lower);

    if (amountPair != null) {
      final from = amountPair.group(2)!.toUpperCase();
      return {
        'conversionAmount': _parseAmount(amountPair.group(1)!),
        'fromCurrency': from == 'RIYAL' || from == 'RIAL' ? 'QAR' : from,
        'toCurrency': amountPair.group(3)!.toUpperCase(),
      };
    }

    final convertPair = RegExp(
      r'convert\s+(qar|inr|pkr|bdt|npr|php|usd|eur)\s+(?:to|→)\s+(qar|inr|pkr|bdt|npr|php|usd|eur)',
      caseSensitive: false,
    ).firstMatch(lower);

    if (convertPair != null) {
      return {
        'fromCurrency': convertPair.group(1)!.toUpperCase(),
        'toCurrency': convertPair.group(2)!.toUpperCase(),
      };
    }

    final barePair = RegExp(
      r'\b(qar|inr|pkr|bdt|npr|php|usd|eur)\s+(?:to|→)\s+(qar|inr|pkr|bdt|npr|php|usd|eur)\b',
      caseSensitive: false,
    ).firstMatch(lower);

    if (barePair != null) {
      return {
        'fromCurrency': barePair.group(1)!.toUpperCase(),
        'toCurrency': barePair.group(2)!.toUpperCase(),
      };
    }

    return null;
  }

  String _cleanEmployerEntity(String raw) {
    var value = raw.trim();
    value = value.replaceAll(RegExp(r'\s+'), ' ');
    value = value.replaceAll(
      RegExp(r'\b(a|an|the|my|this|that|employer|company|recruitment|agency)\b',
          caseSensitive: false),
      '',
    );
    value = value.replaceAll(RegExp(r'\s+'), ' ').trim();
    return _titleCase(value);
  }

  bool _isValidEmployerName(String name) {
    if (name.length < 2) return false;
    final lower = name.toLowerCase();
    const blocked = {
      'employer',
      'company',
      'recruitment',
      'agency',
      'reliable',
      'verify',
      'check',
    };
    return !blocked.contains(lower);
  }

  bool _isValidAgencyName(String name) {
    if (name.length < 2) return false;
    final lower = name.toLowerCase();
    const blocked = {
      'recruitment',
      'agency',
      'verify',
      'check',
    };
    return !blocked.contains(lower);
  }

  double? _parseAmount(String raw) {
    final cleaned = raw.replaceAll(',', '');
    return double.tryParse(cleaned);
  }
}

// ---------------------------------------------------------------------------
// Riverpod
// ---------------------------------------------------------------------------

final smartSearchServiceProvider = Provider<SmartSearchService>((ref) {
  return SmartSearchService();
});

final smartSearchAnalysisProvider = Provider.family<
    SearchAnalysis,
    ({String query, UserAIProfile? profile})>((ref, params) {
  final service = ref.watch(smartSearchServiceProvider);
  return service.analyze(params.query, profile: params.profile);
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
