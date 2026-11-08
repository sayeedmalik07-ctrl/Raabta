import 'package:raabta/features/home/l10n/home_ai_feed_strings.dart';
import 'package:raabta/features/home/utils/home_for_you_pick_family.dart';
import 'package:raabta/services/ai/ai_feed_engine.dart';
import 'package:raabta/services/ai/user_profile_ai_service.dart';

/// Presentation-only "Because …" lines for Home For You picks.
///
/// Uses profile fields and [AIFeedCard.data] already on the card — no new AI or
/// inference (e.g. never assumes remittance intent from nationality alone).
String? homeForYouPresentationBecauseLine({
  required AIFeedCard card,
  required UserAIProfile? profile,
  required String locale,
}) {
  final mapped = _ruleBasedBecause(card: card, profile: profile, locale: locale);
  if (mapped != null) return mapped;
  return homeForYouBecauseLine(card.subtitle);
}

String? _ruleBasedBecause({
  required AIFeedCard card,
  required UserAIProfile? profile,
  required String locale,
}) {
  return switch (card.type) {
    FeedCardType.jobRecommendation => _jobBecause(card, profile, locale),
    FeedCardType.housingRecommendation =>
      _housingBecause(card, profile, locale),
    FeedCardType.exchangeRate => _exchangeBecause(card, locale),
    FeedCardType.visaUpdate => HomeAiFeedStrings.t(
        'for_you_because_visa_update',
        locale,
      ),
    FeedCardType.communityEvent => _eventBecause(profile, locale),
    FeedCardType.scoreSuggestion => _scoreBecause(card, locale),
    FeedCardType.businessOffer ||
    FeedCardType.governmentAnnouncement ||
    FeedCardType.referralPrompt ||
    FeedCardType.sponsored ||
    FeedCardType.welcomeMessage =>
      null,
  };
}

String? _jobBecause(
  AIFeedCard card,
  UserAIProfile? profile,
  String locale,
) {
  final match = card.data['topMatchScore'];
  if (match is num && match >= 70) {
    return HomeAiFeedStrings.format(
      'for_you_because_job_match',
      locale,
      params: {'match': '${match.round()}'},
    );
  }
  final profession = profile?.profession.trim() ?? '';
  if (profession.isNotEmpty) {
    return HomeAiFeedStrings.format(
      'for_you_because_job_profession',
      locale,
      params: {'profession': profession},
    );
  }
  return null;
}

String? _housingBecause(
  AIFeedCard card,
  UserAIProfile? profile,
  String locale,
) {
  final area = profile?.preferredArea.trim() ?? '';
  if (area.isNotEmpty) {
    return HomeAiFeedStrings.format(
      'for_you_because_housing_area',
      locale,
      params: {'area': area},
    );
  }
  final match = card.data['topMatchScore'];
  if (match is num && match > 0) {
    return HomeAiFeedStrings.format(
      'for_you_because_housing_match',
      locale,
      params: {'match': '${match.round()}'},
    );
  }
  return null;
}

String? _exchangeBecause(AIFeedCard card, String locale) {
  final change = card.data['change'];
  if (change is num && change.abs() >= 0.001) {
    return change >= 0
        ? HomeAiFeedStrings.t('for_you_because_exchange_up', locale)
        : HomeAiFeedStrings.t('for_you_because_exchange_down', locale);
  }
  return HomeAiFeedStrings.t('for_you_because_exchange_rates', locale);
}

String? _eventBecause(UserAIProfile? profile, String locale) {
  final area = profile?.preferredArea.trim() ?? '';
  if (area.isNotEmpty) {
    return HomeAiFeedStrings.format(
      'for_you_because_event_area',
      locale,
      params: {'area': area},
    );
  }
  return HomeAiFeedStrings.t('for_you_because_event_week', locale);
}

String? _scoreBecause(AIFeedCard card, String locale) {
  final description = card.subtitle.trim();
  if (description.isEmpty) return null;
  return homeForYouBecauseLine(description);
}
