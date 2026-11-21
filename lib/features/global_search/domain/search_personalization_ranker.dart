import 'package:raabta/core/search/search_keyword_tokenizer.dart';
import 'package:raabta/features/global_search/domain/global_search_models.dart';
import 'package:raabta/features/global_search/domain/intent_relevance_boost.dart';
import 'package:raabta/features/global_search/domain/search_analysis.dart';
import 'package:raabta/features/global_search/domain/search_personalization_context.dart';
import 'package:raabta/features/global_search/domain/search_personalization_signal.dart';
import 'package:raabta/services/ai/smart_search_service.dart';

/// Bounded personalization bonus for BEST MATCH selection (S10).
abstract final class SearchPersonalizationRanker {
  static const maxBonus = 10;
  static const relevanceFloor = 35;

  static const explicitTradeMatch = 6;
  static const explicitJobMatch = 6;
  static const explicitPropertyMatch = 6;
  static const preferredAreaMatch = 4;
  static const recentCategoryAffinity = 3;
  static const recentQueryTokenAffinity = 2;
  static const savedItemMatch = 6;

  static SearchPersonalizationScore score({
    required GlobalSearchResultItem item,
    required SearchAnalysis analysis,
    required SearchPersonalizationContext context,
  }) {
    if (!context.enabled) return SearchPersonalizationScore.neutral;
    if (item.isAction || item.isAskAi) return SearchPersonalizationScore.neutral;
    if (item.score < relevanceFloor) return SearchPersonalizationScore.neutral;
    if (!_isCategoryAligned(item, analysis)) {
      return SearchPersonalizationScore.neutral;
    }
    if (_isCrossIntentMismatch(item, analysis)) {
      return SearchPersonalizationScore.neutral;
    }

    var bonus = 0;
    var usedExplicit = false;

    if (_savedItemBonus(item, context) > 0) {
      bonus += savedItemMatch;
      usedExplicit = true;
    }

    switch (analysis.intent) {
      case SearchIntent.findService:
        if (_explicitServiceTradeMatch(item, analysis, context)) {
          bonus += explicitTradeMatch;
          usedExplicit = true;
        }
      case SearchIntent.findJob:
        if (_explicitJobMatch(item, context)) {
          bonus += explicitJobMatch;
          usedExplicit = true;
        }
      case SearchIntent.findHousing:
        if (_explicitPropertyMatch(item, context)) {
          bonus += explicitPropertyMatch;
          usedExplicit = true;
        }
      case SearchIntent.findBusiness:
        if (_categoryInterestMatch(item, context)) {
          bonus += explicitJobMatch;
          usedExplicit = true;
        }
      default:
        break;
    }

    if (_preferredAreaMatch(item, context)) {
      bonus += preferredAreaMatch;
      usedExplicit = true;
    }

    bonus += _recentCategoryAffinity(analysis, context);
    bonus += _recentQueryTokenAffinity(item, analysis, context);

    return SearchPersonalizationScore(
      bonus: bonus.clamp(0, maxBonus),
      usedExplicitPreference: usedExplicit && bonus > 0,
    );
  }

  static bool _isCategoryAligned(
    GlobalSearchResultItem item,
    SearchAnalysis analysis,
  ) {
    if (analysis.intent == SearchIntent.unknown) return true;
    if (analysis.confidence < SearchBestMatchRankerConfidenceGate.threshold) {
      return IntentRelevanceBoost.forCategory(item.category, analysis) > 0 ||
          analysis.intent == SearchIntent.unknown;
    }
    return IntentRelevanceBoost.forCategory(item.category, analysis) > 0;
  }

  static bool _isCrossIntentMismatch(
    GlobalSearchResultItem item,
    SearchAnalysis analysis,
  ) {
    if (analysis.intent == SearchIntent.unknown) return false;
    if (analysis.confidence < 0.55) return false;

    return switch (analysis.intent) {
      SearchIntent.findJob ||
      SearchIntent.findHousing ||
      SearchIntent.findBusiness =>
        item.category == GlobalSearchCategory.services,
      SearchIntent.findService => item.category == GlobalSearchCategory.jobs,
      _ => false,
    };
  }

  static bool _explicitServiceTradeMatch(
    GlobalSearchResultItem item,
    SearchAnalysis analysis,
    SearchPersonalizationContext context,
  ) {
    final haystack = _itemHaystack(item);
    final trades = context.explicitServiceTrades;
    for (final trade in trades) {
      final token = trade.trim().toLowerCase();
      if (token.length >= 3 && haystack.contains(token)) return true;
    }
    final profession = context.explicitProfession.trim().toLowerCase();
    if (profession.length >= 3 && haystack.contains(profession)) return true;
    return false;
  }

  static bool _explicitJobMatch(
    GlobalSearchResultItem item,
    SearchPersonalizationContext context,
  ) {
    final haystack = _itemHaystack(item);
    final profession = context.explicitProfession.trim().toLowerCase();
    if (profession.length >= 3 && haystack.contains(profession)) return true;

    for (final skill in context.explicitSkills) {
      final token = skill.trim().toLowerCase();
      if (token.length >= 3 && haystack.contains(token)) return true;
    }
    for (final category in context.explicitJobCategories) {
      final token = category.trim().toLowerCase();
      if (token.length >= 3 && haystack.contains(token)) return true;
    }
    return false;
  }

  static bool _explicitPropertyMatch(
    GlobalSearchResultItem item,
    SearchPersonalizationContext context,
  ) {
    final haystack = _itemHaystack(item);
    for (final type in context.explicitPropertyTypes) {
      final token = type.trim().toLowerCase();
      if (token.length >= 3 && haystack.contains(token)) return true;
    }
    for (final interest in context.categoryInterests) {
      final token = interest.trim().toLowerCase();
      if (_isPropertyKeyword(token) && haystack.contains(token)) return true;
    }
    return false;
  }

  static bool _categoryInterestMatch(
    GlobalSearchResultItem item,
    SearchPersonalizationContext context,
  ) {
    final haystack = _itemHaystack(item);
    for (final interest in context.categoryInterests) {
      final token = interest.trim().toLowerCase();
      if (token.length >= 3 && haystack.contains(token)) return true;
    }
    return false;
  }

  static bool _preferredAreaMatch(
    GlobalSearchResultItem item,
    SearchPersonalizationContext context,
  ) {
    final area = context.preferredArea.trim().toLowerCase();
    if (area.length < 3) return false;
    return _itemHaystack(item).contains(area);
  }

  static int _savedItemBonus(
    GlobalSearchResultItem item,
    SearchPersonalizationContext context,
  ) {
    final id = item.id;
    if (context.savedJobIds.contains(id) ||
        context.savedHousingIds.contains(id) ||
        context.savedBusinessIds.contains(id)) {
      return savedItemMatch;
    }
    for (final saved in context.savedJobIds) {
      if (id.contains(saved)) return savedItemMatch;
    }
    for (final saved in context.savedHousingIds) {
      if (id.contains(saved)) return savedItemMatch;
    }
    for (final saved in context.savedBusinessIds) {
      if (id.contains(saved)) return savedItemMatch;
    }
    return 0;
  }

  static int _recentCategoryAffinity(
    SearchAnalysis analysis,
    SearchPersonalizationContext context,
  ) {
    if (context.recentSearchSignals.isEmpty) return 0;

    final intentKeywords = switch (analysis.intent) {
      SearchIntent.findService => ['electrician', 'plumber', 'ac', 'repair', 'service'],
      SearchIntent.findJob => ['job', 'jobs', 'vacancy', 'engineer'],
      SearchIntent.findHousing => ['room', 'apartment', 'flat', 'rent', 'housing'],
      SearchIntent.findBusiness => ['business', 'company', 'shop'],
      _ => const <String>[],
    };
    if (intentKeywords.isEmpty) return 0;

    var affinity = 0.0;
    for (final signal in context.recentSearchSignals) {
      final lower = signal.normalizedQuery;
      if (intentKeywords.any(lower.contains)) {
        affinity += signal.weight;
      }
    }
    return affinity >= 0.85 ? recentCategoryAffinity : 0;
  }

  static int _recentQueryTokenAffinity(
    GlobalSearchResultItem item,
    SearchAnalysis analysis,
    SearchPersonalizationContext context,
  ) {
    if (context.recentSearchSignals.isEmpty) return 0;

    final queryTokens = SearchKeywordTokenizer.tokenize(analysis.normalizedQuery);
    if (queryTokens.isEmpty) return 0;

    final haystackTokens = SearchKeywordTokenizer.tokenize(_itemHaystack(item));
    if (haystackTokens.isEmpty) return 0;

    var affinity = 0.0;
    for (final signal in context.recentSearchSignals) {
      final recentTokens = SearchKeywordTokenizer.tokenize(signal.normalizedQuery);
      final overlap = queryTokens
          .where((t) => recentTokens.contains(t) && haystackTokens.contains(t))
          .length;
      if (overlap > 0) {
        affinity += signal.weight;
      }
    }
    return affinity >= 0.7 ? recentQueryTokenAffinity : 0;
  }

  static String _itemHaystack(GlobalSearchResultItem item) {
    return '${item.title} ${item.subtitle}'.toLowerCase();
  }

  static bool _isPropertyKeyword(String token) {
    return const {
      'apartment',
      'flat',
      'room',
      'studio',
      'villa',
      'compound',
    }.contains(token);
  }
}

/// Exposes confidence threshold for alignment checks without duplicating S5 constants.
abstract final class SearchBestMatchRankerConfidenceGate {
  static const threshold = 0.55;
}
