import 'package:raabta/features/global_search/domain/search_ask_ai_eligibility.dart';

/// ASK AI offer shown in Global Search results (S9).
///
/// Display-only — no network call until the user taps.
class SearchAskAiResult {
  const SearchAskAiResult({
    required this.displayTitle,
    required this.displaySubtitle,
    required this.originalQuery,
    required this.reason,
  });

  final String displayTitle;
  final String displaySubtitle;
  final String originalQuery;
  final SearchAskAiEligibilityReason reason;
}
