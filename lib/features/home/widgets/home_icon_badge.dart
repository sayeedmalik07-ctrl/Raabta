import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/icons/raabta_icon.dart';
import 'package:raabta/core/icons/raabta_icons.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/features/home/widgets/home_card_tiers.dart';

/// Visual treatment for [HomeIconBadge] — default keeps legacy glass chips.
enum HomeIconBadgeVariant {
  standard,
  exploreBrand,
  goldBrand,
  tealBrand,
  greenBrand,
}

/// Consistent icon container for home shortcuts (fintech-style, no emoji).
class HomeIconBadge extends StatelessWidget {
  const HomeIconBadge({
    super.key,
    required this.icon,
    required this.accentColor,
    this.size = 44,
    this.iconSize = RaabtaIcons.gridSize,
    this.circular = false,
    this.variant = HomeIconBadgeVariant.standard,
    this.chipBorderRadius,
  });

  final IconData icon;
  final Color accentColor;
  final double size;
  final double iconSize;
  final bool circular;

  /// Explore core services — kit brand chip (light: white icon on brand gradient).
  final HomeIconBadgeVariant variant;
  final double? chipBorderRadius;

  @override
  Widget build(BuildContext context) {
    if (variant == HomeIconBadgeVariant.exploreBrand) {
      return _ExploreBrandBadge(
        icon: icon,
        size: size,
        iconSize: iconSize,
        chipBorderRadius: chipBorderRadius ??
            HomeCardTier.coreServiceIconChipRadius,
      );
    }
    if (variant == HomeIconBadgeVariant.goldBrand) {
      return _GoldBrandBadge(
        icon: icon,
        size: size,
        iconSize: iconSize,
        chipBorderRadius: chipBorderRadius ??
            HomeCardTier.coreServiceIconChipRadius,
      );
    }
    if (variant == HomeIconBadgeVariant.tealBrand) {
      return _TealBrandBadge(
        icon: icon,
        size: size,
        iconSize: iconSize,
        chipBorderRadius: chipBorderRadius ??
            HomeCardTier.coreServiceIconChipRadius,
      );
    }
    if (variant == HomeIconBadgeVariant.greenBrand) {
      return _GreenBrandBadge(
        icon: icon,
        size: size,
        iconSize: iconSize,
        chipBorderRadius: chipBorderRadius ??
            HomeCardTier.coreServiceIconChipRadius,
      );
    }

    final isLight = AppColors.isLight;
    final fillAlpha = isLight ? 0.28 : 0.35;
    final borderAlpha = isLight ? 0.52 : 0.35;

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
          circular ? size / 2 : (chipBorderRadius ?? AppSpacing.radiusMd),
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accentColor.withValues(alpha: fillAlpha),
            accentColor.withValues(alpha: fillAlpha * 0.35),
          ],
        ),
        border: Border.all(color: accentColor.withValues(alpha: borderAlpha)),
      ),
      child: RaabtaIcon(
        icon,
        size: iconSize,
        color: accentColor,
      ),
    );
  }
}

class _ExploreBrandBadge extends StatelessWidget {
  const _ExploreBrandBadge({
    required this.icon,
    required this.size,
    required this.iconSize,
    required this.chipBorderRadius,
  });

  final IconData icon;
  final double size;
  final double iconSize;
  final double chipBorderRadius;

  @override
  Widget build(BuildContext context) {
    final isLight = AppColors.isLight;
    final brandMain = AppColors.brandFamilyMain;
    final brandDeep = AppColors.brandFamilyLightDeep;

    if (isLight) {
      return Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(chipBorderRadius),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [brandMain, brandDeep],
          ),
          boxShadow: [
            BoxShadow(
              color: brandMain.withValues(alpha: 0.35),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: RaabtaIcon(
          icon,
          size: iconSize,
          color: Colors.white,
        ),
      );
    }

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(chipBorderRadius),
        color: brandMain.withValues(alpha: 0.22),
        border: Border.all(color: brandMain.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: brandMain.withValues(alpha: 0.35),
            blurRadius: 18,
          ),
        ],
      ),
      child: RaabtaIcon(
        icon,
        size: iconSize,
        color: brandMain,
      ),
    );
  }
}

class _GoldBrandBadge extends StatelessWidget {
  const _GoldBrandBadge({
    required this.icon,
    required this.size,
    required this.iconSize,
    required this.chipBorderRadius,
  });

  final IconData icon;
  final double size;
  final double iconSize;
  final double chipBorderRadius;

  @override
  Widget build(BuildContext context) {
    final isLight = AppColors.isLight;
    final goldMain = AppColors.goldFamilyMain;
    final goldDeep = AppColors.goldFamilyLightDeep;

    if (isLight) {
      return Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(chipBorderRadius),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [goldMain, goldDeep],
          ),
          boxShadow: [
            BoxShadow(
              color: goldMain.withValues(alpha: 0.35),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: RaabtaIcon(
          icon,
          size: iconSize,
          color: Colors.white,
        ),
      );
    }

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(chipBorderRadius),
        color: goldMain.withValues(alpha: 0.22),
        border: Border.all(color: goldMain.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: goldMain.withValues(alpha: 0.35),
            blurRadius: 18,
          ),
        ],
      ),
      child: RaabtaIcon(
        icon,
        size: iconSize,
        color: goldMain,
      ),
    );
  }
}

class _GreenBrandBadge extends StatelessWidget {
  const _GreenBrandBadge({
    required this.icon,
    required this.size,
    required this.iconSize,
    required this.chipBorderRadius,
  });

  final IconData icon;
  final double size;
  final double iconSize;
  final double chipBorderRadius;

  @override
  Widget build(BuildContext context) {
    final isLight = AppColors.isLight;
    final greenMain = AppColors.greenFamilyMain;
    final greenDeep = AppColors.greenFamilyLightDeep;

    if (isLight) {
      return Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(chipBorderRadius),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [greenMain, greenDeep],
          ),
          boxShadow: [
            BoxShadow(
              color: greenMain.withValues(alpha: 0.35),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: RaabtaIcon(
          icon,
          size: iconSize,
          color: Colors.white,
        ),
      );
    }

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(chipBorderRadius),
        color: greenMain.withValues(alpha: 0.22),
        border: Border.all(color: greenMain.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: greenMain.withValues(alpha: 0.35),
            blurRadius: 18,
          ),
        ],
      ),
      child: RaabtaIcon(
        icon,
        size: iconSize,
        color: greenMain,
      ),
    );
  }
}

class _TealBrandBadge extends StatelessWidget {
  const _TealBrandBadge({
    required this.icon,
    required this.size,
    required this.iconSize,
    required this.chipBorderRadius,
  });

  final IconData icon;
  final double size;
  final double iconSize;
  final double chipBorderRadius;

  @override
  Widget build(BuildContext context) {
    final isLight = AppColors.isLight;
    final tealMain = AppColors.tealFamilyMain;
    final tealDeep = AppColors.tealFamilyLightDeep;

    if (isLight) {
      return Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(chipBorderRadius),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [tealMain, tealDeep],
          ),
          boxShadow: [
            BoxShadow(
              color: tealMain.withValues(alpha: 0.35),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: RaabtaIcon(
          icon,
          size: iconSize,
          color: Colors.white,
        ),
      );
    }

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(chipBorderRadius),
        color: tealMain.withValues(alpha: 0.22),
        border: Border.all(color: tealMain.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: tealMain.withValues(alpha: 0.35),
            blurRadius: 18,
          ),
        ],
      ),
      child: RaabtaIcon(
        icon,
        size: iconSize,
        color: tealMain,
      ),
    );
  }
}
