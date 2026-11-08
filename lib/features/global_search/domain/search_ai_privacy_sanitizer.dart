/// Deterministic privacy sanitizer before AI requests (S9).
abstract final class SearchAiPrivacySanitizer {
  static const maxInputLength = 500;
  static const redactedToken = '[REDACTED]';

  /// Returns sanitized text safe to send to AI. Returns null if unsendable.
  static String? sanitize(String query) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return null;
    if (_isBlockedForAi(trimmed)) return null;
    if (trimmed.length > maxInputLength) {
      return _applyRedactions(trimmed.substring(0, maxInputLength));
    }
    return _applyRedactions(trimmed);
  }

  static bool isBlocked(String query) => sanitize(query) == null;

  /// Blocks auth secrets — card/phone patterns are redacted, not blocked.
  static bool _isBlockedForAi(String trimmed) {
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

    // Payment card patterns.
    result = result.replaceAll(
      RegExp(r'\b\d{4}[\s-]?\d{4}[\s-]?\d{4}[\s-]?\d{4}\b'),
      redactedToken,
    );

    // QID-like 11-digit identifiers.
    result = result.replaceAll(
      RegExp(r'\b\d{11}\b'),
      redactedToken,
    );

    // Phone numbers (8+ digits, optional + prefix).
    result = result.replaceAll(
      RegExp(r'(\+?\d[\d\s-]{7,}\d)'),
      redactedToken,
    );

    // Standalone OTP-like codes (4-8 digits) — preserve common amounts.
    result = result.replaceAllMapped(
      RegExp(r'\b\d{4,8}\b'),
      (match) {
        final value = match.group(0)!;
        final n = int.tryParse(value);
        if (n != null && n <= 99999) return value;
        return redactedToken;
      },
    );

    // Long numeric identifiers (10+ digits).
    result = result.replaceAll(
      RegExp(r'\b\d{10,}\b'),
      redactedToken,
    );

    return result.trim();
  }
}
