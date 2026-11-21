import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:raabta/config/app_config.dart';
import 'package:raabta/services/qatar_live_event.dart';

/// Fetches live Qatar events from multiple online RSS/API sources.
/// Community "Post Event" submissions remain separate in Firestore.
class QatarEventsService {
  QatarEventsService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const _userAgent =
      'Mozilla/5.0 (compatible; Raabta/1.0; +${AppConfig.publicWebsiteUrl})';

  static const _rssSources = [
    _EventRssSource(
      name: 'Google Events Qatar',
      url:
          'https://news.google.com/rss/search?q=Qatar+Doha+events+concert+festival+2026&hl=en&gl=QA&ceid=QA:en',
    ),
    _EventRssSource(
      name: 'Google Meetups Qatar',
      url:
          'https://news.google.com/rss/search?q=Qatar+meetup+exhibition+workshop+Doha&hl=en-US&gl=US&ceid=US:en',
    ),
    _EventRssSource(
      name: 'Google Sports Qatar',
      url:
          'https://news.google.com/rss/search?q=Qatar+cricket+tournament+marathon+sport+Doha&hl=en&gl=QA&ceid=QA:en',
    ),
    _EventRssSource(
      name: 'Google Cultural Qatar',
      url:
          'https://news.google.com/rss/search?q=Qatar+cultural+festival+heritage+Katara+Doha&hl=en&gl=QA&ceid=QA:en',
    ),
    _EventRssSource(
      name: 'Eventbrite Qatar',
      url:
          'https://news.google.com/rss/search?q=site:eventbrite.com+Qatar+Doha+events&hl=en&gl=US&ceid=US:en',
    ),
  ];

  Future<QatarLiveEventsResponse> fetchLiveEvents() async {
    try {
      final backend = await _fetchFromBackend();
      if (backend.events.isNotEmpty) return backend;
    } catch (_) {}

    final merged = await _fetchFromRssSources();
    if (merged.isNotEmpty) {
      return QatarLiveEventsResponse(
        events: merged,
        fetchedAt: DateTime.now(),
        sourceLabel: 'Live',
      );
    }

    throw QatarEventsException(
      'Could not load live events. Pull to refresh.',
    );
  }

  Future<QatarLiveEventsResponse> _fetchFromBackend() async {
    final response = await _client
        .get(
          Uri.parse('${AppConfig.backendUrl}/api/events/qatar-live'),
          headers: {'Accept': 'application/json', 'User-Agent': _userAgent},
        )
        .timeout(const Duration(seconds: 12));

    if (response.statusCode == 404 || response.statusCode >= 500) {
      throw QatarEventsException('Backend unavailable');
    }
    if (response.statusCode >= 400) {
      throw QatarEventsException('Backend error');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final events = (body['events'] as List<dynamic>? ?? [])
        .map((e) => QatarLiveEvent(
              id: e['id'] as String? ?? '${e['sourceUrl']}'.hashCode.toString(),
              title: e['title'] as String? ?? '',
              summary: e['summary'] as String? ?? '',
              location: e['location'] as String? ?? 'Doha, Qatar',
              dateTime: DateTime.tryParse(e['dateTime'] as String? ?? ''),
              sourceName: e['sourceName'] as String? ?? 'Events',
              sourceUrl: e['sourceUrl'] as String? ?? '',
              category: e['category'] as String? ?? 'Upcoming',
              isFree: e['isFree'] as bool? ?? false,
              emoji: e['emoji'] as String? ?? '🎉',
            ))
        .toList();

    return QatarLiveEventsResponse(
      events: events,
      fetchedAt: DateTime.tryParse(body['fetchedAt'] as String? ?? '') ??
          DateTime.now(),
      sourceLabel: 'Raabta API',
    );
  }

  Future<List<QatarLiveEvent>> _fetchFromRssSources() async {
    final seen = <String>{};
    final merged = <QatarLiveEvent>[];

    for (final source in _rssSources) {
      try {
        final response = await _client
            .get(
              Uri.parse(source.url),
              headers: {
                'User-Agent': _userAgent,
                'Accept': 'application/rss+xml',
              },
            )
            .timeout(const Duration(seconds: 15));

        if (response.statusCode >= 400) continue;
        final events = parseRssXmlToEvents(response.body, source.name);

        for (final event in events) {
          final key = event.title.toLowerCase().trim();
          if (key.isEmpty || seen.contains(key)) continue;
          seen.add(key);
          merged.add(event);
        }
      } catch (_) {
        continue;
      }
      if (merged.length >= 25) break;
    }

    merged.sort((a, b) {
      final da = a.dateTime ?? DateTime.fromMillisecondsSinceEpoch(0);
      final db = b.dateTime ?? DateTime.fromMillisecondsSinceEpoch(0);
      return db.compareTo(da);
    });

    return merged.take(30).toList();
  }
}

class _EventRssSource {
  const _EventRssSource({required this.name, required this.url});
  final String name;
  final String url;
}

class QatarLiveEventsResponse {
  const QatarLiveEventsResponse({
    required this.events,
    required this.fetchedAt,
    this.sourceLabel = 'Live',
  });

  final List<QatarLiveEvent> events;
  final DateTime fetchedAt;
  final String sourceLabel;

  bool get isFresh => DateTime.now().difference(fetchedAt).inMinutes < 30;
}

class QatarEventsException implements Exception {
  QatarEventsException(this.message);
  final String message;
  @override
  String toString() => message;
}
