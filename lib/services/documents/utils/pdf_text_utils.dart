/// Best-effort text extraction from text-based PDF bytes (email confirmations).
class PdfTextUtils {
  PdfTextUtils._();

  /// Extracts visible text from common PDF text streams. Returns empty for
  /// scanned/image-only PDFs — caller should prompt for a photo instead.
  static String extractText(List<int> bytes) {
    final raw = String.fromCharCodes(bytes, 0, bytes.length.clamp(0, 500000));
    final buffer = StringBuffer();

    final parenPattern = RegExp(r'\(([^\\)]{2,200})\)');
    for (final match in parenPattern.allMatches(raw)) {
      final chunk = match.group(1);
      if (chunk == null || !_isLikelyText(chunk)) continue;
      buffer.writeln(_unescapePdfString(chunk));
    }

    final tjPattern = RegExp(r'\[(.*?)\]\s*TJ', dotAll: true);
    for (final match in tjPattern.allMatches(raw)) {
      final inner = match.group(1) ?? '';
      for (final part in RegExp(r'\(([^)]*)\)').allMatches(inner)) {
        final text = part.group(1);
        if (text != null && _isLikelyText(text)) {
          buffer.write(_unescapePdfString(text));
        }
      }
    }

    return buffer.toString().replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  static bool _isLikelyText(String s) {
    if (s.length < 2) return false;
    final printable = RegExp(r'[\x20-\x7E\u0600-\u06FF]');
    final hits = printable.allMatches(s).length;
    return hits / s.length > 0.7;
  }

  static String _unescapePdfString(String s) {
    return s
        .replaceAll(r'\(', '(')
        .replaceAll(r'\)', ')')
        .replaceAll(r'\\', '\\')
        .replaceAll(r'\n', '\n');
  }
}
