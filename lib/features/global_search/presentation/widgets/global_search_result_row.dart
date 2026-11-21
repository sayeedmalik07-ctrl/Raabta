import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/global_search/presentation/global_search_directional_icons.dart';
import 'package:raabta/features/global_search/presentation/widgets/global_search_category_icon_chip.dart';
import 'package:raabta/features/global_search/presentation/widgets/global_search_presentation_tokens.dart';
import 'package:raabta/features/home/widgets/home_card_tiers.dart';

/// Tappable search hit row (group, best match, actions).
class GlobalSearchResultRow extends StatelessWidget {
  const GlobalSearchResultRow({
    super.key,
    required this.icon,
    required this.accent,
    required this.title,
    this.subtitle,
    this.tertiary,
    this.semanticLabel,
    this.onTap,
    this.trailing,
    this.glowColor,
    this.glowIntensity = HomeCardTier.homeCardGlowIntensity,
  });

  final IconData icon;
  final Color accent;
  final String title;
  final String? subtitle;
  final String? tertiary;
  final String? semanticLabel;
  final VoidCallback? onTap;
  final Widget? trailing;
  final Color? glowColor;
  final double glowIntensity;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: onTap != null,
      label: semanticLabel ?? title,
      child: GlassCard(
        onTap: onTap,
        margin: const EdgeInsets.only(bottom: GlobalSearchPresentationTokens.rowGap),
        padding: GlobalSearchPresentationTokens.cardPadding,
        borderRadius: GlobalSearchPresentationTokens.cardRadius,
        glowColor: glowColor ?? accent,
        glowIntensity: glowIntensity,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GlobalSearchCategoryIconChip(icon: icon, accent: accent),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.body.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle != null && subtitle!.isNotEmpty)
                    Text(
                      subtitle!,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textOnGlassMuted,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  if (tertiary != null && tertiary!.isNotEmpty)
                    Text(
                      tertiary!,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            trailing ??
                Icon(
                  GlobalSearchDirectionalIcons.chevronForward(context),
                  color: AppColors.textOnGlassMuted,
                ),
          ],
        ),
      ),
    );
  }
}
