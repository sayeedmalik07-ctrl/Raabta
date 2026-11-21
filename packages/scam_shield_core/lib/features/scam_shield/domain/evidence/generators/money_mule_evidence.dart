import 'package:scam_shield_core/features/scam_shield/domain/evidence/money_mule_detector.dart';
import 'package:scam_shield_core/features/scam_shield/domain/evidence/scam_evidence_models.dart';

abstract final class MoneyMuleEvidenceGenerator {
  static const priority = 750;

  static List<ScamEvidence> generate(String text) {
    if (!MoneyMuleDetector.detect(text)) return const [];
    return const [
      ScamEvidence(
        kind: ScamEvidenceKind.moneyMuleRecruitment,
        priority: priority,
        textKey: 'ss_evidence_money_mule',
        sourceLabel: 'Pattern check',
      ),
    ];
  }
}
