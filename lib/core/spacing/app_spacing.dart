/// Shared spacing, sizing, and motion tokens for the RAABTA design system.
class AppSpacing {
  AppSpacing._();

  // Spacing scale
  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
  static const double xxxl = 64;

  // Border radius
  static const double radiusXs = 8;
  static const double radiusSm = 12;
  /// Kit glass bar controls (AI header back / menu).
  static const double radiusBarControl = 14;
  static const double radiusMd = 18;
  static const double radiusLg = 24;
  static const double radiusXl = 28;
  static const double radiusFull = 100;

  // Icon sizes
  static const double iconXs = 12;
  static const double iconSm = 16;
  static const double iconMd = 20;
  static const double iconLg = 24;
  static const double iconXl = 32;

  // Avatar sizes
  static const double avatarSm = 32;
  static const double avatarMd = 40;
  static const double avatarLg = 56;

  /// AI composer pill height (kit living refs).
  static const double aiComposerHeight = 54;

  // App bar
  static const double appBarHeight = 56;

  // Floating navigation
  static const double navHeight = 64;
  static const double navRadius = 32;
  static const double navBottomMargin = 20;
  static const double navHorizontalMargin = 20;

  // Glass components
  static const double glassBlur = 20;
  static const double glassBorderWidth = 1;
  static const double glassGlowBlur = 24;

  // Card padding
  static const double cardPadding = 16;
  static const double sectionSpacing = 24;
  static const double screenHorizontalPadding = 16;
  static const double screenVerticalPadding = 16;

  // Animation durations
  static const Duration tapAnimation = Duration(milliseconds: 120);
  static const Duration contentAnimation = Duration(milliseconds: 200);
  static const Duration ambientAnimation = Duration(milliseconds: 8000);
}
