import 'package:raabta/features/scam_shield/data/scam_community_patterns_config.dart';
import 'package:raabta/features/scam_shield/domain/scam_community_correlator.dart';

/// Local first-pass for investment-scheme / external-group-recruitment content.
///
/// Reuses [ScamCommunityPatternsConfig.investmentPattern] via [ScamCommunityCorrelator]
/// — no duplicated keyword list.
abstract final class CommunityInvestmentModerationPrefilter {
  static const _externalGroupInvitePatterns = [
    r'\bjoin\s+(our|this|my|the)\s+(whatsapp|telegram|wa|tg)\b.{0,80}\b(invest|investment|trading|crypto|forex|profit|usdt|returns?)\b',
    r'\b(whatsapp|telegram)\s+group\b.{0,60}\b(invest|investment|trading|crypto|forex|profit|returns?|double)\b',
    r'\b(invest|investment|trading|crypto|forex|profit)\b.{0,60}\b(whatsapp|telegram)\s+group\b',
    r'\b(t\.me/|chat\.whatsapp\.com/|wa\.me/)\S+',
  ];

  static const _ordinaryFinancialPatterns = [
    r'\b(salary|eosb|end of service|cost of living|bank account|remittance)\b',
    r'\bhow much (do|does|is|are)\b',
    r'\b(qnb|qatar national bank|commercial bank|doha bank|cbq)\b',
    r'\b(landlord|employer|rent|housing|visa fee|iqama)\b',
    r'\badvice\b',
    r'\bquestion\b',
    r'\banyone know\b',
    r'\bhas anyone\b',
  ];

  /// Returns true when content should trigger the investment warn interstitial.
  static bool shouldWarn(String text) {
    final trimmed = text.trim();
    if (trimmed.length < 8) return false;

    final normalized = _normalize(trimmed);
    if (_matchesAny(normalized, _ordinaryFinancialPatterns)) {
      return false;
    }

    final correlation = ScamCommunityCorrelator.analyze(trimmed);
    if (correlation.matches
        .any((m) => m.patternId == ScamCommunityPatternsConfig.investmentPattern.id)) {
      return true;
    }

    if (_matchesExternalInvestmentGroupRecruitment(normalized)) {
      return true;
    }

    return false;
  }

  static bool _matchesExternalInvestmentGroupRecruitment(String normalized) {
    final hasExternalLink = RegExp(
      r'\b(t\.me/|chat\.whatsapp\.com/|wa\.me/)\S+',
      caseSensitive: false,
    ).hasMatch(normalized);

    final hasGroupPlatform = RegExp(
      r'\b(whatsapp|telegram|wa group|tg group)\b',
      caseSensitive: false,
    ).hasMatch(normalized);

    final hasInvestmentFrame = RegExp(
      r'\b(invest|investment|trading|crypto|forex|usdt|guaranteed return|double your|profit group|signal group)\b',
      caseSensitive: false,
    ).hasMatch(normalized);

    if (hasExternalLink && hasInvestmentFrame) return true;

    if (hasGroupPlatform && hasInvestmentFrame) {
      return RegExp(
        r'\bjoin\b',
        caseSensitive: false,
      ).hasMatch(normalized);
    }

    for (final pattern in _externalGroupInvitePatterns) {
      if (RegExp(pattern, caseSensitive: false, dotAll: true).hasMatch(normalized)) {
        return true;
      }
    }

    return false;
  }

  static bool _matchesAny(String text, List<String> patterns) {
    for (final pattern in patterns) {
      if (RegExp(pattern, caseSensitive: false).hasMatch(text)) return true;
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
