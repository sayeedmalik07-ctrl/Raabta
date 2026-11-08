import 'dart:convert';

import 'package:raabta/features/health_insurance/data/models/compliance_check_model.dart';
import 'package:raabta/features/health_insurance/data/models/insurance_policy_model.dart';
import 'package:raabta/features/health_insurance/presentation/l10n/health_insurance_strings.dart';
import 'package:raabta/features/truth_engine/domain/truth_package.dart';
import 'package:raabta/services/ai/claude_ai_service.dart';

/// Template-based plain-language explanations for compliance results (no legal advice).
class HealthInsuranceExplanationService {
  const HealthInsuranceExplanationService();

  String explainItem(ComplianceCheckItem item, String locale) {
    final title = HealthInsuranceStrings.t(item.titleKey, locale);
    final body = HealthInsuranceStrings.t(item.explanationKey, locale);
    final action = HealthInsuranceStrings.t(item.actionKey, locale);
    return '$title\n\n$body\n\n$action';
  }

  String buildResultsOverview(ComplianceCheckResult result, String locale) {
    if (result.isExemptSession) {
      return HealthInsuranceStrings.t('hi_results_overview_exempt', locale);
    }
    final violations = result.items
        .where((i) => i.status.name == 'violation')
        .length;
    if (violations == 0 && result.allCompliant) {
      return HealthInsuranceStrings.t('hi_results_overview_pass', locale);
    }
    if (violations > 0) {
      return HealthInsuranceStrings.t('hi_results_overview_violations', locale)
          .replaceAll('{count}', violations.toString());
    }
    return HealthInsuranceStrings.t('hi_results_overview_review', locale);
  }
}

/// Document-based policy explainer — Claude explain-only, never invents coverage.
class HealthInsurancePolicyExplainerService {
  HealthInsurancePolicyExplainerService(this._ai);

  final ClaudeAIService _ai;

  static const requestType = 'health_insurance_policy_explainer';

  Future<PolicyExplainerResult> explainPolicy({
    required InsurancePolicyDocument document,
    required String locale,
    String? userId,
  }) async {
    if (!document.hasExtractableText) {
      return PolicyExplainerResult(
        summary: '',
        coverageCategories: const [],
        exclusions: const [],
        networkNotes: const [],
        ambiguityNotes: const [
          'Document text could not be read. Try re-scanning with better lighting.',
        ],
        disclaimerKey: 'hi_policy_explainer_disclaimer',
        sourceDocumentId: document.documentId,
      );
    }

    final reply = await _ai.sendMessage(
      _buildPrompt(document.ocrText, locale),
      language: locale,
      requestType: requestType,
    );

    if (reply.trim().isEmpty || reply == 'Please try again.') {
      return _fallbackFromOcr(document);
    }

    return _parseAiResponse(reply, document.documentId);
  }

  String _buildPrompt(String ocrText, String locale) {
    final package = TruthPackage(
      engineType: TruthPackageCatalog.healthInsurance,
      facts: {'documentOcrText': ocrText},
      calculation: const {},
      assumptions: TruthPackageCatalog.healthInsurancePolicyAssumptions(),
      unknowns: TruthPackageCatalog.healthInsurancePolicyUnknowns(),
      sourceRefs: TruthPackageCatalog.healthInsurancePolicySourceRefs(),
    );

    return TruthPackagePrompt.build(
      package: package,
      locale: locale,
      trailingInstructions: '''
STRICT RULES:
- Extract and rephrase ONLY what appears in the document OCR text in facts.documentOcrText.
- Do NOT invent coverage amounts, maternity caps, procedure limits, or minimum legal baselines.
- Do NOT give medical advice, diagnoses, or treatment recommendations.
- Return JSON only with keys: summary, coverageCategories (array), exclusions (array), networkNotes (array), ambiguityNotes (array).''',
    );
  }

  PolicyExplainerResult _parseAiResponse(String reply, String docId) {
    try {
      final start = reply.indexOf('{');
      final end = reply.lastIndexOf('}');
      if (start < 0 || end <= start) {
        return PolicyExplainerResult(
          summary: reply.trim(),
          coverageCategories: const [],
          exclusions: const [],
          networkNotes: const [],
          ambiguityNotes: const [],
          disclaimerKey: 'hi_policy_explainer_disclaimer',
          sourceDocumentId: docId,
        );
      }
      final jsonStr = reply.substring(start, end + 1);
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      return PolicyExplainerResult(
        summary: map['summary']?.toString() ?? '',
        coverageCategories: _stringList(map['coverageCategories']),
        exclusions: _stringList(map['exclusions']),
        networkNotes: _stringList(map['networkNotes']),
        ambiguityNotes: _stringList(map['ambiguityNotes']),
        disclaimerKey: 'hi_policy_explainer_disclaimer',
        sourceDocumentId: docId,
      );
    } catch (_) {
      return PolicyExplainerResult(
        summary: reply.trim(),
        coverageCategories: const [],
        exclusions: const [],
        networkNotes: const [],
        ambiguityNotes: const [
          'Could not structure the summary automatically. Review the raw text below.',
        ],
        disclaimerKey: 'hi_policy_explainer_disclaimer',
        sourceDocumentId: docId,
      );
    }
  }

  List<String> _stringList(Object? value) {
    if (value is! List) return [];
    return value.map((e) => e.toString()).where((s) => s.isNotEmpty).toList();
  }

  PolicyExplainerResult _fallbackFromOcr(InsurancePolicyDocument document) {
    final preview = document.ocrText.length > 600
        ? '${document.ocrText.substring(0, 600)}…'
        : document.ocrText;
    return PolicyExplainerResult(
      summary: preview,
      coverageCategories: const [],
      exclusions: const [],
      networkNotes: const [],
      ambiguityNotes: const [
        'AI summary unavailable — showing extracted document text only.',
      ],
      disclaimerKey: 'hi_policy_explainer_disclaimer',
      sourceDocumentId: document.documentId,
    );
  }
}
