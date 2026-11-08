import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/features/home/domain/home_ai_assistant_action.dart';
import 'package:raabta/features/home/providers/home_intelligence_providers.dart';
import 'package:raabta/features/home/utils/home_ai_assistant_action_resolver.dart';
import 'package:raabta/features/home/utils/home_ai_feed_utils.dart';
import 'package:raabta/features/profile/privacy/providers/privacy_providers.dart';
import 'package:raabta/providers/auth_providers.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:raabta/screens/ai_chat/models/ai_chat_feed_teaser.dart';
import 'package:raabta/services/ai/ai_feed_engine.dart';
import 'package:raabta/services/ai/expat_life_score_service.dart';
import 'package:raabta/services/ai/user_profile_ai_service.dart';

/// Contextual Home actions for chat empty state (max 3, resolver contract).
final aiChatContextualActionsProvider =
    Provider<List<HomeAiAssistantAction>>((ref) {
  final locale = ref.watch(userLanguageProvider);
  final profile = ref.watch(userAIProfileProvider);
  final expatState = ref.watch(expatLifeScoreProvider);
  final uid = ref.watch(currentUserProvider)?.uid;
  final privacy = ref.watch(privacySettingsProvider).valueOrNull;
  final personalizationEnabled =
      privacy?.aiPersonalizationEnabled ?? true;

  final intelligenceAsync = ref.watch(homeIntelligenceFocusProvider);
  if (intelligenceAsync.isLoading || intelligenceAsync.hasError) {
    return HomeAiAssistantActionResolver.resolve(
      expatState: expatState,
      intelligenceItems: const [],
      locale: locale,
      profile: profile,
      authUid: uid,
      personalizationEnabled: false,
    );
  }

  final intelligenceItems = intelligenceAsync.valueOrNull ?? const [];

  return HomeAiAssistantActionResolver.resolve(
    expatState: expatState,
    intelligenceItems: intelligenceItems,
    locale: locale,
    profile: profile,
    authUid: uid,
    personalizationEnabled: personalizationEnabled,
  );
});

/// Up to two feed cards from existing [aiFeedProvider] — no extra load call.
final aiChatFeedTeasersProvider = Provider<List<AiChatFeedTeaser>>((ref) {
  final feedAsync = ref.watch(aiFeedProvider);
  if (feedAsync.isLoading || feedAsync.hasError) {
    return const [];
  }
  final result = feedAsync.valueOrNull;
  if (result == null) return const [];

  final cards = HomeAiFeedUtils.visibleCards(result);
  if (cards.isEmpty) return const [];

  return cards.take(2).map(_teaserFromCard).toList();
});

AiChatFeedTeaser _teaserFromCard(AIFeedCard card) {
  final route = card.ctaRoute.isEmpty ? '/ai-chat' : card.ctaRoute;
  final prompt = card.subtitle.trim().isNotEmpty
      ? card.subtitle.trim()
      : card.title.trim();
  return AiChatFeedTeaser(
    title: card.title,
    subtitle: card.subtitle,
    route: route,
    accentColor: card.borderColor,
    promptOnChatRoute: prompt,
  );
}
