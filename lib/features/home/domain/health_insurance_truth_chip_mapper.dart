import 'package:raabta/features/health_insurance/data/models/compliance_check_model.dart';
import 'package:raabta/features/health_insurance/domain/models/health_compliance_enums.dart';
import 'package:raabta/features/home/domain/truth_chip_status.dart';
import 'package:raabta/features/home/domain/truth_chip_urgency_thresholds.dart';
import 'package:raabta/features/home/l10n/truth_chip_health_insurance_strings.dart';
import 'package:raabta/models/visa_models.dart';

/// Pure Health Insurance → [TruthChipStatus] from saved compliance data.
abstract final class HealthInsuranceTruthChipMapper {
  HealthInsuranceTruthChipMapper._();

  static const titleKey = 'tool_health_insurance_title';
  static const _engineHome = '/health-insurance';
  static const _gapItemId = 'insurer_switch_gap';

  static TruthChipStatus map({
    required InsuranceComplianceInput? input,
    required ComplianceCheckResult? result,
    required DateTime now,
    String locale = 'English',
  }) {
    if (result == null || input == null) {
      return TruthChipStatus(
        engine: TruthChipEngine.healthInsurance,
        state: TruthChipState.invite,
        tone: TruthChipTone.neutral,
        titleKey: titleKey,
        statusText:
            TruthChipHealthInsuranceStrings.t('truth_chip_hi_invite', locale),
        freshnessText: '',
        deepLink: _engineHome,
      );
    }

    final freshness =
        TruthChipHealthInsuranceStrings.t('truth_chip_hi_freshness', locale);
    final revealed = _revealedDetail(input, now, locale);
    final coverageEnd = _coverageEndDate(input);

    final gapUrgent = _gapViolationUrgent(result, locale, freshness, revealed);
    if (gapUrgent != null) return gapUrgent;

    final endedUrgent =
        _coverEndedUrgent(input, now, locale, freshness, revealed, coverageEnd);
    if (endedUrgent != null) return endedUrgent;

    final issueUrgent = _otherViolationUrgent(result, locale, freshness, revealed);
    if (issueUrgent != null) return issueUrgent;

    final renewAttention =
        _renewalAttention(coverageEnd, now, locale, freshness, revealed);
    if (renewAttention != null) return renewAttention;

    if (TruthChipUrgencyThresholds.isStale(
      lastSavedAt: result.checkedAt,
      now: now,
    )) {
      return TruthChipStatus(
        engine: TruthChipEngine.healthInsurance,
        state: TruthChipState.stale,
        tone: TruthChipTone.neutral,
        titleKey: titleKey,
        statusText:
            TruthChipHealthInsuranceStrings.t('truth_chip_hi_stale', locale),
        pillText:
            TruthChipHealthInsuranceStrings.t('truth_chip_hi_pill_refresh', locale),
        freshnessText: freshness,
        deepLink: _engineHome,
        revealedText: revealed,
      );
    }

    return _tracked(
      input: input,
      result: result,
      coverageEnd: coverageEnd,
      now: now,
      locale: locale,
      freshness: freshness,
      revealed: revealed,
    );
  }

  static TruthChipStatus? _gapViolationUrgent(
    ComplianceCheckResult result,
    String locale,
    String freshness,
    String? revealed,
  ) {
    final gapViolation = result.items.any(
      (item) =>
          item.id == _gapItemId &&
          item.status == HealthComplianceStatus.violation,
    );
    if (!gapViolation) return null;

    return TruthChipStatus(
      engine: TruthChipEngine.healthInsurance,
      state: TruthChipState.urgent,
      tone: TruthChipTone.red,
      titleKey: titleKey,
      statusText:
          TruthChipHealthInsuranceStrings.t('truth_chip_hi_urgent_gap', locale),
      pillText:
          TruthChipHealthInsuranceStrings.t('truth_chip_hi_pill_action', locale),
      freshnessText: freshness,
      deepLink: _engineHome,
      revealedText: revealed,
    );
  }

  static TruthChipStatus? _coverEndedUrgent(
    InsuranceComplianceInput input,
    DateTime now,
    String locale,
    String freshness,
    String? revealed,
    DateTime? coverageEnd,
  ) {
    if (coverageEnd == null) return null;
    if (!_dateOnly(coverageEnd).isBefore(_dateOnly(now))) return null;

    return TruthChipStatus(
      engine: TruthChipEngine.healthInsurance,
      state: TruthChipState.urgent,
      tone: TruthChipTone.red,
      titleKey: titleKey,
      statusText:
          TruthChipHealthInsuranceStrings.t('truth_chip_hi_urgent_ended', locale),
      pillText:
          TruthChipHealthInsuranceStrings.t('truth_chip_hi_pill_action', locale),
      freshnessText: freshness,
      deepLink: _engineHome,
      revealedText: revealed,
    );
  }

  static TruthChipStatus? _otherViolationUrgent(
    ComplianceCheckResult result,
    String locale,
    String freshness,
    String? revealed,
  ) {
    final otherViolation = result.items.any(
      (item) =>
          item.id != _gapItemId &&
          item.status == HealthComplianceStatus.violation,
    );
    if (!otherViolation) return null;

    return TruthChipStatus(
      engine: TruthChipEngine.healthInsurance,
      state: TruthChipState.urgent,
      tone: TruthChipTone.red,
      titleKey: titleKey,
      statusText:
          TruthChipHealthInsuranceStrings.t('truth_chip_hi_urgent_issue', locale),
      pillText:
          TruthChipHealthInsuranceStrings.t('truth_chip_hi_pill_action', locale),
      freshnessText: freshness,
      deepLink: _engineHome,
      revealedText: revealed,
    );
  }

  static TruthChipStatus? _renewalAttention(
    DateTime? coverageEnd,
    DateTime now,
    String locale,
    String freshness,
    String? revealed,
  ) {
    final end = coverageEnd;
    if (end == null) return null;
    final days = _dateOnly(end).difference(_dateOnly(now)).inDays;
    if (days < 0) return null;
    final tier = TruthChipUrgencyThresholds.documentUrgencyForDaysRemaining(days);
    if (tier == DeadlineUrgency.green) return null;
    if (tier == DeadlineUrgency.red) {
      return TruthChipStatus(
        engine: TruthChipEngine.healthInsurance,
        state: TruthChipState.urgent,
        tone: TruthChipTone.red,
        titleKey: titleKey,
        statusText: TruthChipHealthInsuranceStrings.format(
          'truth_chip_hi_attention_renew',
          locale,
          params: {'days': '$days'},
        ),
        pillText:
            TruthChipHealthInsuranceStrings.t('truth_chip_hi_pill_action', locale),
        freshnessText: freshness,
        deepLink: _engineHome,
        revealedText: revealed,
      );
    }

    return TruthChipStatus(
      engine: TruthChipEngine.healthInsurance,
      state: TruthChipState.attention,
      tone: TruthChipTone.amber,
      titleKey: titleKey,
      statusText: TruthChipHealthInsuranceStrings.format(
        'truth_chip_hi_attention_renew',
        locale,
        params: {'days': '$days'},
      ),
      pillText: '${days}d',
      progress: _coverageProgress(end, inputStart: null, now: now),
      freshnessText: freshness,
      deepLink: _engineHome,
      revealedText: revealed,
    );
  }

  static TruthChipStatus _tracked({
    required InsuranceComplianceInput input,
    required ComplianceCheckResult result,
    required DateTime? coverageEnd,
    required DateTime now,
    required String locale,
    required String freshness,
    required String? revealed,
  }) {
    if (result.isExemptSession) {
      return TruthChipStatus(
        engine: TruthChipEngine.healthInsurance,
        state: TruthChipState.tracked,
        tone: TruthChipTone.ok,
        titleKey: titleKey,
        statusText:
            TruthChipHealthInsuranceStrings.t('truth_chip_hi_tracked_exempt', locale),
        freshnessText: freshness,
        deepLink: _engineHome,
        revealedText: revealed,
      );
    }

    final end = coverageEnd;
    if (end != null && !_dateOnly(end).isBefore(_dateOnly(now))) {
      final month =
          TruthChipHealthInsuranceStrings.monthShort(end.month, locale);
      return TruthChipStatus(
        engine: TruthChipEngine.healthInsurance,
        state: TruthChipState.tracked,
        tone: TruthChipTone.ok,
        titleKey: titleKey,
        statusText: TruthChipHealthInsuranceStrings.format(
          'truth_chip_hi_tracked_covered',
          locale,
          params: {'month': month},
        ),
        progress: _coverageProgress(
          end,
          inputStart: input.newPolicyStartDate,
          now: now,
        ),
        freshnessText: freshness,
        deepLink: _engineHome,
        revealedText: revealed,
      );
    }

    return TruthChipStatus(
      engine: TruthChipEngine.healthInsurance,
      state: TruthChipState.tracked,
      tone: TruthChipTone.ok,
      titleKey: titleKey,
      statusText:
          TruthChipHealthInsuranceStrings.t('truth_chip_hi_tracked_saved', locale),
      freshnessText: freshness,
      deepLink: _engineHome,
      revealedText: revealed,
    );
  }

  static DateTime? _coverageEndDate(InsuranceComplianceInput input) {
    final start = input.newPolicyStartDate;
    if (start != null) {
      return start.add(
        const Duration(days: TruthChipHealthInsuranceStrings.annualCoverageDays),
      );
    }
    return input.previousPolicyEndDate;
  }

  static double? _coverageProgress(
    DateTime end,
    {DateTime? inputStart,
    required DateTime now,
  }) {
    final start = inputStart;
    if (start == null) return null;
    final startDay = _dateOnly(start);
    final endDay = _dateOnly(end);
    final total = endDay.difference(startDay).inDays;
    if (total <= 0) return null;
    final elapsed = _dateOnly(now).difference(startDay).inDays;
    return (elapsed / total).clamp(0.0, 1.0);
  }

  static String? _revealedDetail(
    InsuranceComplianceInput input,
    DateTime now,
    String locale,
  ) {
    final insurer = input.insurerName.trim();
    final end = _coverageEndDate(input);
    if (insurer.isEmpty || end == null) return null;
    final date =
        '${end.year}-${end.month.toString().padLeft(2, '0')}-${end.day.toString().padLeft(2, '0')}';
    return TruthChipHealthInsuranceStrings.format(
      'truth_chip_hi_revealed',
      locale,
      params: {'insurer': insurer, 'date': date},
    );
  }

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);
}
