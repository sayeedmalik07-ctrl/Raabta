/// Privacy sanitizer before semantic embedding (S12).
abstract final class SearchSemanticPrivacySanitizer {
  static const maxInputLength = 500;

  /// Returns sanitized text safe to embed. Returns null if blocked.
  static String? sanitize(String query) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return null;
    if (isBlocked(trimmed)) return null;
    if (trimmed.length > maxInputLength) {
      return _applyRedactions(trimmed.substring(0, maxInputLength));
    }
    return _applyRedactions(trimmed);
  }

  static bool isBlocked(String query) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return true;
    if (trimmed.length < 2) return true;

    final lower = trimmed.toLowerCase();
    const blockedTerms = [
      'password',
      'passwd',
      'otp',
      'pin code',
      'cvv',
      'cvc',
      'secret',
      'token',
      'api key',
      'apikey',
    ];
    if (blockedTerms.any(lower.contains)) return true;

    if (RegExp(r'^\d+$').hasMatch(trimmed) && trimmed.length >= 6) {
      return true;
    }
    return false;
  }

  static String _applyRedactions(String input) {
    var result = input;

    result = result.replaceAll(
      RegExp(r'\b\d{4}[\s-]?\d{4}[\s-]?\d{4}[\s-]?\d{4}\b'),
      '[REDACTED]',
    );

    result = result.replaceAll(
      RegExp(r'\b\d{11}\b'),
      '[REDACTED]',
    );

    result = result.replaceAll(
      RegExp(r'(\+?\d[\d\s-]{7,}\d)'),
      '[REDACTED]',
    );

    result = result.replaceAllMapped(
      RegExp(r'\b\d{4,8}\b'),
      (match) {
        final value = match.group(0)!;
        final n = int.tryParse(value);
        if (n != null && n <= 99999) return value;
        return '[REDACTED]';
      },
    );

    result = result.replaceAll(
      RegExp(r'\b\d{10,}\b'),
      '[REDACTED]',
    );

    return result.trim();
  }
}
