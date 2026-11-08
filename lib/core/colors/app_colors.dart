import 'package:flutter/material.dart';

/// Shared color tokens for the RAABTA glass design system.
/// Semantic surface/text/glass colors update via [applyBrightness].
class AppColors {
  AppColors._();

  static bool _isLight = false;
  static bool get isLight => _isLight;

  // Dark palette (defaults)
  static const Color _darkBackground = Color(0xFF0A0E1A);
  static const Color _darkBackgroundMid = Color(0xFF0D1221);
  static const Color _darkSurface = Color(0xFF121829);
  static const Color _darkSurfaceElevated = Color(0xFF1A2035);
  static const Color _darkGlassSurface = Color(0x1AFFFFFF);
  static const Color _darkGlassBorder = Color(0x14FFFFFF);
  static const Color _darkGlassBorderBright = Color(0x33FFFFFF);
  static const Color _darkTextPrimary = Color(0xFFF8FAFC);
  static const Color _darkTextSecondary = Color(0xFF94A3B8);
  static const Color _darkTextTertiary = Color(0xFF64748B);
  static const Color _darkInactiveNavigation = Color(0xFF64748B);
  static const Color _darkShareCardBackground = Color(0xFF0A0620);

  // Light palette
  static const Color _lightBackground = Color(0xFFF4F6FA);
  static const Color _lightBackgroundMid = Color(0xFFEEF2F7);
  static const Color _lightSurface = Color(0xFFFFFFFF);
  static const Color _lightSurfaceElevated = Color(0xFFF1F5F9);
  static const Color _lightGlassSurface = Color(0xBFFFFFFF);
  static const Color _lightGlassBorder = Color(0x260F172A);
  static const Color _lightGlassBorderBright = Color(0x330F172A);
  static const Color _lightTextPrimary = Color(0xFF0F172A);
  static const Color _lightTextSecondary = Color(0xFF475569);
  static const Color _lightTextTertiary = Color(0xFF64748B);
  static const Color _lightInactiveNavigation = Color(0xFF94A3B8);
  static const Color _lightShareCardBackground = Color(0xFFF8FAFC);

  static Color background = _darkBackground;
  static Color backgroundMid = _darkBackgroundMid;
  static Color surface = _darkSurface;
  static Color surfaceElevated = _darkSurfaceElevated;
  static Color glassSurface = _darkGlassSurface;
  static Color glassBorder = _darkGlassBorder;
  static Color glassBorderBright = _darkGlassBorderBright;
  static Color textPrimary = _darkTextPrimary;
  static Color textSecondary = _darkTextSecondary;
  static Color textTertiary = _darkTextTertiary;
  static Color inactiveNavigation = _darkInactiveNavigation;
  static Color shareCardBackground = _darkShareCardBackground;

  /// Syncs mutable semantic colors when effective brightness changes.
  static void applyBrightness(bool isLight) {
    _isLight = isLight;
    if (isLight) {
      background = _lightBackground;
      backgroundMid = _lightBackgroundMid;
      surface = _lightSurface;
      surfaceElevated = _lightSurfaceElevated;
      glassSurface = _lightGlassSurface;
      glassBorder = _lightGlassBorder;
      glassBorderBright = _lightGlassBorderBright;
      textPrimary = _lightTextPrimary;
      textSecondary = _lightTextSecondary;
      textTertiary = _lightTextTertiary;
      inactiveNavigation = _lightInactiveNavigation;
      shareCardBackground = _lightShareCardBackground;
    } else {
      background = _darkBackground;
      backgroundMid = _darkBackgroundMid;
      surface = _darkSurface;
      surfaceElevated = _darkSurfaceElevated;
      glassSurface = _darkGlassSurface;
      glassBorder = _darkGlassBorder;
      glassBorderBright = _darkGlassBorderBright;
      textPrimary = _darkTextPrimary;
      textSecondary = _darkTextSecondary;
      textTertiary = _darkTextTertiary;
      inactiveNavigation = _darkInactiveNavigation;
      shareCardBackground = _darkShareCardBackground;
    }
  }

  // Brand colors — fixed across themes
  static const Color cyanGlow = Color(0xFF00D4FF);
  static const Color purpleGlow = Color(0xFF7B61FF);
  static const Color blueGlow = Color(0xFF3B82F6);
  static const Color emeraldGlow = Color(0xFF10B981);
  static const Color amberGlow = Color(0xFFF59E0B);
  static const Color roseGlow = Color(0xFFF43F5E);
  static const Color iceCyanGlow = Color(0xFF67E8F9);
  static const Color tealGlow = Color(0xFF14B8A6);

  static const Color textAccent = cyanGlow;

  static const Color success = emeraldGlow;
  static const Color warning = amberGlow;
  static const Color error = roseGlow;
  static const Color info = cyanGlow;

  static const Color successBright = Color(0xFF2DC653);
  static const Color errorBright = Color(0xFFE63946);
  static const Color accentGold = Color(0xFFFFB627);
  static const Color heatOrange = Color(0xFFFF6B35);
  static const Color pinkAccent = Color(0xFFEC4899);
  static const Color sharePurple = Color(0xFF6C3FC5);
  static const Color sharePurpleLight = Color(0xFF9B59B6);

  /// Raabta Home design kit v2.1 — brand family (Explore core services).
  static const Color brandFamilyDark = Color(0xFF9B7BFF);
  static const Color brandFamilyLightDeep = Color(0xFF4A2A96);

  /// Primary brand accent for the current theme (dark / light main).
  static Color get brandFamilyMain =>
      _isLight ? sharePurple : brandFamilyDark;

  /// Deep brand for labels and emphasis on light surfaces.
  static Color get brandFamilyText =>
      _isLight ? brandFamilyLightDeep : brandFamilyDark;

  /// Raabta Home design kit v2.1 — gold family (Truth Engines, money tools).
  static const Color goldFamilyLight = Color(0xFFE39A00);
  static const Color goldFamilyLightDeep = Color(0xFF8A5A00);

  /// Primary gold accent for the current theme (dark uses [accentGold]).
  static Color get goldFamilyMain =>
      _isLight ? goldFamilyLight : accentGold;

  /// Deep gold for emphasis on light surfaces.
  static Color get goldFamilyText =>
      _isLight ? goldFamilyLightDeep : accentGold;

  /// Raabta Home design kit v2.1 — teal family (Prayer, lifestyle tools).
  static const Color tealFamilyDark = Color(0xFF2DD4BF);
  static const Color tealFamilyLight = Color(0xFF12A596);
  static const Color tealFamilyLightDeep = Color(0xFF0A6B61);

  /// Primary teal accent for the current theme.
  static Color get tealFamilyMain =>
      _isLight ? tealFamilyLight : tealFamilyDark;

  /// Deep teal for labels and emphasis on light surfaces.
  static Color get tealFamilyText =>
      _isLight ? tealFamilyLightDeep : tealFamilyDark;

  /// Raabta Home design kit v2.1 — green semantic (ScamShield calm, success).
  static const Color greenFamilyDark = Color(0xFF2ED3A0);
  static const Color greenFamilyLight = Color(0xFF12A877);
  static const Color greenFamilyLightDeep = Color(0xFF0A6F4D);

  /// Primary green accent for the current theme.
  static Color get greenFamilyMain =>
      _isLight ? greenFamilyLight : greenFamilyDark;

  /// Deep green for labels and emphasis on light surfaces.
  static Color get greenFamilyText =>
      _isLight ? greenFamilyLightDeep : greenFamilyDark;

  static const Color quickActionBlue = Color(0xFF3B82F6);
  static const Color quickActionGreen = Color(0xFF34D399);
  static const Color quickActionYellow = Color(0xFFFBBF24);
  static const Color quickActionIndigo = Color(0xFF6366F1);
  static const Color quickActionCyan = Color(0xFF22D3EE);

  static const List<Color> scoreGradient = [
    cyanGlow,
    blueGlow,
    purpleGlow,
    amberGlow,
  ];

  static const Color chipScanner = Color(0xFF00D4FF);
  static const Color chipFood = Color(0xFF34D399);
  static const Color chipCommunity = Color(0xFF14B8A6);
  static const Color chipLease = Color(0xFFF97316);
  static const Color chipWage = Color(0xFF10B981);
  static const Color chipClimate = Color(0xFF67E8F9);
  static const Color chipQueue = Color(0xFF7B61FF);
  static const Color chipEosb = Color(0xFF10B981);
  static const Color chipHealthInsurance = Color(0xFF0EA5E9);
  static const Color chipSponsorshipTransfer = Color(0xFF8B5CF6);
  static const Color chipPrayer = Color(0xFF14B8A6);
  static const Color chipTrip = Color(0xFF3B82F6);

  static const Color activeNavigation = cyanGlow;

  static Color get textOnGlassSecondary =>
      _isLight ? _lightTextSecondary : _darkTextSecondary;

  static Color get textOnGlassMuted =>
      _isLight ? _lightTextTertiary : _darkTextTertiary;

  /// Theme-aware link color — darker cyan in light mode for WCAG contrast on glass.
  static Color get link => _isLight ? const Color(0xFF0284C7) : cyanGlow;

  static Color get divider => glassBorder;

  static const Color shadowSoft = Color(0x14000000);
  static const Color shadowStrong = Color(0x26000000);
}
