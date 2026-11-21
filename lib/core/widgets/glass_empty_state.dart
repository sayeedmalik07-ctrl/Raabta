import 'package:flutter/material.dart';

import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/widgets/hub/community_hub_accent.dart';
import 'package:raabta/core/widgets/hub/community_hub_icons.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';

/// Default [cyan] preserves legacy accent; [brand] uses hub brand family.
enum GlassEmptyStateAccent {
  cyan,
  brand,
  teal,
}

/// Unified empty state for list and feature screens.
class GlassEmptyState extends StatelessWidget {
  const GlassEmptyState({
    super.key,
    required this.title,
    required this.description,
    this.icon = Icons.inbox_outlined,
    this.actionLabel,
    this.onAction,
    this.accent = GlassEmptyStateAccent.cyan,
  });

  final String title;
  final String description;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;
  final GlassEmptyStateAccent accent;

  Color get _iconColor => switch (accent) {
        GlassEmptyStateAccent.brand => AppColors.brandFamilyMain,
        GlassEmptyStateAccent.cyan => AppColors.cyanGlow,
        GlassEmptyStateAccent.teal => communityHubAccent,
      };

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          switch (accent) {
            GlassEmptyStateAccent.teal => CommunityHubIcons.emptyStateChip(icon),
            GlassEmptyStateAccent.brand => CommunityHubIcons.emptyStateChip(
                icon,
                brand: true,
              ),
            GlassEmptyStateAccent.cyan => Icon(icon, size: 48, color: _iconColor),
          },
          const SizedBox(height: AppSpacing.md),
          Text(
            title,
            style: AppTypography.headline2,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            description,
            style: AppTypography.bodySmall,
            textAlign: TextAlign.center,
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: AppSpacing.lg),
            if (accent == GlassEmptyStateAccent.brand ||
                accent == GlassEmptyStateAccent.teal)
              _BrandEmptyStateAction(
                label: actionLabel!,
                onTap: onAction!,
              )
            else
              GlassCard(
                onTap: onAction,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.sm,
                ),
                borderRadius: AppSpacing.radiusFull,
                glowColor: AppColors.cyanGlow,
                glowIntensity: 0.15,
                child: Text(
                  actionLabel!,
                  style: AppTypography.subtitle.copyWith(
                    color: AppColors.cyanGlow,
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _BrandEmptyStateAction extends StatelessWidget {
  const _BrandEmptyStateAction({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  static const double _pillHeight = 46;
  static const double _pillRadius = 23;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(_pillRadius),
          child: Ink(
            height: _pillHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(_pillRadius),
              gradient: LinearGradient(
                colors: [
                  AppColors.brandFamilyMain,
                  AppColors.brandFamilyLightDeep,
                ],
              ),
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Text(
                  label,
                  style: AppTypography.button.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
