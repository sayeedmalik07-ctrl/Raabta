import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/home/widgets/home_icon_badge.dart';

/// Standard title block for bottom-nav hub tabs — mirrors Services hub header.
class HubTabHeader extends StatelessWidget {
  const HubTabHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.leadingIcon,
    this.actionLabel,
    this.actionIcon,
    this.onAction,
  });

  final String title;
  final String subtitle;
  final IconData? leadingIcon;
  final String? actionLabel;
  final IconData? actionIcon;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.lg,
        AppSpacing.xl,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (leadingIcon != null) ...[
                HomeIconBadge(
                  icon: leadingIcon!,
                  accentColor: AppColors.cyanGlow,
                  size: 44,
                ),
                const SizedBox(width: AppSpacing.sm),
              ],
              Expanded(
                child: Text(title, style: AppTypography.headline2),
              ),
              if (onAction != null && actionLabel != null)
                TextButton.icon(
                  onPressed: onAction,
                  icon: Icon(
                    actionIcon ?? Icons.add,
                    size: 18,
                    color: AppColors.cyanGlow,
                  ),
                  label: Text(
                    actionLabel!,
                    style: AppTypography.link.copyWith(color: AppColors.link),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            subtitle,
            style: AppTypography.body.copyWith(color: AppColors.textOnGlassMuted),
          ),
        ],
      ),
    );
  }
}
