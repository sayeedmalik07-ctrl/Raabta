import 'package:raabta/features/sponsorship_transfer/domain/models/sponsorship_transfer_enums.dart';
import 'package:raabta/features/sponsorship_transfer/domain/models/transfer_readiness_input.dart';
import 'package:raabta/features/sponsorship_transfer/domain/models/transfer_readiness_models.dart';
import 'package:raabta/features/sponsorship_transfer/domain/rules/law_14_2004_art_39_probation.dart';
import 'package:raabta/features/sponsorship_transfer/domain/rules/law_18_2020_notice.dart';
import 'package:raabta/features/sponsorship_transfer/domain/rules/law_19_2020_sponsorship.dart';
import 'package:raabta/features/sponsorship_transfer/domain/rules/moi_decree_51_2020.dart';

/// Deterministic transfer readiness checks — verified legal facts only.
class TransferReadinessChecker {
  const TransferReadinessChecker({this.referenceDate});

  final DateTime? referenceDate;

  TransferReadinessResult check(TransferReadinessInput input) {
    final now = _dateOnly(referenceDate ?? DateTime.now());
    final monthsEmployed = _monthsEmployed(input.employmentStartDate, now);
    final noticeResolution = _resolveNotice(input, monthsEmployed);
    final permit = _permitWindow(input.residencePermitExpiry, now);

    final items = <TransferReadinessItem>[
      _noticePeriodItem(noticeResolution),
      _permitWindowItem(permit),
      _nocRightsItem(),
      _formalNoticeItem(input.formalNoticeStatus, noticeResolution),
      ..._informationalRights(),
    ]..sort((a, b) => a.sortPriority.compareTo(b.sortPriority));

    return TransferReadinessResult(
      items: items,
      checkedAt: DateTime.now(),
      noticeMonths: noticeResolution.noticeMonths,
      permitWindowStatus: permit.status,
      daysSincePermitExpiry: permit.daysSinceExpiry,
      monthsEmployed: monthsEmployed,
      probationNoticeApplies: noticeResolution.probationNoticeApplies,
    );
  }

  _NoticeResolution _resolveNotice(
    TransferReadinessInput input,
    int? monthsEmployed,
  ) {
    final probation = input.probationPeriodStatus;
    final withinProbationWindow = monthsEmployed != null &&
        monthsEmployed < Law142004Art39Probation.maxProbationMonths;

    if (probation == ProbationPeriodStatus.yes) {
      if (monthsEmployed != null &&
          monthsEmployed >= Law142004Art39Probation.maxProbationMonths) {
        return _NoticeResolution(
          noticeMonths: _postProbationNoticeMonths(monthsEmployed),
          explanationKey: 'st_check_notice_probation_conflict',
          actionKey: 'st_check_notice_action_probation_conflict',
          status: TransferReadinessStatus.needsVerification,
          ruleKey: 'law_14_art_39_probation',
          citationKey: 'st_cite_law14_art39',
        );
      }
      return const _NoticeResolution(
        noticeMonths: Law142004Art39Probation.probationNoticeMonths,
        explanationKey: 'st_check_notice_probation',
        actionKey: 'st_check_notice_action_probation',
        status: TransferReadinessStatus.informational,
        ruleKey: 'law_14_art_39_probation',
        citationKey: 'st_cite_law14_art39',
        probationNoticeApplies: true,
      );
    }

    if (probation == ProbationPeriodStatus.notSure && withinProbationWindow) {
      return _NoticeResolution(
        noticeMonths: Law142004Art39Probation.probationNoticeMonths,
        explanationKey: 'st_check_notice_probation_unsure',
        actionKey: 'st_check_notice_action_probation_unsure',
        status: TransferReadinessStatus.needsVerification,
        ruleKey: 'law_14_art_39_probation',
        citationKey: 'st_cite_law14_art39',
      );
    }

    if (probation == null && withinProbationWindow) {
      return _NoticeResolution(
        noticeMonths: Law142004Art39Probation.probationNoticeMonths,
        explanationKey: 'st_check_notice_probation_unanswered',
        actionKey: 'st_check_notice_action_probation_unanswered',
        status: TransferReadinessStatus.needsVerification,
        ruleKey: 'law_14_art_39_probation',
        citationKey: 'st_cite_law14_art39',
      );
    }

    if (monthsEmployed == null) {
      return const _NoticeResolution(
        noticeMonths: Law182020Notice.noticeMonthsUnderTwoYears,
        explanationKey: 'st_check_notice_needs_start',
        actionKey: 'st_check_notice_action_needs_start',
        status: TransferReadinessStatus.needsVerification,
        ruleKey: 'law_18_notice',
        citationKey: 'st_cite_law18_notice',
      );
    }

    final noticeMonths = _postProbationNoticeMonths(monthsEmployed);
    return _NoticeResolution(
      noticeMonths: noticeMonths,
      explanationKey: noticeMonths == 1
          ? 'st_check_notice_one_month'
          : 'st_check_notice_two_months',
      actionKey: 'st_check_notice_action',
      status: TransferReadinessStatus.informational,
      ruleKey: 'law_18_notice',
      citationKey: 'st_cite_law18_notice',
    );
  }

  int _postProbationNoticeMonths(int monthsEmployed) {
    if (monthsEmployed >= Law182020Notice.twoYearsThresholdMonths) {
      return Law182020Notice.noticeMonthsTwoYearsPlus;
    }
    return Law182020Notice.noticeMonthsUnderTwoYears;
  }

  int? _monthsEmployed(DateTime? start, DateTime reference) {
    if (start == null) return null;
    final s = _dateOnly(start);
    var months = (reference.year - s.year) * 12 + (reference.month - s.month);
    if (reference.day < s.day) months -= 1;
    return months < 0 ? 0 : months;
  }

  _PermitWindow _permitWindow(DateTime? expiry, DateTime reference) {
    if (expiry == null) {
      return const _PermitWindow(status: PermitWindowStatus.unknown);
    }
    final exp = _dateOnly(expiry);
    if (!exp.isBefore(reference)) {
      return const _PermitWindow(status: PermitWindowStatus.valid);
    }
    final daysSince = reference.difference(exp).inDays;
    if (daysSince <= MoiDecree512020.postExpiryGraceDays) {
      return _PermitWindow(
        status: PermitWindowStatus.graceWindow,
        daysSinceExpiry: daysSince,
      );
    }
    return _PermitWindow(
      status: PermitWindowStatus.outsideGrace,
      daysSinceExpiry: daysSince,
    );
  }

  TransferReadinessItem _noticePeriodItem(_NoticeResolution resolution) {
    return TransferReadinessItem(
      id: 'notice_period',
      titleKey: 'st_check_notice_title',
      explanationKey: resolution.explanationKey,
      actionKey: resolution.actionKey,
      status: resolution.status,
      ruleKey: resolution.ruleKey,
      citationKey: resolution.citationKey,
      sortPriority: 10,
    );
  }

  TransferReadinessItem _permitWindowItem(_PermitWindow permit) {
    switch (permit.status) {
      case PermitWindowStatus.valid:
        return const TransferReadinessItem(
          id: 'permit_window',
          titleKey: 'st_check_permit_title',
          explanationKey: 'st_check_permit_valid',
          actionKey: 'st_check_permit_action_valid',
          status: TransferReadinessStatus.compliant,
          ruleKey: 'moi_decree_51',
          citationKey: 'st_cite_moi_decree_51',
          sortPriority: 0,
        );
      case PermitWindowStatus.graceWindow:
        return const TransferReadinessItem(
          id: 'permit_window',
          titleKey: 'st_check_permit_title',
          explanationKey: 'st_check_permit_grace',
          actionKey: 'st_check_permit_action_grace',
          status: TransferReadinessStatus.warning,
          ruleKey: 'moi_decree_51',
          citationKey: 'st_cite_moi_decree_51',
          sortPriority: 1,
        );
      case PermitWindowStatus.outsideGrace:
        return const TransferReadinessItem(
          id: 'permit_window',
          titleKey: 'st_check_permit_title',
          explanationKey: 'st_check_permit_outside_grace',
          actionKey: 'st_check_permit_action_outside_grace',
          status: TransferReadinessStatus.critical,
          ruleKey: 'moi_decree_51',
          citationKey: 'st_cite_moi_decree_51',
          sortPriority: 0,
        );
      case PermitWindowStatus.unknown:
        return const TransferReadinessItem(
          id: 'permit_window',
          titleKey: 'st_check_permit_title',
          explanationKey: 'st_check_permit_unknown',
          actionKey: 'st_check_permit_action_unknown',
          status: TransferReadinessStatus.needsVerification,
          ruleKey: 'moi_decree_51',
          citationKey: 'st_cite_moi_decree_51',
          sortPriority: 5,
        );
    }
  }

  TransferReadinessItem _nocRightsItem() {
    return const TransferReadinessItem(
      id: 'noc_rights',
      titleKey: 'st_check_noc_title',
      explanationKey: 'st_check_noc_exp',
      actionKey: 'st_check_noc_action',
      status: TransferReadinessStatus.informational,
      ruleKey: 'law_19_art_21',
      citationKey: 'st_cite_law19_noc',
      sortPriority: 20,
    );
  }

  TransferReadinessItem _formalNoticeItem(
    FormalNoticeStatus? status,
    _NoticeResolution noticeResolution,
  ) {
    final probationNotice = noticeResolution.probationNoticeApplies;
    switch (status) {
      case FormalNoticeStatus.yes:
        return const TransferReadinessItem(
          id: 'formal_notice',
          titleKey: 'st_check_formal_notice_title',
          explanationKey: 'st_check_formal_notice_yes',
          actionKey: 'st_check_formal_notice_action_yes',
          status: TransferReadinessStatus.compliant,
          ruleKey: 'law_18_notice',
          sortPriority: 15,
        );
      case FormalNoticeStatus.no:
        return TransferReadinessItem(
          id: 'formal_notice',
          titleKey: 'st_check_formal_notice_title',
          explanationKey: probationNotice
              ? 'st_check_formal_notice_no_probation'
              : 'st_check_formal_notice_no',
          actionKey: 'st_check_formal_notice_action_no',
          status: TransferReadinessStatus.warning,
          ruleKey: probationNotice ? 'law_14_art_39_probation' : 'law_18_notice',
          citationKey: probationNotice
              ? 'st_cite_law14_art39'
              : 'st_cite_law18_notice',
          sortPriority: 14,
        );
      case FormalNoticeStatus.notSure:
        return const TransferReadinessItem(
          id: 'formal_notice',
          titleKey: 'st_check_formal_notice_title',
          explanationKey: 'st_check_formal_notice_unsure',
          actionKey: 'st_check_formal_notice_action_unsure',
          status: TransferReadinessStatus.needsVerification,
          ruleKey: 'law_18_notice',
          sortPriority: 14,
        );
      case null:
        return const TransferReadinessItem(
          id: 'formal_notice',
          titleKey: 'st_check_formal_notice_title',
          explanationKey: 'st_check_formal_notice_unanswered',
          actionKey: 'st_check_formal_notice_action_unanswered',
          status: TransferReadinessStatus.needsVerification,
          ruleKey: 'law_18_notice',
          sortPriority: 16,
        );
    }
  }

  List<TransferReadinessItem> _informationalRights() {
    return const [
      TransferReadinessItem(
        id: 'ldrc_disputes',
        titleKey: 'st_right_ldrc_title',
        explanationKey: 'st_right_ldrc_exp',
        actionKey: 'st_right_ldrc_action',
        status: TransferReadinessStatus.informational,
        ruleKey: 'cabinet_res_6',
        citationKey: 'st_cite_cabinet_res_6',
        sortPriority: 50,
      ),
      TransferReadinessItem(
        id: 'approval_statistics',
        titleKey: 'st_right_stats_title',
        explanationKey: 'st_right_stats_exp',
        actionKey: 'st_right_stats_action',
        status: TransferReadinessStatus.informational,
        ruleKey: 'peer_reviewed_stats',
        citationKey: 'st_cite_german_law_journal',
        sortPriority: 51,
      ),
      TransferReadinessItem(
        id: 'domestic_workers_exclusion',
        titleKey: 'st_right_domestic_title',
        explanationKey: 'st_right_domestic_exp',
        actionKey: 'st_right_domestic_action',
        status: TransferReadinessStatus.informational,
        ruleKey: 'law_15_2017',
        sortPriority: 52,
      ),
      TransferReadinessItem(
        id: 'article_22_deleted',
        titleKey: 'st_right_art22_title',
        explanationKey: 'st_right_art22_exp',
        actionKey: 'st_right_art22_action',
        status: TransferReadinessStatus.informational,
        ruleKey: 'law_19_art_22_deleted',
        sortPriority: 53,
      ),
    ];
  }

  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);
}

class _NoticeResolution {
  const _NoticeResolution({
    required this.noticeMonths,
    required this.explanationKey,
    required this.actionKey,
    required this.status,
    required this.ruleKey,
    this.citationKey,
    this.probationNoticeApplies = false,
  });

  final int noticeMonths;
  final String explanationKey;
  final String actionKey;
  final TransferReadinessStatus status;
  final String ruleKey;
  final String? citationKey;
  final bool probationNoticeApplies;
}

class _PermitWindow {
  const _PermitWindow({
    required this.status,
    this.daysSinceExpiry,
  });

  final PermitWindowStatus status;
  final int? daysSinceExpiry;
}

/// Exposed for tests and UI.
String sponsorshipTransferLawDisambiguationNote() =>
    'Law ${Law192020Sponsorship.lawIdentifier} amends sponsorship (${Law192020Sponsorship.amends}) — NOC removal. '
    'Law ${Law182020Notice.lawIdentifier} amends labour (${Law182020Notice.amends}) — notice period. '
    'Law No. 17 of 2020 is minimum wage only — separate law.';
