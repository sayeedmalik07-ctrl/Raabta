import 'package:flutter/material.dart';
import 'package:raabta/features/community/services/community_moderation_config.dart';
import 'package:raabta/features/community/services/community_post_moderation_service.dart';
import 'package:raabta/features/community/widgets/community_investment_moderation_dialog.dart';

/// Resolves soft moderation warn interstitials before allowing a post to proceed.
Future<PostModerationResult> resolveCommunityModeration({
  required BuildContext context,
  required String locale,
  required Future<PostModerationResult> Function({
    bool investmentWarningAcknowledged,
    bool fundraisingWarningAcknowledged,
  }) runModeration,
  required PostModerationResult initialResult,
  Future<void> Function(PostModerationResult result)? onCancelled,
}) async {
  var result = initialResult;
  if (!result.requiresConfirmation) return result;

  final category = result.category;
  final proceed = await CommunityModerationWarnDialog.show(
    context,
    locale,
    category: category,
  );
  if (!context.mounted) return result;

  if (!proceed) {
    if (onCancelled != null) {
      await onCancelled(result);
    }
    return result;
  }

  if (category == CommunityModerationConfig.categoryFundraisingSolicitation) {
    return runModeration(fundraisingWarningAcknowledged: true);
  }
  return runModeration(investmentWarningAcknowledged: true);
}
