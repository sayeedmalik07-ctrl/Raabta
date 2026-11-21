import 'package:raabta/core/search/search_keyword_tokenizer.dart';
import 'package:raabta/features/global_search/domain/global_search_models.dart';
import 'package:raabta/features/global_search/l10n/global_search_index_strings.dart';

/// A statically defined searchable destination (tools, guides, tabs).
class StaticSearchEntry {
  const StaticSearchEntry({
    required this.id,
    this.titleKey,
    this.subtitleKey,
    this.subtitleFormatParams,
    this.title,
    this.subtitle,
    required this.keywords,
    required this.routePath,
    required this.category,
  }) : assert(
          (titleKey != null && subtitleKey != null) ||
              (title != null && (subtitle != null || subtitleKey != null)),
          'Provide titleKey+subtitleKey, or title with subtitle/subtitleKey',
        );

  final String id;
  final String? titleKey;
  final String? subtitleKey;
  final Map<String, String>? subtitleFormatParams;
  final String? title;
  final String? subtitle;
  final List<String> keywords;
  final String routePath;
  final GlobalSearchCategory category;

  String localizedTitle(String locale) {
    if (titleKey != null) {
      return GlobalSearchIndexStrings.t(titleKey!, locale);
    }
    return title!;
  }

  String localizedSubtitle(String locale) {
    if (subtitleKey != null) {
      final params = subtitleFormatParams;
      if (params != null && params.isNotEmpty) {
        return GlobalSearchIndexStrings.format(
          subtitleKey!,
          locale,
          params: params,
        );
      }
      return GlobalSearchIndexStrings.t(subtitleKey!, locale);
    }
    return subtitle!;
  }

  bool matches(String query, {String locale = 'English'}) {
    final q = query.toLowerCase().trim();
    if (q.isEmpty) return false;

    final titles = <String>{
      localizedTitle(locale),
      if (titleKey != null && locale != 'English')
        GlobalSearchIndexStrings.t(titleKey!, 'English'),
      if (title != null) title!,
    };
    final subtitles = <String>{
      localizedSubtitle(locale),
      if (subtitleKey != null && locale != 'English')
        GlobalSearchIndexStrings.t(subtitleKey!, 'English'),
      if (subtitle != null) subtitle!,
    };

    for (final t in titles) {
      if (t.toLowerCase().contains(q)) return true;
    }
    for (final s in subtitles) {
      if (s.toLowerCase().contains(q)) return true;
    }
    for (final kw in keywords) {
      if (kw.toLowerCase().contains(q)) return true;
    }

    final tokens = SearchKeywordTokenizer.tokenize(q);
    if (tokens.isEmpty) return false;
    final haystack = [
      ...titles,
      ...subtitles,
      ...keywords,
    ].join(' ').toLowerCase();
    return tokens.every((token) => haystack.contains(token));
  }

  int scoreFor(String query, {String locale = 'English'}) {
    final title = localizedTitle(locale);
    final englishTitle =
        titleKey != null ? GlobalSearchIndexStrings.t(titleKey!, 'English') : title;
    final subtitle = localizedSubtitle(locale);
    return SearchKeywordTokenizer.score(
      query: query,
      title: locale == 'English' ? title : '$title $englishTitle',
      subtitle: '$subtitle ${keywords.join(' ')}',
    );
  }
}

/// Client-side search over a static catalog.
List<StaticSearchEntry> searchStaticCatalog(
  String query,
  List<StaticSearchEntry> catalog, {
  String locale = 'English',
}) {
  if (query.trim().length < 2) return const [];
  return catalog.where((e) => e.matches(query, locale: locale)).toList();
}
