import 'package:raabta/features/eosb/domain/models/overtime_truth_models.dart';
import 'package:raabta/features/eosb/presentation/l10n/eosb_strings.dart';

/// Deterministic Overtime AI Review — same JSON shape as former Claude output.
class OvertimeReviewTemplateService {
  const OvertimeReviewTemplateService();

  OvertimeAiReview generate({
    required OvertimeTruthResult result,
    required String locale,
  }) {
    final summary = result.summary;
    final comparison = result.comparison;
    final currency = result.record.profile.currency;

    final summaryText = _fmt(
      'tpl_ot_summary',
      locale,
      {
        'month': result.record.label,
        'regular': summary.regularDayHours.toStringAsFixed(1),
        'rest': summary.restDayHours.toStringAsFixed(1),
        'holiday': summary.holidayHours.toStringAsFixed(1),
        'night': summary.nightHours.toStringAsFixed(1),
        'totalHours': result.totalOvertimeHours.toStringAsFixed(1),
        'totalPay': formatEosbCurrency(result.totalLegalOwed, symbol: currency),
      },
    );

    final calcExplain = _buildCalculationExplanation(result, locale, currency);
    final missingPayments = <String>[];
    final potentialErrors = <String>[];
    final questions = <String>[];
    final tips = <String>[
      EosbStrings.t('tpl_ot_tip_wps', locale),
      EosbStrings.t('tpl_ot_tip_payslip', locale),
    ];
    final nextSteps = <String>[
      EosbStrings.t('tpl_ot_next_payslip', locale),
      EosbStrings.t('eosb_step_compare_adlsa', locale),
    ];

    for (final alert in result.alerts) {
      final body = EosbStrings.t(alert.bodyKey, locale);
      if (alert.titleKey == 'ot_alert_unpaid') {
        missingPayments.add(body);
        questions.add(EosbStrings.t('tpl_ot_q_unpaid', locale));
      } else if (alert.titleKey == 'ot_alert_overpaid') {
        potentialErrors.add(body);
        questions.add(EosbStrings.t('tpl_ot_q_overpaid', locale));
      } else if (alert.titleKey == 'ot_alert_hours_mismatch') {
        potentialErrors.add(body);
        questions.add(EosbStrings.t('tpl_ot_q_hours', locale));
      } else if (alert.titleKey == 'ot_alert_weekly_cap') {
        potentialErrors.add(body);
        questions.add(EosbStrings.t('tpl_ot_q_weekly_cap', locale));
      } else if (alert.titleKey == 'ot_alert_missing_days') {
        potentialErrors.add(body);
        questions.add(EosbStrings.t('tpl_ot_q_missing_days', locale));
      } else if (alert.titleKey == 'ot_alert_no_salary') {
        potentialErrors.add(body);
      } else if (alert.titleKey == 'ot_alert_no_overtime') {
        potentialErrors.add(body);
      } else {
        potentialErrors.add(
          '${EosbStrings.t(alert.titleKey, locale)}: $body',
        );
      }
    }

    if (comparison.isUnderpaid && comparison.unpaidGap > 0) {
      missingPayments.add(
        _fmt(
          'tpl_ot_missing_gap',
          locale,
          {
            'gap': formatEosbCurrency(comparison.unpaidGap, symbol: currency),
            'percent': comparison.percentDifference.abs().toStringAsFixed(1),
          },
        ),
      );
      if (summary.nightHours > 0) {
        questions.add(EosbStrings.t('tpl_ot_q_night', locale));
      }
      if (summary.restDayHours > 0 || summary.holidayHours > 0) {
        questions.add(EosbStrings.t('tpl_ot_q_rest_holiday', locale));
      }
    } else if (!comparison.isUnderpaid &&
        !comparison.isOverpaid &&
        comparison.employerPaid > 0) {
      nextSteps.insert(0, EosbStrings.t('tpl_ot_next_match', locale));
    }

    if (summary.missingDays > 0) {
      questions.add(EosbStrings.t('tpl_ot_q_missing_days', locale));
    }

    final confidence = (result.confidenceScore / 100).clamp(0.0, 1.0);

    return OvertimeAiReview(
      summary: summaryText,
      missingPayments: _dedupe(missingPayments),
      potentialErrors: _dedupe(potentialErrors),
      calculationExplanation: calcExplain,
      questionsForEmployer: _dedupe(questions),
      payrollTips: tips,
      nextSteps: nextSteps,
      confidence: confidence,
    );
  }

  String _buildCalculationExplanation(
    OvertimeTruthResult result,
    String locale,
    String currency,
  ) {
    final lines = <String>[
      _fmt(
        'tpl_ot_calc_intro',
        locale,
        {
          'basic': formatEosbCurrency(
            result.record.profile.basicSalary,
            symbol: currency,
          ),
          'hourly': formatEosbCurrency(
            result.rateBreakdown.hourlyRate,
            symbol: currency,
          ),
        },
      ),
    ];

    for (final item in result.lineItems) {
      if (item.hours <= 0) continue;
      lines.add(
        _fmt(
          'tpl_ot_calc_line',
          locale,
          {
            'category': _categoryLabel(item.dayCategory, locale),
            'hours': item.hours.toStringAsFixed(1),
            'rate': item.rateMultiplier.toStringAsFixed(2),
            'amount': formatEosbCurrency(item.amount, symbol: currency),
          },
        ),
      );
    }

    lines.addAll(
      result.rateBreakdown.steps.map((s) => '• $s'),
    );

    lines.add(
      _fmt(
        'tpl_ot_calc_total',
        locale,
        {
          'total': formatEosbCurrency(result.totalLegalOwed, symbol: currency),
          'employer': formatEosbCurrency(
            result.comparison.employerPaid,
            symbol: currency,
          ),
        },
      ),
    );

    return lines.join('\n');
  }

  String _categoryLabel(OvertimeDayCategory cat, String locale) {
    return switch (cat) {
      OvertimeDayCategory.regularDay =>
        EosbStrings.t('ot_cat_weekday', locale),
      OvertimeDayCategory.weeklyRestDay =>
        EosbStrings.t('ot_cat_restday', locale),
      OvertimeDayCategory.publicHoliday =>
        EosbStrings.t('ot_cat_holiday', locale),
      OvertimeDayCategory.nightShift =>
        EosbStrings.t('ot_cat_night', locale),
      OvertimeDayCategory.emergencyCallOut =>
        EosbStrings.t('ot_cat_emergency', locale),
      OvertimeDayCategory.standby => EosbStrings.t('ot_cat_standby', locale),
      OvertimeDayCategory.custom => EosbStrings.t('ot_cat_custom', locale),
    };
  }

  List<String> _dedupe(List<String> items) {
    return items.toSet().toList();
  }

  String _fmt(String key, String locale, Map<String, String> params) {
    var text = EosbStrings.t(key, locale);
    params.forEach((k, v) => text = text.replaceAll('{$k}', v));
    return text;
  }
}
