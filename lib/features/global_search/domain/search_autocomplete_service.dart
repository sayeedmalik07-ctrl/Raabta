import 'package:flutter/material.dart';
import 'package:raabta/core/l10n/app_shell_strings.dart';
import 'package:raabta/features/global_search/domain/global_search_models.dart';
import 'package:raabta/features/global_search/domain/multilingual_query_normalizer.dart';
import 'package:raabta/features/global_search/domain/search_action_id.dart';
import 'package:raabta/features/global_search/domain/search_autocomplete_result.dart';
import 'package:raabta/features/global_search/domain/search_autocomplete_source.dart';
import 'package:raabta/features/global_search/domain/search_recent_query.dart';
import 'package:raabta/features/global_search/domain/service_search_terminology.dart';

/// Deterministic local autocomplete for Global Search (S8).
abstract final class SearchAutocompleteService {
  static const maxSuggestions = 6;

  static List<_CatalogEntry>? _cachedCatalog;

  static List<SearchAutocompleteResult> suggest({
    required String rawQuery,
    required List<SearchRecentQuery> recentQueries,
    required String locale,
  }) {
    try {
      final trimmed = rawQuery.trim();
      final normalization = MultilingualQueryNormalizer.normalize(trimmed);
      final canonical = normalization.canonicalLower;

      if (trimmed.isEmpty) {
        return _emptyQuerySuggestions(recentQueries, locale);
      }

      if (trimmed.length == 1) {
        return _rankAndLimit(
          _matchCatalog(
            query: trimmed,
            canonical: canonical,
            recentQueries: recentQueries,
            locale: locale,
            highConfidenceOnly: true,
          ),
        );
      }

      return _rankAndLimit(
        _matchCatalog(
          query: trimmed,
          canonical: canonical,
          recentQueries: recentQueries,
          locale: locale,
          highConfidenceOnly: false,
        ),
      );
    } catch (_) {
      return const [];
    }
  }

  static List<SearchAutocompleteResult> _emptyQuerySuggestions(
    List<SearchRecentQuery> recentQueries,
    String locale,
  ) {
    final results = <SearchAutocompleteResult>[];

    for (final recent in recentQueries.take(maxSuggestions)) {
      results.add(
        SearchAutocompleteResult(
          displayText: recent.text,
          subtitle: AppShellStrings.t('global_search_recent', locale),
          source: SearchAutocompleteSource.recent,
          normalizedText: recent.text.toLowerCase(),
          relevanceScore: 115,
          submitQuery: recent.text,
          icon: Icons.history_rounded,
          isRecent: true,
        ),
      );
    }

    if (results.length >= maxSuggestions) {
      return results.take(maxSuggestions).toList();
    }

    for (final starter in _starterSuggestions(locale)) {
      if (results.any((r) => r.submitQuery == starter.submitQuery)) continue;
      results.add(starter);
      if (results.length >= maxSuggestions) break;
    }

    return results;
  }

  static List<SearchAutocompleteResult> _starterSuggestions(String locale) {
    return [
      _starter(
        locale: locale,
        titleKey: 'global_search_find_electrician',
        subtitleKey: 'global_search_best_match_service',
        submitQuery: 'electrician near me',
        source: SearchAutocompleteSource.service,
        icon: GlobalSearchCategory.services.icon,
        category: GlobalSearchCategory.services,
      ),
      _starter(
        locale: locale,
        titleKey: 'global_search_jobs_in_doha',
        subtitleKey: 'global_search_best_match_job',
        submitQuery: 'jobs in Doha',
        source: SearchAutocompleteSource.job,
        icon: GlobalSearchCategory.jobs.icon,
        category: GlobalSearchCategory.jobs,
      ),
      _starter(
        locale: locale,
        titleKey: 'global_search_rooms_under_price',
        subtitleKey: 'global_search_best_match_housing',
        submitQuery: 'room under 1500 Doha',
        source: SearchAutocompleteSource.housing,
        icon: GlobalSearchCategory.housing.icon,
        category: GlobalSearchCategory.housing,
      ),
      _starter(
        locale: locale,
        titleKey: 'global_search_calculate_eosb',
        subtitleKey: 'global_search_action_eosb_subtitle',
        submitQuery: 'calculate EOSB',
        source: SearchAutocompleteSource.action,
        icon: Icons.calculate_outlined,
        actionId: SearchActionId.calculateEosb,
      ),
      _starter(
        locale: locale,
        titleKey: 'global_search_convert_currency',
        subtitleKey: 'global_search_action_currency_title',
        submitQuery: '500 QAR to INR',
        source: SearchAutocompleteSource.currency,
        icon: Icons.currency_exchange_rounded,
        actionId: SearchActionId.convertCurrency,
      ),
      _starter(
        locale: locale,
        titleKey: 'global_search_qatar_id_renewal',
        subtitleKey: 'global_search_best_match_reason',
        submitQuery: 'Qatar ID renewal',
        source: SearchAutocompleteSource.visa,
        icon: GlobalSearchCategory.visa.icon,
        category: GlobalSearchCategory.visa,
      ),
    ];
  }

  static SearchAutocompleteResult _starter({
    required String locale,
    required String titleKey,
    required String subtitleKey,
    required String submitQuery,
    required SearchAutocompleteSource source,
    required IconData icon,
    GlobalSearchCategory? category,
    SearchActionId? actionId,
  }) {
    return SearchAutocompleteResult(
      displayText: AppShellStrings.t(titleKey, locale),
      subtitle: AppShellStrings.t(subtitleKey, locale),
      source: source,
      normalizedText: submitQuery.toLowerCase(),
      relevanceScore: 50,
      submitQuery: submitQuery,
      icon: icon,
      category: category,
      actionId: actionId,
    );
  }

  static List<SearchAutocompleteResult> _matchCatalog({
    required String query,
    required String canonical,
    required List<SearchRecentQuery> recentQueries,
    required String locale,
    required bool highConfidenceOnly,
  }) {
    final q = canonical.isNotEmpty ? canonical : query.toLowerCase();
    final results = <SearchAutocompleteResult>[];

    for (final recent in recentQueries) {
      final recentNorm = recent.text.toLowerCase();
      final score = _scoreMatch(q, recentNorm, source: SearchAutocompleteSource.recent);
      if (score <= 0) continue;
      if (highConfidenceOnly && score < 60) continue;
      results.add(
        SearchAutocompleteResult(
          displayText: recent.text,
          subtitle: AppShellStrings.t('global_search_recent', locale),
          source: SearchAutocompleteSource.recent,
          normalizedText: recentNorm,
          relevanceScore: score + 15,
          submitQuery: recent.text,
          icon: Icons.history_rounded,
          isRecent: true,
        ),
      );
    }

    for (final entry in _catalog) {
      final score = _scoreMatch(q, entry.normalized, source: entry.source);
      if (score <= 0) continue;
      if (highConfidenceOnly && score < 60) continue;
      results.add(
        SearchAutocompleteResult(
          displayText: entry.display,
          subtitle: entry.subtitleFor(locale),
          source: entry.source,
          normalizedText: entry.normalized,
          relevanceScore: score + entry.intentBoost,
          submitQuery: entry.submitQuery,
          icon: entry.icon,
          category: entry.category,
          actionId: entry.actionId,
        ),
      );
    }

    return results;
  }

  static int _scoreMatch(
    String query,
    String candidate, {
    required SearchAutocompleteSource source,
  }) {
    if (query.isEmpty) return 0;
    if (candidate == query) return 100;
    if (candidate.startsWith(query)) return 60;

    final words = candidate.split(RegExp(r'\s+'));
    if (words.isNotEmpty && words.first.startsWith(query)) return 40;

    final tokens = query.split(RegExp(r'\s+')).where((t) => t.length >= 2);
    var tokenHits = 0;
    for (final token in tokens) {
      if (candidate.contains(token)) tokenHits++;
    }
    if (tokenHits > 0) return 20 * tokenHits;

    if (source == SearchAutocompleteSource.recent && candidate.contains(query)) {
      return 25;
    }

    return 0;
  }

  static List<SearchAutocompleteResult> _rankAndLimit(
    List<SearchAutocompleteResult> raw,
  ) {
    final deduped = <String, SearchAutocompleteResult>{};
    for (final item in raw) {
      final key = item.normalizedText.trim();
      final existing = deduped[key];
      if (existing == null || item.relevanceScore > existing.relevanceScore) {
        deduped[key] = item;
      }
    }

    final sorted = deduped.values.toList()
      ..sort((a, b) {
        final byScore = b.relevanceScore.compareTo(a.relevanceScore);
        if (byScore != 0) return byScore;
        final byLength = a.displayText.length.compareTo(b.displayText.length);
        if (byLength != 0) return byLength;
        return a.displayText.compareTo(b.displayText);
      });

    return sorted.take(maxSuggestions).map((item) {
      final lengthBonus = (30 - item.displayText.length.clamp(0, 30)) ~/ 10;
      return SearchAutocompleteResult(
        displayText: item.displayText,
        subtitle: item.subtitle,
        source: item.source,
        normalizedText: item.normalizedText,
        relevanceScore: item.relevanceScore + lengthBonus,
        submitQuery: item.submitQuery,
        icon: item.icon,
        category: item.category,
        actionId: item.actionId,
        isRecent: item.isRecent,
      );
    }).toList();
  }

  static List<_CatalogEntry> get _catalog {
    return _cachedCatalog ??= _buildCatalog();
  }

  static List<_CatalogEntry> _buildCatalog() {
    final entries = <_CatalogEntry>[];

    void add({
      required String display,
      required String submitQuery,
      required SearchAutocompleteSource source,
      required String subtitleKey,
      IconData? icon,
      GlobalSearchCategory? category,
      SearchActionId? actionId,
      int intentBoost = 0,
      List<String> aliases = const [],
    }) {
      final normalized = MultilingualQueryNormalizer.normalize(submitQuery)
          .canonicalLower;
      final haystack = [
        normalized,
        display.toLowerCase(),
        ...aliases.map((a) => a.toLowerCase()),
        ...aliases.map(
          (a) => MultilingualQueryNormalizer.normalize(a).canonicalLower,
        ),
      ].join(' ');

      entries.add(
        _CatalogEntry(
          display: display,
          submitQuery: submitQuery,
          normalized: haystack,
          source: source,
          subtitleKey: subtitleKey,
          icon: icon,
          category: category,
          actionId: actionId,
          intentBoost: intentBoost,
        ),
      );
    }

    for (final trade in ServiceSearchTerminology.tradeKeywords) {
      add(
        display: trade,
        submitQuery: trade,
        source: SearchAutocompleteSource.service,
        subtitleKey: 'global_search_best_match_service',
        icon: GlobalSearchCategory.services.icon,
        category: GlobalSearchCategory.services,
        intentBoost: 10,
      );
      add(
        display: '$trade near me',
        submitQuery: '$trade near me',
        source: SearchAutocompleteSource.service,
        subtitleKey: 'global_search_near_me',
        icon: GlobalSearchCategory.services.icon,
        category: GlobalSearchCategory.services,
        intentBoost: 10,
      );
    }

    const serviceAliases = [
      ('كهربائي', 'electrician near me'),
      ('كهربائي قريب مني', 'electrician near me'),
      ('इलेक्ट्रीशियन', 'electrician near me'),
      ('الیکٹریشن', 'electrician near me'),
      ('electrician paas mein', 'electrician near me'),
      ('plumber', 'plumber near me'),
      ('سباك', 'plumber near me'),
      ('پلمبر', 'plumber near me'),
    ];
    for (final (alias, submit) in serviceAliases) {
      add(
        display: alias,
        submitQuery: submit,
        source: SearchAutocompleteSource.service,
        subtitleKey: 'global_search_best_match_service',
        icon: GlobalSearchCategory.services.icon,
        category: GlobalSearchCategory.services,
        aliases: [submit],
      );
    }

    const jobPhrases = [
      'electrician jobs',
      'electrician job in Doha',
      'electrician jobs in Doha',
      'safety officer jobs',
      'driver jobs in Doha',
      'engineer jobs',
      'وظيفة كهربائي في الدوحة',
      'دोहा में इलेक्ट्रीशियन की नौकरी',
      'jobs in Doha',
      'jobs above 7000',
    ];
    for (final phrase in jobPhrases) {
      add(
        display: phrase,
        submitQuery: phrase,
        source: SearchAutocompleteSource.job,
        subtitleKey: 'global_search_best_match_job',
        icon: GlobalSearchCategory.jobs.icon,
        category: GlobalSearchCategory.jobs,
        intentBoost: 10,
      );
    }

    const housingPhrases = [
      'room under 1500',
      'room under 1500 Doha',
      'flat in Doha',
      '2 bedroom apartment Doha',
      'family friendly 2BHK apartment Doha',
      'دوحہ میں 1500 ریال سے کم کمرہ',
      'room in Al Khor',
    ];
    for (final phrase in housingPhrases) {
      add(
        display: phrase,
        submitQuery: phrase,
        source: SearchAutocompleteSource.housing,
        subtitleKey: 'global_search_best_match_housing',
        icon: GlobalSearchCategory.housing.icon,
        category: GlobalSearchCategory.housing,
        intentBoost: 10,
      );
    }

    const businessPhrases = [
      'electrician company',
      'Indian restaurant Doha',
      'best Indian restaurants in Doha',
      'الیکٹریشن کمپنی دوحہ',
    ];
    for (final phrase in businessPhrases) {
      add(
        display: phrase,
        submitQuery: phrase,
        source: SearchAutocompleteSource.business,
        subtitleKey: 'global_search_best_match_business',
        icon: GlobalSearchCategory.businesses.icon,
        category: GlobalSearchCategory.businesses,
        intentBoost: 10,
      );
    }

    const visaPhrases = [
      'Qatar ID renewal',
      'QID renewal',
      'visa renewal',
      'work permit',
      'قطر آئی ڈی تجدید',
    ];
    for (final phrase in visaPhrases) {
      add(
        display: phrase,
        submitQuery: phrase,
        source: SearchAutocompleteSource.visa,
        subtitleKey: 'global_search_best_match_reason',
        icon: GlobalSearchCategory.visa.icon,
        category: GlobalSearchCategory.visa,
      );
    }

    const areas = [
      'Doha',
      'Al Rayyan',
      'Al Wakrah',
      'Lusail',
      'Al Khor',
      'West Bay',
      'Industrial Area',
      'Old Airport',
      'الدوحة',
      'دوحہ',
      'दोहा',
    ];
    for (final area in areas) {
      add(
        display: area,
        submitQuery: 'services in $area',
        source: SearchAutocompleteSource.area,
        subtitleKey: 'global_search_best_match_reason',
        icon: Icons.location_on_outlined,
        intentBoost: 5,
        aliases: [area],
      );
    }

    const currencyPhrases = [
      '500 QAR to INR',
      '500 ریال سے INR',
      '500 ريال إلى INR',
      'INR exchange rate',
      'convert QAR to INR',
    ];
    for (final phrase in currencyPhrases) {
      add(
        display: phrase,
        submitQuery: phrase,
        source: SearchAutocompleteSource.currency,
        subtitleKey: 'global_search_action_currency_title',
        icon: Icons.currency_exchange_rounded,
        actionId: SearchActionId.convertCurrency,
      );
    }

    const actions = [
      ('calculate EOSB', SearchActionId.calculateEosb, 'global_search_action_eosb_title'),
      ('calculate gratuity', SearchActionId.calculateEosb, 'global_search_action_eosb_title'),
      ('scan document', SearchActionId.scanDocument, 'global_search_action_scan_title'),
      ('verify employer', SearchActionId.verifyEmployer, 'global_search_action_employer_title'),
      ('verify recruitment agency', SearchActionId.verifyAgency, 'global_search_action_agency_title'),
      ('مكافأة نهاية الخدمة', SearchActionId.calculateEosb, 'global_search_action_eosb_title'),
    ];
    for (final (phrase, actionId, subtitleKey) in actions) {
      add(
        display: phrase,
        submitQuery: phrase,
        source: SearchAutocompleteSource.action,
        subtitleKey: subtitleKey,
        icon: Icons.bolt_rounded,
        category: GlobalSearchCategory.actions,
        actionId: actionId,
        intentBoost: 10,
      );
    }

    const tools = [
      ('prayer times', 'Prayer & Mosques'),
      ('trip planner', 'Trip Planner'),
      ('document scanner', 'Document Scanner'),
    ];
    for (final (label, subtitle) in tools) {
      entries.add(
        _CatalogEntry(
          display: label,
          submitQuery: label,
          normalized: label.toLowerCase(),
          source: SearchAutocompleteSource.tool,
          subtitleKey: 'global_search_best_match_reason',
          icon: GlobalSearchCategory.tools.icon,
          category: GlobalSearchCategory.tools,
          intentBoost: 5,
          customSubtitle: subtitle,
        ),
      );
    }

    return entries;
  }

  /// Clears in-memory catalog cache (tests).
  static void resetCatalogForTests() => _cachedCatalog = null;
}

class _CatalogEntry {
  const _CatalogEntry({
    required this.display,
    required this.submitQuery,
    required this.normalized,
    required this.source,
    required this.subtitleKey,
    this.icon,
    this.category,
    this.actionId,
    this.intentBoost = 0,
    this.customSubtitle,
  });

  final String display;
  final String submitQuery;
  final String normalized;
  final SearchAutocompleteSource source;
  final String subtitleKey;
  final IconData? icon;
  final GlobalSearchCategory? category;
  final SearchActionId? actionId;
  final int intentBoost;
  final String? customSubtitle;

  String subtitleFor(String locale) {
    if (customSubtitle != null) return customSubtitle!;
    return AppShellStrings.t(subtitleKey, locale);
  }
}
