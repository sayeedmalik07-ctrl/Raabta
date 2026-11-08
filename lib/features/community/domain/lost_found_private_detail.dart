import 'package:raabta/features/community/domain/lost_found_sensitive_text.dart';

/// Finder-only verification detail (never on public listing doc).
abstract final class LostFoundPrivateDetail {
  static const subcollection = 'finder_private';
  static const documentId = 'detail';
  static const maxLength = 200;

  static const _forbiddenPhrases = [
    'iban',
    'bank account',
    'wire transfer',
    'reward',
    'payment',
    'qid number',
    'passport number',
    'credit card',
    'debit card',
  ];

  /// Returns normalized text or null if empty/invalid.
  static String? normalize(String? raw) {
    if (raw == null) return null;
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;
    if (trimmed.length > maxLength) {
      return trimmed.substring(0, maxLength);
    }
    final lower = trimmed.toLowerCase();
    for (final phrase in _forbiddenPhrases) {
      if (lower.contains(phrase)) return null;
    }
    if (LostFoundSensitiveText.containsProhibitedNumberPattern(trimmed)) {
      return null;
    }
    return trimmed;
  }
}
