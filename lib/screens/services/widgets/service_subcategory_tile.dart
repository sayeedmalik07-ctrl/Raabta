import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/screens/services/utils/service_subcategory_visuals.dart';

/// Premium subcategory tile — gradient icon badge + glass card (classified-app style).
class ServiceSubcategoryTile extends StatelessWidget {
  const ServiceSubcategoryTile({
    super.key,
    required this.label,
    required this.visual,
    required this.onTap,
    this.selected = false,
    this.compact = false,
    this.trailing,
  });

  final String label;
  final ServiceSubcategoryVisual visual;
  final VoidCallback onTap;
  final bool selected;
  final bool compact;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return GlassCard(
        onTap: onTap,
        borderRadius: AppSpacing.radiusLg,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        glowColor: selected ? visual.glowColor : null,
        glowIntensity: selected ? 0.18 : 0.06,
        backgroundColor: selected
            ? visual.glowColor.withValues(alpha: 0.1)
            : AppColors.surfaceElevated.withValues(alpha: 0.35),
        child: Row(
          children: [
            _PremiumIconBadge(visual: visual, size: 40, iconSize: 20),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTypography.subtitle.copyWith(
                      fontSize: 14,
                      color: selected
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            trailing ??
                Icon(
                  Icons.chevron_right_rounded,
                  color: selected ? visual.glowColor : AppColors.textTertiary,
                ),
          ],
        ),
      );
    }

    return GlassCard(
      onTap: onTap,
      borderRadius: AppSpacing.radiusXl,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.md,
      ),
      glowColor: selected ? visual.glowColor : visual.glowColor,
      glowIntensity: selected ? 0.22 : 0.08,
      backgroundColor: selected
          ? visual.glowColor.withValues(alpha: 0.12)
          : AppColors.glassSurface,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _PremiumIconBadge(
            visual: visual,
            size: 52,
            iconSize: 26,
            showSparkle: selected,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            label,
            style: AppTypography.caption.copyWith(
              fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
              color: selected ? AppColors.textPrimary : AppColors.textSecondary,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _PremiumIconBadge extends StatelessWidget {
  const _PremiumIconBadge({
    required this.visual,
    required this.size,
    required this.iconSize,
    this.showSparkle = false,
  });

  final ServiceSubcategoryVisual visual;
  final double size;
  final double iconSize;
  final bool showSparkle;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: visual.gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(size * 0.28),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.22),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: visual.glowColor.withValues(alpha: 0.45),
                blurRadius: 14,
                spreadRadius: 0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            visual.icon,
            color: Colors.white,
            size: iconSize,
          ),
        ),
        if (showSparkle)
          Positioned(
            top: -3,
            right: -3,
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.accentGold, AppColors.amberGlow],
                ),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.background, width: 1.5),
              ),
              child: const Icon(
                Icons.star_rounded,
                size: 10,
                color: Colors.white,
              ),
            ),
          ),
      ],
    );
  }
}

/// Large hero badge for category headers.
class ServiceCategoryHeroBadge extends StatelessWidget {
  const ServiceCategoryHeroBadge({
    super.key,
    required this.icon,
    required this.gradient,
    required this.glowColor,
  });

  final IconData icon;
  final List<Color> gradient;
  final Color glowColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
        boxShadow: [
          BoxShadow(
            color: glowColor.withValues(alpha: 0.5),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Icon(icon, color: Colors.white, size: 28),
    );
  }
}
