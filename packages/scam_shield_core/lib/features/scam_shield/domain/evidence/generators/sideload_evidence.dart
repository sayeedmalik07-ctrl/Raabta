import 'package:scam_shield_core/features/scam_shield/domain/evidence/scam_evidence_models.dart';

abstract final class SideloadEvidenceGenerator {
  static const priority = 650;

  static List<ScamEvidence> generate(List<String> localFlags) {
    if (!localFlags.contains('ss_flag_sideload_app')) return const [];
    return const [
      ScamEvidence(
        kind: ScamEvidenceKind.sideloadApp,
        priority: priority,
        textKey: 'ss_evidence_sideload',
        sourceLabel: 'Pattern check',
      ),
    ];
  }
}
