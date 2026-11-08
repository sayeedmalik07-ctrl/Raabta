import '../models/overtime_truth_models.dart';
import '../rules/overtime_rules.dart';

/// Deterministic overtime calculation — AI never performs these calculations.
class OvertimeTruthEngine {
  const OvertimeTruthEngine._();

  static OvertimeTruthResult calculateRecord(OvertimeMonthlyRecord record) {
    final rules = OvertimeRulesRegistry.forCountry(record.profile.countryCode);
    final profile = record.profile;
    final hourly = rules.hourlyRateFromProfile(profile);
    final rateBreakdown = OvertimeRateBreakdown.fromRules(
      rules: rules,
      basicSalary: profile.basicSalary,
      profile: profile,
    );

    final validation = _validate(record);
    final buckets = _aggregateDays(record.days, profile);
    final lineItems = _buildLineItems(buckets, hourly, rules);

    final totalHours = buckets.values.fold<double>(0, (s, h) => s + h);
    final totalOwed = lineItems.fold<double>(0, (s, i) => s + i.amount);
    final summary = _buildSummary(record, buckets, totalOwed, totalHours);
    final comparison = _buildComparison(record, totalOwed, totalHours);
    final alerts = _buildAlerts(record, comparison, summary, rules);
    final confidence = _confidenceScore(record, lineItems, validation);
    final weeklyAvg = summary.weeklyTotals.isEmpty
        ? 0.0
        : summary.weeklyTotals.reduce((a, b) => a + b) / summary.weeklyTotals.length;

    final legacyInput = OvertimeTruthInput(
      companyName: profile.companyName,
      basicSalary: profile.basicSalary,
      periodStart: record.periodStart,
      periodEnd: record.periodEnd,
      workingDaysPerWeek: profile.workingDaysPerWeek,
      standardHoursPerDay: profile.workingHoursPerDay,
      isRamadanPeriod: profile.isRamadanPeriod,
      inputMode: OvertimeInputMode.calendar,
      employerPaidOvertime: record.employerPaidOvertime,
      employerReportedOvertimeHours: record.employerReportedHours,
      record: record,
    );

    return OvertimeTruthResult(
      record: record,
      input: legacyInput,
      lineItems: lineItems,
      summary: summary,
      rateBreakdown: rateBreakdown,
      totalOvertimeHours: totalHours,
      totalLegalOwed: totalOwed,
      comparison: comparison,
      alerts: alerts,
      validationIssues: validation,
      confidenceScore: confidence,
      calculatedAt: DateTime.now(),
      standardHoursInPeriod: profile.monthlyWorkingDays *
          rules.effectiveWorkingHoursPerDay(profile).toDouble(),
      weeklyAverageHours: weeklyAvg,
      statusKey: totalHours > 0 ? 'ot_status_complete' : 'ot_status_pending',
    );
  }

  /// Legacy path — preserved for backward compatibility.
  static OvertimeTruthResult calculate(OvertimeTruthInput input) {
    if (input.record != null && input.record!.days.any((d) => d.totalHours > 0)) {
      return calculateRecord(input.record!);
    }

    final now = DateTime.now();
    final record = OvertimeMonthlyRecord(
      id: 'legacy_${now.millisecondsSinceEpoch}',
      year: input.periodStart?.year ?? now.year,
      month: input.periodStart?.month ?? now.month,
      profile: OvertimeEmployeeProfile(
        companyName: input.companyName,
        basicSalary: input.basicSalary,
        workingHoursPerDay: input.standardHoursPerDay,
        workingDaysPerWeek: input.workingDaysPerWeek,
        isRamadanPeriod: input.isRamadanPeriod,
        countryCode: 'QA',
      ),
      employerPaidOvertime: input.employerPaidOvertime,
      employerReportedHours: input.employerReportedOvertimeHours,
    );

    if (input.inputMode == OvertimeInputMode.detailed) {
      final days = <OvertimeDayEntry>[];
      void addBucket(double hours, OvertimeDayCategory cat) {
        if (hours <= 0) return;
        days.add(OvertimeDayEntry(
          date: input.periodStart ?? now,
          dayCategory: cat,
          overtimeHours: hours.floor(),
          overtimeMinutes: ((hours - hours.floor()) * 60).round(),
        ));
      }

      addBucket(input.weekdayOvertimeHours, OvertimeDayCategory.regularDay);
      addBucket(input.restDayHours, OvertimeDayCategory.weeklyRestDay);
      addBucket(input.publicHolidayHours, OvertimeDayCategory.publicHoliday);

      return calculateRecord(record.copyWith(days: days));
    }

    final standard = input.periodDays /
        7 *
        input.workingDaysPerWeek *
        input.effectiveStandardHoursPerDay;
    final extra = (input.totalHoursWorked - standard).clamp(0, double.infinity);
    final day = OvertimeDayEntry(
      date: input.periodStart ?? now,
      overtimeHours: extra.floor(),
      overtimeMinutes: ((extra - extra.floor()) * 60).round(),
    );
    return calculateRecord(record.copyWith(days: extra > 0 ? [day] : []));
  }

  static Map<OvertimeDayCategory, double> _aggregateDays(
    List<OvertimeDayEntry> days,
    OvertimeEmployeeProfile profile,
  ) {
    final map = <OvertimeDayCategory, double>{};
    for (final day in days) {
      if (day.totalHours <= 0) continue;
      var cat = day.dayCategory;
      if (day.shiftType == OvertimeShiftType.night &&
          cat == OvertimeDayCategory.regularDay) {
        cat = OvertimeDayCategory.nightShift;
      }
      map[cat] = (map[cat] ?? 0) + day.totalHours;
    }
    return map;
  }

  static List<OvertimeLineItem> _buildLineItems(
    Map<OvertimeDayCategory, double> buckets,
    double hourly,
    OvertimeCountryRules rules,
  ) {
    final items = <OvertimeLineItem>[];
    for (final entry in buckets.entries) {
      if (entry.value <= 0) continue;
      final rule = rules.ruleFor(entry.key);
      items.add(OvertimeLineItem(
        category: _legacyCategory(entry.key),
        dayCategory: entry.key,
        hours: entry.value,
        rateMultiplier: rule.multiplier,
        hourlyRate: hourly,
        amount: entry.value * hourly * rule.multiplier,
        ruleKey: rule.ruleKey,
        formulaKey: rule.formulaKey,
        articleRef: rule.articleRef,
      ));
    }
    return items;
  }

  static OvertimeRateCategory _legacyCategory(OvertimeDayCategory cat) {
    return switch (cat) {
      OvertimeDayCategory.regularDay => OvertimeRateCategory.weekdayExtra,
      OvertimeDayCategory.weeklyRestDay => OvertimeRateCategory.restDay,
      OvertimeDayCategory.publicHoliday => OvertimeRateCategory.publicHoliday,
      OvertimeDayCategory.nightShift => OvertimeRateCategory.nightShift,
      OvertimeDayCategory.emergencyCallOut => OvertimeRateCategory.emergency,
      OvertimeDayCategory.standby => OvertimeRateCategory.standby,
      OvertimeDayCategory.custom => OvertimeRateCategory.custom,
    };
  }

  static OvertimeMonthlySummary _buildSummary(
    OvertimeMonthlyRecord record,
    Map<OvertimeDayCategory, double> buckets,
    double totalPayment,
    double totalHours,
  ) {
    final daysWithOt =
        record.days.where((d) => d.totalHours > 0).toList(growable: false);
    daysWithOt.sort((a, b) => b.totalHours.compareTo(a.totalHours));

    OvertimeDayEntry? highest;
    OvertimeDayEntry? lowest;
    if (daysWithOt.isNotEmpty) {
      highest = daysWithOt.first;
      lowest = daysWithOt.last;
    }

    final dailyTotals = record.days.map((d) => d.totalHours).toList();
    final weeklyTotals = <double>[];
    for (var i = 0; i < dailyTotals.length; i += 7) {
      final end = (i + 7).clamp(0, dailyTotals.length);
      weeklyTotals.add(
        dailyTotals.sublist(i, end).fold<double>(0, (s, v) => s + v),
      );
    }

    final recorded = daysWithOt.length;
    final expected = record.days.length;
    final missing = expected - recorded;

    return OvertimeMonthlySummary(
      regularDayHours: buckets[OvertimeDayCategory.regularDay] ?? 0,
      restDayHours: buckets[OvertimeDayCategory.weeklyRestDay] ?? 0,
      holidayHours: buckets[OvertimeDayCategory.publicHoliday] ?? 0,
      nightHours: buckets[OvertimeDayCategory.nightShift] ?? 0,
      emergencyHours: buckets[OvertimeDayCategory.emergencyCallOut] ?? 0,
      standbyHours: buckets[OvertimeDayCategory.standby] ?? 0,
      customHours: buckets[OvertimeDayCategory.custom] ?? 0,
      totalHours: totalHours,
      totalPayment: totalPayment,
      averageDailyOvertime: recorded > 0 ? totalHours / recorded : 0,
      highestDay: highest,
      lowestDay: lowest,
      workingDaysRecorded: recorded,
      missingDays: missing > 0 ? missing : 0,
      weeklyTotals: weeklyTotals,
      dailyTotals: dailyTotals,
    );
  }

  static OvertimeEmployerComparison _buildComparison(
    OvertimeMonthlyRecord record,
    double totalOwed,
    double totalHours,
  ) {
    final paid = record.employerPaidOvertime;
    final diff = totalOwed - paid;
    final isUnderpaid = diff > 1;
    final isOverpaid = diff < -1;
    final gap = isUnderpaid ? diff : 0.0;
    final coverage =
        totalOwed > 0 ? (paid / totalOwed * 100).clamp(0, 200).toDouble() : 100;
    final pctDiff = totalOwed > 0 ? (diff / totalOwed * 100) : 0.0;
    final hoursGap = (totalHours - record.employerReportedHours)
        .clamp(0, double.infinity)
        .toDouble();

    return OvertimeEmployerComparison(
      legalOwed: totalOwed,
      employerPaid: paid,
      unpaidGap: gap,
      isUnderpaid: isUnderpaid,
      isOverpaid: isOverpaid,
      paymentCoveragePercent: coverage.clamp(0, 100).toDouble(),
      percentDifference: pctDiff,
      hoursGap: hoursGap,
      confidenceNoteKey: 'ot_comparison_note',
    );
  }

  static List<OvertimeValidationIssue> _validate(OvertimeMonthlyRecord record) {
    final issues = <OvertimeValidationIssue>[];
    if (record.profile.basicSalary <= 0) {
      issues.add(const OvertimeValidationIssue(
        fieldKey: 'basicSalary',
        messageKey: 'ot_val_salary',
      ));
    }

    final seen = <String>{};
    for (final day in record.days) {
      if (day.overtimeHours < 0 || day.overtimeMinutes < 0) {
        issues.add(const OvertimeValidationIssue(
          fieldKey: 'hours',
          messageKey: 'ot_val_negative',
        ));
      }
      if (day.totalHours > 16) {
        issues.add(const OvertimeValidationIssue(
          fieldKey: 'hours',
          messageKey: 'ot_val_impossible',
        ));
      }
      final key = day.date.toIso8601String().split('T').first;
      if (seen.contains(key)) {
        issues.add(const OvertimeValidationIssue(
          fieldKey: 'date',
          messageKey: 'ot_val_duplicate',
        ));
      }
      seen.add(key);
    }
    return issues;
  }

  static List<OvertimeAlert> _buildAlerts(
    OvertimeMonthlyRecord record,
    OvertimeEmployerComparison comparison,
    OvertimeMonthlySummary summary,
    OvertimeCountryRules rules,
  ) {
    final alerts = <OvertimeAlert>[];
    if (record.profile.isRamadanPeriod) {
      alerts.add(const OvertimeAlert(
        severity: 'low',
        titleKey: 'ot_alert_ramadan',
        bodyKey: 'ot_alert_ramadan_body',
      ));
    }
    if (record.profile.basicSalary <= 0) {
      alerts.add(const OvertimeAlert(
        severity: 'high',
        titleKey: 'ot_alert_no_salary',
        bodyKey: 'ot_alert_no_salary_body',
      ));
    }
    if (comparison.isUnderpaid) {
      alerts.add(const OvertimeAlert(
        severity: 'high',
        titleKey: 'ot_alert_unpaid',
        bodyKey: 'ot_alert_unpaid_body',
      ));
    }
    if (comparison.isOverpaid) {
      alerts.add(const OvertimeAlert(
        severity: 'low',
        titleKey: 'ot_alert_overpaid',
        bodyKey: 'ot_alert_overpaid_body',
      ));
    }
    for (final w in summary.weeklyTotals) {
      if (w > rules.maxWeeklyHours + summary.totalHours * 0.1) {
        alerts.add(const OvertimeAlert(
          severity: 'medium',
          titleKey: 'ot_alert_weekly_cap',
          bodyKey: 'ot_alert_weekly_cap_body',
        ));
        break;
      }
    }
    if (summary.missingDays > 5) {
      alerts.add(const OvertimeAlert(
        severity: 'low',
        titleKey: 'ot_alert_missing_days',
        bodyKey: 'ot_alert_missing_days_body',
      ));
    }
    return alerts;
  }

  static int _confidenceScore(
    OvertimeMonthlyRecord record,
    List<OvertimeLineItem> items,
    List<OvertimeValidationIssue> validation,
  ) {
    var score = 35;
    if (record.profile.basicSalary > 0) score += 20;
    if (record.profile.employeeName.isNotEmpty) score += 5;
    if (record.days.any((d) => d.totalHours > 0)) score += 20;
    if (record.employerPaidOvertime > 0) score += 10;
    if (items.length > 1) score += 5;
    score -= validation.length * 5;
    return score.clamp(0, 100);
  }
}

double overtimeHoursForEosb(OvertimeTruthResult result) => result.totalOvertimeHours;

double unpaidOvertimeAmountForEosb(OvertimeTruthResult result) =>
    result.comparison.unpaidGap;
