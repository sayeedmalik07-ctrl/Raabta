import 'package:raabta/core/l10n/app_shell_strings.dart';
import 'package:raabta/features/home/utils/expat_score_profile_helper.dart';
import 'package:raabta/screens/expat_score/l10n/expat_score_strings.dart';
import 'package:raabta/screens/profile/l10n/progressive_profile_strings.dart';
import 'package:raabta/services/ai/expat_life_score_service.dart';
import 'package:raabta/services/ai/user_profile_ai_service.dart';

/// One profile field chip in the setup Today hero.
class TodayHeroSetupStep {
  const TodayHeroSetupStep({
    required this.label,
    required this.complete,
  });

  final String label;
  final bool complete;
}

/// Visual phase for the adaptive Home Expat / profile hero.
enum HomeExpatHeroPhase {
  guest,
  loading,
  setup,
  populated,
}

/// Pure mapping from profile and score signals to hero copy and ring values.
abstract final class HomeExpatHeroPresenter {
  static HomeExpatHeroPhase phase({
    required bool isSignedIn,
    required bool isLoading,
    required bool scoreReady,
    required bool profileIncomplete,
  }) {
    if (!isSignedIn) return HomeExpatHeroPhase.guest;
    if (isLoading) return HomeExpatHeroPhase.loading;
    if (scoreReady && !profileIncomplete) {
      return HomeExpatHeroPhase.populated;
    }
    return HomeExpatHeroPhase.setup;
  }

  static bool profileIncomplete(UserAIProfile? profile) {
    return profile == null ||
        ExpatScoreProfileHelper.isProfileIncomplete(profile);
  }

  static int profileCompletionPercent(UserAIProfile? profile) {
    if (profile == null) return 0;
    return ExpatScoreProfileHelper.profileCompletionPercent(profile);
  }

  static double expatScoreValue(ExpatScoreState expatState) {
    final score = expatState.score?.total;
    if (score == null) return 0;
    return score.clamp(0, 100).toDouble();
  }

  static double ringScore({
    required HomeExpatHeroPhase phase,
    required ExpatScoreState expatState,
    required UserAIProfile? profile,
  }) {
    switch (phase) {
      case HomeExpatHeroPhase.guest:
      case HomeExpatHeroPhase.loading:
        return 0;
      case HomeExpatHeroPhase.setup:
        return profileCompletionPercent(profile).toDouble();
      case HomeExpatHeroPhase.populated:
        return expatScoreValue(expatState);
    }
  }

  static String subtitle({
    required HomeExpatHeroPhase phase,
    required bool profileIncomplete,
    required bool scoreReady,
    ExpatLifeScore? score,
    required UserAIProfile? profile,
    required String locale,
  }) {
    if (phase == HomeExpatHeroPhase.guest) {
      return AppShellStrings.t('home_hero_guest_body', locale);
    }
    if (phase == HomeExpatHeroPhase.loading) {
      return AppShellStrings.t('home_calculating', locale);
    }
    if (profileIncomplete) {
      final percent = profileCompletionPercent(profile);
      return AppShellStrings.format(
        'home_profile_percent',
        locale,
        params: {'percent': '$percent'},
      );
    }
    if (!scoreReady) {
      return AppShellStrings.t('home_build_profile', locale);
    }
    if (score != null) {
      return ExpatScoreStrings.levelLabelForTotal(score.total, locale);
    }
    return AppShellStrings.t('home_updated_today', locale);
  }

  static String insight({
    required HomeExpatHeroPhase phase,
    required bool profileIncomplete,
    required bool scoreReady,
    required UserAIProfile? profile,
    required String locale,
    String? aiAdvice,
    List<ScoreAction> improvementActions = const [],
  }) {
    if (phase == HomeExpatHeroPhase.guest) {
      return AppShellStrings.t('home_hero_guest_body', locale);
    }
    if (phase == HomeExpatHeroPhase.loading) {
      return AppShellStrings.t('home_score_insight_build', locale);
    }
    if (profileIncomplete && profile != null) {
      return ExpatScoreProfileHelper.buildProfilePrompt(profile, locale);
    }
    if (!scoreReady) {
      return AppShellStrings.t('home_score_insight_build', locale);
    }
    if (aiAdvice != null && aiAdvice.isNotEmpty) return aiAdvice;
    if (improvementActions.isNotEmpty) {
      return improvementActions.first.description;
    }
    return AppShellStrings.t('home_score_insight_default', locale);
  }

  static String? statusLabel(ExpatLifeScore? score, String locale) {
    if (score == null) return null;
    return ExpatScoreProfileHelper.statusLabelWithTrend(
      level: ExpatScoreStrings.levelLabelForTotal(score.total, locale),
      weeklyGrowth: score.weeklyGrowth,
    );
  }

  /// Up to three real profile fields for setup step chips (existing capture flow).
  static List<TodayHeroSetupStep> setupSteps(
    UserAIProfile? profile,
    String locale,
  ) {
    final p = profile;
    bool filled(String value) => value.trim().isNotEmpty;

    return [
      TodayHeroSetupStep(
        label: ProgressiveProfileStrings.t('step_label_profession', locale),
        complete: p != null && filled(p.profession),
      ),
      TodayHeroSetupStep(
        label: ProgressiveProfileStrings.t('step_label_nationality', locale),
        complete: p != null && filled(p.nationality),
      ),
      TodayHeroSetupStep(
        label: ProgressiveProfileStrings.t('step_label_preferred_area', locale),
        complete: p != null && filled(p.preferredArea),
      ),
    ];
  }

  static String setupHeroTitle(String locale) =>
      AppShellStrings.t('home_build_profile', locale);

  static String setupHeroSubtitle(String locale) =>
      AppShellStrings.t('home_score_insight_build', locale);

  static String semanticsLabel({
    required String title,
    required HomeExpatHeroPhase phase,
    required double ringScore,
    required String? statusLabel,
    required String locale,
  }) {
    if (phase == HomeExpatHeroPhase.guest) {
      return AppShellStrings.t('home_hero_guest_title', locale);
    }
    if (phase == HomeExpatHeroPhase.loading) {
      return '$title, ${AppShellStrings.t('home_calculating', locale)}';
    }
    if (phase == HomeExpatHeroPhase.setup) {
      return '$title, ${AppShellStrings.t('home_complete_profile', locale)}';
    }
    if (ringScore > 0) {
      final status =
          statusLabel ?? AppShellStrings.t('home_get_started', locale);
      return '$title, ${ringScore.round()}, $status';
    }
    return title;
  }
}
