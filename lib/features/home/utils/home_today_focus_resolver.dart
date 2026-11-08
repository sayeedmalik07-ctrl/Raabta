import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/l10n/app_shell_strings.dart';
import 'package:raabta/features/concierge_90_day/data/models/journey_milestone.dart';
import 'package:raabta/features/concierge_90_day/presentation/l10n/concierge_strings.dart';
import 'package:raabta/features/concierge_90_day/presentation/providers/concierge_providers.dart';
import 'package:raabta/services/ai/expat_life_score_service.dart';
import 'package:raabta/services/ai/user_profile_ai_service.dart';

/// Resolved content for [TodaysFocusCard] on Home.
class TodayFocusContent {
  const TodayFocusContent({
    required this.title,
    required this.description,
    required this.estimatedTime,
    required this.actionLabel,
    required this.icon,
    required this.accentColor,
    required this.route,
    this.highPriority = false,
    this.openExpatScore = false,
  });

  final String title;
  final String description;
  final String estimatedTime;
  final String actionLabel;
  final IconData icon;
  final Color accentColor;
  final String route;
  final bool highPriority;
  final bool openExpatScore;
}

abstract final class HomeTodayFocusResolver {
  static TodayFocusContent resolve({
    required ExpatScoreState expatState,
    required List<ScoreAction> improvementActions,
    required ConciergeState? conciergeState,
    required String locale,
  }) {
    final action =
        improvementActions.isNotEmpty ? improvementActions.first : null;
    if (action != null) {
      return TodayFocusContent(
        title: action.title,
        description: action.description,
        estimatedTime: action.estimatedTime,
        actionLabel: AppShellStrings.t('home_continue', locale),
        icon: Icons.assignment_rounded,
        accentColor: AppColors.cyanGlow,
        route: '/expat-score',
        highPriority: true,
        openExpatScore: true,
      );
    }

    final milestone = _conciergeMilestone(conciergeState);
    if (milestone != null) {
      return TodayFocusContent(
        title: ConciergeStrings.t(milestone.titleKey, locale),
        description: ConciergeStrings.t(milestone.descriptionKey, locale),
        estimatedTime: '5 min',
        actionLabel: ConciergeStrings.t(milestone.actionKey, locale),
        icon: Icons.flag_outlined,
        accentColor: AppColors.cyanGlow,
        route: milestone.route,
        highPriority: true,
      );
    }

    final score = expatState.score;
    if (score != null) {
      final category = _weakestCategoryKey(score);
      if (category != null) {
        return _fromCategory(category, locale);
      }
    }

    return TodayFocusContent(
      title: AppShellStrings.t('home_focus_explore_score_title', locale),
      description: AppShellStrings.t('home_focus_explore_score_desc', locale),
      estimatedTime: '3 min',
      actionLabel: AppShellStrings.t('home_view_score', locale),
      icon: Icons.insights_outlined,
      accentColor: AppColors.amberGlow,
      route: '/expat-score',
      openExpatScore: true,
    );
  }

  static JourneyMilestone? _conciergeMilestone(ConciergeState? state) {
    if (state == null || !state.shouldShowConcierge) return null;
    return state.snapshot?.nextMilestone;
  }

  static String? _weakestCategoryKey(ExpatLifeScore score) {
    final entries = <MapEntry<String, double>>[
      MapEntry('career', score.career),
      MapEntry('housing', score.housing),
      MapEntry('financial', score.financial),
      MapEntry('community', score.community),
      MapEntry('health', score.health),
      MapEntry('documentation', score.documentation),
    ];
    entries.sort((a, b) => a.value.compareTo(b.value));
    final weakest = entries.first;
    if (weakest.value >= 12) return null;
    return weakest.key;
  }

  static TodayFocusContent _fromCategory(String category, String locale) {
    return switch (category) {
      'career' => TodayFocusContent(
          title: AppShellStrings.t('home_focus_career_title', locale),
          description: AppShellStrings.t('home_focus_career_desc', locale),
          estimatedTime: '5 min',
          actionLabel: AppShellStrings.t('home_focus_career_action', locale),
          icon: Icons.work_outline_rounded,
          accentColor: AppColors.cyanGlow,
          route: '/jobs',
        ),
      'housing' => TodayFocusContent(
          title: AppShellStrings.t('home_focus_housing_title', locale),
          description: AppShellStrings.t('home_focus_housing_desc', locale),
          estimatedTime: '5 min',
          actionLabel: AppShellStrings.t('home_focus_housing_action', locale),
          icon: Icons.home_outlined,
          accentColor: AppColors.blueGlow,
          route: '/housing',
        ),
      'financial' => TodayFocusContent(
          title: AppShellStrings.t('home_focus_financial_title', locale),
          description: AppShellStrings.t('home_focus_financial_desc', locale),
          estimatedTime: '3 min',
          actionLabel: AppShellStrings.t('home_focus_financial_action', locale),
          icon: Icons.account_balance_wallet_outlined,
          accentColor: AppColors.amberGlow,
          route: '/money',
        ),
      'community' => TodayFocusContent(
          title: AppShellStrings.t('home_focus_community_title', locale),
          description: AppShellStrings.t('home_focus_community_desc', locale),
          estimatedTime: '2 min',
          actionLabel: AppShellStrings.t('home_focus_community_action', locale),
          icon: Icons.groups_outlined,
          accentColor: AppColors.purpleGlow,
          route: '/community',
        ),
      'documentation' => TodayFocusContent(
          title: AppShellStrings.t('home_focus_documentation_title', locale),
          description: AppShellStrings.t('home_focus_documentation_desc', locale),
          estimatedTime: '3 min',
          actionLabel: AppShellStrings.t('home_focus_documentation_action', locale),
          icon: Icons.description_outlined,
          accentColor: AppColors.emeraldGlow,
          route: '/visa',
        ),
      _ => TodayFocusContent(
          title: AppShellStrings.t('home_focus_health_title', locale),
          description: AppShellStrings.t('home_focus_health_desc', locale),
          estimatedTime: '3 min',
          actionLabel: AppShellStrings.t('home_focus_health_action', locale),
          icon: Icons.local_hospital_outlined,
          accentColor: AppColors.roseGlow,
          route: '/health-insurance/compliance',
        ),
    };
  }
}
