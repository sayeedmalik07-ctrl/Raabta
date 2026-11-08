import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';

/// WBGT band visuals for Climate Navigator status (Part A) — semantic [AppColors] only.
abstract final class ClimateWbgtStatusPresentation {
  static Color accentForLevel(String levelKey) {
    switch (levelKey) {
      case 'work_stop':
        return AppColors.errorBright;
      case 'extreme':
        return AppColors.error;
      case 'high':
        return AppColors.heatOrange;
      case 'moderate':
        return AppColors.accentGold;
      default:
        return AppColors.success;
    }
  }

  static IconData iconForLevel(String levelKey) {
    switch (levelKey) {
      case 'work_stop':
        return Icons.stop_circle_outlined;
      case 'extreme':
        return Icons.warning_amber_rounded;
      case 'high':
        return Icons.whatshot_outlined;
      case 'moderate':
        return Icons.wb_cloudy_outlined;
      default:
        return Icons.ac_unit_outlined;
    }
  }

  static String narrationGuidanceKeyForLevel(String levelKey) {
    switch (levelKey) {
      case 'work_stop':
        return 'wbgt_narration_guidance_work_stop';
      case 'extreme':
        return 'wbgt_narration_guidance_extreme';
      case 'high':
        return 'wbgt_narration_guidance_high';
      case 'moderate':
        return 'wbgt_narration_guidance_moderate';
      default:
        return 'wbgt_narration_guidance_lower';
    }
  }

  static String guidanceKeyForLevel(String levelKey) {
    switch (levelKey) {
      case 'work_stop':
        return 'wbgt_band_guidance_work_stop';
      case 'extreme':
        return 'wbgt_band_guidance_extreme';
      case 'high':
        return 'wbgt_band_guidance_high';
      case 'moderate':
        return 'wbgt_band_guidance_moderate';
      default:
        return 'wbgt_band_guidance_lower';
    }
  }

  /// Large metric / short label colour — falls back to [AppColors.textPrimary] when
  /// band accent fails WCAG 3:1 large-text contrast on the hero backdrop.
  static Color metricColorForLevel(String levelKey) {
    final accent = accentForLevel(levelKey);
    final backdrop = AppColors.isLight
        ? const Color(0xFFFFFFFF)
        : const Color(0xFF0A0E1A);
    final l1 = accent.computeLuminance();
    final l2 = backdrop.computeLuminance();
    final lighter = l1 > l2 ? l1 : l2;
    final darker = l1 > l2 ? l2 : l1;
    final ratio = (lighter + 0.05) / (darker + 0.05);
    return ratio >= 3.0 ? accent : AppColors.textPrimary;
  }

  static String shortLabelKeyForLevel(String levelKey) {
    switch (levelKey) {
      case 'work_stop':
        return 'wbgt_band_short_work_stop';
      case 'extreme':
        return 'wbgt_band_short_extreme';
      case 'high':
        return 'wbgt_band_short_high';
      case 'moderate':
        return 'wbgt_band_short_moderate';
      default:
        return 'wbgt_band_short_lower';
    }
  }
}
