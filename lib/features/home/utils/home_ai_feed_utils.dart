import 'package:raabta/services/ai/ai_feed_engine.dart';

/// Shared AI feed sorting for Home zones (Today removed duplicate in Phase 3).
abstract final class HomeAiFeedUtils {
  HomeAiFeedUtils._();

  static List<AIFeedCard> visibleCards(AIFeedResult result) {
    final cards = result.cards
        .where((card) => card.type != FeedCardType.welcomeMessage)
        .toList();
    cards.sort((a, b) => b.priority.compareTo(a.priority));
    return cards;
  }
}
