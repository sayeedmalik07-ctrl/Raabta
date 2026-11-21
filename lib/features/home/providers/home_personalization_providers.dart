import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/features/concierge_90_day/presentation/providers/concierge_providers.dart';
import 'package:raabta/features/home/providers/expat_score_advice_provider.dart';
import 'package:raabta/features/home/utils/home_personalization_resolver.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:raabta/services/ai/user_profile_ai_service.dart';
import 'package:raabta/services/ai/expat_life_score_service.dart';

final homePersonalizationInputProvider = Provider<HomePersonalizationInput>((ref) {
  final locale = ref.watch(userLanguageProvider);
  final profile = ref.watch(userAIProfileProvider);
  final expatState = ref.watch(expatLifeScoreProvider);
  final conciergeState = ref.watch(conciergeStateProvider).maybeWhen(
        data: (state) => state,
        orElse: () => null,
      );
  final improvementActions = ref.watch(expatImprovementActionsProvider);
  final todayRoute = resolveTodayFocusRoute(
    expatState: expatState,
    improvementActions: improvementActions,
    conciergeState: conciergeState,
    locale: locale,
  );

  return HomePersonalizationInput(
    profile: profile,
    expatState: expatState,
    conciergeState: conciergeState,
    todayFocusRoute: todayRoute,
  );
});

final homeSectionOrderProvider = Provider<List<HomeSectionId>>((ref) {
  final input = ref.watch(homePersonalizationInputProvider);
  return HomePersonalizationResolver.sectionOrder(input);
});

final homeShowVerificationLinksProvider = Provider<bool>((ref) {
  final input = ref.watch(homePersonalizationInputProvider);
  return HomePersonalizationResolver.shouldShowVerificationLinks(input);
});

final homeQatarLifeRoutesProvider = Provider<List<String>>((ref) {
  final profile = ref.watch(userAIProfileProvider);
  return HomePersonalizationResolver.qatarLifePreviewRoutes(profile);
});
