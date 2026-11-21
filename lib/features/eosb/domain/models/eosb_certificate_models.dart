import 'package:flutter/foundation.dart';
import 'package:raabta/features/eosb/domain/rules/eosb_certificate_constants.dart';

/// Immutable legal reference frozen from [LegalSourcesSeedCatalog] at generation.
@immutable
class EosbLegalReferenceSnapshot {
  const EosbLegalReferenceSnapshot({
    required this.catalogId,
    required this.lawIdentifier,
    required this.sourceUrl,
    required this.dateLastVerified,
  });

  final String catalogId;
  final String lawIdentifier;
  final String sourceUrl;

  /// ISO date YYYY-MM-DD from catalog — never hardcoded in certificate code.
  final String dateLastVerified;
}

/// Article mapping for one breakdown line — derived from existing rule keys only.
@immutable
class EosbBreakdownLegalRefSnapshot {
  const EosbBreakdownLegalRefSnapshot({
    required this.breakdownId,
    required this.ruleKey,
    required this.lawCatalogId,
    required this.articles,
  });

  final String breakdownId;
  final String ruleKey;
  final String lawCatalogId;
  final List<String> articles;
}

/// Structured legal provenance — distinguishes law, articles, and Raabta layer.
@immutable
class EosbLegalProvenanceSnapshot {
  const EosbLegalProvenanceSnapshot({
    required this.primaryLaw,
    required this.supplementaryLaws,
    required this.breakdownLegalRefs,
    required this.raabtaRulesetLabel,
    required this.raabtaRulesetVersion,
    required this.sourceVerifiedDate,
    required this.disclaimerKey,
  });

  final EosbLegalReferenceSnapshot primaryLaw;
  final List<EosbLegalReferenceSnapshot> supplementaryLaws;
  final List<EosbBreakdownLegalRefSnapshot> breakdownLegalRefs;
  final String raabtaRulesetLabel;
  final String raabtaRulesetVersion;

  /// Frozen from catalog [dateLastVerified] at generation time.
  final String sourceVerifiedDate;
  final String disclaimerKey;
}

@immutable
class EosbBreakdownSnapshotItem {
  const EosbBreakdownSnapshotItem({
    required this.id,
    required this.amount,
    required this.ruleKey,
    required this.formulaKey,
    required this.isEstimated,
  });

  final String id;
  final String amount;
  final String ruleKey;
  final String formulaKey;
  final bool isEstimated;
}

@immutable
class EosbWarningSnapshotItem {
  const EosbWarningSnapshotItem({
    required this.severity,
    required this.titleKey,
    this.explanationKey,
    this.actionKey,
  });

  final String severity;
  final String titleKey;
  final String? explanationKey;
  final String? actionKey;
}

@immutable
class EosbViolationSnapshotItem {
  const EosbViolationSnapshotItem({
    required this.ruleKey,
    required this.riskLevelKey,
  });

  final String ruleKey;
  final String riskLevelKey;
}

/// Immutable Truth Certificate snapshot — never mutated after creation.
///
/// No employer identity fields — calculation provenance does not require them.
@immutable
class EosbCertificateSnapshot {
  const EosbCertificateSnapshot({
    required this.certificateId,
    required this.certificateSchemaVersion,
    required this.eosbRulesetVersion,
    required this.legalSourceVersion,
    required this.appVersion,
    required this.appBuildNumber,
    required this.generatedAt,
    required this.generationLocale,
    required this.calculatedAt,
    required this.currency,
    required this.basicSalary,
    required this.totalSalary,
    required this.housingAllowance,
    required this.foodAllowance,
    required this.transportAllowance,
    this.joiningDate,
    this.lastWorkingDate,
    required this.serviceDays,
    required this.serviceYears,
    required this.contractType,
    required this.employmentCategory,
    required this.terminationType,
    required this.summaryDismissalGround,
    required this.summaryDismissalGroundConfirmed,
    required this.noticeServed,
    required this.noticeBuyoutAmount,
    required this.unusedLeaveDays,
    required this.unusedSickLeaveDays,
    required this.overtimeHours,
    required this.pendingSalary,
    required this.familySponsored,
    required this.returnTicketIncluded,
    required this.dependentsCount,
    required this.otherContractualBenefits,
    required this.annualBonus,
    required this.commission,
    required this.retentionBonus,
    required this.totalEntitlement,
    required this.breakdown,
    required this.warnings,
    required this.violations,
    required this.inputCompletenessScore,
    required this.certificateConfidenceBand,
    required this.legalProvenance,
    required this.calculationFingerprint,
    required this.trustState,
    this.art67ContractTerminationDate,
    this.art67DateOfLeavingWork,
    this.art67Art49NoticeGiven,
    this.art67Branch,
    this.art67DeadlineDate,
    this.art67RuleVersion,
  });

  final String certificateId;
  final int certificateSchemaVersion;
  final String eosbRulesetVersion;

  /// Format: `{catalogId}@{YYYY-MM-DD}` from catalog at generation.
  final String legalSourceVersion;
  final String appVersion;
  final String appBuildNumber;
  final DateTime generatedAt;
  final String generationLocale;
  final DateTime calculatedAt;
  final String currency;
  final String basicSalary;
  final String totalSalary;
  final String housingAllowance;
  final String foodAllowance;
  final String transportAllowance;
  final String? joiningDate;
  final String? lastWorkingDate;
  final int serviceDays;
  final String serviceYears;
  final String contractType;
  final String employmentCategory;
  final String terminationType;
  final String summaryDismissalGround;
  final bool summaryDismissalGroundConfirmed;
  final bool noticeServed;
  final String noticeBuyoutAmount;
  final int unusedLeaveDays;
  final int unusedSickLeaveDays;
  final String overtimeHours;
  final String pendingSalary;
  final bool familySponsored;
  final bool returnTicketIncluded;
  final int dependentsCount;
  final String otherContractualBenefits;
  final String annualBonus;
  final String commission;
  final String retentionBonus;
  final String totalEntitlement;
  final List<EosbBreakdownSnapshotItem> breakdown;
  final List<EosbWarningSnapshotItem> warnings;
  final List<EosbViolationSnapshotItem> violations;
  final String inputCompletenessScore;
  final EosbCertificateConfidenceBand certificateConfidenceBand;
  final EosbLegalProvenanceSnapshot legalProvenance;
  final String calculationFingerprint;
  final EosbCertificateTrustState trustState;

  /// Art. 67 facts — only when verified deadline is computable from user inputs.
  final String? art67ContractTerminationDate;
  final String? art67DateOfLeavingWork;
  final bool? art67Art49NoticeGiven;
  final String? art67Branch;
  final String? art67DeadlineDate;
  final String? art67RuleVersion;
}
