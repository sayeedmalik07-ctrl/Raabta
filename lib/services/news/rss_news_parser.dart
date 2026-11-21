import 'package:raabta/services/news_service.dart';

/// Parses RSS 2.0 XML into [QatarNewsArticle] items.
class RssNewsParser {
  static List<QatarNewsArticle> parse(String xml, {String defaultSource = 'RSS'}) {
    final items = <QatarNewsArticle>[];
    final blocks = RegExp(r'<item[\s\S]*?<\/item>', caseSensitive: false)
        .allMatches(xml);

    for (final match in blocks) {
      final block = match.group(0)!;
      final title = _field(block, 'title');
      final link = _link(block);
      final description = _field(block, 'description') ?? _field(block, 'content:encoded');
      final pubDate = _field(block, 'pubDate') ?? _field(block, 'dc:date');
      final source = _field(block, 'source') ?? defaultSource;

      if (title == null || title.isEmpty || link == null || link.isEmpty) {
        continue;
      }

      items.add(
        QatarNewsArticle(
          title: title,
          summary: _cleanSummary(description ?? title),
          sourceName: source,
          sourceUrl: link,
          publishedAt: _parseDate(pubDate),
          category: NewsCategorizer.categorize(title, description ?? ''),
        ),
      );
    }

    return items;
  }

  static String? _field(String block, String tag) {
    final cdata = RegExp(
      '<$tag[^>]*><!\\[CDATA\\[([\\s\\S]*?)\\]\\]></$tag>',
      caseSensitive: false,
    ).firstMatch(block);
    if (cdata != null) return _decode(cdata.group(1));

    final plain = RegExp(
      '<$tag[^>]*>([\\s\\S]*?)</$tag>',
      caseSensitive: false,
    ).firstMatch(block);
    return plain != null ? _decode(plain.group(1)) : null;
  }

  static String? _link(String block) {
    final atom = RegExp(
      '<link[^>]*>([\\s\\S]*?)</link>',
      caseSensitive: false,
    ).firstMatch(block);
    if (atom != null) {
      final v = _decode(atom.group(1));
      if (v != null && v.startsWith('http')) return v;
    }

    final attr = RegExp(
      "<link[^>]*href=['\"]([^'\"]+)['\"]",
      caseSensitive: false,
    ).firstMatch(block);
    return attr != null ? _decode(attr.group(1)) : null;
  }

  static String _cleanSummary(String text) {
    final cleaned = _decode(text)?.replaceAll(RegExp(r'\s+'), ' ').trim() ?? '';
    if (cleaned.length <= 280) return cleaned;
    return '${cleaned.substring(0, 277)}...';
  }

  static String? _decode(String? raw) {
    if (raw == null) return null;
    return raw
        .replaceAll(RegExp(r'<[^>]+>'), '')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&apos;', "'")
        .trim();
  }

  static DateTime? _parseDate(String? raw) {
    if (raw == null || raw.isEmpty) return DateTime.now();
    return DateTime.tryParse(raw) ?? DateTime.now();
  }
}

class NewsCategorizer {
  static const _expatKeywords = [
    'qatar',
    'expat',
    'visa',
    'residency',
    'iqama',
    'labour',
    'labor',
    'worker',
    'traffic',
    'weather',
    'doha',
    'housing',
    'salary',
    'sponsor',
    'gcc',
    'metrash',
    'ministry',
  ];

  static bool isRelevant(String title, String summary, {bool strict = true}) {
    final text = '$title $summary'.toLowerCase();
    // Always require Qatar/Doha mention for this feed
    if (!text.contains('qatar') && !text.contains('doha')) {
      return false;
    }
    if (!strict) return true;
    return _expatKeywords.any(text.contains);
  }

  static String categorize(String title, String summary) {
    final text = '$title $summary'.toLowerCase();
    if (RegExp(r'visa|iqama|residency|exit permit|metrash|sponsor').hasMatch(text)) {
      return 'Visa';
    }
    if (RegExp(r'job|hiring|salary|labour|labor|worker|employment').hasMatch(text)) {
      return 'Jobs';
    }
    if (RegExp(r'traffic|road|expressway|metro|transport').hasMatch(text)) {
      return 'Traffic';
    }
    if (RegExp(r'event|festival|national day|holiday|celebration').hasMatch(text)) {
      return 'Events';
    }
    if (RegExp(r'government|ministry|mol|law|regulation|decree').hasMatch(text)) {
      return 'Government';
    }
    return 'General';
  }
}
