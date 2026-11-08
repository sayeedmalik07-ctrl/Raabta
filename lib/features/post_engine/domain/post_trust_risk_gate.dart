/// Deterministic criteria for escalating a listing draft to AI moderation (Part 7C).
abstract final class PostTrustRiskGate {
  /// Categories with higher scam prevalence — AI check only when matched.
  static const highRiskCategorySegments = {
    'mobiles',
    'laptops',
    'televisions',
    'cars',
    'motorcycles_bikes',
    'air_conditioners',
    'electronics',
  };

  static const scamKeywordPatterns = [
    'whatsapp only',
    'wire transfer',
    'pay first',
    'urgent deposit',
    'western union',
    'crypto only',
    'send money',
  ];

  /// Returns true when an AI moderation call is cost-justified for this draft.
  static bool shouldEscalateToAi({
    required String categoryPath,
    required Map<String, dynamic> fieldValues,
    required List<String> deterministicFlags,
  }) {
    if (deterministicFlags.contains('duplicate_listing')) return true;
    if (deterministicFlags.contains('suspicious_price')) return true;
    if (deterministicFlags.contains('invalid_price')) return true;
    if (_isHighRiskCategory(categoryPath)) return true;
    if (_hasScamKeywords(fieldValues)) return true;
    return false;
  }

  static bool _isHighRiskCategory(String categoryPath) {
    final segments = categoryPath.toLowerCase().split('.');
    return segments.any(highRiskCategorySegments.contains);
  }

  static bool _hasScamKeywords(Map<String, dynamic> values) {
    final text = [
      values['title'],
      values['description'],
      values['brand'],
      values['model'],
    ].whereType<Object>().map((e) => e.toString().toLowerCase()).join(' ');
    if (text.trim().isEmpty) return false;
    return scamKeywordPatterns.any(text.contains);
  }
}
