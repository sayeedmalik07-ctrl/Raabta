import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:raabta/core/design/app_colors.dart';
import 'package:raabta/core/design/app_text_styles.dart';

class AppTheme {
  AppTheme._();

  static final ThemeData light = _buildLight();
  static final ThemeData dark = _buildDark();

  static ThemeData _buildDark() {
    final base = _baseDark();
    return base.copyWith(
      textTheme: GoogleFonts.interTextTheme(base.textTheme),
    );
  }

  static ThemeData _buildLight() {
    final base = _baseLight();
    return base.copyWith(
      textTheme: GoogleFonts.interTextTheme(base.textTheme),
    );
  }

  static ThemeData _baseDark() => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        primaryColor: AppColors.primary,
        colorScheme: ColorScheme.dark(
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          surface: AppColors.surface,
          error: AppColors.error,
        ),
        cardColor: AppColors.card,
        dividerColor: AppColors.border,
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: AppTextStyles.h2,
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: AppColors.surface,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textMuted,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
        ),
        iconTheme: IconThemeData(color: AppColors.textSecondary),
        listTileTheme: ListTileThemeData(
          tileColor: AppColors.surface,
          selectedTileColor: AppColors.surfaceElevated,
          iconColor: AppColors.textSecondary,
        ),
        textTheme: TextTheme(
          displayLarge: AppTextStyles.displayLarge,
          displayMedium: AppTextStyles.displayMedium,
          headlineLarge: AppTextStyles.h1,
          headlineMedium: AppTextStyles.h2,
          headlineSmall: AppTextStyles.h3,
          bodyLarge: AppTextStyles.bodyLarge,
          bodyMedium: AppTextStyles.bodyMedium,
          bodySmall: AppTextStyles.bodySmall,
          labelLarge: AppTextStyles.labelLarge,
        ),
      );

  static ThemeData _baseLight() => ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF4F6FA),
        primaryColor: AppColors.primary,
        colorScheme: ColorScheme.light(
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          surface: Colors.white,
          error: AppColors.error,
        ),
        cardColor: Colors.white,
        dividerColor: const Color(0xFFE2E8F0),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF0F172A),
          elevation: 0,
          centerTitle: false,
          titleTextStyle: AppTextStyles.h2.copyWith(
            color: const Color(0xFF0F172A),
          ),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: const Color(0xFF94A3B8),
          type: BottomNavigationBarType.fixed,
          elevation: 0,
        ),
        iconTheme: const IconThemeData(color: Color(0xFF64748B)),
        listTileTheme: const ListTileThemeData(
          tileColor: Colors.white,
          selectedTileColor: Color(0xFFF1F5F9),
          iconColor: Color(0xFF64748B),
        ),
        textTheme: TextTheme(
          displayLarge: AppTextStyles.displayLarge
              .copyWith(color: const Color(0xFF0F172A)),
          displayMedium: AppTextStyles.displayMedium
              .copyWith(color: const Color(0xFF0F172A)),
          headlineLarge:
              AppTextStyles.h1.copyWith(color: const Color(0xFF0F172A)),
          headlineMedium:
              AppTextStyles.h2.copyWith(color: const Color(0xFF0F172A)),
          headlineSmall:
              AppTextStyles.h3.copyWith(color: const Color(0xFF0F172A)),
          bodyLarge:
              AppTextStyles.bodyLarge.copyWith(color: const Color(0xFF334155)),
          bodyMedium:
              AppTextStyles.bodyMedium.copyWith(color: const Color(0xFF334155)),
          bodySmall:
              AppTextStyles.bodySmall.copyWith(color: const Color(0xFF64748B)),
          labelLarge:
              AppTextStyles.labelLarge.copyWith(color: const Color(0xFF0F172A)),
        ),
      );
}
