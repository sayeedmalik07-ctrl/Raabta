import 'package:raabta/features/community/services/community_investment_moderation_prefilter.dart';
import 'package:raabta/features/marketplace/domain/marketplace_platform_hop_detector.dart';
import 'package:raabta/features/scam_shield/domain/scam_community_correlator.dart';

enum BuddyChatSafetyAdvisoryKind {
  platformHop,
  financialPressure,
}

/// Deterministic Buddy chat advisories — zero AI, non-blocking, advisory only.
abstract final class BuddyChatSafetyScanner {
  static const _peerToPeerMoneyPatternIds = {
    'job_visa_fee',
    'investment_guaranteed',
    'rental_deposit_scam',
  };

  static BuddyChatSafetyAdvisoryKind? scan(String text) {
    final trimmed = text.trim();
    if (trimmed.length < 6) return null;

    if (MarketplacePlatformHopDetector.scan(text: trimmed).hasSignal) {
      return BuddyChatSafetyAdvisoryKind.platformHop;
    }

    if (CommunityInvestmentModerationPrefilter.shouldWarn(trimmed)) {
      return BuddyChatSafetyAdvisoryKind.financialPressure;
    }

    final correlation = ScamCommunityCorrelator.analyze(trimmed);
    if (correlation.matches.any(
      (m) => _peerToPeerMoneyPatternIds.contains(m.patternId),
    )) {
      return BuddyChatSafetyAdvisoryKind.financialPressure;
    }

    return null;
  }
}
