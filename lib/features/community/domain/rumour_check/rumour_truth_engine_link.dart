import 'package:raabta/features/community/domain/rumour_check/rumour_check_models.dart';
import 'package:raabta/features/scam_shield/domain/evidence/scam_truth_engine_bridges.dart';

/// Optional deep link into an existing Truth Engine screen (deterministic, no AI).
class RumourTruthEngineLink {
  const RumourTruthEngineLink({
    required this.routePath,
    required this.target,
  });

  final String routePath;
  final ScamTruthEngineBridgeTarget target;
}

abstract final class RumourTruthEngineLinkResolver {
  static RumourTruthEngineLink? resolve({
    required RumourCategory category,
    required String claimText,
  }) {
    final lower = claimText.trim().toLowerCase();
    if (lower.isEmpty) {
      return _fromCategoryOnly(category);
    }

    if (_containsAny(lower, _overtimeKeywords)) {
      return _linkFor(ScamTruthEngineBridgeTarget.eosbOvertime);
    }
    if (_containsAny(lower, _eosbKeywords)) {
      return _linkFor(ScamTruthEngineBridgeTarget.eosbTruthEngine);
    }
    if (_containsAny(lower, _sponsorshipKeywords)) {
      return _linkFor(ScamTruthEngineBridgeTarget.sponsorshipTransfer);
    }
    if (_containsAny(lower, _tenancyKeywords)) {
      return _linkFor(ScamTruthEngineBridgeTarget.tenancyTruthEngine);
    }
    if (_containsAny(lower, _healthKeywords)) {
      return _linkFor(ScamTruthEngineBridgeTarget.healthInsurance);
    }
    if (_containsAny(lower, _visaKeywords)) {
      return _linkFor(ScamTruthEngineBridgeTarget.visaDocuments);
    }

    return _fromCategoryOnly(category);
  }

  static RumourTruthEngineLink? _fromCategoryOnly(RumourCategory category) {
    return switch (category) {
      RumourCategory.visa =>
        _linkFor(ScamTruthEngineBridgeTarget.visaDocuments),
      RumourCategory.labour =>
        _linkFor(ScamTruthEngineBridgeTarget.eosbTruthEngine),
      RumourCategory.housing =>
        _linkFor(ScamTruthEngineBridgeTarget.tenancyTruthEngine),
      RumourCategory.health =>
        _linkFor(ScamTruthEngineBridgeTarget.healthInsurance),
      RumourCategory.fees => null,
      RumourCategory.other => null,
    };
  }

  static RumourTruthEngineLink? _linkFor(ScamTruthEngineBridgeTarget target) {
    final meta = ScamTruthEngineBridgeTable.metaFor(target);
    if (meta == null || !meta.isBuilt) return null;
    return RumourTruthEngineLink(routePath: meta.routePath, target: target);
  }

  static bool _containsAny(String haystack, List<String> needles) {
    for (final needle in needles) {
      if (haystack.contains(needle)) return true;
    }
    return false;
  }

  static const _overtimeKeywords = [
    'overtime',
    'extra hours',
    'ot pay',
  ];

  static const _eosbKeywords = [
    'eosb',
    'end of service',
    'gratuity',
    'final settlement',
  ];

  static const _sponsorshipKeywords = [
    'sponsorship transfer',
    'change employer',
    'employer change',
    'noc',
    'transfer visa',
  ];

  static const _tenancyKeywords = [
    'tenancy',
    'landlord',
    'rent deposit',
    'lease',
    'eviction',
  ];

  static const _healthKeywords = [
    'health insurance',
    'medical insurance',
    'seha',
    'policy coverage',
  ];

  static const _visaKeywords = [
    'visa',
    'qid',
    'residence permit',
    'exit permit',
  ];
}
