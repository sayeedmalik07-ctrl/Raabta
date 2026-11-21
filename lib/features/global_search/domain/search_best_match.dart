import 'package:raabta/features/global_search/domain/global_search_models.dart';

/// Provenance signal for how a BEST MATCH was selected (S5).
enum SearchBestMatchSource {
  intent,
  relevance,
  exactMatch,
  serviceListing,
  destination,
}

/// Top FIND highlight derived after provider merge — not a separate nav target (S5).
class SearchBestMatch {
  const SearchBestMatch({
    required this.result,
    required this.score,
    required this.reasonKey,
    required this.source,
    this.distanceMeters,
  });

  /// Underlying FIND result — navigation uses this item unchanged.
  final GlobalSearchResultItem result;

  /// Ranker score (existing result score + bounded bonuses; original score untouched).
  final double score;

  /// Localization key for the reason line (resolved in UI).
  final String reasonKey;

  final SearchBestMatchSource source;

  /// S6 — optional distance for display when coordinates were valid.
  final int? distanceMeters;
}
