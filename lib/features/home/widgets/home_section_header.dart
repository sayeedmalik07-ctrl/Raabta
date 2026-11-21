import 'package:flutter/material.dart';

import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/home/widgets/home_card_tiers.dart';

/// Reusable section header for Home dashboard sections.
class HomeSectionHeader extends StatelessWidget {
  const HomeSectionHeader({
    super.key,
    this.overline,
    required this.title,
    this.subtitle,
    this.actionText,
    this.onActionTap,
    this.leadingIcon,
    this.compact = false,
    this.actionLinkColor,
    this.includeContentGap = true,
    this.titleTrailing,
  });

  /// Small category label above the title (N26 / Revolut pattern).
  final String? overline;
  final String title;
  final String? subtitle;
  final String? actionText;
  final VoidCallback? onActionTap;
  final IconData? leadingIcon;

  /// When true, hides the subtitle for a tighter section header.
  final bool compact;

  /// Optional header action color (defaults to [AppColors.link]).
  final Color? actionLinkColor;

  /// When true, adds [HomeZoneSpacing.afterSectionHeader] below the header.
  final bool includeContentGap;

  /// Optional trailing controls beside the title (e.g. Truth Engine privacy eye).
  final Widget? titleTrailing;

  @override
  Widget build(BuildContext context) {
    final subtitleColor = AppColors.textOnGlassMuted;
    final overlineColor = AppColors.textOnGlassSecondary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (overline != null) ...[
          Text(
            _formatOverline(overline!, context),
            style: AppTypography.overline.copyWith(color: overlineColor),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.xs),
        ],
        Row(
          children: [
            if (leadingIcon != null) ...[
              Icon(
                leadingIcon,
                size: AppSpacing.iconMd,
                color: AppColors.textOnGlassSecondary,
              ),
              const SizedBox(width: AppSpacing.sm),
            ],
            Expanded(
              child: Text(
                title,
                style: AppTypography.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (titleTrailing != null) ...[
              const SizedBox(width: AppSpacing.sm),
              titleTrailing!,
            ],
            if (actionText != null)
              _SectionAction(
                label: actionText!,
                onTap: onActionTap,
                linkColor: actionLinkColor,
              ),
          ],
        ),
        if (subtitle != null && !compact) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            subtitle!,
            style: AppTypography.bodySmall.copyWith(color: subtitleColor),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        if (includeContentGap)
          const SizedBox(height: HomeZoneSpacing.afterSectionHeader),
      ],
    );
  }

  static String _formatOverline(String text, BuildContext context) {
    if (Directionality.of(context) == TextDirection.rtl) return text;
    return text.toUpperCase();
  }
}

class _SectionAction extends StatelessWidget {
  const _SectionAction({
    required this.label,
    this.onTap,
    this.linkColor,
  });

  final String label;
  final VoidCallback? onTap;
  final Color? linkColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48, minWidth: 48),
          child: Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              child: Text(
                label,
                style: AppTypography.link.copyWith(
                  color: linkColor ?? AppColors.link,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
