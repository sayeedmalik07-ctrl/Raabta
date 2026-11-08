import 'package:flutter/material.dart';
import 'package:raabta/core/navigation/shell_nav_config.dart';
import 'package:raabta/features/home/domain/home_ai_assistant_action.dart';
import 'package:raabta/features/home/l10n/home_floating_ai_strings.dart';
import 'package:raabta/features/home/utils/expat_score_profile_helper.dart';
import 'package:raabta/services/ai/expat_life_score_service.dart';
import 'package:raabta/services/ai/user_profile_ai_service.dart';
import 'package:raabta/services/intelligence/home_intelligence_focus_service.dart';

/// Resolves up to three contextual actions from Home state already on screen.
abstract final class HomeAiAssistantActionResolver {
  static const maxActions = 3;

  static const _profileRoute = '/profile/progressive-capture';
  static const _expatScoreRoute = '/expat-score';
  static const _jobsRoute = '/jobs';
  static const _housingRoute = '/housing';
  static const _visaRoute = '/visa';

  static List<HomeAiAssistantAction> resolve({
    required ExpatScoreState expatState,
    required List<HomeIntelligenceFocusItem> intelligenceItems,
    required String locale,
    UserAIProfile? profile,
    String? authUid,
    required bool personalizationEnabled,
  }) {
    final actions = <HomeAiAssistantAction>[];

    void tryAdd(HomeAiAssistantAction action) {
      if (actions.length >= maxActions) return;
      actions.add(action);
    }

    final profileOwned = authUid != null &&
        authUid.isNotEmpty &&
        profile != null &&
        UserProfileOwnership.matches(profile, authUid);

    if (profileOwned &&
        ExpatScoreProfileHelper.isProfileIncomplete(profile)) {
      tryAdd(
        HomeAiAssistantAction(
          id: 'complete_profile',
          label: HomeFloatingAiStrings.t('action_complete_profile', locale),
          summary: HomeFloatingAiStrings.t(
            'summary_complete_profile',
            locale,
          ),
          icon: Icons.person_outline_rounded,
          target: const HomeAiAssistantRouteTarget(_profileRoute),
        ),
      );
    }

    if (expatState.score != null) {
      tryAdd(
        HomeAiAssistantAction(
          id: 'understand_expat_score',
          label: HomeFloatingAiStrings.t('action_understand_expat_score', locale),
          summary: HomeFloatingAiStrings.t(
            'summary_understand_expat_score',
            locale,
          ),
          icon: Icons.insights_outlined,
          target: const HomeAiAssistantRouteTarget(_expatScoreRoute),
        ),
      );
    }

    if (personalizationEnabled && intelligenceItems.isNotEmpty) {
      final route = _routeForInsight(intelligenceItems.first.insightType);
      if (route != null) {
        tryAdd(
          HomeAiAssistantAction(
            id: 'home_alert',
            label: HomeFloatingAiStrings.t('action_home_alert', locale),
            summary: HomeFloatingAiStrings.t('summary_home_alert', locale),
            icon: Icons.notifications_active_outlined,
            target: HomeAiAssistantRouteTarget(route),
          ),
        );
      }
    }

    for (final entry in _staticFallbacks(locale)) {
      if (actions.length >= maxActions) break;
      if (actions.any(
        (action) =>
            action.target is HomeAiAssistantRouteTarget &&
            (action.target as HomeAiAssistantRouteTarget).route == entry.route,
      )) {
        continue;
      }
      tryAdd(
        HomeAiAssistantAction(
          id: entry.id,
          label: entry.label,
          summary: entry.summary,
          icon: entry.icon,
          target: HomeAiAssistantRouteTarget(entry.route),
        ),
      );
    }

    return actions;
  }

  /// Context passed to Ask Raabta — generic when personalization is off.
  static String askRaabtaContextBody({
    required String locale,
    required bool personalizationEnabled,
  }) {
    if (!personalizationEnabled) {
      return HomeFloatingAiStrings.t('context_ask_generic', locale);
    }
    return HomeFloatingAiStrings.t('context_ask_generic', locale);
  }

  static List<({String id, String route, String label, String summary, IconData icon})>
      _staticFallbacks(String locale) {
    return [
      (
        id: 'find_work',
        route: _jobsRoute,
        label: HomeFloatingAiStrings.t('action_find_work', locale),
        summary: HomeFloatingAiStrings.t('summary_find_work', locale),
        icon: Icons.work_outline_rounded,
      ),
      (
        id: 'housing_help',
        route: _housingRoute,
        label: HomeFloatingAiStrings.t('action_housing_help', locale),
        summary: HomeFloatingAiStrings.t('summary_housing_help', locale),
        icon: Icons.home_outlined,
      ),
      (
        id: 'visa_guidance',
        route: _visaRoute,
        label: HomeFloatingAiStrings.t('action_visa_guidance', locale),
        summary: HomeFloatingAiStrings.t('summary_visa_guidance', locale),
        icon: Icons.description_outlined,
      ),
    ];
  }

  static String? _routeForInsight(String insightType) {
    final normalized = insightType.toLowerCase();
    if (normalized.contains('eosb') || normalized.contains('overtime')) {
      return '/eosb';
    }
    if (normalized.contains('health')) {
      return '/health-insurance/compliance';
    }
    if (normalized.contains('vault') ||
        normalized.contains('expiry') ||
        normalized.contains('document')) {
      return '/document-vault';
    }
    if (normalized.contains('visa')) {
      return _visaRoute;
    }
    return null;
  }
}

/// Whether the Home floating AI assistant should render on screen.
bool isHomeFloatingAiAssistantVisible({
  required ShellTab currentTab,
  required bool postDialOpen,
}) {
  return currentTab == ShellTab.home && !postDialOpen;
}
