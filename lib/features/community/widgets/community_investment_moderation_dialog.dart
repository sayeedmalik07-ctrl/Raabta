import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/community/presentation/l10n/community_strings.dart';
import 'package:raabta/features/community/services/community_moderation_config.dart';

/// Confirm-to-proceed interstitial for soft moderation categories.
abstract final class CommunityModerationWarnDialog {
  static Future<bool> show(
    BuildContext context,
    String locale, {
    String? category,
  }) async {
    final warnCategory = category ??
        CommunityModerationConfig.categoryInvestmentFinancialOpportunity;
    final isFundraising = warnCategory ==
        CommunityModerationConfig.categoryFundraisingSolicitation;

    final titleKey = isFundraising
        ? 'community_mod_fundraising_warn_title'
        : 'community_mod_investment_warn_title';
    final bodyKey = isFundraising
        ? 'community_mod_fundraising_warn_body'
        : 'community_mod_investment_warn_body';
    final noteKey = isFundraising
        ? 'community_mod_fundraising_verify_note'
        : 'community_mod_investment_scamshield_note';
    final linkKey = isFundraising
        ? 'community_mod_fundraising_official_directory_link'
        : 'community_mod_investment_scamshield_link';
    final linkRoute = isFundraising
        ? '/scam-shield/official-directory'
        : '/scam-shield';

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: isFundraising,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          CommunityStrings.t(titleKey, locale),
          style: AppTypography.headline2,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              CommunityStrings.t(bodyKey, locale),
              style: AppTypography.bodySmall.copyWith(height: 1.45),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              CommunityStrings.t(noteKey, locale),
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => ctx.push(linkRoute),
                icon: Icon(
                  isFundraising ? Icons.verified_user_outlined : Icons.shield_outlined,
                  size: 18,
                ),
                label: Text(CommunityStrings.t(linkKey, locale)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              CommunityStrings.t('community_mod_investment_cancel', locale),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.brandFamilyMain,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              CommunityStrings.t('community_mod_investment_proceed', locale),
            ),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}

/// @deprecated Use [CommunityModerationWarnDialog].
abstract final class CommunityInvestmentModerationDialog {
  static Future<bool> show(BuildContext context, String locale) =>
      CommunityModerationWarnDialog.show(
        context,
        locale,
        category: CommunityModerationConfig.categoryInvestmentFinancialOpportunity,
      );
}
