import 'package:raabta/features/global_search/domain/search_action_id.dart';

/// Validated AI ASK response for Global Search (S9).
class SearchAskAiResponse {
  const SearchAskAiResponse({
    required this.answer,
    this.detectedIntent,
    this.confidence,
    this.suggestedActions = const [],
    this.suggestedDestinations = const [],
    this.disclaimerRequired = true,
    this.fromFallback = false,
    this.errorMessage,
  });

  final String answer;
  final String? detectedIntent;
  final double? confidence;

  /// Allowlisted [SearchActionId] values only — never raw routes.
  final List<SearchActionId> suggestedActions;

  /// Allowlisted destination route prefixes only.
  final List<String> suggestedDestinations;
  final bool disclaimerRequired;
  final bool fromFallback;
  final String? errorMessage;

  bool get hasError => errorMessage != null && errorMessage!.isNotEmpty;
  bool get isEmpty => answer.trim().isEmpty;
}
