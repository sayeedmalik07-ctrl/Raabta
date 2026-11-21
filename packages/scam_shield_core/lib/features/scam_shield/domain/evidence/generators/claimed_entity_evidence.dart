import 'package:scam_shield_core/features/scam_shield/domain/evidence/scam_evidence_models.dart';
import 'package:scam_shield_core/features/scam_shield/domain/official_directory.dart';

abstract final class ClaimedEntityEvidenceGenerator {
  static ScamEvidenceHeadline headline(String text, String locale) {
    final claim = OfficialDirectory.detectClaimedEntity(text, locale);
    final id = claim.primaryId;
    if (id == null) {
      return const ScamEvidenceHeadline(textKey: 'ss_evidence_headline_generic');
    }
    final entry = OfficialDirectory.lookupById(id);
    return ScamEvidenceHeadline(
      textKey: 'ss_evidence_headline_claimed',
      params: {'entity': entry?.displayName(locale) ?? id},
    );
  }

  static List<ScamEvidence> generate(String text, String locale) {
    final claim = OfficialDirectory.detectClaimedEntity(text, locale);
    if (claim.primaryId == null) return const [];
    final entry = OfficialDirectory.lookupById(claim.primaryId!);
    if (entry == null) return const [];
    return [
      ScamEvidence(
        kind: ScamEvidenceKind.claimedEntity,
        priority: 400,
        textKey: 'ss_evidence_claimed_entity',
        params: {'entity': entry.displayName(locale)},
        sourceLabel: 'Official directory',
        entityId: entry.id,
        direction: ScamEvidenceDirection.informational,
      ),
    ];
  }
}
