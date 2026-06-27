import 'package:flutter/material.dart';

/// App-wide palette. Mutable fields update instantly when [applyThemeMode] runs.
class AppColors {
  AppColors._();

  static bool _isLight = false;
  static bool get isLight => _isLight;

  static void applyThemeMode(ThemeMode mode) {
    _isLight = mode == ThemeMode.light;
    if (_isLight) {
      background = _lightBackground;
      surface = _lightSurface;
      surfaceElevated = _lightSurfaceElevated;
      card = _lightCard;
      textPrimary = _lightTextPrimary;
      textSecondary = _lightTextSecondary;
      textMuted = _lightTextMuted;
      textHint = _lightTextHint;
      border = _lightBorder;
      borderHighlight = _lightBorderHighlight;
      glass = _lightGlass;
      glassBorder = _lightGlassBorder;
    } else {
      background = _darkBackground;
      surface = _darkSurface;
      surfaceElevated = _darkSurfaceElevated;
      card = _darkCard;
      textPrimary = _darkTextPrimary;
      textSecondary = _darkTextSecondary;
      textMuted = _darkTextMuted;
      textHint = _darkTextHint;
      border = _darkBorder;
      borderHighlight = _darkBorderHighlight;
      glass = _darkGlass;
      glassBorder = _darkGlassBorder;
    }
  }

  // Dark defaults
  static const Color _darkBackground = Color(0xFF050A0F);
  static const Color _darkSurface = Color(0xFF0D1520);
  static const Color _darkSurfaceElevated = Color(0xFF111D2C);
  static const Color _darkCard = Color(0xFF0F1923);
  static const Color _darkTextPrimary = Color(0xFFE8EDF5);
  static const Color _darkTextSecondary = Color(0xFF8A9BB0);
  static const Color _darkTextMuted = Color(0xFF4A5568);
  static const Color _darkTextHint = Color(0xFF2D3748);
  static const Color _darkBorder = Color(0x1AFFFFFF);
  static const Color _darkBorderHighlight = Color(0x33FFFFFF);
  static const Color _darkGlass = Color(0x1AFFFFFF);
  static const Color _darkGlassBorder = Color(0x26FFFFFF);

  static const Color _lightBackground = Color(0xFFF4F6FA);
  static const Color _lightSurface = Color(0xFFFFFFFF);
  static const Color _lightSurfaceElevated = Color(0xFFF1F5F9);
  static const Color _lightCard = Color(0xFFFFFFFF);
  static const Color _lightTextPrimary = Color(0xFF0F172A);
  static const Color _lightTextSecondary = Color(0xFF64748B);
  static const Color _lightTextMuted = Color(0xFF94A3B8);
  static const Color _lightTextHint = Color(0xFFCBD5E1);
  static const Color _lightBorder = Color(0xFFE2E8F0);
  static const Color _lightBorderHighlight = Color(0xFFCBD5E1);
  static const Color _lightGlass = Color(0x0F0F172A);
  static const Color _lightGlassBorder = Color(0x1A0F172A);

  static Color background = _darkBackground;
  static Color surface = _darkSurface;
  static Color surfaceElevated = _darkSurfaceElevated;
  static Color card = _darkCard;
  static Color textPrimary = _darkTextPrimary;
  static Color textSecondary = _darkTextSecondary;
  static Color textMuted = _darkTextMuted;
  static Color textHint = _darkTextHint;
  static Color border = _darkBorder;
  static Color borderHighlight = _darkBorderHighlight;
  static Color glass = _darkGlass;
  static Color glassBorder = _darkGlassBorder;

  // Brand Colors
  static const Color primary = Color(0xFF22D3EE);
  static const Color primaryDark = Color(0xFF0891B2);
  static const Color secondary = Color(0xFF6366F1);
  static const Color accent = Color(0xFFA78BFA);

  static const Color gradientStart = Color(0xFF22D3EE);
  static const Color gradientMid = Color(0xFF6366F1);
  static const Color gradientEnd = Color(0xFFA78BFA);

  static const Color gold = Color(0xFFFFB800);
  static const Color goldLight = Color(0xFFFFD700);

  static const Color success = Color(0xFF34D399);
  static const Color warning = Color(0xFFFBBF24);
  static const Color error = Color(0xFFF87171);
  static const Color info = Color(0xFF60A5FA);

  static const Color scoreExcellent = Color(0xFF34D399);
  static const Color scoreGood = Color(0xFF60A5FA);
  static const Color scoreAverage = Color(0xFFFBBF24);
  static const Color scorePoor = Color(0xFFF87171);

  static const Color borderPrimary = Color(0x3322D3EE);

  static const Color verifiedGold = Color(0xFFFFB800);
  static const Color verifiedGreen = Color(0xFF34D399);
  static const Color verifiedBlue = Color(0xFF60A5FA);

  static LinearGradient get primaryGradient => LinearGradient(
        colors: const [Color(0xFF22D3EE), Color(0xFF6366F1)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFFFB800), Color(0xFFFF6B00)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient scoreGradient = LinearGradient(
    colors: [Color(0xFF22D3EE), Color(0xFF34D399)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient get darkGradient => LinearGradient(
        colors: _isLight
            ? const [_lightSurface, _lightBackground]
            : const [Color(0xFF0D1520), Color(0xFF050A0F)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );
}
