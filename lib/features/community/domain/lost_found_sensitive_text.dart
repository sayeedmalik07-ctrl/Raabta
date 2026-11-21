/// Deterministic checks for ID/card-like number sequences (no logging).
abstract final class LostFoundSensitiveText {
  /// Minimum consecutive digits treated as sensitive (avoids years/dates alone).
  static const minLongDigitRun = 8;

  static final _longDigitRun = RegExp(r'\d{8,}');

  /// Qatar QID and similar national IDs are often 11 digits.
  static final _elevenDigitBlock = RegExp(r'(?<!\d)\d{11}(?!\d)');

  /// Returns true when text should be blocked from public listing fields.
  static bool containsProhibitedNumberPattern(String text) {
    if (text.trim().isEmpty) return false;
    final normalized = text.replaceAll(RegExp(r'[\s\-–—.]'), '');
    if (_longDigitRun.hasMatch(normalized)) return true;
    if (_elevenDigitBlock.hasMatch(normalized)) return true;
    return false;
  }

  static bool anyFieldContainsProhibited(Iterable<String> fields) {
    for (final field in fields) {
      if (containsProhibitedNumberPattern(field)) return true;
    }
    return false;
  }
}
