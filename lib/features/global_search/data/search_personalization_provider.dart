import 'package:raabta/features/global_search/domain/search_personalization_context.dart';
import 'package:raabta/features/global_search/domain/search_personalization_signal.dart';
import 'package:raabta/services/ai/user_profile_ai_service.dart';

/// Builds [SearchPersonalizationContext] from existing local profile state (S10).
abstract final class SearchPersonalizationProvider {
  static const _decayWeights = [
    1.0,
    0.85,
    0.7,
    0.55,
    0.4,
    0.3,
    0.2,
    0.15,
  ];

  static const _propertyKeywords = {
    'apartment',
    'flat',
    'room',
    'studio',
    'villa',
    'compound',
  };

  static const _serviceTradeKeywords = {
    'electrician',
    'plumber',
    'ac',
    'mechanic',
    'carpenter',
    'painter',
    'cleaner',
    'technician',
  };

  static SearchPersonalizationContext build({
    UserAIProfile? profile,
    bool personalizationEnabled = true,
    List<String> recentQueries = const [],
  }) {
    if (!personalizationEnabled || profile == null) {
      return SearchPersonalizationContext.neutral;
    }

    try {
      return _fromProfile(profile, recentQueries);
    } catch (_) {
      return SearchPersonalizationContext.neutral;
    }
  }

  static SearchPersonalizationContext _fromProfile(
    UserAIProfile profile,
    List<String> recentQueries,
  ) {
    final interests = _categoryInterests(profile.interests);
    final serviceTrades = _deriveServiceTrades(profile, interests);
    final jobCategories = _deriveJobCategories(profile, interests);
    final propertyTypes = _derivePropertyTypes(interests);

    return SearchPersonalizationContext(
      schemaVersion: SearchPersonalizationContext.schemaVersionCurrent,
      enabled: true,
      preferredArea: _normalizeArea(profile.preferredArea),
      explicitProfession: profile.profession.trim(),
      explicitSkills: _normalizeList(profile.skills),
      explicitServiceTrades: serviceTrades,
      explicitJobCategories: jobCategories,
      explicitPropertyTypes: propertyTypes,
      categoryInterests: interests,
      savedJobIds: profile.savedJobIds.take(50).toSet(),
      savedHousingIds: profile.savedHousingIds.take(50).toSet(),
      savedBusinessIds: profile.savedBusinessIds.take(50).toSet(),
      recentSearchSignals: _recentSignals(recentQueries),
    );
  }

  static List<SearchRecentSearchSignal> _recentSignals(List<String> queries) {
    final signals = <SearchRecentSearchSignal>[];
    for (var i = 0; i < queries.length && i < _decayWeights.length; i++) {
      final normalized = queries[i].trim().toLowerCase();
      if (normalized.isEmpty) continue;
      signals.add(
        SearchRecentSearchSignal(
          normalizedQuery: normalized,
          weight: _decayWeights[i],
        ),
      );
    }
    return signals;
  }

  static List<String> _categoryInterests(List<String> interests) {
    return interests
        .where((i) => !i.contains(':'))
        .map((i) => i.trim().toLowerCase())
        .where((i) => i.length >= 3)
        .take(20)
        .toList();
  }

  static List<String> _deriveServiceTrades(
    UserAIProfile profile,
    List<String> interests,
  ) {
    final trades = <String>{};
    final profession = profile.profession.trim().toLowerCase();
    if (_serviceTradeKeywords.any(profession.contains)) {
      trades.add(profession);
    }
    for (final skill in profile.skills) {
      final lower = skill.trim().toLowerCase();
      if (_serviceTradeKeywords.any(lower.contains)) trades.add(lower);
    }
    for (final interest in interests) {
      if (_serviceTradeKeywords.any(interest.contains)) trades.add(interest);
    }
    return trades.toList();
  }

  static List<String> _deriveJobCategories(
    UserAIProfile profile,
    List<String> interests,
  ) {
    final categories = <String>{};
    final profession = profile.profession.trim().toLowerCase();
    if (profession.isNotEmpty) categories.add(profession);
    categories.addAll(
      profile.skills.map((s) => s.trim().toLowerCase()).where((s) => s.length >= 3),
    );
    categories.addAll(interests.where((i) => !_isPropertyKeyword(i)));
    return categories.take(15).toList();
  }

  static List<String> _derivePropertyTypes(List<String> interests) {
    return interests.where(_isPropertyKeyword).toList();
  }

  static bool _isPropertyKeyword(String token) {
    return _propertyKeywords.contains(token.trim().toLowerCase());
  }

  static String _normalizeArea(String area) {
    return area.trim();
  }

  static List<String> _normalizeList(List<String> values) {
    return values
        .map((v) => v.trim().toLowerCase())
        .where((v) => v.length >= 2)
        .take(20)
        .toList();
  }

  /// Safe parse for corrupted persisted personalization payloads (tests).
  static SearchPersonalizationContext fromJson(Map<String, dynamic>? json) {
    if (json == null || json.isEmpty) return SearchPersonalizationContext.neutral;
    try {
      final version = json['schemaVersion'] as int? ?? 0;
      if (version != SearchPersonalizationContext.schemaVersionCurrent) {
        return SearchPersonalizationContext.neutral;
      }
      return SearchPersonalizationContext(
        schemaVersion: version,
        enabled: json['enabled'] as bool? ?? false,
        preferredArea: json['preferredArea'] as String? ?? '',
        explicitProfession: json['explicitProfession'] as String? ?? '',
      );
    } catch (_) {
      return SearchPersonalizationContext.neutral;
    }
  }
}
