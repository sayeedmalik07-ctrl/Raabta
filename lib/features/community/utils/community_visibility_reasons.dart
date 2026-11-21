import 'package:raabta/features/community/data/community_content_labels.dart';
import 'package:raabta/features/community/data/community_group_registry.dart';
import 'package:raabta/features/community/presentation/l10n/community_strings.dart';

/// Inputs already available on a community card at render time (Part B).
class CommunityVisibilityInput {
  const CommunityVisibilityInput({
    this.relevantGroupIds = const [],
    this.contentLocation,
    this.contentLanguage,
    this.likeCount = 0,
    this.voteCount = 0,
    this.commentCount = 0,
  });

  final List<String> relevantGroupIds;
  final String? contentLocation;
  final String? contentLanguage;
  final int likeCount;
  final int voteCount;
  final int commentCount;
}

/// Deterministic, zero-cost explanations for why content is shown (no AI).
abstract final class CommunityVisibilityReasons {
  static const trendingLikeThreshold = 5;
  static const trendingVoteThreshold = 3;

  static const fallbackReason = 'Recent in Qatar Community';

  static List<String> build({
    required CommunityVisibilityInput content,
    required Set<int> joinedGroupIds,
    String? userPreferredArea,
    String appLanguage = 'English',
  }) {
    final reasons = <String>[];
    final joinedIds = joinedGroupIds.map((id) => '$id').toSet();
    final seenGroups = <String>{};

    for (final groupId in content.relevantGroupIds) {
      if (CommunityContentLabels.isContentLabel(groupId)) {
        if (groupId == CommunityContentLabels.leavingQatarId &&
            !seenGroups.contains(groupId)) {
          seenGroups.add(groupId);
          reasons.add(
            CommunityStrings.t(
              'community_visibility_tagged_leaving_qatar',
              appLanguage,
            ),
          );
        }
        continue;
      }
      if (!joinedIds.contains(groupId) || seenGroups.contains(groupId)) {
        continue;
      }
      seenGroups.add(groupId);
      final name =
          CommunityGroupRegistry.byId(groupId)?.name ?? 'your community';
      reasons.add("You're a member of $name");
    }

    final area = userPreferredArea?.trim();
    if (area != null &&
        area.isNotEmpty &&
        area.toLowerCase() != 'unknown' &&
        _locationMatches(content.contentLocation, area)) {
      reasons.add('Posted near $area');
    }

    final lang = content.contentLanguage?.trim();
    if (lang != null &&
        lang.isNotEmpty &&
        lang.toLowerCase() == appLanguage.trim().toLowerCase()) {
      reasons.add('In your language');
    }

    if (content.likeCount >= trendingLikeThreshold ||
        content.voteCount >= trendingVoteThreshold) {
      reasons.add('Trending in your communities');
    }

    if (reasons.isEmpty) {
      return [fallbackReason];
    }
    return reasons;
  }

  static bool _locationMatches(String? contentLocation, String userArea) {
    if (contentLocation == null || contentLocation.trim().isEmpty) {
      return false;
    }
    final c = _normalizeLocation(contentLocation);
    final u = _normalizeLocation(userArea);
    if (c.isEmpty || u.isEmpty) return false;
    return c.contains(u) || u.contains(c);
  }

  static String _normalizeLocation(String value) {
    return value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9\s]'), ' ').trim();
  }
}
