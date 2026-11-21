import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/l10n/app_shell_strings.dart';
import 'package:raabta/features/home/widgets/hero_expat_score_card.dart';
import 'package:raabta/services/ai/user_profile_ai_service.dart';

/// Helpers for Expat Score presentation on Home.
class ExpatScoreProfileHelper {
  ExpatScoreProfileHelper._();

  static const Map<String, double> categoryMaxPoints = {
    'career': 25,
    'housing': 20,
    'financial': 20,
    'community': 15,
    'documentation': 10,
  };

  /// True when core profile fields needed for a meaningful score are missing.
  static bool isProfileIncomplete(UserAIProfile profile) {
    return profile.profession.trim().isEmpty ||
        profile.nationality.trim().isEmpty ||
        profile.preferredArea.trim().isEmpty;
  }

  /// Minimum personalization readiness — profession, nationality, preferredArea.
  static int profileCompletionPercent(UserAIProfile profile) {
    var filled = 0;
    const total = 3;

    if (profile.profession.trim().isNotEmpty) filled++;
    if (profile.nationality.trim().isNotEmpty) filled++;
    if (profile.preferredArea.trim().isNotEmpty) filled++;

    return ((filled / total) * 100).round().clamp(0, 100);
  }

  static String buildProfilePrompt(UserAIProfile profile, [String locale = 'English']) {
    if (profile.profession.trim().isEmpty) {
      return AppShellStrings.t('home_profile_prompt_profession', locale);
    }
    if (profile.nationality.trim().isEmpty) {
      return AppShellStrings.t('home_profile_prompt_nationality', locale);
    }
    if (profile.preferredArea.trim().isEmpty) {
      return AppShellStrings.t('home_profile_prompt_area', locale);
    }
    return AppShellStrings.t('home_profile_prompt_complete', locale);
  }

  static String scoreChipLabel({
    int? score,
    String? level,
    String locale = 'English',
  }) {
    if (score == null) {
      return AppShellStrings.t('home_build_score_chip', locale);
    }
    final levelText =
        level != null && level.trim().isNotEmpty ? level.trim() : 'Expat';
    return '⭐ $score · $levelText';
  }

  static double normalizeCategoryPercent(double rawPoints, String categoryKey) {
    final max = categoryMaxPoints[categoryKey] ?? 100;
    if (max <= 0) return 0;
    return ((rawPoints / max) * 100).clamp(0, 100);
  }

  /// Five reference categories as 0–100% bars (Career → Documentation).
  static List<ScoreCategory> categoriesFromScore(
    ExpatLifeScore score, [
    String locale = 'English',
  ]) {
    return [
      ScoreCategory(
        title: AppShellStrings.t('score_category_career', locale),
        icon: Icons.work_rounded,
        score: normalizeCategoryPercent(score.career, 'career'),
        color: AppColors.cyanGlow,
      ),
      ScoreCategory(
        title: AppShellStrings.t('score_category_housing', locale),
        icon: Icons.home_rounded,
        score: normalizeCategoryPercent(score.housing, 'housing'),
        color: AppColors.blueGlow,
      ),
      ScoreCategory(
        title: AppShellStrings.t('score_category_financial', locale),
        icon: Icons.account_balance_wallet_rounded,
        score: normalizeCategoryPercent(score.financial, 'financial'),
        color: AppColors.amberGlow,
      ),
      ScoreCategory(
        title: AppShellStrings.t('score_category_community', locale),
        icon: Icons.groups_rounded,
        score: normalizeCategoryPercent(score.community, 'community'),
        color: AppColors.purpleGlow,
      ),
      ScoreCategory(
        title: AppShellStrings.t('score_category_documentation', locale),
        icon: Icons.description_rounded,
        score: normalizeCategoryPercent(score.documentation, 'documentation'),
        color: AppColors.emeraldGlow,
      ),
    ];
  }

  /// Level label with week-over-week trend arrow from [weeklyGrowth].
  static String statusLabelWithTrend({
    required String level,
    required double weeklyGrowth,
  }) {
    final cleaned = level.replaceAll('📈', '').replaceAll('🏠', '').trim();
    if (weeklyGrowth > 0.5) return '$cleaned ↗';
    if (weeklyGrowth < -0.5) return '$cleaned ↘';
    return cleaned;
  }
}
