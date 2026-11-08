/// Multi-format date parsing for OCR text (English + Arabic numerals).
class DateParseUtils {
  DateParseUtils._();

  static final _patterns = <RegExp>[
    RegExp(r'(\d{4})[-/.](\d{1,2})[-/.](\d{1,2})'),
    RegExp(r'(\d{1,2})[-/.](\d{1,2})[-/.](\d{4})'),
    RegExp(r'(\d{1,2})[-/.](\d{1,2})[-/.](\d{2})\b'),
    RegExp(
      r'(\d{1,2})\s+(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)[a-z]*\s+(\d{4})',
      caseSensitive: false,
    ),
  ];

  static DateTime? parseFirst(String text) {
    for (final pattern in _patterns) {
      final match = pattern.firstMatch(text);
      if (match == null) continue;
      final parsed = _fromMatch(match, pattern);
      if (parsed != null && _isSaneDate(parsed)) return parsed;
    }
    return null;
  }

  static DateTime? parseNearLabels(String text, Iterable<String> labels) {
    final lower = text.toLowerCase();
    for (final label in labels) {
      final idx = lower.indexOf(label.toLowerCase());
      if (idx < 0) continue;
      final slice = text.substring(
        idx,
        (idx + 120).clamp(0, text.length),
      );
      final parsed = parseFirst(slice);
      if (parsed != null) return parsed;
    }
    return null;
  }

  static DateTime parseMrzDate(String yymmdd, {required bool isExpiry}) {
    final yy = int.parse(yymmdd.substring(0, 2));
    final mm = int.parse(yymmdd.substring(2, 4));
    final dd = int.parse(yymmdd.substring(4, 6));
    final now = DateTime.now();
    final currentYy = now.year % 100;

    int year;
    if (isExpiry) {
      year = yy >= 50 ? 1900 + yy : 2000 + yy;
    } else {
      year = yy > currentYy ? 1900 + yy : 2000 + yy;
    }
    return DateTime(year, mm, dd);
  }

  static bool _isSaneDate(DateTime date) {
    final now = DateTime.now();
    return date.year >= 1950 && date.year <= now.year + 30;
  }

  static DateTime? _fromMatch(RegExpMatch match, RegExp pattern) {
    try {
      final source = pattern.pattern;
      if (source.startsWith(r'(\d{4})')) {
        return DateTime(
          int.parse(match.group(1)!),
          int.parse(match.group(2)!),
          int.parse(match.group(3)!),
        );
      }
      if (source.contains('Jan|Feb')) {
        final month = _monthIndex(match.group(2)!);
        if (month == null) return null;
        return DateTime(
          int.parse(match.group(3)!),
          month,
          int.parse(match.group(1)!),
        );
      }
      final a = int.parse(match.group(1)!);
      final b = int.parse(match.group(2)!);
      var c = int.parse(match.group(3)!);
      if (c < 100) c += c >= 50 ? 1900 : 2000;

      // Prefer DD/MM when one part > 12 (common on Qatari documents).
      if (a > 12 && b <= 12) {
        return DateTime(c, b, a);
      }
      if (b > 12 && a <= 12) {
        return DateTime(c, a, b);
      }
      return DateTime(c, b, a);
    } catch (_) {
      return null;
    }
  }

  static int? _monthIndex(String raw) {
    const months = [
      'jan', 'feb', 'mar', 'apr', 'may', 'jun',
      'jul', 'aug', 'sep', 'oct', 'nov', 'dec',
    ];
    final key = raw.toLowerCase().substring(0, 3);
    final idx = months.indexOf(key);
    return idx >= 0 ? idx + 1 : null;
  }

  static bool isExpiryAfterIssue(DateTime? expiry, DateTime? issue) {
    if (expiry == null || issue == null) return true;
    return expiry.isAfter(issue);
  }
}
