import 'package:raabta/features/scam_shield/domain/scam_shield_models.dart';

/// Pre-lease listing details entered by the user — not verified facts.
class ListingVerificationInput {
  const ListingVerificationInput({
    this.monthlyRent,
    this.depositRequested,
    this.paymentMethodNotes = '',
    this.reservationFeeNotes = '',
    this.contactInfo = '',
    this.propertyDetails = '',
    this.landlordMessage = '',
  });

  final double? monthlyRent;
  final double? depositRequested;
  final String paymentMethodNotes;
  final String reservationFeeNotes;
  final String contactInfo;
  final String propertyDetails;
  final String landlordMessage;

  bool get hasStructuredFields =>
      (monthlyRent != null && monthlyRent! > 0) ||
      (depositRequested != null && depositRequested! > 0) ||
      paymentMethodNotes.trim().isNotEmpty ||
      reservationFeeNotes.trim().isNotEmpty;

  bool get hasOpenEndedMessage => landlordMessage.trim().isNotEmpty;
}

enum ListingTenancyFindingKind {
  depositOverCap,
  registrationReminder,
}

class ListingTenancyFinding {
  const ListingTenancyFinding({
    required this.kind,
    required this.messageKey,
    this.params = const {},
  });

  final ListingTenancyFindingKind kind;
  final String messageKey;
  final Map<String, String> params;
}

/// Combined tenancy rule checks + optional ScamShield assessment (Level 0/1).
class ListingVerificationResult {
  const ListingVerificationResult({
    required this.tenancyFindings,
    this.scamAssessment,
    required this.scanTextPreview,
  });

  final List<ListingTenancyFinding> tenancyFindings;
  final ScamShieldAssessmentResult? scamAssessment;
  final String scanTextPreview;

  bool get hasDepositIssue => tenancyFindings.any(
        (f) => f.kind == ListingTenancyFindingKind.depositOverCap,
      );

  bool get hasScamSignals =>
      scamAssessment != null &&
      (scamAssessment!.redFlags.isNotEmpty ||
          scamAssessment!.overallRisk != ScamShieldRiskLevel.low);
}
