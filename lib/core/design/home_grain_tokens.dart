import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Home-only film grain (Round 4B Batch F). Alpha is baked into PNG assets.
abstract final class HomeGrainTokens {
  HomeGrainTokens._();

  static const double tilePixelSize = 128;

  static const darkAssetPath =
      'assets/home_materiality_assets/home_grain_dark.png';

  static const lightSoftAssetPath =
      'assets/home_materiality_assets/home_grain_light_soft.png';

  static const lightFullAssetPath =
      'assets/home_materiality_assets/home_grain_light.png';

  /// Global strength knob (single token — tune in one place).
  static const double defaultStrength = 1.0;

  /// Logical size so one source pixel maps to one device pixel.
  static double logicalTileSize(double devicePixelRatio) {
    final dpr = devicePixelRatio > 0 ? devicePixelRatio : 1.0;
    return tilePixelSize / dpr;
  }

  static String assetPathFor(
    Brightness brightness, {
    bool preferSoftLight = true,
  }) {
    if (brightness == Brightness.dark) {
      return darkAssetPath;
    }
    return preferSoftLight ? lightSoftAssetPath : lightFullAssetPath;
  }

  /// Whether grain should render (Batch F wires platform flags).
  static bool shouldShowGrain({
    required bool reduceMotion,
    required MediaQueryData mediaQuery,
    PlatformDispatcher? dispatcher,
  }) {
    if (reduceMotion) return false;
    if (mediaQuery.disableAnimations && !kIsWeb) return false;
    if (mediaQuery.accessibleNavigation) return false;

    final features =
        dispatcher?.accessibilityFeatures ??
            PlatformDispatcher.instance.accessibilityFeatures;
    if (features.reduceMotion || features.disableAnimations) {
      return false;
    }
    return true;
  }
}