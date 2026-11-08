import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/hub/community_hub_icons.dart';
import 'package:raabta/core/widgets/hub/hub_subscreen_scaffold.dart';
import 'package:raabta/features/home/widgets/home_icon_badge.dart';

/// Hub-aligned chrome for Community T2 section screens.
abstract final class CommunitySectionPrimitives {
  static Color get refreshColor => AppColors.brandFamilyMain;

  static EdgeInsets embeddedListPadding({required bool embedded}) {
    return EdgeInsets.fromLTRB(
      AppSpacing.md,
      embedded ? AppSpacing.lg : AppSpacing.md,
      AppSpacing.md,
      AppSpacing.xxxl,
    );
  }

  static Widget standaloneScaffold({
    required BuildContext context,
    required String title,
    required String subtitle,
    required Widget body,
  }) {
    return HubSubscreenScaffold(
      title: title,
      subtitle: subtitle,
      onBack: () => Navigator.of(context).pop(),
      body: body,
    );
  }

  /// Groups tab / section lists — kit overline + title (not Home dashboard chrome).
  static Widget sectionHeader({
    String? overline,
    required String title,
    String? subtitle,
    IconData? leadingIcon,
    HomeIconBadgeVariant leadingVariant = HomeIconBadgeVariant.tealBrand,
  }) {
    final overlineColor = AppColors.textSecondary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (overline != null && overline.isNotEmpty) ...[
          Text(
            overline,
            style: AppTypography.overline.copyWith(color: overlineColor),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.xs),
        ],
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (leadingIcon != null) ...[
              CommunityHubIcons.sectionChip(
                leadingIcon,
                variant: leadingVariant,
              ),
              const SizedBox(width: AppSpacing.md),
            ],
            Expanded(
              child: Text(
                title,
                style: AppTypography.headline2,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        if (subtitle != null && subtitle.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            subtitle,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  static Widget embeddedSectionHeader({
    required String title,
    required String subtitle,
    IconData? leadingIcon,
    Widget? trailing,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (leadingIcon != null) ...[
          CommunityHubIcons.sectionChip(leadingIcon),
          const SizedBox(width: AppSpacing.md),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTypography.headline2),
              Text(
                subtitle,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        if (trailing != null) trailing,
      ],
    );
  }
}
