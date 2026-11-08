import 'package:raabta/features/community/data/community_group_registry.dart';

enum CommunityNationalitySuggestionKind { hidden, joinGroup, noGroup }

/// Deterministic nationality group suggestion — no AI, no user profiling.
class CommunityNationalitySuggestionView {
  const CommunityNationalitySuggestionView.hidden()
      : kind = CommunityNationalitySuggestionKind.hidden,
        countryId = null,
        nationalityLabel = null,
        group = null;

  const CommunityNationalitySuggestionView.joinGroup({
    required this.countryId,
    required this.nationalityLabel,
    required this.group,
  }) : kind = CommunityNationalitySuggestionKind.joinGroup;

  const CommunityNationalitySuggestionView.noGroup({
    required this.countryId,
    required this.nationalityLabel,
  })  : kind = CommunityNationalitySuggestionKind.noGroup,
        group = null;

  final CommunityNationalitySuggestionKind kind;
  final String? countryId;
  final String? nationalityLabel;
  final CommunityGroupDefinition? group;
}
