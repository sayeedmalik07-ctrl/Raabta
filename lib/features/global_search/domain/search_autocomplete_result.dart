import 'package:flutter/material.dart';
import 'package:raabta/features/global_search/domain/global_search_models.dart';
import 'package:raabta/features/global_search/domain/search_action_id.dart';
import 'package:raabta/features/global_search/domain/search_autocomplete_source.dart';

/// Immutable autocomplete suggestion for Global Search (S8).
class SearchAutocompleteResult {
  const SearchAutocompleteResult({
    required this.displayText,
    required this.subtitle,
    required this.source,
    required this.normalizedText,
    required this.relevanceScore,
    required this.submitQuery,
    this.icon,
    this.category,
    this.actionId,
    this.isRecent = false,
  });

  /// Visible primary line (may be localized for starters).
  final String displayText;

  /// Secondary line (category hint).
  final String subtitle;

  final SearchAutocompleteSource source;
  final String normalizedText;
  final int relevanceScore;

  /// Query passed into the existing Global Search pipeline on selection.
  final String submitQuery;

  final IconData? icon;
  final GlobalSearchCategory? category;
  final SearchActionId? actionId;
  final bool isRecent;
}
