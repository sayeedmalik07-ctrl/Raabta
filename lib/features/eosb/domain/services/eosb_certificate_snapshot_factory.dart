import 'dart:math';

import 'package:raabta/features/eosb/domain/models/eosb_certificate_models.dart';
import 'package:raabta/features/eosb/domain/models/eosb_employee_input.dart';
import 'package:raabta/features/eosb/domain/models/eosb_result.dart';
import 'package:raabta/features/eosb/domain/rules/eosb_certificate_constants.dart';
import 'package:raabta/features/eosb/domain/services/eosb_certificate_confidence.dart';
import 'package:raabta/features/eosb/domain/services/eosb_certificate_decimal_format.dart';
import 'package:raabta/features/eosb/domain/services/eosb_certificate_fingerprint.dart';
import 'package:raabta/features/eosb/domain/services/art_67_input_resolver.dart';
import 'package:raabta/features/eosb/domain/services/eosb_certificate_id_generator.dart';
import 'package:raabta/features/eosb/domain/services/eosb_legal_provenance_composer.dart';
import 'package:raabta/services/legal_deadline_service.dart';

/// Builds immutable [EosbCertificateSnapshot] from existing calculation output.
///
/// Never calls [EosbCalculationService] — consumes frozen result/input only.
abstract final class EosbCertificateSnapshotFactory {
  static EosbCertificateSnapshot create({
    required EosbResult result,
    required EosbEmployeeInput input,
    required String appVersion,
    required String appBuildNumber,
    required String generationLocale,
    DateTime? generatedAt,
    Random? certificateIdRandom,
  }) {
    final generated = generatedAt ?? DateTime.now().toUtc();
    final certificateId = EosbCertificateIdGenerator.generate(
      random: certificateIdRandom,
    );

    final joiningIso = input.joiningDate == null
        ? null
        : EosbCertificateDecimalFormat.isoDate(input.joiningDate!);
    final lastWorkingIso = input.lastWorkingDate == null
        ? null
        : EosbCertificateDecimalFormat.isoDate(input.lastWorkingDate!);

    final breakdown = result.breakdown
        .map(
          (item) => EosbBreakdownSnapshotItem(
            id: item.id,
            amount: EosbCertificateDecimalFormat.money(item.amount),
            ruleKey: item.ruleKey,
            formulaKey: item.formulaKey,
            isEstimated: item.isEstimated,
          ),
        )
        .toList(growable: false);

    final warnings = result.warnings
        .map(
          (w) => EosbWarningSnapshotItem(
            severity: w.severity.name,
            titleKey: w.titleKey,
            explanationKey: w.explanationKey,
            actionKey: w.actionKey,
          ),
        )
        .toList(growable: false);

    final violations = result.violations
        .map(
          (v) => EosbViolationSnapshotItem(
            ruleKey: v.ruleKey,
            riskLevelKey: v.riskLevelKey,
          ),
        )
        .toList(growable: false);

    final legalProvenance = EosbLegalProvenanceComposer.compose(
      breakdown: breakdown,
    );

    final basicSalary = EosbCertificateDecimalFormat.money(input.basicSalary);
    final totalSalary = EosbCertificateDecimalFormat.money(input.totalSalary);
    final inputCompletenessScore = EosbCertificateDecimalFormat.score(
      result.explanation.confidenceScore,
    );

    final art67Deadline = LegalDeadlineService.eosbFinalSettlementPaymentDeadline(
      art49NoticeGiven: input.art49NoticeGiven,
      contractTerminationDate:
          Art67InputResolver.contractTerminationDate(input),
      dateOfLeavingWork: Art67InputResolver.dateOfLeavingWork(input),
    );
    final resolvedTermination =
        Art67InputResolver.contractTerminationDate(input);
    final resolvedLeaving = Art67InputResolver.dateOfLeavingWork(input);
    final art67TerminationIso = resolvedTermination == null
        ? null
        : EosbCertificateDecimalFormat.isoDate(resolvedTermination);
    final art67LeavingIso = resolvedLeaving == null
        ? null
        : EosbCertificateDecimalFormat.isoDate(resolvedLeaving);
    final art67DeadlineIso = art67Deadline == null
        ? null
        : EosbCertificateDecimalFormat.isoDate(art67Deadline.deadlineDate);

    final confidenceBand = EosbCertificateConfidence.fromResult(
      result: result,
      joiningDateIso: joiningIso,
      lastWorkingDateIso: lastWorkingIso,
      basicSalary: basicSalary,
      totalSalary: totalSalary,
      totalEntitlement:
          EosbCertificateDecimalFormat.money(result.totalEntitlement),
      breakdown: breakdown,
      warnings: warnings,
      violations: violations,
    );

    final withoutFingerprint = EosbCertificateSnapshot(
      certificateId: certificateId,
      certificateSchemaVersion: EosbCertificateSchemaVersion.current,
      eosbRulesetVersion: EosbRulesetVersion.current,
      legalSourceVersion: EosbLegalProvenanceComposer.legalSourceVersionKey(),
      appVersion: appVersion,
      appBuildNumber: appBuildNumber,
      generatedAt: generated,
      generationLocale: generationLocale,
      calculatedAt: result.calculatedAt.toUtc(),
      currency: 'QAR',
      basicSalary: basicSalary,
      totalSalary: totalSalary,
      housingAllowance: EosbCertificateDecimalFormat.money(input.housingAllowance),
      foodAllowance: EosbCertificateDecimalFormat.money(input.foodAllowance),
      transportAllowance:
          EosbCertificateDecimalFormat.money(input.transportAllowance),
      joiningDate: joiningIso,
      lastWorkingDate: lastWorkingIso,
      serviceDays: input.serviceDays,
      serviceYears: EosbCertificateDecimalFormat.serviceYears(input.serviceYears),
      contractType: input.contractType.name,
      employmentCategory: input.employmentCategory.name,
      terminationType: input.terminationType.name,
      summaryDismissalGround: input.summaryDismissalGround.name,
      summaryDismissalGroundConfirmed: input.summaryDismissalGroundConfirmed,
      noticeServed: input.noticeServed,
      noticeBuyoutAmount:
          EosbCertificateDecimalFormat.money(input.noticeBuyoutAmount),
      unusedLeaveDays: input.unusedLeaveDays,
      unusedSickLeaveDays: input.unusedSickLeaveDays,
      overtimeHours: EosbCertificateDecimalFormat.money(input.overtimeHours),
      pendingSalary: EosbCertificateDecimalFormat.money(input.pendingSalary),
      familySponsored: input.familySponsored,
      returnTicketIncluded: input.returnTicketIncluded,
      dependentsCount: input.dependentsCount,
      otherContractualBenefits:
          EosbCertificateDecimalFormat.money(input.otherContractualBenefits),
      annualBonus: EosbCertificateDecimalFormat.money(input.annualBonus),
      commission: EosbCertificateDecimalFormat.money(input.commission),
      retentionBonus: EosbCertificateDecimalFormat.money(input.retentionBonus),
      totalEntitlement:
          EosbCertificateDecimalFormat.money(result.totalEntitlement),
      breakdown: breakdown,
      warnings: warnings,
      violations: violations,
      inputCompletenessScore: inputCompletenessScore,
      certificateConfidenceBand: confidenceBand,
      legalProvenance: legalProvenance,
      calculationFingerprint: '',
      trustState: EosbCertificateTrustState.visualEstimate,
      art67ContractTerminationDate: art67TerminationIso,
      art67DateOfLeavingWork: art67LeavingIso,
      art67Art49NoticeGiven: input.art49NoticeGiven,
      art67Branch: art67Deadline?.art67Branch?.name,
      art67DeadlineDate: art67DeadlineIso,
      art67RuleVersion: art67Deadline?.art67RuleVersion,
    );

    final fingerprint = EosbCertificateFingerprint.compute(withoutFingerprint);

    return EosbCertificateSnapshot(
      certificateId: withoutFingerprint.certificateId,
      certificateSchemaVersion: withoutFingerprint.certificateSchemaVersion,
      eosbRulesetVersion: withoutFingerprint.eosbRulesetVersion,
      legalSourceVersion: withoutFingerprint.legalSourceVersion,
      appVersion: withoutFingerprint.appVersion,
      appBuildNumber: withoutFingerprint.appBuildNumber,
      generatedAt: withoutFingerprint.generatedAt,
      generationLocale: withoutFingerprint.generationLocale,
      calculatedAt: withoutFingerprint.calculatedAt,
      currency: withoutFingerprint.currency,
      basicSalary: withoutFingerprint.basicSalary,
      totalSalary: withoutFingerprint.totalSalary,
      housingAllowance: withoutFingerprint.housingAllowance,
      foodAllowance: withoutFingerprint.foodAllowance,
      transportAllowance: withoutFingerprint.transportAllowance,
      joiningDate: withoutFingerprint.joiningDate,
      lastWorkingDate: withoutFingerprint.lastWorkingDate,
      serviceDays: withoutFingerprint.serviceDays,
      serviceYears: withoutFingerprint.serviceYears,
      contractType: withoutFingerprint.contractType,
      employmentCategory: withoutFingerprint.employmentCategory,
      terminationType: withoutFingerprint.terminationType,
      summaryDismissalGround: withoutFingerprint.summaryDismissalGround,
      summaryDismissalGroundConfirmed:
          withoutFingerprint.summaryDismissalGroundConfirmed,
      noticeServed: withoutFingerprint.noticeServed,
      noticeBuyoutAmount: withoutFingerprint.noticeBuyoutAmount,
      unusedLeaveDays: withoutFingerprint.unusedLeaveDays,
      unusedSickLeaveDays: withoutFingerprint.unusedSickLeaveDays,
      overtimeHours: withoutFingerprint.overtimeHours,
      pendingSalary: withoutFingerprint.pendingSalary,
      familySponsored: withoutFingerprint.familySponsored,
      returnTicketIncluded: withoutFingerprint.returnTicketIncluded,
      dependentsCount: withoutFingerprint.dependentsCount,
      otherContractualBenefits: withoutFingerprint.otherContractualBenefits,
      annualBonus: withoutFingerprint.annualBonus,
      commission: withoutFingerprint.commission,
      retentionBonus: withoutFingerprint.retentionBonus,
      totalEntitlement: withoutFingerprint.totalEntitlement,
      breakdown: withoutFingerprint.breakdown,
      warnings: withoutFingerprint.warnings,
      violations: withoutFingerprint.violations,
      inputCompletenessScore: withoutFingerprint.inputCompletenessScore,
      certificateConfidenceBand: withoutFingerprint.certificateConfidenceBand,
      legalProvenance: withoutFingerprint.legalProvenance,
      calculationFingerprint: fingerprint,
      trustState: withoutFingerprint.trustState,
      art67ContractTerminationDate: withoutFingerprint.art67ContractTerminationDate,
      art67DateOfLeavingWork: withoutFingerprint.art67DateOfLeavingWork,
      art67Art49NoticeGiven: withoutFingerprint.art67Art49NoticeGiven,
      art67Branch: withoutFingerprint.art67Branch,
      art67DeadlineDate: withoutFingerprint.art67DeadlineDate,
      art67RuleVersion: withoutFingerprint.art67RuleVersion,
    );
  }
}
