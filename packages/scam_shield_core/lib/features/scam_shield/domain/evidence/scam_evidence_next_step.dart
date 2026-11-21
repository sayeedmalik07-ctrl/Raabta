import 'package:scam_shield_core/features/scam_shield/domain/evidence/scam_evidence_models.dart';
import 'package:scam_shield_core/features/scam_shield/domain/official_directory.dart';
import 'package:scam_shield_core/features/scam_shield/domain/payment_candidate_extractor.dart';
import 'package:scam_shield_core/features/scam_shield/domain/payment_check_models.dart';
import 'package:scam_shield_core/features/scam_shield/domain/scam_incident_models.dart';
import 'package:scam_shield_core/features/scam_shield/domain/scam_scan_risk_engine.dart';

enum ScamEvidenceNextStepKind {
  checkPayment,
  incidentResponse,
  checkInvestmentLicensed,
  contactRealEntity,
  reportAuthorityDirectory,
}

class ScamEvidenceNextStep {
  const ScamEvidenceNextStep({
    required this.kind,
    this.entityId,
    this.prefill,
    this.recoveryOfferPrimary = false,
  });

  final ScamEvidenceNextStepKind kind;
  final String? entityId;
  final PaymentCheckPrefill? prefill;
  final bool recoveryOfferPrimary;
}

/// Next-step table (first match wins):
/// 1. Payment red flags OR payment candidates → Check payment (Phase 10)
/// 2. Compromise / user shared secrets → Incident response
/// 3. Claimed directory entity → Contact real X (directory)
/// 4. Otherwise → Report via authority directory
abstract final class ScamEvidenceNextStepResolver {
  static ScamEvidenceNextStep resolve({
    required List<ScamEvidence> evidence,
    required List<String> localFlags,
    required String text,
    required ScamScanRiskAnalysis analysis,
    required bool phase10Available,
    required String locale,
  }) {
    final hasEventTicket = evidence.any(
      (e) => e.kind == ScamEvidenceKind.eventTicketScam,
    );
    if (hasEventTicket) {
      final hasPaymentEvidence = evidence.any(
            (e) => e.kind == ScamEvidenceKind.paymentRedFlag,
          ) ||
          _paymentFlags(localFlags);
      if (hasPaymentEvidence && phase10Available) {
        final candidates = PaymentCandidateExtractor.extract(text);
        return ScamEvidenceNextStep(
          kind: ScamEvidenceNextStepKind.checkPayment,
          prefill: PaymentCheckPrefill(
            ibanCandidates: candidates.ibans,
            phoneCandidates: candidates.phones,
            linkCandidates: candidates.links,
          ),
        );
      }
    }

    final hasRecoveryOffer = evidence.any(
      (e) => e.kind == ScamEvidenceKind.recoveryOffer,
    );
    if (hasRecoveryOffer) {
      return const ScamEvidenceNextStep(
        kind: ScamEvidenceNextStepKind.reportAuthorityDirectory,
        recoveryOfferPrimary: true,
      );
    }

    final hasPaymentEvidence = evidence.any(
          (e) => e.kind == ScamEvidenceKind.paymentRedFlag,
        ) ||
        _paymentFlags(localFlags);
    if (hasPaymentEvidence && phase10Available) {
      final candidates = PaymentCandidateExtractor.extract(text);
      return ScamEvidenceNextStep(
        kind: ScamEvidenceNextStepKind.checkPayment,
        prefill: PaymentCheckPrefill(
          ibanCandidates: candidates.ibans,
          phoneCandidates: candidates.phones,
          linkCandidates: candidates.links,
        ),
      );
    }

    if (analysis.stop.triggered ||
        analysis.attackStage == ScamAttackStage.suspectedCompromise) {
      return const ScamEvidenceNextStep(
        kind: ScamEvidenceNextStepKind.incidentResponse,
      );
    }

    final hasInvestmentSign = evidence.any(
      (e) => e.kind == ScamEvidenceKind.investmentOfferSign,
    );
    if (hasInvestmentSign) {
      return const ScamEvidenceNextStep(
        kind: ScamEvidenceNextStepKind.checkInvestmentLicensed,
      );
    }

    final claim = OfficialDirectory.detectClaimedEntity(text, locale);
    if (claim.primaryId != null) {
      return ScamEvidenceNextStep(
        kind: ScamEvidenceNextStepKind.contactRealEntity,
        entityId: claim.primaryId,
      );
    }

    return const ScamEvidenceNextStep(
      kind: ScamEvidenceNextStepKind.reportAuthorityDirectory,
    );
  }

  static bool _paymentFlags(List<String> flags) {
    const keys = {
      'ss_flag_unusual_payment',
      'ss_flag_upfront_fee',
      'ss_flag_otp',
    };
    return flags.any(keys.contains);
  }
}
