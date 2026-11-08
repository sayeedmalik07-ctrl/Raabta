import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/features/home/widgets/home_icon_badge.dart';
import 'package:raabta/services/ai/ai_feed_engine.dart';

/// Kit §2 domain colors for For You picks (presentation-only; feed data unchanged).
enum HomeForYouPickFamily {
  gold,
  teal,
}

/// Maps [FeedCardType] and [AIFeedCard.ctaRoute] to gold (money/rights) or teal (lifestyle).
HomeForYouPickFamily homeForYouPickFamily(AIFeedCard card) {
  final route = card.ctaRoute;
  if (_goldRoutes.contains(route)) {
    return HomeForYouPickFamily.gold;
  }
  if (_tealRoutes.contains(route)) {
    return HomeForYouPickFamily.teal;
  }

  return switch (card.type) {
    FeedCardType.exchangeRate ||
    FeedCardType.visaUpdate ||
    FeedCardType.scoreSuggestion ||
    FeedCardType.governmentAnnouncement =>
      HomeForYouPickFamily.gold,
    FeedCardType.jobRecommendation ||
    FeedCardType.housingRecommendation ||
    FeedCardType.communityEvent ||
    FeedCardType.businessOffer ||
    FeedCardType.referralPrompt ||
    FeedCardType.sponsored ||
    FeedCardType.welcomeMessage =>
      HomeForYouPickFamily.teal,
  };
}

Color homeForYouFamilyMain(HomeForYouPickFamily family) {
  return switch (family) {
    HomeForYouPickFamily.gold => AppColors.goldFamilyMain,
    HomeForYouPickFamily.teal => AppColors.tealFamilyMain,
  };
}

Color homeForYouFamilyText(HomeForYouPickFamily family) {
  return switch (family) {
    HomeForYouPickFamily.gold => AppColors.goldFamilyText,
    HomeForYouPickFamily.teal => AppColors.tealFamilyText,
  };
}

HomeIconBadgeVariant homeForYouBadgeVariant(HomeForYouPickFamily family) {
  return switch (family) {
    HomeForYouPickFamily.gold => HomeIconBadgeVariant.goldBrand,
    HomeForYouPickFamily.teal => HomeIconBadgeVariant.tealBrand,
  };
}

/// Uses feed [subtitle] when non-empty; prefixes "Because " only if not already present.
String? homeForYouBecauseLine(String subtitle) {
  final trimmed = subtitle.trim();
  if (trimmed.isEmpty) return null;
  final lower = trimmed.toLowerCase();
  if (lower.startsWith('because ')) return trimmed;
  return 'Because $trimmed';
}

const _goldRoutes = {
  '/money',
  '/visa',
  '/eosb',
  '/tenancy',
  '/health-insurance',
  '/sponsorship-transfer',
  '/expat-score',
};

const _tealRoutes = {
  '/jobs',
  '/housing',
  '/community/events',
  '/trip-planner',
  '/climate-navigator',
  '/queue-avoidance',
  '/know-qatar',
  '/businesses',
  '/news',
  '/profile',
};
