import 'package:flutter/material.dart';
import 'package:raabta/core/design/raabta_continuous_shape.dart';
import 'package:raabta/core/design/raabta_physical_shadow_tokens.dart';

/// Solid tactile controls — fill, tight shadow, inner top highlight, press metrics.
abstract final class RaabtaTactileButtonTokens {
  RaabtaTactileButtonTokens._();

  static Color brandFill(Brightness brightness) =>
      RaabtaTactileHighlightTokens.solidBrandFill(brightness);

  static List<BoxShadow> shadows(Brightness brightness) =>
      RaabtaPhysicalShadowTokens.tactileButton(brightness);

  static const double pressedOffsetY =
      RaabtaPhysicalShadowTokens.tactilePressedOffsetY;

  static const double pressedScale =
      RaabtaPhysicalShadowTokens.tactilePressedScale;

  static Offset pressTranslation(bool pressed, {bool reduceMotion = false}) {
    if (!pressed || reduceMotion) return Offset.zero;
    return const Offset(0, pressedOffsetY);
  }

  static double pressScale(bool pressed, {bool reduceMotion = false}) {
    if (!pressed || reduceMotion) return 1;
    return pressedScale;
  }

  /// Squircle / pill solid brand button decoration (no neon glow).
  static ShapeDecoration shapeDecoration({
    required Brightness brightness,
    required double radius,
    Color? fill,
  }) {
    final base = fill ?? brandFill(brightness);
    final highlight = RaabtaTactileHighlightTokens.innerTopEdge(brightness);
    return RaabtaContinuousShape.decoration(
      radius: radius,
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color.alphaBlend(highlight, base),
          base,
        ],
        stops: const [0, 0.24],
      ),
      shadows: shadows(brightness),
    );
  }

  /// Centre Post FAB and circular AI orb shell.
  static BoxDecoration circleDecoration({
    required Brightness brightness,
    Color? fill,
  }) {
    final base = fill ?? brandFill(brightness);
    final highlight = RaabtaTactileHighlightTokens.innerTopEdge(brightness);
    return BoxDecoration(
      shape: BoxShape.circle,
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color.alphaBlend(highlight, base),
          base,
        ],
        stops: const [0, 0.28],
      ),
      boxShadow: shadows(brightness),
    );
  }
}