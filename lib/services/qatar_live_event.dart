import 'package:raabta/services/news/rss_news_parser.dart';

/// A public event happening in Qatar, fetched from online sources (not community posts).
class QatarLiveEvent {
  const QatarLiveEvent({
    required this.id,
    required this.title,
    required this.summary,
    required this.location,
    required this.dateTime,
    required this.sourceName,
    required this.sourceUrl,
    required this.category,
    this.isFree = false,
    this.emoji = '🎉',
  });

  final String id;
  final String title;
  final String summary;
  final String location;
  final DateTime? dateTime;
  final String sourceName;
  final String sourceUrl;
  final String category;
  final bool isFree;
  final String emoji;

  List<String> get tags {
    final t = <String>['Upcoming', category];
    if (isFree) t.add('Free');
    if (_isThisWeek) t.add('This Week');
    return t.toSet().toList();
  }

  bool get _isThisWeek {
    final dt = dateTime;
    if (dt == null) return false;
    final now = DateTime.now();
    return !dt.isBefore(now) && dt.isBefore(now.add(const Duration(days: 7)));
  }
}

class QatarEventCategorizer {
  static bool isEventRelevant(String title, String summary) {
    final text = '$title $summary'.toLowerCase();
    if (!text.contains('qatar') && !text.contains('doha')) return false;
    const eventWords = [
      'event', 'concert', 'festival', 'exhibition', 'meetup', 'meet-up',
      'conference', 'summit', 'marathon', 'tournament', 'show', 'fair',
      'gala', 'workshop', 'seminar', 'opening', 'celebration', 'night',
      'cricket', 'football', 'sport', 'cultural', 'iftar', 'eid', 'national day',
    ];
    return eventWords.any(text.contains);
  }

  static String categorize(String title, String summary) {
    final text = '$title $summary'.toLowerCase();
    if (RegExp(r'\bfree\b|no charge|complimentary|gratis').hasMatch(text)) {
      return 'Free';
    }
    if (RegExp(r'sport|cricket|football|marathon|tournament|fitness|gym').hasMatch(text)) {
      return 'Sports';
    }
    if (RegExp(r'cultural|concert|festival|art|music|heritage|museum|theatre|theater').hasMatch(text)) {
      return 'Cultural';
    }
    return 'Upcoming';
  }

  static bool detectFree(String title, String summary) {
    final text = '$title $summary'.toLowerCase();
    return RegExp(r'\bfree\b|no charge|complimentary|gratis|free entry').hasMatch(text);
  }

  static String emojiFor(String title, String summary) {
    final text = '$title $summary'.toLowerCase();
    if (text.contains('cricket') || text.contains('sport')) return '🏏';
    if (text.contains('concert') || text.contains('music')) return '🎤';
    if (text.contains('festival')) return '🎪';
    if (text.contains('exhibition') || text.contains('art')) return '🎨';
    if (text.contains('marathon') || text.contains('run')) return '🏃';
    if (text.contains('conference') || text.contains('summit')) return '💼';
    if (text.contains('food') || text.contains('iftar')) return '🍽️';
    return '🎉';
  }

  static String guessLocation(String title, String summary) {
    final text = '$title $summary';
    const areas = [
      'Al Khor', 'Lusail', 'West Bay', 'The Pearl', 'Katara', 'Souq Waqif',
      'Education City', 'Aspire', 'Industrial Area', 'Al Wakrah', 'Museum of Islamic Art',
    ];
    for (final area in areas) {
      if (text.toLowerCase().contains(area.toLowerCase())) return area;
    }
    return 'Doha, Qatar';
  }
}

/// Converts RSS news-style items into [QatarLiveEvent] entries.
List<QatarLiveEvent> mapRssToLiveEvents(
  List<dynamic> articles, {
  required String Function(dynamic) getTitle,
  required String Function(dynamic) getSummary,
  required String Function(dynamic) getUrl,
  required String Function(dynamic) getSource,
  required DateTime? Function(dynamic) getDate,
}) {
  final events = <QatarLiveEvent>[];
  for (final a in articles) {
    final title = getTitle(a);
    final summary = getSummary(a);
    if (!QatarEventCategorizer.isEventRelevant(title, summary)) continue;

    final url = getUrl(a);
    events.add(
      QatarLiveEvent(
        id: url.hashCode.toString(),
        title: title,
        summary: summary,
        location: QatarEventCategorizer.guessLocation(title, summary),
        dateTime: getDate(a),
        sourceName: getSource(a),
        sourceUrl: url,
        category: QatarEventCategorizer.categorize(title, summary),
        isFree: QatarEventCategorizer.detectFree(title, summary),
        emoji: QatarEventCategorizer.emojiFor(title, summary),
      ),
    );
  }
  return events;
}

List<QatarLiveEvent> mapNewsArticlesToEvents(List<dynamic> articles) {
  return mapRssToLiveEvents(
    articles,
    getTitle: (a) => (a as dynamic).title as String,
    getSummary: (a) => (a as dynamic).summary as String,
    getUrl: (a) => (a as dynamic).sourceUrl as String,
    getSource: (a) => (a as dynamic).sourceName as String,
    getDate: (a) => (a as dynamic).publishedAt as DateTime?,
  );
}

/// Parse RSS XML directly into live events.
List<QatarLiveEvent> parseRssXmlToEvents(String xml, String sourceName) {
  final parsed = RssNewsParser.parse(xml, defaultSource: sourceName);
  return parsed
      .where((a) => QatarEventCategorizer.isEventRelevant(a.title, a.summary))
      .map(
        (a) => QatarLiveEvent(
          id: a.sourceUrl.hashCode.toString(),
          title: a.title,
          summary: a.summary,
          location: QatarEventCategorizer.guessLocation(a.title, a.summary),
          dateTime: a.publishedAt,
          sourceName: a.sourceName,
          sourceUrl: a.sourceUrl,
          category: QatarEventCategorizer.categorize(a.title, a.summary),
          isFree: QatarEventCategorizer.detectFree(a.title, a.summary),
          emoji: QatarEventCategorizer.emojiFor(a.title, a.summary),
        ),
      )
      .toList();
}
