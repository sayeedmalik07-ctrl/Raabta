import 'package:raabta/core/search/search_keyword_tokenizer.dart';

/// Deterministic `searchKeywords` generation for `service_listings` (S3.1).
///
/// Uses public listing fields only — never phone, email, or user IDs.
abstract final class ServiceSearchKeywordBuilder {
  static const maxKeywords = 40;

  /// Caps description contribution to avoid indexing every word.
  static const maxDescriptionTokens = 12;

  static List<String> build({
    required String title,
    required String serviceName,
    required String serviceCategory,
    required String description,
    required String providerName,
    required String area,
  }) {
    final keywords = SearchKeywordTokenizer.buildFromFields([
      _stripPhoneLikeText(title),
      _stripPhoneLikeText(serviceName),
      _stripPhoneLikeText(serviceCategory),
      _stripPhoneLikeText(providerName),
      _stripPhoneLikeText(area),
      _sampleDescription(description),
    ]).where((token) => !_looksLikePhoneToken(token));

    final normalized = keywords.toList();
    if (normalized.length <= maxKeywords) return normalized;
    return normalized.take(maxKeywords).toList();
  }

  static String _stripPhoneLikeText(String value) {
    return value.replaceAll(RegExp(r'\+?\d[\d\s\-]{6,}\d'), ' ');
  }

  static bool _looksLikePhoneToken(String token) {
    final digits = token.replaceAll(RegExp(r'\D'), '');
    return digits.length >= 7;
  }

  static String _sampleDescription(String description) {
    final trimmed = description.trim();
    if (trimmed.isEmpty) return '';
    final tokens = SearchKeywordTokenizer.tokenize(trimmed);
    if (tokens.length <= maxDescriptionTokens) return trimmed;
    return tokens.take(maxDescriptionTokens).join(' ');
  }
}
