import 'package:raabta/features/scam_shield/domain/scam_incident_models.dart';

/// Compound-risk multiplier from reported shared-data categories (not additive).
abstract final class ScamCompoundRiskDetector {
  static ScamCompoundRiskResult evaluate(Set<ScamSharedDataCategory> shared) {
    if (shared.isEmpty) {
      return const ScamCompoundRiskResult(
        band: ScamCompoundRiskBand.low,
        multiplier: 1.0,
        reasonKeys: ['ss_compound_none'],
      );
    }

    final hasQid = shared.contains(ScamSharedDataCategory.qid);
    final hasIdentityDoc = shared.contains(ScamSharedDataCategory.passport) ||
        shared.contains(ScamSharedDataCategory.drivingLicence);
    final hasPhoneConfirm =
        shared.contains(ScamSharedDataCategory.phoneConfirmation);
    final hasOtp = shared.contains(ScamSharedDataCategory.otp);
    final hasCredential = shared.contains(ScamSharedDataCategory.password) ||
        shared.contains(ScamSharedDataCategory.bankDetails) ||
        shared.contains(ScamSharedDataCategory.cardDetails);

    if (hasQid && hasIdentityDoc && hasPhoneConfirm && hasOtp) {
      return const ScamCompoundRiskResult(
        band: ScamCompoundRiskBand.critical,
        multiplier: 2.5,
        reasonKeys: [
          'ss_compound_qid',
          'ss_compound_identity_doc',
          'ss_compound_phone',
          'ss_compound_otp',
        ],
      );
    }

    if (hasQid && hasIdentityDoc && hasPhoneConfirm) {
      return const ScamCompoundRiskResult(
        band: ScamCompoundRiskBand.high,
        multiplier: 2.0,
        reasonKeys: [
          'ss_compound_qid',
          'ss_compound_identity_doc',
          'ss_compound_phone',
        ],
      );
    }

    if (hasQid && hasIdentityDoc) {
      return const ScamCompoundRiskResult(
        band: ScamCompoundRiskBand.medium,
        multiplier: 1.5,
        reasonKeys: ['ss_compound_qid', 'ss_compound_identity_doc'],
      );
    }

    if (hasOtp || hasCredential) {
      return ScamCompoundRiskResult(
        band: hasOtp ? ScamCompoundRiskBand.critical : ScamCompoundRiskBand.high,
        multiplier: hasOtp ? 2.5 : 2.0,
        reasonKeys: [
          if (hasOtp) 'ss_compound_otp',
          if (hasCredential) 'ss_compound_credentials',
        ],
      );
    }

    if (hasQid) {
      return const ScamCompoundRiskResult(
        band: ScamCompoundRiskBand.medium,
        multiplier: 1.25,
        reasonKeys: ['ss_compound_qid'],
      );
    }

    return const ScamCompoundRiskResult(
      band: ScamCompoundRiskBand.low,
      multiplier: 1.1,
      reasonKeys: ['ss_compound_partial'],
    );
  }
}
