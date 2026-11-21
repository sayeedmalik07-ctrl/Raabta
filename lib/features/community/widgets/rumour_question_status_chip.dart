import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/widgets/hub/community_hub_accent.dart';
import 'package:raabta/features/community/domain/rumour_check/rumour_check_models.dart';
import 'package:raabta/features/community/presentation/l10n/community_strings.dart';
import 'package:raabta/features/home/widgets/status_badge.dart';

/// Rumour thread status — never implies claim truth, only community context state.
class RumourQuestionStatusChip extends StatelessWidget {
  const RumourQuestionStatusChip({
    super.key,
    required this.status,
    required this.locale,
  });

  final RumourDisplayStatus status;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final (label, color, icon) = switch (status) {
      RumourDisplayStatus.open => (
          CommunityStrings.t('community_rumour_status_open', locale),
          AppColors.warning,
          Icons.hourglass_empty,
        ),
      RumourDisplayStatus.contextAdded => (
          CommunityStrings.t('community_rumour_status_context', locale),
          communityHubAccent,
          Icons.notes,
        ),
      RumourDisplayStatus.communityVerified => (
          CommunityStrings.t('community_rumour_status_verified', locale),
          AppColors.success,
          Icons.verified_outlined,
        ),
    };

    return StatusBadge(label: label, color: color, icon: icon);
  }
}
