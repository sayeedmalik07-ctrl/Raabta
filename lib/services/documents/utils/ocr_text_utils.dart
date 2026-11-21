/// Shared OCR text normalization and label-anchored value extraction.
class OcrTextUtils {
  OcrTextUtils._();

  static String normalize(String text) =>
      text.replaceAll('\r\n', '\n').replaceAll('\r', '\n');

  static List<String> lines(String text) =>
      normalize(text).split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();

  static String collapseWhitespace(String text) =>
      text.replaceAll(RegExp(r'\s+'), ' ').trim();

  /// Case-insensitive search for any needle in [haystack].
  static bool containsAny(String haystack, Iterable<String> needles) {
    final lower = haystack.toLowerCase();
    for (final needle in needles) {
      if (lower.contains(needle.toLowerCase())) return true;
    }
    return false;
  }

  /// Find first regex match in full text (multiline).
  static RegExpMatch? firstMatch(String text, RegExp pattern) =>
      pattern.firstMatch(text);

  /// Extract value on same line after a label, or on the next non-empty line.
  static String? valueAfterLabel(
    String text,
    Iterable<String> labels, {
    RegExp? valuePattern,
  }) {
    final allLines = lines(text);
    for (var i = 0; i < allLines.length; i++) {
      final line = allLines[i];
      for (final label in labels) {
        final labelRe = RegExp(
          '${RegExp.escape(label)}\\s*[:：]?\\s*(.*)',
          caseSensitive: false,
        );
        final sameLine = labelRe.firstMatch(line);
        if (sameLine != null) {
          final captured = sameLine.group(1)?.trim();
          if (captured != null && captured.isNotEmpty) {
            if (valuePattern == null || valuePattern.hasMatch(captured)) {
              return captured;
            }
          }
          if (i + 1 < allLines.length) {
            final next = allLines[i + 1].trim();
            if (next.isNotEmpty &&
                (valuePattern == null || valuePattern.hasMatch(next))) {
              return next;
            }
          }
        }

        if (line.toLowerCase().contains(label.toLowerCase()) &&
            i + 1 < allLines.length) {
          final next = allLines[i + 1].trim();
          if (next.isNotEmpty &&
              (valuePattern == null || valuePattern.hasMatch(next))) {
            return next;
          }
        }
      }
    }
    return null;
  }

  /// Pull first amount-like token near any of [anchorWords] within [window] chars.
  static double? amountNearAnchors(
    String text,
    Iterable<String> anchorWords, {
    int window = 80,
  }) {
    final amountRe = RegExp(
      r'(?:QAR|QR|ر\.?\s*ق)?\s*([\d,]+\.?\d*)',
      caseSensitive: false,
    );
    final lower = text.toLowerCase();
    for (final anchor in anchorWords) {
      final idx = lower.indexOf(anchor.toLowerCase());
      if (idx < 0) continue;
      final slice = text.substring(
        idx,
        (idx + window).clamp(0, text.length),
      );
      final match = amountRe.firstMatch(slice);
      if (match != null) {
        final raw = match.group(1)?.replaceAll(',', '');
        if (raw != null) {
          final value = double.tryParse(raw);
          if (value != null && value > 0) return value;
        }
      }
    }
    return null;
  }

  static String? firstLineLikelyVendor(String text) {
    final skip = RegExp(
      r'^(receipt|tax invoice|invoice|فاتورة|إيصال|tel|phone|www\.|http)',
      caseSensitive: false,
    );
    for (final line in lines(text)) {
      if (line.length < 3 || line.length > 60) continue;
      if (skip.hasMatch(line)) continue;
      if (RegExp(r'^\d').hasMatch(line)) continue;
      return line;
    }
    return null;
  }
}
