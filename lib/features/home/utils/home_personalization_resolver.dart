import 'package:raabta/features/concierge_90_day/presentation/providers/concierge_providers.dart';
import 'package:raabta/features/home/utils/expat_score_profile_helper.dart';
import 'package:raabta/features/home/utils/home_today_focus_resolver.dart';
import 'package:raabta/features/home/widgets/home_essential_tools_zone.dart';
import 'package:raabta/services/ai/expat_life_score_service.dart';
import 'package:raabta/services/ai/user_profile_ai_service.dart';

/// Identifiers for reorderable Home content blocks (below hero).
enum HomeSectionId {
  trust,
  qatarLife,
  dailyEssentials,
  forYou,
  explore,
}

/// Inputs for Home personalization — derived from existing providers only.
class HomePersonalizationInput {
  const HomePersonalizationInput({
    this.profile,
    this.expatState = const ExpatScoreState(),
    this.conciergeState,
    this.todayFocusRoute,
  });

  final UserAIProfile? profile;
  final ExpatScoreState expatState;
  final ConciergeState? conciergeState;
  final String? todayFocusRoute;
}

/// Deterministic Home personalization — no fake signals or new backends.
abstract final class HomePersonalizationResolver {
  HomePersonalizationResolver._();

  static const _defaultSectionOrder = [
    HomeSectionId.trust,
    HomeSectionId.qatarLife,
    HomeSectionId.dailyEssentials,
    HomeSectionId.forYou,
    HomeSectionId.explore,
  ];

  static bool jobSeekerSignals(HomePersonalizationInput input) {
    final profile = input.profile;
    if (profile == null) return false;

    if (profile.savedJobIds.isNotEmpty || profile.viewedJobIds.isNotEmpty) {
      return true;
    }

    if (input.todayFocusRoute == '/jobs') return true;

    final careerScore = input.expatState.score?.career;
    if (careerScore != null &&
        ExpatScoreProfileHelper.normalizeCategoryPercent(
              careerScore,
              'career',
            ) <
            50) {
      return true;
    }

    if (profile.profession.trim().isEmpty && profile.yearsExperience <= 2) {
      return true;
    }

    return false;
  }

  static bool housingSignals(HomePersonalizationInput input) {
    final profile = input.profile;
    if (profile == null) return false;

    if (profile.savedHousingIds.isNotEmpty ||
        profile.viewedHousingIds.isNotEmpty) {
      return true;
    }

    if (input.todayFocusRoute == '/housing') return true;

    final housingScore = input.expatState.score?.housing;
    if (housingScore != null &&
        ExpatScoreProfileHelper.normalizeCategoryPercent(
              housingScore,
              'housing',
            ) <
            50) {
      return true;
    }

    return false;
  }

  static bool newResidentSignals(HomePersonalizationInput input) {
    final concierge = input.conciergeState;
    if (concierge != null && concierge.shouldShowConcierge) return true;

    final profile = input.profile;
    if (profile == null) return true;
    if (ExpatScoreProfileHelper.isProfileIncomplete(profile)) return true;
    if (profile.yearsExperience <= 1) return true;

    return false;
  }

  /// Employer/agency verification — contextual for job-seeking journeys.
  static bool shouldShowVerificationLinks(HomePersonalizationInput input) {
    return jobSeekerSignals(input);
  }

  static List<HomeSectionId> sectionOrder(HomePersonalizationInput input) {
    if (jobSeekerSignals(input)) {
      return const [
        HomeSectionId.trust,
        HomeSectionId.explore,
        HomeSectionId.dailyEssentials,
        HomeSectionId.forYou,
        HomeSectionId.qatarLife,
      ];
    }

    if (housingSignals(input)) {
      return const [
        HomeSectionId.trust,
        HomeSectionId.explore,
        HomeSectionId.qatarLife,
        HomeSectionId.dailyEssentials,
        HomeSectionId.forYou,
      ];
    }

    if (newResidentSignals(input)) {
      return const [
        HomeSectionId.trust,
        HomeSectionId.qatarLife,
        HomeSectionId.explore,
        HomeSectionId.dailyEssentials,
        HomeSectionId.forYou,
      ];
    }

    return _defaultSectionOrder;
  }

  /// Ranked Qatar Life preview routes using existing profile fields.
  static List<String> qatarLifePreviewRoutes(
    UserAIProfile? profile, {
    int maxVisible = 5,
  }) {
    const all = HomeEssentialToolsZone.qatarLifeRoutes;
    final weights = {for (final route in all) route: 0};

    if (profile != null) {
      if (profile.preferredArea.trim().isNotEmpty) {
        weights['/climate-navigator'] =
            (weights['/climate-navigator'] ?? 0) + 40;
        weights['/queue-avoidance'] = (weights['/queue-avoidance'] ?? 0) + 35;
      }

      if (profile.yearsExperience <= 2 ||
          ExpatScoreProfileHelper.isProfileIncomplete(profile)) {
        weights['/know-qatar'] = (weights['/know-qatar'] ?? 0) + 50;
        weights['/arabic-companion'] =
            (weights['/arabic-companion'] ?? 0) + 45;
      }

      final interests = profile.interests.map((e) => e.toLowerCase()).toList();
      if (interests.any(
        (i) => i.contains('travel') || i.contains('trip'),
      )) {
        weights['/trip-planner'] = (weights['/trip-planner'] ?? 0) + 55;
      }
    }

    weights['/climate-navigator'] = (weights['/climate-navigator'] ?? 0) + 15;
    weights['/know-qatar'] = (weights['/know-qatar'] ?? 0) + 10;

    final sorted = [...all]
      ..sort(
        (a, b) => (weights[b] ?? 0).compareTo(weights[a] ?? 0),
      );
    return sorted.take(maxVisible.clamp(1, all.length)).toList(growable: false);
  }
}

/// Convenience helper for focus route used in personalization.
String? resolveTodayFocusRoute({
  required ExpatScoreState expatState,
  required List<ScoreAction> improvementActions,
  required ConciergeState? conciergeState,
  required String locale,
}) {
  return HomeTodayFocusResolver.resolve(
    expatState: expatState,
    improvementActions: improvementActions,
    conciergeState: conciergeState,
    locale: locale,
  ).route;
}
