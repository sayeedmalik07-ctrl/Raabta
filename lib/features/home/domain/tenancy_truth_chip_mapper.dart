import 'package:raabta/features/case_timeline/domain/case_timeline_engine_type.dart';
import 'package:raabta/features/case_timeline/presentation/navigation/case_timeline_navigation.dart';
import 'package:raabta/features/home/domain/truth_chip_status.dart';
import 'package:raabta/features/home/domain/truth_chip_urgency_thresholds.dart';
import 'package:raabta/features/home/l10n/truth_chip_tenancy_strings.dart';
import 'package:raabta/features/tenancy/domain/models/tenancy_compliance_models.dart';
import 'package:raabta/features/tenancy/domain/models/tenancy_enums.dart';
import 'package:raabta/features/tenancy/domain/models/tenancy_lease_input.dart';
import 'package:raabta/models/visa_models.dart';
import 'package:raabta/services/legal_deadline_service.dart';

/// Pure Tenancy → [TruthChipStatus] from saved lease input and compliance.
abstract final class TenancyTruthChipMapper {
  TenancyTruthChipMapper._();

  static const titleKey = 'tool_tenancy_title';
  static const _engineHome = '/tenancy';
  static const _registrationItemId = 'registration';

  static TruthChipStatus map({
    required TenancyLeaseInput? input,
    required TenancyComplianceResult? result,
    required DateTime now,
    String locale = 'English',
  }) {
    if (result == null || input == null) {
      return TruthChipStatus(
        engine: TruthChipEngine.tenancy,
        state: TruthChipState.invite,
        tone: TruthChipTone.neutral,
        titleKey: titleKey,
        statusText:
            TruthChipTenancyStrings.t('truth_chip_tenancy_invite', locale),
        freshnessText: '',
        deepLink: _engineHome,
      );
    }

    final freshness =
        TruthChipTenancyStrings.t('truth_chip_tenancy_freshness', locale);

    final unregisteredUrgent = _unregisteredUrgent(input, result, locale, freshness);
    if (unregisteredUrgent != null) return unregisteredUrgent;

    final legalUrgent = _legalUrgent(input, result, now, locale, freshness);
    if (legalUrgent != null) return legalUrgent;

    final leaseEndUrgent = _leaseEndUrgent(input, now, locale, freshness, result);
    if (leaseEndUrgent != null) return leaseEndUrgent;

    final legalAttention = _legalAttention(input, result, now, locale, freshness);
    if (legalAttention != null) return legalAttention;

    final leaseEndAttention =
        _leaseEndAttention(input, now, locale, freshness, result);
    if (leaseEndAttention != null) return leaseEndAttention;

    if (TruthChipUrgencyThresholds.isStale(
      lastSavedAt: result.checkedAt,
      now: now,
    )) {
      return TruthChipStatus(
        engine: TruthChipEngine.tenancy,
        state: TruthChipState.stale,
        tone: TruthChipTone.neutral,
        titleKey: titleKey,
        statusText:
            TruthChipTenancyStrings.t('truth_chip_tenancy_stale', locale),
        pillText:
            TruthChipTenancyStrings.t('truth_chip_tenancy_pill_refresh', locale),
        freshnessText: freshness,
        deepLink: _engineHome,
      );
    }

    return _tracked(input, now, locale, freshness);
  }

  static TruthChipStatus? _unregisteredUrgent(
    TenancyLeaseInput input,
    TenancyComplianceResult result,
    String locale,
    String freshness,
  ) {
    if (!input.isUnregistered) return null;
    final registrationCritical = result.items.any(
      (item) =>
          item.id == _registrationItemId &&
          item.status == TenancyComplianceStatus.critical,
    );
    if (!registrationCritical) return null;

    return TruthChipStatus(
      engine: TruthChipEngine.tenancy,
      state: TruthChipState.urgent,
      tone: TruthChipTone.red,
      titleKey: titleKey,
      statusText: TruthChipTenancyStrings.t(
        'truth_chip_tenancy_urgent_unregistered',
        locale,
      ),
      pillText: TruthChipTenancyStrings.t(
        'truth_chip_tenancy_pill_action',
        locale,
      ),
      freshnessText: freshness,
      deepLink: _caseDeepLink(result),
    );
  }

  static TruthChipStatus? _legalUrgent(
    TenancyLeaseInput input,
    TenancyComplianceResult result,
    DateTime now,
    String locale,
    String freshness,
  ) {
    final primary = _primaryLegalDeadline(input, now);
    if (primary == null) return null;
    final urgency = primary.urgency;
    if (urgency != LegalDeadlineUrgency.expired &&
        urgency != LegalDeadlineUrgency.urgent) {
      return null;
    }

    final statusKey = primary.kind == LegalDeadlineKind.tenancyDepositReturn
        ? 'truth_chip_tenancy_urgent_deposit'
        : 'truth_chip_tenancy_urgent_appeal';
    return TruthChipStatus(
      engine: TruthChipEngine.tenancy,
      state: TruthChipState.urgent,
      tone: TruthChipTone.red,
      titleKey: titleKey,
      statusText: TruthChipTenancyStrings.t(statusKey, locale),
      pillText: TruthChipTenancyStrings.t(
        'truth_chip_tenancy_pill_action',
        locale,
      ),
      freshnessText: freshness,
      deepLink: _caseDeepLink(result),
    );
  }

  static TruthChipStatus? _legalAttention(
    TenancyLeaseInput input,
    TenancyComplianceResult result,
    DateTime now,
    String locale,
    String freshness,
  ) {
    final primary = _primaryLegalDeadline(input, now);
    if (primary == null) return null;
    if (primary.urgency != LegalDeadlineUrgency.approaching) return null;

    return TruthChipStatus(
      engine: TruthChipEngine.tenancy,
      state: TruthChipState.attention,
      tone: TruthChipTone.amber,
      titleKey: titleKey,
      statusText: TruthChipTenancyStrings.format(
        'truth_chip_tenancy_attention_deposit',
        locale,
        params: {'days': '${primary.daysRemaining}'},
      ),
      pillText: '${primary.daysRemaining}d',
      progress: _depositWindowProgress(primary.daysRemaining),
      freshnessText: freshness,
      deepLink: _caseDeepLink(result),
    );
  }

  static TruthChipStatus? _leaseEndUrgent(
    TenancyLeaseInput input,
    DateTime now,
    String locale,
    String freshness,
    TenancyComplianceResult result,
  ) {
    final days = _daysUntilLeaseEnd(input, now);
    if (days == null || days < 0) return null;
    final tier = TruthChipUrgencyThresholds.documentUrgencyForDaysRemaining(days);
    if (tier != DeadlineUrgency.red) return null;

    return TruthChipStatus(
      engine: TruthChipEngine.tenancy,
      state: TruthChipState.urgent,
      tone: TruthChipTone.red,
      titleKey: titleKey,
      statusText: TruthChipTenancyStrings.t(
        'truth_chip_tenancy_urgent_lease_end',
        locale,
      ),
      pillText: TruthChipTenancyStrings.t(
        'truth_chip_tenancy_pill_action',
        locale,
      ),
      freshnessText: freshness,
      deepLink: _caseDeepLink(result),
    );
  }

  static TruthChipStatus? _leaseEndAttention(
    TenancyLeaseInput input,
    DateTime now,
    String locale,
    String freshness,
    TenancyComplianceResult result,
  ) {
    final days = _daysUntilLeaseEnd(input, now);
    if (days == null || days < 0) return null;
    final tier = TruthChipUrgencyThresholds.documentUrgencyForDaysRemaining(days);
    if (tier != DeadlineUrgency.amber) return null;

    return TruthChipStatus(
      engine: TruthChipEngine.tenancy,
      state: TruthChipState.attention,
      tone: TruthChipTone.amber,
      titleKey: titleKey,
      statusText: TruthChipTenancyStrings.format(
        'truth_chip_tenancy_attention_lease_end',
        locale,
        params: {'days': '$days'},
      ),
      pillText: '${days}d',
      progress: _leaseTermProgress(input, now),
      freshnessText: freshness,
      deepLink: _engineHome,
    );
  }

  static TruthChipStatus _tracked(
    TenancyLeaseInput input,
    DateTime now,
    String locale,
    String freshness,
  ) {
    final days = _daysUntilLeaseEnd(input, now);
    if (days != null && days >= 0) {
      return TruthChipStatus(
        engine: TruthChipEngine.tenancy,
        state: TruthChipState.tracked,
        tone: TruthChipTone.ok,
        titleKey: titleKey,
        statusText: TruthChipTenancyStrings.format(
          'truth_chip_tenancy_tracked_lease_end',
          locale,
          params: {'days': '$days'},
        ),
        progress: _leaseTermProgress(input, now),
        freshnessText: freshness,
        deepLink: _engineHome,
      );
    }

    return TruthChipStatus(
      engine: TruthChipEngine.tenancy,
      state: TruthChipState.tracked,
      tone: TruthChipTone.ok,
      titleKey: titleKey,
      statusText:
          TruthChipTenancyStrings.t('truth_chip_tenancy_tracked_saved', locale),
      freshnessText: freshness,
      deepLink: _engineHome,
    );
  }

  static LegalDeadlineResult? _primaryLegalDeadline(
    TenancyLeaseInput input,
    DateTime now,
  ) {
    final deadlines = <LegalDeadlineResult>[];
    if (input.leaseEndDate != null) {
      final deposit = LegalDeadlineService.tenancyDepositReturnDeadline(
        leaseEndDate: input.leaseEndDate,
        now: now,
      );
      if (deposit != null) deadlines.add(deposit);
    }
    if (input.committeeDecisionDate != null) {
      final appeal = LegalDeadlineService.tenancyAppealDeadline(
        committeeDecisionDate: input.committeeDecisionDate,
        now: now,
      );
      if (appeal != null) deadlines.add(appeal);
    }
    if (deadlines.isEmpty) return null;
    deadlines.sort((a, b) => a.daysRemaining.compareTo(b.daysRemaining));
    return deadlines.first;
  }

  static int? _daysUntilLeaseEnd(TenancyLeaseInput input, DateTime now) {
    final end = input.leaseEndDate;
    if (end == null) return null;
    return _dateOnly(end).difference(_dateOnly(now)).inDays;
  }

  static double? _leaseTermProgress(TenancyLeaseInput input, DateTime now) {
    final start = input.leaseStartDate;
    final end = input.leaseEndDate;
    if (start == null || end == null) return null;
    final startDay = _dateOnly(start);
    final endDay = _dateOnly(end);
    final total = endDay.difference(startDay).inDays;
    if (total <= 0) return null;
    final elapsed = _dateOnly(now).difference(startDay).inDays;
    return (elapsed / total).clamp(0.0, 1.0);
  }

  static double? _depositWindowProgress(int daysRemaining) {
    const total = LegalDeadlineService.tenancyDepositReturnDays;
    if (total <= 0) return null;
    final elapsed = total - daysRemaining;
    return (elapsed / total).clamp(0.0, 1.0);
  }

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  static String _caseDeepLink(TenancyComplianceResult result) {
    final caseId = CaseTimelineNavigation.tenancyCaseIdFromCheckedAt(
      result.checkedAt,
    );
    return CaseTimelineNavigation.routePath(
      engine: CaseTimelineEngineType.tenancy,
      caseId: caseId,
    );
  }
}
