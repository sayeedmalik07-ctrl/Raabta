import 'package:raabta/features/community/data/community_content_labels.dart';

/// Normalizes optional multi-group tags on community content (Part A).
abstract final class CommunityGroupTagging {
  /// Reads [relevantGroupIds] from Firestore, falling back to legacy [groupId].
  static List<String> parseFromFirestore(Map<String, dynamic> data) {
    final raw = data['relevantGroupIds'];
    if (raw is List && raw.isNotEmpty) {
      return raw.map((e) => e.toString()).where((id) => id.isNotEmpty).toList();
    }
    final legacy = data['groupId'] as String? ?? '';
    if (legacy.isNotEmpty) return [legacy];
    return const [];
  }

  /// Dedupes, drops empties, preserves order.
  static List<String> normalize(List<String> ids) {
    final seen = <String>{};
    final out = <String>[];
    for (final id in ids) {
      final trimmed = id.trim();
      if (trimmed.isEmpty || seen.contains(trimmed)) continue;
      seen.add(trimmed);
      out.add(trimmed);
    }
    return out;
  }

  /// Legacy [groupId] field — prefers real group IDs over content labels.
  static String primaryGroupId(List<String> ids) {
    for (final id in ids) {
      if (!CommunityContentLabels.isContentLabel(id)) return id;
    }
    return ids.isNotEmpty ? ids.first : '';
  }

  static List<String> groupIdsOnly(List<String> ids) =>
      ids.where((id) => !CommunityContentLabels.isContentLabel(id)).toList();

  static bool isTaggedToGroup(List<String> ids, String groupId) =>
      ids.contains(groupId);
}
