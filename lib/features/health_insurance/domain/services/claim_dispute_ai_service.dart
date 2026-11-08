import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/features/health_insurance/data/claim_dispute_step_catalog.dart';
import 'package:raabta/features/health_insurance/data/models/claim_dispute_models.dart';
import 'package:raabta/features/health_insurance/domain/models/insurer_regulatory_body.dart';
import 'package:raabta/features/health_insurance/presentation/l10n/health_insurance_strings.dart';
import 'package:raabta/features/truth_engine/domain/truth_package.dart';
import 'package:raabta/services/ai/claude_ai_service.dart';

/// AI assistant for claim denial disputes — explain-only + constrained letter draft.
class ClaimDisputeAiService {
  ClaimDisputeAiService(this._ref);

  final Ref _ref;

  static const requestTypeExplain = 'health_insurance_claim_dispute_explain';
  static const requestTypeClause = 'health_insurance_claim_dispute_clause';
  static const requestTypeLetter = 'health_insurance_claim_dispute_letter';

  ClaudeAIService get _ai => _ref.read(claudeAIServiceProvider);

  Future<String> explainStep({
    required String stepId,
    required String locale,
  }) async {
    ClaimDisputeStepDef? matched;
    for (final s in ClaimDisputeStepCatalog.all) {
      if (s.id == stepId) {
        matched = s;
        break;
      }
    }
    if (matched == null) return '';
    final step = matched;

    final title = HealthInsuranceStrings.t(step.titleKey, locale);
    final body = HealthInsuranceStrings.t(step.descriptionKey, locale);
    final citation = step.citationKey != null
        ? HealthInsuranceStrings.t(step.citationKey!, locale)
        : '';

    final package = TruthPackage(
      engineType: TruthPackageCatalog.healthInsurance,
      facts: {
        'stepId': stepId,
        'stepTitle': title,
        'stepText': body,
        if (citation.isNotEmpty) 'citation': citation,
      },
      calculation: const {},
      assumptions: TruthPackageCatalog.healthInsuranceDisputeAssumptions(),
      unknowns: TruthPackageCatalog.healthInsuranceDisputeUnknowns(),
      sourceRefs: TruthPackageCatalog.healthInsuranceDisputeSourceRefs(),
    );

    final reply = await _ai.sendMessage(
      TruthPackagePrompt.build(
        package: package,
        locale: locale,
        trailingInstructions: '''
- Restate what the step means — do NOT add new steps, deadlines, or legal arguments.
- Do NOT predict outcomes or recommend hospitals, doctors, or lawyers.
- Keep it brief (3–5 sentences).''',
      ),
      language: locale,
      requestType: requestTypeExplain,
    );

    return _withDisclaimer(reply.trim(), locale);
  }

  Future<String> explainClause({
    required String clauseText,
    required String locale,
  }) async {
    if (clauseText.trim().isEmpty) {
      return HealthInsuranceStrings.t('hi_denial_clause_empty', locale);
    }

    final package = TruthPackage(
      engineType: TruthPackageCatalog.healthInsurance,
      facts: {'clauseText': clauseText},
      calculation: const {},
      assumptions: TruthPackageCatalog.healthInsuranceDisputeAssumptions(),
      unknowns: TruthPackageCatalog.healthInsuranceDisputeUnknowns(),
      sourceRefs: TruthPackageCatalog.healthInsuranceDisputeSourceRefs(),
    );

    final reply = await _ai.sendMessage(
      TruthPackagePrompt.build(
        package: package,
        locale: locale,
        trailingInstructions: '''
- Restate ONLY what the clause text says — never invent coverage interpretations.
- Do NOT give medical or legal advice.
- Do NOT predict whether a claim will succeed.''',
      ),
      language: locale,
      requestType: requestTypeClause,
    );

    return _withDisclaimer(reply.trim(), locale);
  }

  Future<String> draftLetter({
    required HealthInsuranceClaimDispute dispute,
    required String locale,
    required bool toRegulator,
    String? policyClauseText,
  }) async {
    final reasonLabel =
        HealthInsuranceStrings.t(dispute.denialReason.labelKey, locale);
    final otherReason = dispute.denialReason == ClaimDenialReasonCategory.other
        ? (dispute.denialReasonOtherText ?? '')
        : '';
    final denialDate = dispute.denialDate != null
        ? dispute.denialDate!.toIso8601String().split('T').first
        : '';
    final recipient = toRegulator
        ? (dispute.regulatoryBody == InsurerRegulatoryBody.qfcra
            ? 'QFCRA Customer Dispute Resolution Scheme (CDRS)'
            : 'Qatar Central Bank Customer Protection Department')
        : '${dispute.insurerName} Complaints Department';

    final package = TruthPackage(
      engineType: TruthPackageCatalog.healthInsurance,
      facts: {
        'recipient': recipient,
        'insurerName': dispute.insurerName,
        'denialReasonCategory': reasonLabel,
        if (otherReason.isNotEmpty) 'otherReason': otherReason,
        if (denialDate.isNotEmpty) 'denialDate': denialDate,
        if (dispute.policyNumber?.isNotEmpty == true)
          'policyNumber': dispute.policyNumber,
        if (dispute.claimAmount?.isNotEmpty == true)
          'claimAmount': dispute.claimAmount,
        if (policyClauseText?.trim().isNotEmpty == true)
          'policyClauseText': policyClauseText!.trim(),
      },
      calculation: const {},
      assumptions: TruthPackageCatalog.healthInsuranceDisputeAssumptions(),
      unknowns: TruthPackageCatalog.healthInsuranceDisputeUnknowns(),
      sourceRefs: TruthPackageCatalog.healthInsuranceDisputeSourceRefs(),
    );

    const letterFooter =
        'Drafted from the information you provided. Review carefully before sending — you are responsible for its accuracy.';

    final reply = await _ai.sendMessage(
      TruthPackagePrompt.build(
        package: package,
        locale: locale,
        trailingInstructions: '''
Draft a formal complaint/appeal letter using ONLY facts in the TruthPackage.
- Include ONLY those facts — never invent clinical arguments or medical guidelines.
- You may name QCB Law No. 13 of 2012 / Article 190 or QFCRA CDRS by name only.
- Request a factual review — do NOT predict outcomes.
- End the letter body with this exact footer on its own line:
"$letterFooter"
- Formal business letter format with date placeholder [Date], addressee, subject, body, closing.''',
      ),
      language: locale,
      requestType: requestTypeLetter,
    );

    final letter = reply.trim();
    const footer =
        'Drafted from the information you provided. Review carefully before sending — you are responsible for its accuracy.';
    if (!letter.contains(footer)) {
      return '$letter\n\n$footer';
    }
    return letter;
  }

  String _withDisclaimer(String body, String locale) {
    final disclaimer =
        HealthInsuranceStrings.t('hi_denial_ai_disclaimer', locale);
    return '$disclaimer\n\n$body';
  }
}
