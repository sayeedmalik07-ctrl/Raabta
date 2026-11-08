import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/features/concierge_90_day/presentation/providers/concierge_providers.dart';
import 'package:raabta/features/home/providers/expat_score_advice_provider.dart';
import 'package:raabta/features/home/providers/home_intelligence_providers.dart';
import 'package:raabta/features/home/utils/home_today_focus_resolver.dart';
import 'package:raabta/features/home/widgets/home_adaptive_expat_hero.dart';
import 'package:raabta/features/home/widgets/life_event_health_coverage_card.dart';
import 'package:raabta/features/home/widgets/life_event_shock_cluster_card.dart';
import 'package:raabta/features/home/widgets/life_intelligence_signal_card.dart';
import 'package:raabta/features/home/widgets/security_awareness_today_card.dart';
import 'package:raabta/features/home/widgets/todays_focus_card.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:raabta/services/ai/expat_life_score_service.dart';

/// Zone 2 — unified Today hero plus supplementary life/intelligence cards.
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
    final intelligenceItems =
        ref.watch(homeIntelligenceFocusProvider).valueOrNull ?? const [];

    void onFocusPrimaryTap() {
      if (focus.openExpatScore) {
        onFocusTap();
        return;
      }
      context.push(focus.route);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HomeAdaptiveExpatHero(
          isLoading: expatScoreLoading,
          onOpenExpatScore: onOpenExpatScore,
          onOpenBuildProfile: onOpenBuildProfile,
          focus: focus,
          onFocusPrimaryTap: onFocusPrimaryTap,
        ),
        if (intelligenceItems.isNotEmpty) ...[
          HomeTodayIntelligenceAlerts(
            items: intelligenceItems,
            locale: locale,
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
        const LifeEventHealthCoverageCard(),
        const LifeEventShockClusterCard(),
        const LifeIntelligenceSignalCard(),
        const SecurityAwarenessTodayCard(),
      ],
    );
  }
}
