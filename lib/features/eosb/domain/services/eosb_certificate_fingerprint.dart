import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:raabta/features/eosb/domain/models/eosb_certificate_models.dart';
import 'package:raabta/features/eosb/domain/services/eosb_certificate_decimal_format.dart';

/// SHA-256 fingerprint over canonical JSON — locale- and presentation-independent.
///
/// ## FROZEN CONTRACT — do not change without bumping [EosbCertificateSchemaVersion].
///
/// ### INCLUDED IN FINGERPRINT (calculation-relevant snapshot fields)
///
/// Top-level keys (ASCII-sorted in output):
/// - `annualBonus`, `basicSalary`, `breakdown`, `calculatedAt`, `certificateConfidenceBand`
/// - `certificateSchemaVersion`, `commission`, `contractType`, `currency`, `dependentsCount`
/// - `employmentCategory`, `eosbRulesetVersion`, `familySponsored`, `foodAllowance`
/// - `housingAllowance`, `inputCompletenessScore`, `joiningDate` (if set), `lastWorkingDate` (if set)
/// - `legalProvenance`, `legalSourceVersion`, `noticeBuyoutAmount`, `noticeServed`
/// - `otherContractualBenefits`, `overtimeHours`, `pendingSalary`, `retentionBonus`
/// - `returnTicketIncluded`, `serviceDays`, `serviceYears`, `summaryDismissalGround`
/// - `summaryDismissalGroundConfirmed`, `terminationType`, `totalEntitlement`, `totalSalary`
/// - `transportAllowance`, `unusedLeaveDays`, `unusedSickLeaveDays`, `violations`, `warnings`
///
/// `breakdown[]` items (sorted by `id`): `amount`, `formulaKey`, `id`, `isEstimated`, `ruleKey`
///
/// `warnings[]` items (sorted by `titleKey`): `severity`, `titleKey`
///
/// `violations[]` items (sorted by `ruleKey`): `riskLevelKey`, `ruleKey`
///
/// `legalProvenance`: `breakdownLegalRefs`, `disclaimerKey`, `primaryLaw`, `raabtaRulesetLabel`,
/// `raabtaRulesetVersion`, `sourceVerifiedDate`, `supplementaryLaws`
///
/// ### EXCLUDED FROM FINGERPRINT
///
/// - `certificateId` — random document identity, not calculation content
/// - `generatedAt` — certificate generation event
/// - `generationLocale` — presentation
/// - `appVersion`, `appBuildNumber` — app release metadata
/// - `trustState` — Phase 1/2 verification status, not calculation content
/// - Localized strings, PDF layout, share-card layout, QR graphics
/// - Warning `explanationKey` / `actionKey` — presentation-only on private snapshot
/// - Employer identity (not on snapshot)
abstract final class EosbCertificateFingerprint {
  /// Documented top-level keys present in the canonical fingerprint payload.
  static const includedTopLevelKeys = [
    'annualBonus',
    'art67Art49NoticeGiven',
    'art67Branch',
    'art67ContractTerminationDate',
    'art67DateOfLeavingWork',
    'art67DeadlineDate',
    'art67RuleVersion',
    'basicSalary',
    'breakdown',
    'calculatedAt',
    'certificateConfidenceBand',
    'certificateSchemaVersion',
    'commission',
    'contractType',
    'currency',
    'dependentsCount',
    'employmentCategory',
    'eosbRulesetVersion',
    'familySponsored',
    'foodAllowance',
    'housingAllowance',
    'inputCompletenessScore',
    'joiningDate',
    'lastWorkingDate',
    'legalProvenance',
    'legalSourceVersion',
    'noticeBuyoutAmount',
    'noticeServed',
    'otherContractualBenefits',
    'overtimeHours',
    'pendingSalary',
    'retentionBonus',
    'returnTicketIncluded',
    'serviceDays',
    'serviceYears',
    'summaryDismissalGround',
    'summaryDismissalGroundConfirmed',
    'terminationType',
    'totalEntitlement',
    'totalSalary',
    'transportAllowance',
    'unusedLeaveDays',
    'unusedSickLeaveDays',
    'violations',
    'warnings',
  ];

  /// Snapshot fields intentionally omitted from the fingerprint payload.
  static const excludedSnapshotFields = [
    'certificateId',
    'generatedAt',
    'generationLocale',
    'appVersion',
    'appBuildNumber',
    'trustState',
  ];

  static String compute(EosbCertificateSnapshot snapshot) {
    return computeFromPayload(buildFingerprintPayload(snapshot));
  }

  @visibleForTesting
  static String computeFromPayload(Map<String, dynamic> payload) {
    final json = canonicalJsonEncode(payload);
    final digest = sha256.convert(utf8.encode(json));
    return digest.toString();
  }

  @visibleForTesting
  static Map<String, dynamic> buildFingerprintPayload(
    EosbCertificateSnapshot snapshot,
  ) {
    final breakdown = [...snapshot.breakdown]
      ..sort((a, b) => a.id.compareTo(b.id));
    final warnings = [...snapshot.warnings]
      ..sort((a, b) => a.titleKey.compareTo(b.titleKey));
    final violations = [...snapshot.violations]
      ..sort((a, b) => a.ruleKey.compareTo(b.ruleKey));

    final map = <String, dynamic>{
      'annualBonus': snapshot.annualBonus,
      'basicSalary': snapshot.basicSalary,
      'breakdown': breakdown.map(_breakdownMap).toList(),
      'calculatedAt': EosbCertificateDecimalFormat.isoDateTimeUtc(
        snapshot.calculatedAt,
      ),
      'certificateConfidenceBand': snapshot.certificateConfidenceBand.name,
      'certificateSchemaVersion': snapshot.certificateSchemaVersion,
      'commission': snapshot.commission,
      'contractType': snapshot.contractType,
      'currency': snapshot.currency,
      'dependentsCount': snapshot.dependentsCount,
      'employmentCategory': snapshot.employmentCategory,
      'eosbRulesetVersion': snapshot.eosbRulesetVersion,
      'familySponsored': snapshot.familySponsored,
      'foodAllowance': snapshot.foodAllowance,
      'housingAllowance': snapshot.housingAllowance,
      'inputCompletenessScore': snapshot.inputCompletenessScore,
      'legalProvenance': _legalProvenanceMap(snapshot.legalProvenance),
      'legalSourceVersion': snapshot.legalSourceVersion,
      'noticeBuyoutAmount': snapshot.noticeBuyoutAmount,
      'noticeServed': snapshot.noticeServed,
      'otherContractualBenefits': snapshot.otherContractualBenefits,
      'overtimeHours': snapshot.overtimeHours,
      'pendingSalary': snapshot.pendingSalary,
      'retentionBonus': snapshot.retentionBonus,
      'returnTicketIncluded': snapshot.returnTicketIncluded,
      'serviceDays': snapshot.serviceDays,
      'serviceYears': snapshot.serviceYears,
      'summaryDismissalGround': snapshot.summaryDismissalGround,
      'summaryDismissalGroundConfirmed':
          snapshot.summaryDismissalGroundConfirmed,
      'terminationType': snapshot.terminationType,
      'totalEntitlement': snapshot.totalEntitlement,
      'totalSalary': snapshot.totalSalary,
      'transportAllowance': snapshot.transportAllowance,
      'unusedLeaveDays': snapshot.unusedLeaveDays,
      'unusedSickLeaveDays': snapshot.unusedSickLeaveDays,
      'violations': violations.map(_violationMap).toList(),
      'warnings': warnings.map(_warningMap).toList(),
    };

    if (snapshot.joiningDate != null) {
      map['joiningDate'] = snapshot.joiningDate;
    }
    if (snapshot.lastWorkingDate != null) {
      map['lastWorkingDate'] = snapshot.lastWorkingDate;
    }
    if (snapshot.art67ContractTerminationDate != null) {
      map['art67ContractTerminationDate'] =
          snapshot.art67ContractTerminationDate;
    }
    if (snapshot.art67DateOfLeavingWork != null) {
      map['art67DateOfLeavingWork'] = snapshot.art67DateOfLeavingWork;
    }
    if (snapshot.art67Art49NoticeGiven != null) {
      map['art67Art49NoticeGiven'] = snapshot.art67Art49NoticeGiven;
    }
    if (snapshot.art67Branch != null) {
      map['art67Branch'] = snapshot.art67Branch;
    }
    if (snapshot.art67DeadlineDate != null) {
      map['art67DeadlineDate'] = snapshot.art67DeadlineDate;
    }
    if (snapshot.art67RuleVersion != null) {
      map['art67RuleVersion'] = snapshot.art67RuleVersion;
    }

    return map;
  }

  static Map<String, dynamic> _breakdownMap(EosbBreakdownSnapshotItem item) {
    return {
      'amount': item.amount,
      'formulaKey': item.formulaKey,
      'id': item.id,
      'isEstimated': item.isEstimated,
      'ruleKey': item.ruleKey,
    };
  }

  static Map<String, dynamic> _warningMap(EosbWarningSnapshotItem item) {
    return {
      'severity': item.severity,
      'titleKey': item.titleKey,
    };
  }

  static Map<String, dynamic> _violationMap(EosbViolationSnapshotItem item) {
    return {
      'riskLevelKey': item.riskLevelKey,
      'ruleKey': item.ruleKey,
    };
  }

  static Map<String, dynamic> _legalProvenanceMap(
    EosbLegalProvenanceSnapshot provenance,
  ) {
    final refs = [...provenance.breakdownLegalRefs]
      ..sort((a, b) => a.breakdownId.compareTo(b.breakdownId));
    final supplementary = [...provenance.supplementaryLaws]
      ..sort((a, b) => a.catalogId.compareTo(b.catalogId));

    return {
      'breakdownLegalRefs': refs.map((ref) {
        final articles = [...ref.articles]..sort();
        return {
          'articles': articles,
          'breakdownId': ref.breakdownId,
          'lawCatalogId': ref.lawCatalogId,
          'ruleKey': ref.ruleKey,
        };
      }).toList(),
      'disclaimerKey': provenance.disclaimerKey,
      'primaryLaw': _legalRefMap(provenance.primaryLaw),
      'raabtaRulesetLabel': provenance.raabtaRulesetLabel,
      'raabtaRulesetVersion': provenance.raabtaRulesetVersion,
      'sourceVerifiedDate': provenance.sourceVerifiedDate,
      'supplementaryLaws': supplementary.map(_legalRefMap).toList(),
    };
  }

  static Map<String, dynamic> _legalRefMap(EosbLegalReferenceSnapshot ref) {
    return {
      'catalogId': ref.catalogId,
      'dateLastVerified': ref.dateLastVerified,
      'lawIdentifier': ref.lawIdentifier,
      'sourceUrl': ref.sourceUrl,
    };
  }

  /// UTF-8 JSON with ASCII-sorted keys at every object level, no whitespace.
  static String canonicalJsonEncode(Object? value) {
    return jsonEncode(_canonicalize(value));
  }

  static dynamic _canonicalize(dynamic value) {
    if (value is Map) {
      final keys = value.keys.map((k) => k.toString()).toList()..sort();
      final out = <String, dynamic>{};
      for (final key in keys) {
        out[key] = _canonicalize(value[key]);
      }
      return out;
    }
    if (value is List) {
      return value.map(_canonicalize).toList();
    }
    return value;
  }
}
