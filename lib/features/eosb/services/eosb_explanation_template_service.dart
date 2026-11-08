import 'package:raabta/features/eosb/domain/models/eosb_structured_explanation.dart';
import 'package:raabta/features/eosb/domain/models/eosb_employee_input.dart';
import 'package:raabta/features/eosb/domain/models/eosb_enums.dart';
import 'package:raabta/features/eosb/domain/models/eosb_result.dart';
import 'package:raabta/features/eosb/domain/rules/dismissal_dispute_assessment.dart';
import 'package:raabta/features/eosb/presentation/l10n/eosb_strings.dart';

/// Deterministic plain-language EOSB explanation — no Claude, no network.
class EosbExplanationTemplateService {
  const EosbExplanationTemplateService();

  String generate({
    required EosbEmployeeInput input,
    required EosbResult result,
    required String locale,
    String? userQuestion,
  }) {
    if (userQuestion != null && userQuestion.trim().isNotEmpty) {
      if (_isDismissalDisputeQuestion(userQuestion)) {
        return EosbStrings.t('tpl_eosb_art62_explanation', locale);
      }
      return EosbStrings.t('tpl_eosb_followup', locale);
    }

    final blocks = <String>[
      _opening(input, result, locale),
      ..._componentBlocks(result, locale),
      ..._violationBlocks(result, locale),
      ..._warningBlocks(result, locale),
      ..._comparisonBlocks(result, locale),
      _nextSteps(result, locale),
    ].where((b) => b.trim().isNotEmpty);

    return blocks.join('\n\n');
  }

  EosbStructuredExplanation buildStructured({
    required EosbEmployeeInput input,
    required EosbResult result,
    required String locale,
  }) {
    final risks = <EosbAiInsightCard>[];
    if (DismissalDisputeAssessment.evaluate(input) ==
        EosbDismissalReviewOutcome.factsWorthReviewing) {
      risks.add(
        EosbAiInsightCard(
          title: EosbStrings.t('eosb_art62_result_section_title', locale),
          body: EosbStrings.t('eosb_dismissal_review_art64_info', locale),
        ),
      );
    }
    risks.addAll([
      ...result.violations.map(
        (v) => EosbAiInsightCard(
          title: EosbStrings.t(v.titleKey, locale),
          body: EosbStrings.t(v.explanationKey, locale),
          isCritical: true,
        ),
      ),
      ...result.warnings.map(
        (w) => EosbAiInsightCard(
          title: EosbStrings.t(w.titleKey, locale),
          body: EosbStrings.t(w.explanationKey, locale),
        ),
      ),
    ]);

    final comparison = result.comparison;
    if (comparison != null && comparison.isUnderpaid) {
      risks.insert(
        0,
        EosbAiInsightCard(
          title: EosbStrings.t('eosb_status_underpayment', locale),
          body: EosbStrings.t('tpl_eosb_compare_under', locale)
              .replaceAll('{offer}', formatEosbCurrency(comparison.employerOffer))
              .replaceAll('{estimate}', formatEosbCurrency(comparison.legalEstimate))
              .replaceAll('{delta}', formatEosbCurrency(comparison.difference))
              .replaceAll('{percent}', comparison.differencePercent.toStringAsFixed(1)),
          isCritical: true,
        ),
      );
    }

    final nextSteps = <String>[];
    if (comparison != null && comparison.isUnderpaid) {
      for (final key in comparison.suggestedStepsKeys) {
        nextSteps.add(EosbStrings.t(key, locale));
      }
    } else if (result.violations.isNotEmpty || result.warnings.isNotEmpty) {
      nextSteps.add(EosbStrings.t('eosb_step_compare_hr', locale));
      nextSteps.add(EosbStrings.t('eosb_step_compare_adlsa', locale));
    } else if (comparison != null) {
      nextSteps.add(EosbStrings.t('eosb_step_compare_fair', locale));
    } else {
      nextSteps.add(EosbStrings.t('eosb_step_compare_hr', locale));
    }

    return EosbStructuredExplanation(
      summary: _opening(input, result, locale),
      risks: risks,
      nextSteps: nextSteps,
    );
  }

  String _opening(
    EosbEmployeeInput input,
    EosbResult result,
    String locale,
  ) {
    return _fmt(
      'tpl_eosb_opening',
      locale,
      {
        'total': formatEosbCurrency(result.totalEntitlement),
        'years': input.serviceYears.toStringAsFixed(1),
        'contract': _contractLabel(input.contractType, locale),
        'termination': _terminationLabel(input.terminationType, locale),
      },
    );
  }

  List<String> _componentBlocks(EosbResult result, String locale) {
    return result.breakdown
        .where((item) => item.amount > 0)
        .map(
          (item) => _fmt(
            'tpl_eosb_component',
            locale,
            {
              'name': EosbStrings.t(item.titleKey, locale),
              'amount': formatEosbCurrency(item.amount),
              'rule': EosbStrings.t(item.ruleKey, locale),
              'formula': EosbStrings.t(item.formulaKey, locale),
            },
          ),
        )
        .toList();
  }

  List<String> _violationBlocks(EosbResult result, String locale) {
    return result.violations
        .map(
          (v) => _fmt(
            'tpl_eosb_violation',
            locale,
            {
              'title': EosbStrings.t(v.titleKey, locale),
              'explanation': EosbStrings.t(v.explanationKey, locale),
              'risk': EosbStrings.t(v.riskLevelKey, locale),
            },
          ),
        )
        .toList();
  }

  List<String> _warningBlocks(EosbResult result, String locale) {
    return result.warnings
        .map(
          (w) => _fmt(
            'tpl_eosb_warning',
            locale,
            {
              'title': EosbStrings.t(w.titleKey, locale),
              'explanation': EosbStrings.t(w.explanationKey, locale),
            },
          ),
        )
        .toList();
  }

  List<String> _comparisonBlocks(EosbResult result, String locale) {
    final comparison = result.comparison;
    if (comparison == null) return const [];

    final blocks = <String>[];
    if (comparison.isUnderpaid) {
      blocks.add(
        _fmt(
          'tpl_eosb_compare_under',
          locale,
          {
            'offer': formatEosbCurrency(comparison.employerOffer),
            'estimate': formatEosbCurrency(comparison.legalEstimate),
            'delta': formatEosbCurrency(comparison.difference),
            'percent': comparison.differencePercent.toStringAsFixed(1),
          },
        ),
      );
    } else if (comparison.difference.abs() < 500) {
      blocks.add(
        _fmt(
          'tpl_eosb_compare_match',
          locale,
          {
            'offer': formatEosbCurrency(comparison.employerOffer),
            'estimate': formatEosbCurrency(comparison.legalEstimate),
          },
        ),
      );
    } else {
      blocks.add(
        _fmt(
          'tpl_eosb_compare_over',
          locale,
          {
            'offer': formatEosbCurrency(comparison.employerOffer),
            'estimate': formatEosbCurrency(comparison.legalEstimate),
            'delta': formatEosbCurrency(comparison.difference.abs()),
          },
        ),
      );
    }

    for (final dispute in comparison.disputes) {
      blocks.add(
        _fmt(
          'tpl_eosb_dispute',
          locale,
          {
            'item': EosbStrings.t(dispute.issueKey, locale),
            'gap': formatEosbCurrency(dispute.amountGap),
            'rule': EosbStrings.t(dispute.ruleKey, locale),
          },
        ),
      );
    }
    return blocks;
  }

  String _nextSteps(EosbResult result, String locale) {
    final steps = <String>[];
    final comparison = result.comparison;

    if (comparison != null && comparison.isUnderpaid) {
      for (final key in comparison.suggestedStepsKeys) {
        steps.add('• ${EosbStrings.t(key, locale)}');
      }
    } else if (result.violations.isNotEmpty || result.warnings.isNotEmpty) {
      steps.add('• ${EosbStrings.t('eosb_step_compare_hr', locale)}');
      steps.add('• ${EosbStrings.t('eosb_step_compare_adlsa', locale)}');
    } else if (comparison != null) {
      steps.add('• ${EosbStrings.t('eosb_step_compare_fair', locale)}');
    } else {
      steps.add('• ${EosbStrings.t('eosb_step_compare_hr', locale)}');
    }

    if (steps.isEmpty) return '';
    return '${EosbStrings.t('eosb_next_steps', locale)}\n${steps.join('\n')}';
  }

  String _contractLabel(EosbContractType type, String locale) {
    return switch (type) {
      EosbContractType.unlimited =>
        EosbStrings.t('tpl_eosb_contract_unlimited', locale),
      EosbContractType.limited =>
        EosbStrings.t('tpl_eosb_contract_limited', locale),
    };
  }

  String _terminationLabel(EosbTerminationType type, String locale) {
    return EosbStrings.t('tpl_eosb_term_${type.name}', locale);
  }

  String _fmt(
    String key,
    String locale,
    Map<String, String> params,
  ) {
    var text = EosbStrings.t(key, locale);
    params.forEach((k, v) {
      text = text.replaceAll('{$k}', v);
    });
    return text;
  }

  bool _isDismissalDisputeQuestion(String question) {
    final q = question.toLowerCase();
    const keywords = [
      'article 61',
      'art 61',
      'art. 61',
      'article 62',
      'art 62',
      'art. 62',
      'article 64',
      'art 64',
      'art. 64',
      'arbitrary dismissal',
      'wrongful dismissal',
      'unfair dismissal',
      'illegal dismissal',
      'dismissal dispute',
      'disciplinary procedure',
      'المادة 61',
      'المادة 62',
      'المادة 64',
      'فصل تعسفي',
      'إجراء تأديبي',
      'نزاع فصل',
    ];
    return keywords.any(q.contains);
  }
}
