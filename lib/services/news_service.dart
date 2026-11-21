import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:raabta/config/app_config.dart';
import 'package:raabta/features/community/services/community_moderation_config.dart';
import 'package:raabta/services/news/rss_news_parser.dart';

/// Fetches Qatar expat news via the Raabta backend cache (headline + link only).
///
/// Clients should not call RSS sources directly when the backend is reachable.
/// Direct RSS is a last-resort offline fallback only.
class NewsService {
  NewsService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static QatarNewsResponse? _memoryCache;

  static void clearClientCache() => _memoryCache = null;

  static const _userAgent =
      'Mozilla/5.0 (compatible; Raabta/1.0; +${AppConfig.publicWebsiteUrl})';

  static const _rssSources = [
    _RssSource(
      name: 'Google News',
      url:
          'https://news.google.com/rss/search?q=Qatar+expat+visa+labour+law&hl=en&gl=QA&ceid=QA:en',
      strictFilter: false,
    ),
    _RssSource(
      name: 'Google News Qatar',
      url:
          'https://news.google.com/rss/search?q=Qatar+Doha+expats&hl=en-US&gl=US&ceid=US:en',
      strictFilter: false,
    ),
    _RssSource(
      name: 'BBC Middle East',
      url: 'https://feeds.bbci.co.uk/news/world/middle_east/rss.xml',
      strictFilter: true,
    ),
    _RssSource(
      name: 'Al Jazeera',
      url: 'https://www.aljazeera.com/xml/rss/all.xml',
      strictFilter: true,
    ),
  ];

  Future<QatarNewsResponse> fetchQatarExpatNews({
    bool bypassClientCache = false,
  }) async {
    if (!bypassClientCache && _memoryCache != null && _memoryCache!.isFresh) {
      return _memoryCache!.copyWith(cached: true, sourceLabel: 'Client cache');
    }

    try {
      final backend = await _fetchFromBackend();
      if (backend.articles.isNotEmpty) {
        _memoryCache = backend;
        return backend;
      }
    } catch (_) {}

    if (_memoryCache != null && _memoryCache!.articles.isNotEmpty) {
      return _memoryCache!.copyWith(
        cached: true,
        stale: true,
        sourceLabel: 'Client cache (offline)',
      );
    }

    final merged = await _fetchFromRssSources();
    if (merged.isNotEmpty) {
      final fallback = QatarNewsResponse(
        articles: merged,
        cached: false,
        fetchedAt: DateTime.now(),
        sourceLabel: 'Offline RSS fallback',
      );
      _memoryCache = fallback;
      return fallback;
    }

    throw NewsServiceException(
      'Could not load news. Check your connection and pull to refresh.',
    );
  }

  Future<QatarNewsResponse> _fetchFromBackend() async {
    final uri = Uri.parse('${AppConfig.backendUrl}/api/news/qatar-expat');

    final response = await _client
        .get(
          uri,
          headers: {'Accept': 'application/json', 'User-Agent': _userAgent},
        )
        .timeout(const Duration(seconds: 12));

    if (response.statusCode == 404 || response.statusCode >= 500) {
      throw NewsServiceException('Backend unavailable (${response.statusCode})');
    }
    if (response.statusCode >= 400) {
      throw NewsServiceException('Backend error (${response.statusCode})');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final articles = (body['articles'] as List<dynamic>? ?? [])
        .map((e) => QatarNewsArticle.fromJson(e as Map<String, dynamic>))
        .where((a) => a.title.isNotEmpty)
        .toList();

    return QatarNewsResponse(
      articles: articles,
      cached: body['cached'] as bool? ?? false,
      fetchedAt: DateTime.tryParse(body['fetchedAt'] as String? ?? '') ??
          DateTime.now(),
      sourceLabel: 'Raabta API',
      stale: body['stale'] as bool? ?? false,
    );
  }

  Future<List<QatarNewsArticle>> _fetchFromRssSources() async {
    final seen = <String>{};
    final merged = <QatarNewsArticle>[];

    for (final source in _rssSources) {
      try {
        final articles = await _fetchRssSource(source);
        for (final article in articles) {
          final key = article.title.toLowerCase().trim();
          if (key.isEmpty || seen.contains(key)) continue;
          seen.add(key);
          merged.add(article);
        }
      } catch (_) {
        continue;
      }
      if (merged.length >= 25) break;
    }

    merged.sort((a, b) {
      final da = a.publishedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final db = b.publishedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return db.compareTo(da);
    });

    return merged.take(30).toList();
  }

  Future<List<QatarNewsArticle>> _fetchRssSource(_RssSource source) async {
    final response = await _client
        .get(
          Uri.parse(source.url),
          headers: {'User-Agent': _userAgent, 'Accept': 'application/rss+xml'},
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode >= 400) {
      throw NewsServiceException('RSS ${source.name} failed');
    }

    final xml = response.body;
    if (!xml.contains('<rss') && !xml.contains('<feed')) {
      throw NewsServiceException('Invalid RSS from ${source.name}');
    }

    var articles = RssNewsParser.parse(xml, defaultSource: source.name);

    if (source.strictFilter) {
      articles = articles
          .where(
            (a) => NewsCategorizer.isRelevant(
              a.title,
              a.summary,
              strict: true,
            ),
          )
          .toList();
    } else {
      articles = articles
          .where(
            (a) => NewsCategorizer.isRelevant(
              a.title,
              a.summary,
              strict: false,
            ),
          )
          .toList();
    }

    return articles;
  }
}

class _RssSource {
  const _RssSource({
    required this.name,
    required this.url,
    required this.strictFilter,
  });

  final String name;
  final String url;
  final bool strictFilter;
}

class QatarNewsResponse {
  const QatarNewsResponse({
    required this.articles,
    required this.cached,
    required this.fetchedAt,
    this.sourceLabel = 'Live',
    this.stale = false,
  });

  final List<QatarNewsArticle> articles;
  final bool cached;
  final DateTime fetchedAt;
  final String sourceLabel;
  final bool stale;

  bool get isFresh =>
      DateTime.now().difference(fetchedAt) <
      CommunityModerationConfig.newsClientCacheTtl;

  QatarNewsResponse copyWith({
    List<QatarNewsArticle>? articles,
    bool? cached,
    DateTime? fetchedAt,
    String? sourceLabel,
    bool? stale,
  }) {
    return QatarNewsResponse(
      articles: articles ?? this.articles,
      cached: cached ?? this.cached,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      sourceLabel: sourceLabel ?? this.sourceLabel,
      stale: stale ?? this.stale,
    );
  }
}

class QatarNewsArticle {
  const QatarNewsArticle({
    required this.title,
    required this.summary,
    required this.sourceName,
    required this.sourceUrl,
    required this.publishedAt,
    this.imageUrl,
    this.category = 'General',
  });

  final String title;
  final String summary;
  final String sourceName;
  final String sourceUrl;
  final DateTime? publishedAt;
  final String? imageUrl;
  final String category;

  factory QatarNewsArticle.fromJson(Map<String, dynamic> json) {
    return QatarNewsArticle(
      title: json['title'] as String? ?? '',
      summary: json['summary'] as String? ?? '',
      sourceName: json['sourceName'] as String? ?? 'News',
      sourceUrl: json['sourceUrl'] as String? ?? '',
      publishedAt: DateTime.tryParse(json['publishedAt'] as String? ?? ''),
      imageUrl: json['imageUrl'] as String?,
      category: json['category'] as String? ?? 'General',
    );
  }
}

class NewsServiceException implements Exception {
  NewsServiceException(this.message);
  final String message;

  @override
  String toString() => message;
}
