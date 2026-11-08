import 'package:raabta/features/case_timeline/data/checklist/eosb_dispute_checklist_catalog.dart';
import 'package:raabta/features/eosb/domain/models/eosb_contract_analysis.dart';
import 'package:raabta/features/eosb/domain/models/eosb_employee_input.dart';
import 'package:raabta/features/eosb/domain/models/eosb_enums.dart';
import 'package:raabta/features/eosb/domain/models/eosb_result.dart';
import 'package:raabta/features/eosb/presentation/l10n/eosb_strings.dart';
import 'package:raabta/features/eosb/services/eosb_explanation_template_service.dart';

/// Deterministic structured legal review — same shape as former Claude output.
class EosbLegalReviewTemplateService {
  const EosbLegalReviewTemplateService();

  EosbLegalReview generate({
    required EosbEmployeeInput input,
    required EosbResult result,
    required String locale,
    EosbContractAnalysis? contractAnalysis,
  }) {
    final assistant = EosbExplanationTemplateService();
    final summary = assistant.generate(
      input: input,
      result: result,
      locale: locale,
    );

    final missingBenefits = <String>[];
    final possibleUnderpayments = <String>[];
    final labourLawIssues = <String>[];
    final contractRisks = <String>[];
    final illegalClauses = <String>[];
    final nextSteps = <String>[];
    final negotiationAdvice = <String>[];
    final requiredDocuments = <String>[];
    final deadlines = <String>[];

    for (final v in result.violations) {
      labourLawIssues.add(
        '${EosbStrings.t(v.titleKey, locale)}: '
        '${EosbStrings.t(v.explanationKey, locale)}',
      );
    }

    for (final w in result.warnings) {
      if (w.severity == EosbWarningSeverity.violation ||
          w.severity == EosbWarningSeverity.critical) {
        labourLawIssues.add(
          '${EosbStrings.t(w.titleKey, locale)}: '
          '${EosbStrings.t(w.explanationKey, locale)}',
        );
      } else {
        contractRisks.add(
          '${EosbStrings.t(w.titleKey, locale)}: '
          '${EosbStrings.t(w.explanationKey, locale)}',
        );
      }
    }

    final comparison = result.comparison;
    if (comparison != null && comparison.isUnderpaid) {
      for (final d in comparison.disputes) {
        possibleUnderpayments.add(
          '${EosbStrings.t(d.issueKey, locale)} — '
          '${EosbStrings.t('eosb_difference', locale)} '
          '${formatEosbCurrency(d.amountGap)}',
        );
      }
      nextSteps.addAll(
        comparison.suggestedStepsKeys
            .map((k) => EosbStrings.t(k, locale)),
      );
      negotiationAdvice.add(EosbStrings.t('eosb_step_compare_document', locale));
      negotiationAdvice.add(EosbStrings.t('eosb_step_compare_hr', locale));
    } else if (comparison != null) {
      nextSteps.add(EosbStrings.t('eosb_step_compare_fair', locale));
    }

    if (contractAnalysis != null) {
      missingBenefits.addAll(contractAnalysis.missingBenefits);
      illegalClauses.addAll(contractAnalysis.illegalClauses);
      contractRisks.addAll(contractAnalysis.warnings);
    }

    if (nextSteps.isEmpty) {
      nextSteps.add(EosbStrings.t('eosb_step_compare_hr', locale));
      nextSteps.add(EosbStrings.t('eosb_step_compare_adlsa', locale));
    }

    requiredDocuments.addAll(
      EosbDisputeChecklistCatalog.items(
        includeSettlement: comparison != null,
      ).map((item) => EosbStrings.t(item.titleKey, locale)),
    );

    return EosbLegalReview(
      summary: summary.split('\n\n').first,
      missingBenefits: missingBenefits,
      possibleUnderpayments: possibleUnderpayments,
      labourLawIssues: labourLawIssues,
      contractRisks: contractRisks,
      illegalClauses: illegalClauses,
      nextSteps: nextSteps,
      negotiationAdvice: negotiationAdvice,
      requiredDocuments: requiredDocuments,
      deadlines: deadlines,
    );
  }
}
