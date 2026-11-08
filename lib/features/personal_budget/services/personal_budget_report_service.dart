import 'package:intl/intl.dart';
import 'package:raabta/features/cost_of_living/domain/cost_of_living_models.dart';
import 'package:raabta/features/personal_budget/domain/personal_budget_models.dart';
import 'package:raabta/features/personal_budget/presentation/l10n/personal_budget_strings.dart';
import 'package:raabta/features/personal_budget/presentation/widgets/personal_budget_pressure_badge.dart';

/// Auto-generated complete budget report — deterministic, no AI required.
class PersonalBudgetReport {
  const PersonalBudgetReport({
    required this.title,
    required this.generatedAt,
    required this.sections,
    required this.plainText,
  });

  final String title;
  final DateTime generatedAt;
  final List<PersonalBudgetReportSection> sections;
  final String plainText;
}

class PersonalBudgetReportSection {
  const PersonalBudgetReportSection({
    required this.heading,
    required this.body,
    this.bullets = const [],
  });

  final String heading;
  final String body;
  final List<String> bullets;
}

abstract final class PersonalBudgetReportService {
  static PersonalBudgetReport build({
    required PersonalBudgetInputs inputs,
    required PersonalBudgetResult result,
    required String locale,
    CostOfLivingSnapshot? cpiSnapshot,
  }) {
    final generatedAt = DateTime.now();
    final dateLabel = DateFormat.yMMMMd().format(generatedAt);
    final sections = <PersonalBudgetReportSection>[];

    sections.add(
      PersonalBudgetReportSection(
        heading: PersonalBudgetStrings.t('pb_report_exec', locale),
        body: _executiveSummary(inputs, result, locale),
      ),
    );

    sections.add(
      PersonalBudgetReportSection(
        heading: PersonalBudgetStrings.t('pb_report_income', locale),
        body: _incomeExpenseBody(inputs, result, locale),
        bullets: _categoryBullets(result, locale),
      ),
    );

    sections.add(
      PersonalBudgetReportSection(
        heading: PersonalBudgetStrings.t('pb_report_pressure', locale),
        body: _pressureBody(result, locale),
      ),
    );

    if (result.attentionInsight != null) {
      sections.add(
        PersonalBudgetReportSection(
          heading: PersonalBudgetStrings.t('pb_attention_heading', locale),
          body: PersonalBudgetStrings.format(
            _attentionKey(result.attentionInsight!.category),
            locale,
            params: {
              'percent':
                  result.attentionInsight!.sharePercent.toStringAsFixed(1),
            },
          ),
        ),
      );
    }

    sections.add(
      PersonalBudgetReportSection(
        heading: PersonalBudgetStrings.t('pb_report_actions', locale),
        body: PersonalBudgetStrings.t('pb_report_actions_body', locale),
        bullets: _recommendations(result, locale),
      ),
    );

    if (cpiSnapshot != null) {
      sections.add(
        PersonalBudgetReportSection(
          heading: PersonalBudgetStrings.t('pb_report_cpi', locale),
          body: _cpiContext(cpiSnapshot, locale),
        ),
      );
    }

    sections.add(
      PersonalBudgetReportSection(
        heading: PersonalBudgetStrings.t('pb_report_disclaimer', locale),
        body: PersonalBudgetStrings.t('pb_disclaimer', locale),
      ),
    );

    final plainText = StringBuffer()
      ..writeln('RAABTA — ${PersonalBudgetStrings.t('pb_title', locale)}')
      ..writeln('$dateLabel\n');

    for (final section in sections) {
      plainText.writeln('## ${section.heading}');
      plainText.writeln(section.body);
      for (final bullet in section.bullets) {
        plainText.writeln('• $bullet');
      }
      plainText.writeln();
    }

    return PersonalBudgetReport(
      title: PersonalBudgetStrings.t('pb_report_title', locale),
      generatedAt: generatedAt,
      sections: sections,
      plainText: plainText.toString().trim(),
    );
  }

  static String _attentionKey(PersonalBudgetCategory category) {
    return switch (category) {
      PersonalBudgetCategory.rent => 'pb_attention_rent',
      PersonalBudgetCategory.food => 'pb_attention_food',
      PersonalBudgetCategory.transport => 'pb_attention_transport',
      PersonalBudgetCategory.utilities => 'pb_attention_utilities',
      PersonalBudgetCategory.family => 'pb_attention_family',
      PersonalBudgetCategory.remittance => 'pb_attention_remittance',
      PersonalBudgetCategory.other => 'pb_attention_other',
    };
  }

  static String _executiveSummary(
    PersonalBudgetInputs inputs,
    PersonalBudgetResult result,
    String locale,
  ) {
    if (!result.salarySet) {
      return PersonalBudgetStrings.t('pb_enter_salary', locale);
    }
    final pressure = PersonalBudgetStrings.t(
      pressureBandLabelKey(result.pressureBand),
      locale,
    );
    return PersonalBudgetStrings.format(
      'pb_report_exec_body',
      locale,
      params: {
        'monthly': _fmt(result.monthlyCost),
        'salary': _fmt(inputs.salary),
        'savings_rate': result.savingsRatePercent?.toStringAsFixed(1) ?? '—',
        'pressure': pressure,
      },
    );
  }

  static String _incomeExpenseBody(
    PersonalBudgetInputs inputs,
    PersonalBudgetResult result,
    String locale,
  ) {
    return PersonalBudgetStrings.format(
      'pb_report_income_body',
      locale,
      params: {
        'salary': _fmt(inputs.salary),
        'monthly': _fmt(result.monthlyCost),
        'annual': _fmt(result.annualCost),
        'potential': _fmt(result.potentialSavings.abs()),
      },
    );
  }

  static List<String> _categoryBullets(
    PersonalBudgetResult result,
    String locale,
  ) {
    if (result.segments.isEmpty) {
      return [PersonalBudgetStrings.t('pb_breakdown_empty', locale)];
    }
    final total = result.monthlyCost;
    return result.segments.map((seg) {
      final pct = total > 0 ? (seg.amount / total) * 100 : 0.0;
      final label = PersonalBudgetStrings.t(seg.labelKey, locale);
      return '$label: QAR ${_fmt(seg.amount)} (${pct.toStringAsFixed(1)}%)';
    }).toList();
  }

  static String _pressureBody(PersonalBudgetResult result, String locale) {
    if (!result.salarySet) {
      return PersonalBudgetStrings.t('pb_enter_salary', locale);
    }
    return PersonalBudgetStrings.format(
      'pb_report_pressure_body',
      locale,
      params: {
        'percent': result.budgetPressurePercent?.toStringAsFixed(1) ?? '—',
        'band': PersonalBudgetStrings.t(
          pressureBandLabelKey(result.pressureBand),
          locale,
        ),
      },
    );
  }

  static List<String> _recommendations(
    PersonalBudgetResult result,
    String locale,
  ) {
    if (!result.salarySet) {
      return [PersonalBudgetStrings.t('pb_enter_salary', locale)];
    }
    final items = <String>[];
    switch (result.pressureBand) {
      case BudgetPressureBand.comfortable:
        items.add(PersonalBudgetStrings.t('pb_rec_comfortable', locale));
      case BudgetPressureBand.moderate:
        items.add(PersonalBudgetStrings.t('pb_rec_moderate', locale));
      case BudgetPressureBand.high:
        items.add(PersonalBudgetStrings.t('pb_rec_high', locale));
      case BudgetPressureBand.critical:
        items.add(PersonalBudgetStrings.t('pb_rec_critical', locale));
      case BudgetPressureBand.unknown:
        break;
    }
    if (result.potentialSavings < 0) {
      items.add(PersonalBudgetStrings.t('pb_rec_deficit', locale));
    }
    items.add(PersonalBudgetStrings.t('pb_rec_track', locale));
    return items;
  }

  static String _cpiContext(CostOfLivingSnapshot snapshot, String locale) {
    final cpi = snapshot.generalCpi?.toStringAsFixed(2) ?? '—';
    return PersonalBudgetStrings.format(
      'pb_report_cpi_body',
      locale,
      params: {
        'cpi': cpi,
        'date': snapshot.cpiSourceDateLabel,
      },
    );
  }

  static String _fmt(double value) =>
      value == value.roundToDouble()
          ? value.toStringAsFixed(0)
          : value.toStringAsFixed(2);
}
