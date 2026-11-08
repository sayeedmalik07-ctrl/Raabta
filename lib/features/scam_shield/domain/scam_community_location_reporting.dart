import 'package:raabta/features/scam_shield/domain/scam_community_correlator.dart';

/// Location-relevant subset of bundled Phase 6 archetypes (Part A).
abstract final class ScamCommunityLocationReporting {
  static const locationRelevantPatternIds = {
    'rental_deposit_scam',
    'job_visa_fee',
    'delivery_customs_fee',
  };

  static bool isLocationRelevant(String patternId) =>
      locationRelevantPatternIds.contains(patternId);

  static ScamCommunityPatternMatch? firstLocationRelevantMatch(
    ScamCommunityCorrelationResult correlation,
  ) {
    for (final match in correlation.matches) {
      if (isLocationRelevant(match.patternId)) return match;
    }
    return null;
  }
}
