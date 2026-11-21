import 'package:scam_shield_core/features/scam_shield/domain/evidence/scam_evidence_models.dart';

abstract final class PaymentRedFlagEvidenceGenerator {
  static const priority = 700;

  static List<ScamEvidence> generate(List<String> localFlags) {
    final out = <ScamEvidence>[];
    void add(String flag, String textKey) {
      if (localFlags.contains(flag)) {
        out.add(
          ScamEvidence(
            kind: ScamEvidenceKind.paymentRedFlag,
            priority: priority,
            textKey: textKey,
            sourceLabel: 'Pattern check',
          ),
        );
      }
    }

    add('ss_flag_unusual_payment', 'ss_evidence_payment_unusual');
    add('ss_flag_upfront_fee', 'ss_evidence_payment_upfront');
    add('ss_flag_urgency', 'ss_evidence_payment_urgency');
    add('ss_flag_impersonation', 'ss_evidence_payment_impersonation');
    add('ss_flag_platform_hop', 'ss_evidence_platform_hop');
    return out;
  }
}
