import 'package:raabta/features/community/services/community_fundraising_moderation_config.dart';

/// Local first-pass for public fundraising / private-account donation appeals.
abstract final class CommunityFundraisingModerationPrefilter {
  /// Returns true when content should trigger the fundraising warn interstitial.
  static bool shouldWarn(String text) {
    final trimmed = text.trim();
    if (trimmed.length < 8) return false;

    final normalized = _normalize(trimmed);

    if (_matchesAny(normalized, CommunityFundraisingModerationConfig.allowPatterns)) {
      return false;
    }

    if (_matchesAny(normalized, CommunityFundraisingModerationConfig.flagPatterns)) {
      return true;
    }

    final hasPaymentRail = RegExp(
      r'\b(iban|account number|bank details|wallet|swift|beneficiary)\b',
      caseSensitive: false,
    ).hasMatch(normalized);

    final hasCollectionFrame = RegExp(
      r'\b(collecting|collection|crowdfund|crowd fund|fundraising|fund raise|help needed|urgent help)\b',
      caseSensitive: false,
    ).hasMatch(normalized);

    if (hasPaymentRail && hasCollectionFrame) return true;

    return false;
  }

  static bool _matchesAny(String text, List<String> patterns) {
    for (final pattern in patterns) {
      if (RegExp(pattern, caseSensitive: false, unicode: true).hasMatch(text)) {
        return true;
      }
    }
    return false;
  }

  static String _normalize(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^\p{L}\p{N}\s./]', unicode: true), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}
