import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/l10n/app_shell_strings.dart';
import 'package:raabta/providers/auth_providers.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/features/home/utils/home_expat_hero_presenter.dart';
import 'package:raabta/features/home/utils/home_today_focus_resolver.dart';
import 'package:raabta/features/home/widgets/home_unified_today_hero.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:raabta/services/ai/expat_life_score_service.dart';
import 'package:raabta/services/ai/user_profile_ai_service.dart';

/// Adaptive Today hero — setup, loading, or focus + Expat Score (kit §10).
class HomeAdaptiveExpatHero extends ConsumerWidget {
  const HomeAdaptiveExpatHero({
    super.key,
    required this.isLoading,
    required this.onOpenExpatScore,
    required this.onOpenBuildProfile,
    required this.focus,
    required this.onFocusPrimaryTap,
  });

  final bool isLoading;
  final VoidCallback onOpenExpatScore;
  final VoidCallback onOpenBuildProfile;
  final TodayFocusContent focus;
  final VoidCallback onFocusPrimaryTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(userLanguageProvider);
    final user = ref.watch(currentUserProvider);
    final isSignedIn = user != null;
    final profile = ref.watch(userAIProfileProvider);
    final expatState = ref.watch(expatLifeScoreProvider);
    final calculatedScore = expatState.score;
    final scoreReady = calculatedScore != null;
    final profileIncomplete = HomeExpatHeroPresenter.profileIncomplete(profile);

    final phase = HomeExpatHeroPresenter.phase(
      isSignedIn: isSignedIn,
      isLoading: isLoading,
      scoreReady: scoreReady,
      profileIncomplete: profileIncomplete,
    );

    final title = AppShellStrings.t('home_expat_score_title', locale);
    final ringStatusLabel = phase == HomeExpatHeroPhase.populated
        ? HomeExpatHeroPresenter.statusLabel(calculatedScore, locale)
        : null;
    final ringScore = HomeExpatHeroPresenter.ringScore(
      phase: phase,
      expatState: expatState,
      profile: profile,
    );

    return HomeUnifiedTodayHero(
        phase: phase,
        locale: locale,
        ringScore: ringScore,
        onOpenExpatScore: onOpenExpatScore,
        onOpenBuildProfile: onOpenBuildProfile,
        focus: focus,
        onFocusPrimaryTap: onFocusPrimaryTap,
        onSignIn: phase == HomeExpatHeroPhase.guest
            ? () => context.push('/login')
            : null,
        statusLabel: ringStatusLabel,
        setupSteps: phase == HomeExpatHeroPhase.guest
            ? const []
            : HomeExpatHeroPresenter.setupSteps(profile, locale),
        semanticsLabel: HomeExpatHeroPresenter.semanticsLabel(
          title: title,
          phase: phase,
          ringScore: ringScore,
          statusLabel: ringStatusLabel,
          locale: locale,
        ),
    );
  }
}
