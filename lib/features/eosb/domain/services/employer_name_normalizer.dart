import 'employer_name_suffixes.dart';

/// Deterministic employer-name key for aggregation — no AI, no fuzzy matching.
abstract final class EmployerNameNormalizer {
  static String normalize(String raw) {
    var normalized = raw.trim().toLowerCase();
    if (normalized.isEmpty) return '';

    normalized = normalized.replaceAll(RegExp(r'(?<=\w)\.(?=\w)'), '');
    normalized = normalized.replaceAll(RegExp(r'[.\-_/,]+'), ' ');
    normalized = normalized.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (normalized.isEmpty) return '';

    final tokens = normalized.split(' ');
    while (tokens.isNotEmpty &&
        EmployerNameSuffixes.suffixTokens.contains(tokens.last)) {
      tokens.removeLast();
    }

    return tokens.join(' ').trim();
  }
}
