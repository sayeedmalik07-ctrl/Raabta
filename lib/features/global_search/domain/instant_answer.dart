import 'package:raabta/features/global_search/domain/global_search_models.dart';
import 'package:raabta/features/global_search/domain/search_action_id.dart';
import 'package:raabta/features/global_search/domain/search_analysis.dart';

/// Deterministic instant answer types (Batch 3).
enum InstantAnswerType {
  matchSummary,
  documentIdentity,
  currencyIntent,
  nearestService,
}

/// Pure presentation-layer answer derived from an existing search response.
class InstantAnswer {
  const InstantAnswer({
    required this.type,
    required this.primaryLineKey,
    this.primaryLineParams = const {},
    this.supportingLineKey,
    this.supportingLineParams = const {},
    this.actionItem,
    this.actionLabelKey,
    this.actionLabelParams = const {},
    this.suppressBestMatch = false,
    this.duplicateActionId,
  });

  final InstantAnswerType type;

  /// Localization key for the headline value line.
  final String primaryLineKey;
  final Map<String, String> primaryLineParams;

  /// Optional second line (area, distance, document category, cached hint).
  final String? supportingLineKey;
  final Map<String, String> supportingLineParams;

  /// Reuses an existing search result/action for navigation.
  final GlobalSearchResultItem? actionItem;

  /// Optional localized CTA label key.
  final String? actionLabelKey;
  final Map<String, String> actionLabelParams;

  /// When true, Best Match duplicates this answer and should be hidden.
  final bool suppressBestMatch;

  /// When set, matching actions in the ACTIONS group should be hidden.
  final SearchActionId? duplicateActionId;
}

/// Inputs for [InstantAnswerResolver] — no I/O, existing response only.
class InstantAnswerContext {
  const InstantAnswerContext({
    required this.response,
    required this.currentQuery,
    required this.isSignedIn,
  });

  final GlobalSearchResponse response;
  final String currentQuery;
  final bool isSignedIn;

  SearchAnalysis? get analysis => response.analysis;
}
