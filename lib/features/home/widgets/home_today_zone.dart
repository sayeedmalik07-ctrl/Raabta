import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/features/concierge_90_day/presentation/providers/concierge_providers.dart';
import 'package:raabta/features/home/providers/expat_score_advice_provider.dart';
import 'package:raabta/features/home/utils/home_today_focus_resolver.dart';
import 'package:raabta/features/home/widgets/home_adaptive_expat_hero.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:raabta/services/ai/expat_life_score_service.dart';

/// Zone 2 — Today hero only (supplementary cards live in [HomeTodaySupplementaryZone]).
class HomeTodayZone extends ConsumerWidget {
  const HomeTodayZone({
    super.key,
    required this.onFocusTap,
    required this.expatScoreLoading,
    required this.onOpenExpatScore,
    required this.onOpenBuildProfile,
  });

  final VoidCallback onFocusTap;
  final bool expatScoreLoading;
  final VoidCallback onOpenExpatScore;
  final VoidCallback onOpenBuildProfile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(userLanguageProvider);
    final expatState = ref.watch(expatLifeScoreProvider);
    final conciergeState = ref.watch(conciergeStateProvider).maybeWhen(
          data: (state) => state,
          orElse: () => null,
        );

    final improvementActions = ref.watch(expatImprovementActionsProvider);
    final focus = HomeTodayFocusResolver.resolve(
      expatState: expatState,
      improvementActions: improvementActions,
      conciergeState: conciergeState,
      locale: locale,
    );
    void onFocusPrimaryTap() {
      if (focus.openExpatScore) {
        onFocusTap();
        return;
      }
      context.push(focus.route);
    }

    return HomeAdaptiveExpatHero(
      isLoading: expatScoreLoading,
      onOpenExpatScore: onOpenExpatScore,
      onOpenBuildProfile: onOpenBuildProfile,
      focus: focus,
      onFocusPrimaryTap: onFocusPrimaryTap,
    );
  }
}
