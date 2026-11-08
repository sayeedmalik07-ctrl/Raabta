import 'package:scam_shield_core/features/scam_shield/domain/evidence/scam_evidence_models.dart';

/// Documented combination weight — never applied to risk band without concern peers.
abstract final class PersonalContextCombinationPolicy {
  /// Small additive weight when mismatch appears with other concern evidence.
  static const combinationWeight = 4;

  static int concernEvidenceCount(List<ScamEvidence> evidence) {
    return evidence
        .where((e) => e.direction == ScamEvidenceDirection.concern)
        .length;
  }

  static bool qualifiesForCombinationBoost(List<ScamEvidence> evidence) {
    final hasMismatch = evidence.any(
      (e) => e.kind == ScamEvidenceKind.personalContextMismatch,
    );
    if (!hasMismatch) return false;
    return concernEvidenceCount(evidence) >= 2;
  }

  static int combinationBoost(List<ScamEvidence> evidence) {
    return qualifiesForCombinationBoost(evidence) ? combinationWeight : 0;
  }
}
