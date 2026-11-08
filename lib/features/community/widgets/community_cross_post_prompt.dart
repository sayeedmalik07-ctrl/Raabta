import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/community/data/community_content_labels.dart';
import 'package:raabta/features/community/data/community_group_registry.dart';
import 'package:raabta/features/community/presentation/l10n/community_strings.dart';
import 'package:raabta/features/community/utils/community_group_tagging.dart';

/// Opt-in cross-post suggestion when content is tagged to exactly one group (Part C).
abstract final class CommunityCrossPostPrompt {
  /// Returns final [relevantGroupIds] after optional user confirmation.
  ///
  /// No-op when zero or multiple tags are selected. Never cross-posts silently.
  static Future<List<String>> resolveTags({
    required BuildContext context,
    required Iterable<String> selectedTags,
    required Set<int> joinedGroupIds,
    required String locale,
  }) async {
    final normalized = CommunityGroupTagging.normalize(selectedTags.toList());
    if (normalized.length != 1) return normalized;

    final taggedId = normalized.first;
    if (CommunityContentLabels.isContentLabel(taggedId)) return normalized;

    final taggedName = CommunityGroupRegistry.byId(taggedId)?.name ??
        CommunityStrings.t('community_crosspost_fallback_group', locale);

    final otherJoinedIds = joinedGroupIds
        .map((id) => '$id')
        .where((id) => id != taggedId)
        .toList();

    final String destinationLabel;
    final String? additionalGroupId;

    if (otherJoinedIds.isNotEmpty) {
      additionalGroupId = otherJoinedIds.first;
      final otherName = CommunityGroupRegistry.byId(additionalGroupId)?.name ??
          CommunityStrings.t('community_crosspost_another_group', locale);
      destinationLabel = otherName;
    } else {
      additionalGroupId = null;
      destinationLabel =
          CommunityStrings.t('community_crosspost_qatar_community', locale);
    }

    if (!context.mounted) return normalized;

    final accepted = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          CommunityStrings.t('community_crosspost_title', locale),
          style: AppTypography.headline2,
        ),
        content: Text(
          CommunityStrings.format(
            'community_crosspost_body',
            locale,
            params: {
              'taggedName': taggedName,
              'destinationLabel': destinationLabel,
            },
          ),
          style: AppTypography.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(CommunityStrings.t('community_crosspost_no', locale)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(CommunityStrings.t('community_crosspost_yes', locale)),
          ),
        ],
      ),
    );

    if (accepted != true) return normalized;

    if (additionalGroupId != null) {
      return CommunityGroupTagging.normalize([taggedId, additionalGroupId]);
    }

    // General Qatar Community — untagged (visible in main Community surfaces).
    return const [];
  }
}
