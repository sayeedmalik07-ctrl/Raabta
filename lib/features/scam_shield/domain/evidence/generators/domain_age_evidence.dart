import 'package:raabta/features/scam_shield/domain/evidence/domain_age_models.dart';
import 'package:raabta/features/scam_shield/domain/evidence/scam_evidence_models.dart';

abstract final class DomainAgeEvidenceGenerator {
  static const concernPriority = 720;
  static const infoPriority = 520;
  static const concernMaxDays = 29;
  static const infoMaxDays = 90;

  /// Old domains and unknowns produce no line (concern-only signal).
  static ScamEvidence? fromLookup({
    required String domain,
    required String locale,
    required DomainAgeLookupResult result,
  }) {
    if (!result.supported || !result.registered) return null;
    final age = result.ageDays;
    if (age == null || age > infoMaxDays) return null;

    final lookupDate =
        DateTime.now().toIso8601String().split('T').first;

    if (age <= concernMaxDays) {
      return ScamEvidence(
        kind: ScamEvidenceKind.domainAgeConcern,
        priority: concernPriority,
        textKey: 'ss_evidence_domain_age_concern',
        params: {
          'days': '$age',
          'domain': domain,
          'lookupDate': lookupDate,
        },
        sourceLabel: 'ss_evidence_domain_age_source',
        sourceDate: result.createdAt,
        direction: ScamEvidenceDirection.concern,
      );
    }

    return ScamEvidence(
      kind: ScamEvidenceKind.domainAgeInfo,
      priority: infoPriority,
      textKey: 'ss_evidence_domain_age_info',
      params: {
        'days': '$age',
        'domain': domain,
        'lookupDate': lookupDate,
      },
      sourceLabel: 'ss_evidence_domain_age_source',
      sourceDate: result.createdAt,
      direction: ScamEvidenceDirection.informational,
    );
  }

  /// Risk merge: never alone — requires at least one other local concern flag.
  static bool shouldContributeRiskFlag({
    required DomainAgeLookupResult result,
    required List<String> otherLocalFlags,
  }) {
    if (!result.supported || !result.registered) return false;
    final age = result.ageDays;
    if (age == null || age > concernMaxDays) return false;
    if (otherLocalFlags.isEmpty) return false;
    return true;
  }
}
