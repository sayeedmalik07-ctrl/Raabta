/// URL extraction for user-generated text (Phase 32).
abstract final class LinkUrlExtractor {
  static final _urlRegex = RegExp(
    r'(?:(?:https?://)|(?:www\.))[^\s<>"{}|\\^`\[\]]+',
    caseSensitive: false,
  );

  static final _bareDomainRegex = RegExp(
    r'\b([a-z0-9\u0600-\u06FF][-a-z0-9\u0600-\u06FF]*(?:\.[a-z0-9\u0600-\u06FF][-a-z0-9\u0600-\u06FF]*)+\.[a-z]{2,})\b',
    caseSensitive: false,
  );

  static List<String> extractUrlsInOrder(String text) {
    final seen = <String>{};
    final ordered = <String>[];
    for (final match in _urlRegex.allMatches(text)) {
      var raw = match.group(0)!;
      while (raw.endsWith('.') || raw.endsWith(',') || raw.endsWith(')')) {
        raw = raw.substring(0, raw.length - 1);
      }
      if (seen.add(raw)) ordered.add(raw);
    }
    for (final match in _bareDomainRegex.allMatches(text)) {
      final domain = match.group(1)!;
      if (domain.contains('@')) continue;
      final asUrl = 'https://$domain';
      if (seen.add(asUrl)) ordered.add(asUrl);
    }
    return ordered;
  }
}
