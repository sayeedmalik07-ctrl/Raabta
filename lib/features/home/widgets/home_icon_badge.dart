import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/design/color_family.dart';
import 'package:raabta/core/design/raabta_continuous_shape.dart';
import 'package:raabta/core/design/raabta_solid_surface_tokens.dart';
import 'package:raabta/core/icons/raabta_icon.dart';
import 'package:raabta/core/icons/raabta_icons.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/features/home/widgets/home_card_tiers.dart';

ShapeDecoration _homeIconBadgeDecoration({
  required double radius,
  Color? color,
  Gradient? gradient,
  BorderSide side = BorderSide.none,
  List<BoxShadow>? shadows,
}) {
  return RaabtaContinuousShape.decoration(
    radius: radius,
    color: color,
    gradient: gradient,
    side: side,
    shadows: shadows,
  );
}

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
      decoration: _homeIconBadgeDecoration(
        radius: circular ? size / 2 : (chipBorderRadius ?? AppSpacing.radiusMd),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accentColor.withValues(alpha: fillAlpha),
            accentColor.withValues(alpha: fillAlpha * 0.35),
          ],
        ),
        side: BorderSide(color: accentColor.withValues(alpha: borderAlpha)),
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
    return _SolidFamilyIconBadge(
      icon: icon,
      size: size,
      iconSize: iconSize,
      chipBorderRadius: chipBorderRadius,
      surfaceFamily: RaabtaSolidSurfaceFamily.brand,
      glyphFamily: RaabtaColorFamilies.brand,
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
    return _SolidFamilyIconBadge(
      icon: icon,
      size: size,
      iconSize: iconSize,
      chipBorderRadius: chipBorderRadius,
      surfaceFamily: RaabtaSolidSurfaceFamily.gold,
      glyphFamily: RaabtaColorFamilies.gold,
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
    return _SolidFamilyIconBadge(
      icon: icon,
      size: size,
      iconSize: iconSize,
      chipBorderRadius: chipBorderRadius,
      glyphFamily: RaabtaColorFamilies.green,
      surfaceFill: (brightness) => brightness == Brightness.dark
          ? const Color(0xFF0A1F18)
          : const Color(0xFFE8F7F1),
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
    return _SolidFamilyIconBadge(
      icon: icon,
      size: size,
      iconSize: iconSize,
      chipBorderRadius: chipBorderRadius,
      surfaceFamily: RaabtaSolidSurfaceFamily.teal,
      glyphFamily: RaabtaColorFamilies.teal,
    );
  }
}

/// Materiality kit icon chip — solid family tint, dark glyph, no glow.
class _SolidFamilyIconBadge extends StatelessWidget {
  const _SolidFamilyIconBadge({
    required this.icon,
    required this.size,
    required this.iconSize,
    required this.chipBorderRadius,
    required this.glyphFamily,
    this.surfaceFamily,
    this.surfaceFill,
  });

  final IconData icon;
  final double size;
  final double iconSize;
  final double chipBorderRadius;
  final ColorFamily glyphFamily;
  final RaabtaSolidSurfaceFamily? surfaceFamily;
  final Color Function(Brightness brightness)? surfaceFill;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final fill = surfaceFamily != null
        ? RaabtaSolidSurfaceTokens.fill(surfaceFamily!, brightness)
        : (surfaceFill?.call(brightness) ?? glyphFamily.main(brightness));
    final borderColor = surfaceFamily != null
        ? RaabtaSolidSurfaceTokens.hairline(surfaceFamily!, brightness)
        : glyphFamily.main(brightness).withValues(alpha: 0.28);

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: _homeIconBadgeDecoration(
        radius: chipBorderRadius,
        color: fill,
        side: BorderSide(color: borderColor),
      ),
      child: RaabtaIcon(
        icon,
        size: iconSize,
        color: glyphFamily.text(brightness),
      ),
    );
  }
}
