import 'package:raabta/features/community/presentation/l10n/community_strings.dart';

/// Optional content labels stored in [relevantGroupIds] alongside group IDs (Part A).
///
/// Prefixed IDs distinguish labels from numeric group IDs — no Group directory entry required.
class CommunityContentLabelDefinition {
  const CommunityContentLabelDefinition({
    required this.id,
    required this.emoji,
    required this.labelKey,
  });

  final String id;
  final String emoji;
  final String labelKey;

  String displayName(String locale) =>
      CommunityStrings.t(labelKey, locale);
}

abstract final class CommunityContentLabels {
  CommunityContentLabels._();

  static const leavingQatarId = 'label:leaving_qatar';

  static const leavingQatar = CommunityContentLabelDefinition(
    id: leavingQatarId,
    emoji: '✈️',
    labelKey: 'community_tag_leaving_qatar',
  );

  static const all = [leavingQatar];

  static bool isContentLabel(String id) => id.startsWith('label:');

  static CommunityContentLabelDefinition? byId(String id) {
    for (final label in all) {
      if (label.id == id) return label;
    }
    return null;
  }

  static String? displayNameForTag(String id, String locale) {
    return byId(id)?.displayName(locale);
  }
}
