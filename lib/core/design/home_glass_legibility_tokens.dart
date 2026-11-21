import 'package:raabta/core/spacing/app_spacing.dart';

/// Minimum opacity / blur for Home pinned chrome (Round 4C).
abstract final class HomeGlassLegibilityTokens {
  HomeGlassLegibilityTokens._();

  /// Pinned search pill + collapsed Doha glass bar fill.
  static const double pinnedSurfaceAlpha = 0.94;

  /// Collapsed bar backdrop blur when glass path is used (e.g. web dark).
  static const double pinnedBarBlurSigma = 20;

  /// Home tab floating nav pill.
  static const double homeNavSurfaceAlpha = 0.88;

  static const double homeNavBlurSigma = 20;

  /// Fallback when blur is enabled on generic glass surfaces.
  static const double fallbackBlurSigma = AppSpacing.glassBlur;

  /// Bottom gradient scrim above scroll-under-nav on Home.
  static const double bottomScrimMidAlpha = 0.68;

  static const double bottomScrimHighAlpha = 0.97;
}