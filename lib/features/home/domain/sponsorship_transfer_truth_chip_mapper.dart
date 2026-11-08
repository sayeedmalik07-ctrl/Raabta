import 'package:raabta/features/case_timeline/domain/case_timeline_engine_type.dart';
import 'package:raabta/features/case_timeline/presentation/navigation/case_timeline_navigation.dart';
import 'package:raabta/features/home/domain/truth_chip_status.dart';
import 'package:raabta/features/home/domain/truth_chip_urgency_thresholds.dart';
import 'package:raabta/features/home/l10n/truth_chip_sponsorship_transfer_strings.dart';
import 'package:raabta/features/sponsorship_transfer/domain/models/sponsorship_transfer_enums.dart';
import 'package:raabta/features/sponsorship_transfer/domain/models/transfer_readiness_input.dart';
import 'package:raabta/features/sponsorship_transfer/domain/models/transfer_readiness_models.dart';
import 'package:raabta/features/sponsorship_transfer/domain/rules/moi_decree_51_2020.dart';
import 'package:raabta/features/sponsorship_transfer/domain/services/transfer_readiness_checker.dart';
import 'package:raabta/services/legal_deadline_service.dart';

/// Pure Sponsorship Transfer → [TruthChipStatus] from saved readiness data.
abstract final class SponsorshipTransferTruthChipMapper {
  SponsorshipTransferTruthChipMapper._();

  static const titleKey = 'tool_sponsorship_transfer_title';
  static const _engineHome = '/sponsorship-transfer';

  static TruthChipStatus map({
    required TransferReadinessInput? input,
    required TransferReadinessResult? result,
    required DateTime now,
    String locale = 'English',
  }) {
    if (result == null || input == null) {
      return TruthChipStatus(
        engine: TruthChipEngine.sponsorshipTransfer,
        state: TruthChipState.invite,
        tone: TruthChipTone.neutral,
        titleKey: titleKey,
        statusText:
            TruthChipSponsorshipTransferStrings.t('truth_chip_st_invite', locale),
        freshnessText: '',
        deepLink: _engineHome,
      );
    }

    final freshness = TruthChipSponsorshipTransferStrings.t(
      'truth_chip_st_freshness',
      locale,
    );
    final checkerAtNow = TransferReadinessChecker(referenceDate: now);
    final permitSnapshot = checkerAtNow.check(input);
    final graceDeadline = LegalDeadlineService.sponsorshipPermitGraceDeadline(
      residencePermitExpiry: input.residencePermitExpiry,
      now: now,
    );

    final urgentGrace = _urgentFromGrace(
      permitStatus: permitSnapshot.permitWindowStatus,
      graceDeadline: graceDeadline,
      locale: locale,
      saved: result,
    );
    if (urgentGrace != null) return urgentGrace;

    final attentionGrace = _attentionFromGrace(
      graceDeadline: graceDeadline,
      now: now,
      locale: locale,
      saved: result,
    );
    if (attentionGrace != null) return attentionGrace;

    if (TruthChipUrgencyThresholds.isStale(
      lastSavedAt: result.checkedAt,
      now: now,
    )) {
      return TruthChipStatus(
        engine: TruthChipEngine.sponsorshipTransfer,
        state: TruthChipState.stale,
        tone: TruthChipTone.neutral,
        titleKey: titleKey,
        statusText:
            TruthChipSponsorshipTransferStrings.t('truth_chip_st_stale', locale),
        pillText: TruthChipSponsorshipTransferStrings.t(
          'truth_chip_st_pill_refresh',
          locale,
        ),
        freshnessText: freshness,
        deepLink: _engineHome,
      );
    }

    return _tracked(
      input: input,
      permitStatus: permitSnapshot.permitWindowStatus,
      daysSincePermitExpiry: permitSnapshot.daysSincePermitExpiry,
      graceDeadline: graceDeadline,
      now: now,
      locale: locale,
      freshness: freshness,
    );
  }

  static TruthChipStatus? _urgentFromGrace({
    required PermitWindowStatus permitStatus,
    required LegalDeadlineResult? graceDeadline,
    required String locale,
    required TransferReadinessResult saved,
  }) {
    if (permitStatus == PermitWindowStatus.outsideGrace) {
      return TruthChipStatus(
        engine: TruthChipEngine.sponsorshipTransfer,
        state: TruthChipState.urgent,
        tone: TruthChipTone.red,
        titleKey: titleKey,
        statusText: TruthChipSponsorshipTransferStrings.t(
          'truth_chip_st_urgent_grace_closed',
          locale,
        ),
        pillText: TruthChipSponsorshipTransferStrings.t(
          'truth_chip_st_pill_action',
          locale,
        ),
        freshnessText: TruthChipSponsorshipTransferStrings.t(
          'truth_chip_st_freshness',
          locale,
        ),
        deepLink: _caseDeepLink(saved),
      );
    }

    final deadline = graceDeadline;
    if (deadline == null) return null;

    final urgency = deadline.urgency;
    if (urgency == LegalDeadlineUrgency.expired ||
        urgency == LegalDeadlineUrgency.urgent) {
      return TruthChipStatus(
        engine: TruthChipEngine.sponsorshipTransfer,
        state: TruthChipState.urgent,
        tone: TruthChipTone.red,
        titleKey: titleKey,
        statusText: TruthChipSponsorshipTransferStrings.t(
          'truth_chip_st_urgent_grace_closed',
          locale,
        ),
        pillText: TruthChipSponsorshipTransferStrings.t(
          'truth_chip_st_pill_action',
          locale,
        ),
        freshnessText: TruthChipSponsorshipTransferStrings.t(
          'truth_chip_st_freshness',
          locale,
        ),
        deepLink: _caseDeepLink(saved),
      );
    }
    return null;
  }

  static TruthChipStatus? _attentionFromGrace({
    required LegalDeadlineResult? graceDeadline,
    required DateTime now,
    required String locale,
    required TransferReadinessResult saved,
  }) {
    final deadline = graceDeadline;
    if (deadline == null) return null;
    if (deadline.urgency != LegalDeadlineUrgency.approaching) return null;
    if (!_dateOnly(deadline.basisDate).isBefore(_dateOnly(now))) {
      return null;
    }

    return TruthChipStatus(
      engine: TruthChipEngine.sponsorshipTransfer,
      state: TruthChipState.attention,
      tone: TruthChipTone.amber,
      titleKey: titleKey,
      statusText: TruthChipSponsorshipTransferStrings.format(
        'truth_chip_st_attention_grace',
        locale,
        params: {'days': '${deadline.daysRemaining}'},
      ),
      pillText: '${deadline.daysRemaining}d',
      progress: _graceProgress(deadline.daysRemaining),
      freshnessText: TruthChipSponsorshipTransferStrings.t(
        'truth_chip_st_freshness',
        locale,
      ),
      deepLink: _caseDeepLink(saved),
    );
  }

  static TruthChipStatus _tracked({
    required TransferReadinessInput input,
    required PermitWindowStatus permitStatus,
    required int? daysSincePermitExpiry,
    required LegalDeadlineResult? graceDeadline,
    required DateTime now,
    required String locale,
    required String freshness,
  }) {
    final expiry = input.residencePermitExpiry;

    switch (permitStatus) {
      case PermitWindowStatus.valid:
        if (expiry != null) {
          final daysLeft = _daysUntil(_dateOnly(expiry), _dateOnly(now));
          if (daysLeft >= 0) {
            return TruthChipStatus(
              engine: TruthChipEngine.sponsorshipTransfer,
              state: TruthChipState.tracked,
              tone: TruthChipTone.ok,
              titleKey: titleKey,
              statusText: TruthChipSponsorshipTransferStrings.format(
                'truth_chip_st_tracked_window_open',
                locale,
                params: {'days': '$daysLeft'},
              ),
              progress: _validPermitProgress(daysLeft),
              freshnessText: freshness,
              deepLink: _engineHome,
            );
          }
        }
        break;
      case PermitWindowStatus.graceWindow:
        final daysLeft = graceDeadline?.daysRemaining ??
            (daysSincePermitExpiry == null
                ? null
                : MoiDecree512020.postExpiryGraceDays - daysSincePermitExpiry);
        if (daysLeft != null && daysLeft > 0) {
          return TruthChipStatus(
            engine: TruthChipEngine.sponsorshipTransfer,
            state: TruthChipState.tracked,
            tone: TruthChipTone.ok,
            titleKey: titleKey,
            statusText: TruthChipSponsorshipTransferStrings.format(
              'truth_chip_st_tracked_grace',
              locale,
              params: {'days': '$daysLeft'},
            ),
            progress: _graceProgress(daysLeft),
            freshnessText: freshness,
            deepLink: _engineHome,
          );
        }
        break;
      case PermitWindowStatus.unknown:
      case PermitWindowStatus.outsideGrace:
        break;
    }

    return TruthChipStatus(
      engine: TruthChipEngine.sponsorshipTransfer,
      state: TruthChipState.tracked,
      tone: TruthChipTone.ok,
      titleKey: titleKey,
      statusText: TruthChipSponsorshipTransferStrings.t(
        'truth_chip_st_tracked_saved',
        locale,
      ),
      freshnessText: freshness,
      deepLink: _engineHome,
    );
  }

  static double? _graceProgress(int daysRemaining) {
    final total = MoiDecree512020.postExpiryGraceDays;
    if (total <= 0) return null;
    final elapsed = total - daysRemaining;
    return (elapsed / total).clamp(0.0, 1.0);
  }

  static double? _validPermitProgress(int daysLeft) {
    const cap = 365;
    if (daysLeft <= 0 || daysLeft > cap) return null;
    return ((cap - daysLeft) / cap).clamp(0.0, 1.0);
  }

  static int _daysUntil(DateTime target, DateTime from) {
    return _dateOnly(target).difference(_dateOnly(from)).inDays;
  }

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  static String _caseDeepLink(TransferReadinessResult saved) {
    final caseId = CaseTimelineNavigation.sponsorshipCaseIdFromCheckedAt(
      saved.checkedAt,
    );
    return CaseTimelineNavigation.routePath(
      engine: CaseTimelineEngineType.sponsorshipTransfer,
      caseId: caseId,
    );
  }
}
