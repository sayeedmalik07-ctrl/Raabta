import 'package:raabta/features/global_search/domain/multilingual_query_normalizer.dart';
import 'package:raabta/services/ai/smart_search_service.dart';

/// Deterministic pre-router output for Global Search (S1).
///
/// Produced by [SmartSearchService.analyze] — no navigation, no AI.
class SearchAnalysis {
  const SearchAnalysis({
    required this.intent,
    required this.confidence,
    required this.normalizedQuery,
    required this.originalQuery,
    this.area,
    this.nearMe = false,
    this.minPrice,
    this.maxPrice,
    this.minSalary,
    this.currency,
    this.jobCategory,
    this.visaTopic,
    this.employerName,
    this.agencyName,
    this.fromCurrency,
    this.toCurrency,
    this.conversionAmount,
    this.serviceTrade,
    this.jobTitle,
    this.propertyType,
    this.bedrooms,
    this.maxSalary,
    this.businessCategory,
    this.detectedLanguage,
    this.normalizedMultilingualQuery,
  });

  final SearchIntent intent;
  final double confidence;
  final String normalizedQuery;
  final String originalQuery;
  final String? area;
  final bool nearMe;
  final int? minPrice;
  final int? maxPrice;
  final int? minSalary;
  final String? currency;
  final String? jobCategory;
  final String? visaTopic;

  /// S2 entity extraction — employer/agency/currency conversion.
  final String? employerName;
  final String? agencyName;
  final String? fromCurrency;
  final String? toCurrency;
  final double? conversionAmount;

  /// S3 — matched service trade (electrician, plumber, etc.).
  final String? serviceTrade;

  /// S4 — structured FIND filters.
  final String? jobTitle;
  final String? propertyType;
  final int? bedrooms;
  final int? maxSalary;
  final String? businessCategory;

  /// S7 — detected query language family (local heuristic).
  final String? detectedLanguage;

  /// S7 — canonical multilingual normalization (original query preserved separately).
  final String? normalizedMultilingualQuery;

  factory SearchAnalysis.empty() {
    return const SearchAnalysis(
      intent: SearchIntent.unknown,
      confidence: 0,
      normalizedQuery: '',
      originalQuery: '',
    );
  }

  factory SearchAnalysis.fromSmartSearchResult(
    SmartSearchResult result, {
    required String originalQuery,
    MultilingualNormalizationResult? normalization,
  }) {
    final trimmed = originalQuery.trim();
    final filters = result.filters;

    int? readInt(dynamic value) {
      if (value is int) return value;
      if (value is num) return value.round();
      return int.tryParse(value?.toString() ?? '');
    }

    double? readDouble(dynamic value) {
      if (value is double) return value;
      if (value is num) return value.toDouble();
      return double.tryParse(value?.toString() ?? '');
    }

    return SearchAnalysis(
      intent: result.intent,
      confidence: result.confidence,
      normalizedQuery: normalization?.canonicalLower ?? trimmed.toLowerCase(),
      originalQuery: trimmed,
      detectedLanguage: normalization?.detectedLanguage,
      normalizedMultilingualQuery: normalization?.normalizedText,
      area: filters['area']?.toString(),
      nearMe: filters['nearMe'] == true,
      minPrice: readInt(filters['minPrice']),
      maxPrice: readInt(filters['maxPrice']),
      minSalary: readInt(filters['minSalary']),
      currency: filters['currency']?.toString(),
      jobCategory: result.intent == SearchIntent.findJob
          ? filters['category']?.toString()
          : null,
      visaTopic: result.intent == SearchIntent.visaQuestion
          ? filters['topic']?.toString()
          : null,
      employerName: filters['employerName']?.toString(),
      agencyName: filters['agencyName']?.toString(),
      fromCurrency: filters['fromCurrency']?.toString(),
      toCurrency: filters['toCurrency']?.toString(),
      conversionAmount: readDouble(filters['conversionAmount']),
      serviceTrade: filters['serviceTrade']?.toString(),
      jobTitle: result.intent == SearchIntent.findJob
          ? filters['jobTitle']?.toString()
          : null,
      propertyType: result.intent == SearchIntent.findHousing
          ? filters['propertyType']?.toString()
          : null,
      bedrooms: readInt(filters['bedrooms']),
      maxSalary: readInt(filters['maxSalary']),
      businessCategory: result.intent == SearchIntent.findBusiness ||
              result.intent == SearchIntent.findDoctor
          ? filters['category']?.toString()
          : null,
    );
  }
}
