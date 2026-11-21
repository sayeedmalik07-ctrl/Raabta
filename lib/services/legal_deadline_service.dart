/// Deterministic legal filing / appeal deadline calculations for Truth Engines.
///
/// No AI — pure date arithmetic from verified legal rules only.
library;

import 'package:raabta/services/art_67_working_day.dart';

/// Which verified legal deadline rule applies.
enum LegalDeadlineKind {
  /// Qatar Labour Law No. 14 of 2004, Art. 10 — lawsuit for entitlements.
  eosbLabourClaim,

  /// Qatar Labour Law No. 14 of 2004, Art. 67 — employer final settlement payment.
  eosbFinalSettlementPayment,

  /// Law No. 4 of 2008 (as amended), Art. 24 — Rental Dispute Committee appeal.
  tenancyCommitteeAppeal,

  /// Law No. 4 of 2008 — landlord itemized deposit statement + balance return window.
  tenancyDepositReturn,

  /// MOI Decree No. 51 of 2020 — employer-change window after permit expiry.
  sponsorshipPermitGrace,
}

/// UI severity bands for deadline cards (matches EOSB warning colour discipline).
enum LegalDeadlineUrgency {
  /// More than 60 calendar days before deadline.
  informational,

  /// 60 days or fewer — amber heads-up.
  approaching,

  /// 14 days or fewer — red high-visibility.
  urgent,

  /// Deadline date has passed.
  expired,
}

/// Art. 67 branch — standard (Art. 49 notice given) vs exception (left without).
enum Art67DeadlineBranch {
  standard,
  exception,
}

/// Whether a legal deadline is fully verified from user inputs.
enum LegalDeadlineVerificationStatus {
  verified,
  needsConfirmation,
}

/// Result of a deterministic deadline calculation.
class LegalDeadlineResult {
  const LegalDeadlineResult({
    required this.kind,
    required this.basisDate,
    required this.deadlineDate,
    required this.daysRemaining,
    required this.urgency,
    required this.citation,
    required this.basisLabel,
    this.verificationStatus = LegalDeadlineVerificationStatus.verified,
    this.art67Branch,
    this.endOfWorkingDayObligation = false,
    this.art67RuleVersion,
  });

  final LegalDeadlineKind kind;
  final DateTime basisDate;
  final DateTime deadlineDate;
  final int daysRemaining;
  final LegalDeadlineUrgency urgency;
  final String citation;
  final String basisLabel;
  final LegalDeadlineVerificationStatus verificationStatus;
  final Art67DeadlineBranch? art67Branch;
  final bool endOfWorkingDayObligation;

  /// Working-day or seven-day rule version tag (Art. 67 only).
  final String? art67RuleVersion;

  bool get isExpired => urgency == LegalDeadlineUrgency.expired;

  bool get isVerified =>
      verificationStatus == LegalDeadlineVerificationStatus.verified;
}

abstract final class LegalDeadlineService {
  LegalDeadlineService._();

  /// Art. 10 — Law No. 14 of 2004 (verified via ILO NATLEX / Al Meezan mirror):
  /// "the right to file a lawsuit … shall lapse by the expiry of one year from
  /// the date of expiry of the contract."
  ///
  /// Law No. 9 of 2026 amendments reviewed — Art. 10 limitation period unchanged.
  ///
  /// Basis date: [contractExpiryDate] — in Raabta this is the employee's
  /// [EosbEmployeeInput.lastWorkingDate] (when employment/contract ends).
  static const int eosbFilingLimitDays = 365;
  static const String eosbCitation =
      'Qatar Labour Law No. 14 of 2004, Art. 10';
  static const String eosbBasisLabel =
      'Contract expiry (last working day entered)';

  static const int eosbFinalSettlementExceptionDays = 7;
  static const String eosbFinalSettlementCitation =
      'Qatar Labour Law No. 14 of 2004, Art. 67';
  static const String eosbFinalSettlementBasisStandard =
      'Contract termination date';
  static const String eosbFinalSettlementBasisException =
      'Date of leaving work';

  /// Art. 24 — Law No. 4 of 2008 (Tenancy), 15-day committee appeal window.
  static const int tenancyAppealWindowDays = 15;
  static const String tenancyCitation =
      'Law No. 4 of 2008, Art. 24 (appeal window)';
  static const String tenancyBasisLabel = 'Committee decision date';

  /// Law No. 4 of 2008 — 14 calendar days after lease end for deposit statement
  /// and balance return (informational tracking — not adjudication).
  static const int tenancyDepositReturnDays = 14;
  static const String tenancyDepositReturnCitation =
      'Law No. 4 of 2008 (deposit return window)';
  static const String tenancyDepositReturnBasisLabel = 'Lease end date';

  /// MOI Decree No. 51 of 2020 — 90 days after residence permit expiry.
  static const int sponsorshipGraceDays = 90;
  static const String sponsorshipCitation =
      'MOI Decree No. 51 of 2020 (90-day post-expiry window)';
  static const String sponsorshipBasisLabel = 'Residence permit expiry';

  static LegalDeadlineResult? eosbLabourClaimDeadline({
    required DateTime? contractExpiryDate,
    DateTime? now,
  }) {
    if (contractExpiryDate == null) return null;
    return _build(
      kind: LegalDeadlineKind.eosbLabourClaim,
      basisDate: _dateOnly(contractExpiryDate),
      limitDays: eosbFilingLimitDays,
      citation: eosbCitation,
      basisLabel: eosbBasisLabel,
      now: now,
    );
  }

  /// Art. 67 — employer-side final settlement payment deadline (not a worker
  /// filing window).
  ///
  /// Branch selection uses [art49NoticeGiven] only — not [EosbEmployeeInput.noticeServed].
  ///
  /// Returns null when inputs are incomplete (strict legacy mode).
  static LegalDeadlineResult? eosbFinalSettlementPaymentDeadline({
    required bool? art49NoticeGiven,
    required DateTime? contractTerminationDate,
    required DateTime? dateOfLeavingWork,
    DateTime? now,
  }) {
    if (art49NoticeGiven == null) return null;

    if (art49NoticeGiven) {
      if (contractTerminationDate == null) return null;
      final basis = _dateOnly(contractTerminationDate);
      final deadline = Art67WorkingDay.nextWorkingDayAfterTermination(basis);
      return _buildArt67(
        basisDate: basis,
        deadlineDate: deadline,
        basisLabel: eosbFinalSettlementBasisStandard,
        branch: Art67DeadlineBranch.standard,
        endOfWorkingDayObligation: true,
        ruleVersion: Art67WorkingDayRuleVersion.v1FridaySkip,
        now: now,
      );
    }

    if (dateOfLeavingWork == null) return null;
    final basis = _dateOnly(dateOfLeavingWork);
    final deadline =
        basis.add(const Duration(days: eosbFinalSettlementExceptionDays));
    return _buildArt67(
      basisDate: basis,
      deadlineDate: deadline,
      basisLabel: eosbFinalSettlementBasisException,
      branch: Art67DeadlineBranch.exception,
      endOfWorkingDayObligation: false,
      ruleVersion: Art67SevenDayRuleVersion.v1Calendar,
      now: now,
    );
  }

  static LegalDeadlineResult? tenancyAppealDeadline({
    required DateTime? committeeDecisionDate,
    DateTime? now,
  }) {
    if (committeeDecisionDate == null) return null;
    return _build(
      kind: LegalDeadlineKind.tenancyCommitteeAppeal,
      basisDate: _dateOnly(committeeDecisionDate),
      limitDays: tenancyAppealWindowDays,
      citation: tenancyCitation,
      basisLabel: tenancyBasisLabel,
      now: now,
    );
  }

  static LegalDeadlineResult? tenancyDepositReturnDeadline({
    required DateTime? leaseEndDate,
    DateTime? now,
  }) {
    if (leaseEndDate == null) return null;
    return _build(
      kind: LegalDeadlineKind.tenancyDepositReturn,
      basisDate: _dateOnly(leaseEndDate),
      limitDays: tenancyDepositReturnDays,
      citation: tenancyDepositReturnCitation,
      basisLabel: tenancyDepositReturnBasisLabel,
      now: now,
    );
  }

  static LegalDeadlineResult? sponsorshipPermitGraceDeadline({
    required DateTime? residencePermitExpiry,
    DateTime? now,
  }) {
    if (residencePermitExpiry == null) return null;
    return _build(
      kind: LegalDeadlineKind.sponsorshipPermitGrace,
      basisDate: _dateOnly(residencePermitExpiry),
      limitDays: sponsorshipGraceDays,
      citation: sponsorshipCitation,
      basisLabel: sponsorshipBasisLabel,
      now: now,
    );
  }

  static LegalDeadlineUrgency urgencyForDaysRemaining(int daysRemaining) {
    if (daysRemaining < 0) return LegalDeadlineUrgency.expired;
    if (daysRemaining <= 14) return LegalDeadlineUrgency.urgent;
    if (daysRemaining <= 60) return LegalDeadlineUrgency.approaching;
    return LegalDeadlineUrgency.informational;
  }

  static LegalDeadlineResult _buildArt67({
    required DateTime basisDate,
    required DateTime deadlineDate,
    required String basisLabel,
    required Art67DeadlineBranch branch,
    required bool endOfWorkingDayObligation,
    required String ruleVersion,
    DateTime? now,
  }) {
    final clock = _dateOnly(now ?? DateTime.now());
    final daysRemaining = deadlineDate.difference(clock).inDays;
    return LegalDeadlineResult(
      kind: LegalDeadlineKind.eosbFinalSettlementPayment,
      basisDate: basisDate,
      deadlineDate: deadlineDate,
      daysRemaining: daysRemaining,
      urgency: urgencyForDaysRemaining(daysRemaining),
      citation: eosbFinalSettlementCitation,
      basisLabel: basisLabel,
      verificationStatus: LegalDeadlineVerificationStatus.verified,
      art67Branch: branch,
      endOfWorkingDayObligation: endOfWorkingDayObligation,
      art67RuleVersion: ruleVersion,
    );
  }

  static LegalDeadlineResult _build({
    required LegalDeadlineKind kind,
    required DateTime basisDate,
    required int limitDays,
    required String citation,
    required String basisLabel,
    DateTime? now,
  }) {
    final deadline = basisDate.add(Duration(days: limitDays));
    final clock = _dateOnly(now ?? DateTime.now());
    final daysRemaining = deadline.difference(clock).inDays;
    return LegalDeadlineResult(
      kind: kind,
      basisDate: basisDate,
      deadlineDate: deadline,
      daysRemaining: daysRemaining,
      urgency: urgencyForDaysRemaining(daysRemaining),
      citation: citation,
      basisLabel: basisLabel,
    );
  }

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);
}
