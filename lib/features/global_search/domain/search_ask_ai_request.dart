import 'package:raabta/features/global_search/domain/search_analysis.dart';
import 'package:raabta/services/ai/smart_search_service.dart';

/// Structured AI ASK request for Global Search (S9).
///
/// Only privacy-safe fields are sent to the AI service.
class SearchAskAiRequest {
  const SearchAskAiRequest({
    required this.originalQuery,
    required this.sanitizedQuery,
    required this.detectedLanguage,
    required this.intent,
    required this.confidence,
    this.area,
    this.nearMe = false,
    this.visaTopic,
    this.jobCategory,
    this.serviceTrade,
  });

  final String originalQuery;
  final String sanitizedQuery;
  final String detectedLanguage;
  final SearchIntent intent;
  final double confidence;
  final String? area;
  final bool nearMe;
  final String? visaTopic;
  final String? jobCategory;
  final String? serviceTrade;

  factory SearchAskAiRequest.fromAnalysis({
    required SearchAnalysis analysis,
    required String sanitizedQuery,
  }) {
    return SearchAskAiRequest(
      originalQuery: analysis.originalQuery,
      sanitizedQuery: sanitizedQuery,
      detectedLanguage: analysis.detectedLanguage ?? 'en',
      intent: analysis.intent,
      confidence: analysis.confidence,
      area: analysis.area,
      nearMe: analysis.nearMe,
      visaTopic: analysis.visaTopic,
      jobCategory: analysis.jobCategory,
      serviceTrade: analysis.serviceTrade,
    );
  }
}
