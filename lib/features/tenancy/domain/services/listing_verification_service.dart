import 'package:raabta/features/scam_shield/data/scam_shield_verification_channels.dart';
import 'package:raabta/features/scam_shield/domain/scam_input_channel_parser.dart';
import 'package:raabta/features/scam_shield/domain/scam_risk_signal.dart';
import 'package:raabta/features/scam_shield/domain/scam_scan_risk_engine.dart';
import 'package:raabta/features/scam_shield/domain/scam_shield_local_checker.dart';
import 'package:raabta/features/scam_shield/domain/scam_shield_models.dart';
import 'package:raabta/features/scam_shield/domain/scam_trust_label.dart';
import 'package:raabta/features/scam_shield/services/scam_shield_assessment_service.dart';
import 'package:raabta/features/tenancy/domain/models/listing_verification_models.dart';
import 'package:raabta/features/tenancy/domain/rules/law_4_2008_tenancy.dart';
import 'package:raabta/features/tenancy/domain/rules/law_8_2026_tenancy.dart';

/// Pre-lease listing consistency — tenancy facts + ScamShield Level 0/1 reuse.
abstract final class ListingVerificationService {
  static const contentType = ScamShieldContentType.rentalOffer;

  static Future<ListingVerificationResult> verify({
    required ListingVerificationInput input,
    required ScamShieldAssessmentService assessmentService,
    required String language,
    required String? userId,
    required bool canUseAi,
  }) async {
    final tenancyFindings = _tenancyFindings(input);
    final scanText = _buildScanText(input);

    ScamShieldAssessmentResult? scamAssessment;
    if (scanText.trim().isNotEmpty) {
      if (input.hasOpenEndedMessage) {
        scamAssessment = await assessmentService.assess(
          text: scanText,
          contentType: contentType,
          language: language,
          userId: userId,
          canUseAi: canUseAi,
          inputChannel: ScamShieldInputChannel.pasteText,
        );
      } else {
        scamAssessment = _localOnlyAssessment(scanText);
      }
    }

    return ListingVerificationResult(
      tenancyFindings: tenancyFindings,
      scamAssessment: scamAssessment,
      scanTextPreview: scanText,
    );
  }

  static List<ListingTenancyFinding> _tenancyFindings(
    ListingVerificationInput input,
  ) {
    final findings = <ListingTenancyFinding>[];

    final rent = input.monthlyRent;
    final deposit = input.depositRequested;
    if (rent != null &&
        rent > 0 &&
        deposit != null &&
        deposit > rent * Law42008Tenancy.depositCapMonthsResidential) {
      findings.add(
        ListingTenancyFinding(
          kind: ListingTenancyFindingKind.depositOverCap,
          messageKey: 'tenancy_listing_deposit_over_cap',
          params: {
            'deposit': _formatQar(deposit),
            'rent': _formatQar(rent),
            'capMonths':
                '${Law42008Tenancy.depositCapMonthsResidential}',
            'maxDeposit': _formatQar(
              rent * Law42008Tenancy.depositCapMonthsResidential,
            ),
          },
        ),
      );
    }

    findings.add(
      ListingTenancyFinding(
        kind: ListingTenancyFindingKind.registrationReminder,
        messageKey: 'tenancy_listing_registration_reminder',
        params: {
          'fee': '${Law82026Tenancy.registrationFeeQar}',
        },
      ),
    );

    return findings;
  }

  static String _buildScanText(ListingVerificationInput input) {
    final parts = <String>[
      if (input.paymentMethodNotes.trim().isNotEmpty)
        input.paymentMethodNotes.trim(),
      if (input.reservationFeeNotes.trim().isNotEmpty)
        input.reservationFeeNotes.trim(),
      if (input.contactInfo.trim().isNotEmpty) input.contactInfo.trim(),
      if (input.propertyDetails.trim().isNotEmpty) input.propertyDetails.trim(),
      if (input.landlordMessage.trim().isNotEmpty) input.landlordMessage.trim(),
    ];
    return parts.join('\n');
  }

  /// Level 0 only — mirrors [ScamShieldAssessmentService] pre-AI path.
  static ScamShieldAssessmentResult _localOnlyAssessment(String text) {
    final trimmed = text.trim();
    final local = ScamShieldLocalChecker.check(
      text: trimmed,
      contentType: contentType,
    );
    final scanAnalysis = ScamScanRiskEngine.analyze(
      text: trimmed,
      legacyFlags: local.redFlags,
      urlFindings: local.urlFindings,
    );
    final signalFlags =
        scanAnalysis.signals.map((s) => s.labelKey).toList(growable: false);
    final redFlags = <String>{...signalFlags, ...local.redFlags}.toList();

    return ScamShieldAssessmentResult(
      contentType: contentType,
      overallRisk: scanAnalysis.trustLabel.displayRisk,
      localCheck: local,
      redFlags: redFlags,
      requestedInfo: _inferRequestedInfo(local),
      urlFindings: local.urlFindings,
      usedAi: false,
      verificationChannelKeys: ScamShieldVerificationChannels.keysFor(
        contentType: contentType,
      ),
      scanAnalysis: scanAnalysis,
      inputChannel: ScamShieldInputChannel.pasteText,
    );
  }

  static List<String> _inferRequestedInfo(ScamShieldLocalCheckResult local) {
    final info = <String>[];
    if (local.redFlags.contains('ss_flag_otp')) {
      info.add('ss_requested_credentials');
    }
    if (local.redFlags.contains('ss_flag_unusual_payment') ||
        local.redFlags.contains('ss_flag_upfront_fee')) {
      info.add('ss_requested_money');
    }
    if (local.redFlags.contains('ss_flag_impersonation')) {
      info.add('ss_requested_trust');
    }
    return info;
  }

  static String _formatQar(double amount) =>
      amount.toStringAsFixed(amount.truncateToDouble() == amount ? 0 : 2);
}
