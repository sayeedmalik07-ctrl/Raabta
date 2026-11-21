import 'package:raabta/features/community/models/community_models.dart';

/// Filters owner-visible matches using private dismissal docs (same listing only).
abstract final class LostFoundMatchVisibility {
  static List<LostFoundMatchSummary> withoutDismissed({
    required List<LostFoundMatchSummary> matches,
    required Set<String> dismissedPairIds,
  }) {
    if (dismissedPairIds.isEmpty) return matches;
    return matches
        .where((m) => !dismissedPairIds.contains(m.pairId))
        .toList(growable: false);
  }
}
