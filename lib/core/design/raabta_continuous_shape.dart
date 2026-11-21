import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Continuous (squircle) corners via Flutter built-ins — no extra package.
abstract final class RaabtaContinuousShape {
  RaabtaContinuousShape._();

  /// Default card / list radius from materiality kit humanized column.
  static const double defaultCardRadius = 24;

  static const double defaultChipRadius = 18;

  static const double defaultHeroRadius = 34;

  static ShapeBorder rectangle(
    double radius, {
    BorderSide side = BorderSide.none,
  }) {
    return ContinuousRectangleBorder(
      borderRadius: BorderRadius.circular(radius),
      side: side,
    );
  }

  static ShapeBorder superellipse(
    double radius, {
    BorderSide side = BorderSide.none,
  }) {
    return RoundedSuperellipseBorder(
      borderRadius: BorderRadius.circular(radius),
      side: side,
    );
  }

  /// Kit-forward squircle — superellipse on mobile; continuous rectangle on desktop
  /// (Impeller/macOS can mis-composite superellipse + backdrop blur).
  static ShapeBorder surface(
    double radius, {
    BorderSide side = BorderSide.none,
  }) {
    if (!kIsWeb) {
      switch (defaultTargetPlatform) {
        case TargetPlatform.macOS:
        case TargetPlatform.windows:
        case TargetPlatform.linux:
          return rectangle(radius, side: side);
        default:
          break;
      }
    }
    return superellipse(radius, side: side);
  }

  static BorderRadiusGeometry borderRadius(double radius) =>
      BorderRadius.circular(radius);

  static ShapeDecoration decoration({
    required double radius,
    Color? color,
    Gradient? gradient,
    BorderSide side = BorderSide.none,
    List<BoxShadow>? shadows,
  }) {
    return ShapeDecoration(
      color: color,
      gradient: gradient,
      shadows: shadows,
      shape: surface(radius, side: side),
    );
  }

  /// Shadow-only wrapper matching [surface] geometry (fill is on the child).
  static ShapeDecoration shadowOnly({
    required double radius,
    List<BoxShadow>? shadows,
  }) {
    return ShapeDecoration(
      shape: surface(radius),
      shadows: shadows,
    );
  }

  /// Deprecated — prefer [decoration] with [ShapeDecoration].
  static BoxDecoration cardDecoration({
    required Color color,
    required Brightness brightness,
    double radius = defaultCardRadius,
    BorderSide? side,
    List<BoxShadow>? shadows,
  }) {
    return BoxDecoration(
      color: color,
      shape: BoxShape.rectangle,
      border: side != null ? Border.fromBorderSide(side) : null,
      borderRadius: borderRadius(radius),
      boxShadow: shadows,
    );
  }
}