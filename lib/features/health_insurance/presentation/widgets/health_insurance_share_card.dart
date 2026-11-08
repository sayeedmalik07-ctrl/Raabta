import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/features/health_insurance/data/claim_dispute_step_catalog.dart';
import 'package:raabta/features/health_insurance/data/models/claim_dispute_models.dart';
import 'package:raabta/features/health_insurance/data/models/compliance_check_model.dart';
import 'package:raabta/features/health_insurance/data/models/insurance_policy_model.dart';
import 'package:raabta/features/health_insurance/domain/models/health_compliance_enums.dart';
import 'package:raabta/features/health_insurance/domain/services/health_insurance_services.dart';
import 'package:raabta/models/intelligence/permission_level.dart';
import 'package:raabta/services/intelligence/sensitive_action_audit_service.dart';
import 'package:raabta/features/health_insurance/presentation/l10n/health_insurance_strings.dart';
import 'package:raabta/features/truth_engine/presentation/truth_engine_status_colors.dart';
import 'package:raabta/services/sharing/models/shareable_card_data.dart';
import 'package:raabta/services/sharing/widgets/share_card_sheet.dart';

/// Whether sharing a compliance card should prompt the user first.
bool complianceShareRequiresConfirmation(ComplianceCheckResult result) =>
    result.hasUnresolvedViolation;

Color statusColorForHealthCompliance(HealthComplianceStatus status) =>
    TruthEngineStatusColors.forHealthCompliance(status);

String statusLabelForHealthCompliance(
  HealthComplianceStatus status,
  String locale,
) {
  return switch (status) {
    HealthComplianceStatus.compliant =>
      HealthInsuranceStrings.t('hi_status_compliant', locale),
    HealthComplianceStatus.violation =>
      HealthInsuranceStrings.t('hi_status_violation', locale),
    HealthComplianceStatus.needsVerification =>
      HealthInsuranceStrings.t('hi_status_needs_verification', locale),
    HealthComplianceStatus.informational =>
      HealthInsuranceStrings.t('hi_status_informational', locale),
    HealthComplianceStatus.notApplicable =>
      HealthInsuranceStrings.t('hi_status_not_applicable', locale),
  };
}

HealthInsuranceComplianceCardData buildComplianceShareCardData({
  required ComplianceCheckResult result,
  required String locale,
  HealthInsuranceExplanationService explainer =
      const HealthInsuranceExplanationService(),
}) {
  return HealthInsuranceComplianceCardData(
    checkedAt: result.checkedAt,
    overviewSummary: explainer.buildResultsOverview(result, locale),
    hasViolation: result.hasUnresolvedViolation,
    checks: result.items
        .map(
          (item) => HealthInsuranceComplianceCheckRow(
            title: HealthInsuranceStrings.t(item.titleKey, locale),
            statusLabel: statusLabelForHealthCompliance(item.status, locale),
            statusColor: statusColorForHealthCompliance(item.status),
          ),
        )
        .toList(),
    shareCaption: HealthInsuranceStrings.t('hi_share_compliance_caption', locale),
  );
}

HealthInsurancePolicyCardData buildPolicyShareCardData({
  required PolicyExplainerResult result,
  required String documentName,
  required String locale,
}) {
  return HealthInsurancePolicyCardData(
    documentName: documentName,
    summary: result.summary,
    coverageCategories: result.coverageCategories,
    exclusions: result.exclusions,
    networkNotes: result.networkNotes,
    ambiguityNotes: result.ambiguityNotes,
    disclaimerText: HealthInsuranceStrings.t(result.disclaimerKey, locale),
    shareCaption: HealthInsuranceStrings.t('hi_share_policy_caption', locale),
  );
}

Future<bool> _confirmViolationShare(BuildContext context, String locale) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(HealthInsuranceStrings.t('hi_share_confirm_title', locale)),
      content: Text(HealthInsuranceStrings.t('hi_share_confirm_body', locale)),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: Text(HealthInsuranceStrings.t('hi_share_confirm_cancel', locale)),
        ),
        FilledButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: Text(HealthInsuranceStrings.t('hi_share_confirm_proceed', locale)),
        ),
      ],
    ),
  );
  if (confirmed == true) {
    await SensitiveActionAuditService.log(
      actionId: SensitiveActionIds.healthInsuranceViolationShare,
      level: PermissionLevel.confirm,
    );
  }
  return confirmed ?? false;
}

/// Opens branded compliance share card (with violation confirmation when needed).
Future<void> showHealthInsuranceComplianceShareCard(
  BuildContext context, {
  required ComplianceCheckResult result,
  required String locale,
}) async {
  if (complianceShareRequiresConfirmation(result)) {
    final ok = await _confirmViolationShare(context, locale);
    if (!ok || !context.mounted) return;
  }

  await ShareCardSheet.show(
    context,
    buildComplianceShareCardData(result: result, locale: locale),
  );
}

/// Opens branded policy explainer share card (includes on-card disclaimer).
Future<void> showHealthInsurancePolicyShareCard(
  BuildContext context, {
  required PolicyExplainerResult result,
  required String documentName,
  required String locale,
}) async {
  await ShareCardSheet.show(
    context,
    buildPolicyShareCardData(
      result: result,
      documentName: documentName,
      locale: locale,
    ),
  );
}

HealthInsuranceDenialCardData buildDenialShareCardData({
  required HealthInsuranceClaimDispute dispute,
  required String locale,
}) {
  final steps = ClaimDisputeStepCatalog.stepsFor(
    regulatoryBody: dispute.regulatoryBody,
    employerProvidedCoverage: dispute.employerProvidedCoverage,
    denialReason: dispute.denialReason,
  );

  return HealthInsuranceDenialCardData(
    insurerName: dispute.insurerName,
    denialReasonLabel:
        HealthInsuranceStrings.t(dispute.denialReason.labelKey, locale),
    stepsCompleted: dispute.completedStepCount,
    stepsTotal: steps.length,
    documentsAttached: dispute.documentRefs.length,
    disclaimerText: HealthInsuranceStrings.t('hi_denial_export_disclaimer', locale),
    shareCaption: HealthInsuranceStrings.t('hi_share_denial_caption', locale),
  );
}

/// Opens branded claim denial dispute share card.
Future<void> showHealthInsuranceDenialShareCard(
  BuildContext context, {
  required HealthInsuranceClaimDispute dispute,
  required String locale,
}) async {
  await ShareCardSheet.show(
    context,
    buildDenialShareCardData(dispute: dispute, locale: locale),
  );
}
