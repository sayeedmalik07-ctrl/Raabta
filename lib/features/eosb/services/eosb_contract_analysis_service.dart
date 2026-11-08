import 'dart:convert';

import 'package:raabta/data/raabta_ai_brain.dart';
import 'package:raabta/features/eosb/domain/models/eosb_contract_analysis.dart';
import 'package:raabta/features/eosb/domain/models/eosb_employee_input.dart';
import 'package:raabta/features/eosb/domain/models/eosb_enums.dart';
import 'package:raabta/features/eosb/domain/models/eosb_result.dart';
import 'package:raabta/features/truth_engine/domain/truth_package.dart';
import 'package:raabta/services/ai/claude_ai_service.dart';

/// AI-powered contract analysis and legal review — structured JSON only.
class EosbContractAnalysisService {
  EosbContractAnalysisService(this._claude);

  final ClaudeAIService _claude;

  static const _contractSchema = '''
Return ONLY valid JSON (no markdown):
{
  "joiningDate": "YYYY-MM-DD or null",
  "basicSalary": number or null,
  "totalSalary": number or null,
  "housingAllowance": number or null,
  "transportAllowance": number or null,
  "foodAllowance": number or null,
  "noticePeriodDays": number or null,
  "leavePolicyDays": number or null,
  "contractType": "unlimited|limited|null",
  "eosbClauseSummary": "string",
  "ticketPolicy": "string",
  "bonusPolicy": "string",
  "illegalClauses": ["string"],
  "missingBenefits": ["string"],
  "warnings": ["string"],
  "confidence": 0.0-1.0,
  "summary": "2 sentence plain-language summary"
}''';

  static const _legalReviewSchema = '''
Return ONLY valid JSON (no markdown):
{
  "summary": "2 sentences",
  "missingBenefits": ["string"],
  "possibleUnderpayments": ["string"],
  "labourLawIssues": ["string — cite Qatar Labour Law where relevant"],
  "contractRisks": ["string"],
  "illegalClauses": ["string"],
  "nextSteps": ["string"],
  "negotiationAdvice": ["string"],
  "requiredDocuments": ["string"],
  "deadlines": ["string"]
}
Always distinguish: labour law vs contract vs company policy. Not formal legal advice.''';

  Future<EosbContractAnalysis> analyzeDocumentText({
    required String documentText,
    required String documentKind,
    required String language,
  }) async {
    final langCode = _languageCode(language);
    final package = TruthPackage(
      engineType: TruthPackageCatalog.eosb,
      facts: {
        'documentKind': documentKind,
        'documentText': documentText,
      },
      calculation: const {},
      assumptions: TruthPackageCatalog.eosbAssumptions(),
      unknowns: TruthPackageCatalog.eosbUnknowns(),
      sourceRefs: TruthPackageCatalog.eosbSourceRefs(),
    );

    final prompt = TruthPackagePrompt.build(
      package: package,
      locale: language,
      preamble: RaabtaAIBrain.buildLabourExpertContext(
        userLanguageCode: langCode,
        message: documentText,
      ),
      trailingInstructions: '''
Analyze the employment document in facts.documentText for End of Service Benefits field extraction.
Flag illegal or non-compliant clauses under Qatar Labour Law.
$_contractSchema''',
    );

    final raw = await _claude.sendMessage(
      prompt,
      language: language,
      requestType: 'eosb_contract_analysis',
    );

    return _parseContractAnalysis(raw);
  }

  Future<EosbLegalReview> generateLegalReview({
    required EosbResult result,
    required EosbEmployeeInput input,
    required String language,
    EosbContractAnalysis? contractAnalysis,
  }) async {
    final breakdown = result.breakdown
        .map((b) => '${b.titleKey}: QAR ${b.amount.toStringAsFixed(0)}')
        .join('\n');

    final comparison = result.comparison;
    final comparisonText = comparison == null
        ? 'No employer offer entered.'
        : 'Employer offer QAR ${comparison.employerOffer.toStringAsFixed(0)} vs '
            'estimate QAR ${comparison.legalEstimate.toStringAsFixed(0)} '
            '(difference QAR ${comparison.difference.toStringAsFixed(0)}).';

    final contractText = contractAnalysis == null
        ? ''
        : 'Contract analysis warnings: ${contractAnalysis.warnings.join('; ')}';

    final langCode = _languageCode(language);
    final package = TruthPackage(
      engineType: TruthPackageCatalog.eosb,
      facts: {
        'serviceYears': input.serviceYears,
        'terminationType': input.terminationType.name,
        if (contractAnalysis != null)
          'contractWarnings': contractAnalysis.warnings,
      },
      calculation: {
        'totalEntitlementQar': result.totalEntitlement,
        'breakdownLines': breakdown,
        'employerComparison': comparisonText,
        if (contractText.isNotEmpty) 'contractAnalysis': contractText,
      },
      assumptions: TruthPackageCatalog.eosbAssumptions(),
      unknowns: TruthPackageCatalog.eosbUnknowns(),
      sourceRefs: TruthPackageCatalog.eosbSourceRefs(),
    );

    final prompt = TruthPackagePrompt.build(
      package: package,
      locale: language,
      preamble: RaabtaAIBrain.buildLabourExpertContext(
        userLanguageCode: langCode,
        message: 'end of service gratuity termination ${input.terminationType.name}',
      ),
      trailingInstructions: '''
Provide educational guidance — NOT formal legal advice.
$_legalReviewSchema''',
    );

    final raw = await _claude.sendMessage(
      prompt,
      language: language,
      requestType: 'eosb_legal_review',
    );

    return _parseLegalReview(raw);
  }

  EosbEmployeeInput applyAnalysisToInput(
    EosbEmployeeInput current,
    EosbContractAnalysis analysis,
  ) {
    EosbContractType? contractType;
    if (analysis.contractType?.toLowerCase() == 'limited') {
      contractType = EosbContractType.limited;
    } else if (analysis.contractType?.toLowerCase() == 'unlimited') {
      contractType = EosbContractType.unlimited;
    }

    return current.copyWith(
      joiningDate: analysis.joiningDate ?? current.joiningDate,
      basicSalary: analysis.basicSalary ?? current.basicSalary,
      totalSalary: analysis.totalSalary ?? current.totalSalary,
      housingAllowance: analysis.housingAllowance ?? current.housingAllowance,
      transportAllowance:
          analysis.transportAllowance ?? current.transportAllowance,
      foodAllowance: analysis.foodAllowance ?? current.foodAllowance,
      contractType: contractType ?? current.contractType,
    );
  }

  EosbContractAnalysis _parseContractAnalysis(String raw) {
    try {
      final json = _extractJson(raw);
      return EosbContractAnalysis.fromJson(json);
    } catch (_) {
      return EosbContractAnalysis(
        warnings: const ['Could not parse AI response — enter details manually.'],
        rawSummary: raw.length > 500 ? raw.substring(0, 500) : raw,
      );
    }
  }

  EosbLegalReview _parseLegalReview(String raw) {
    try {
      final json = _extractJson(raw);
      return EosbLegalReview.fromJson(json);
    } catch (_) {
      return EosbLegalReview(
        summary: raw,
        nextSteps: const ['Consult MoL hotline 16505 or mol.gov.qa for official guidance.'],
      );
    }
  }

  Map<String, dynamic> _extractJson(String raw) {
    final clean = raw
        .replaceAll('```json', '')
        .replaceAll('```', '')
        .trim();
    final start = clean.indexOf('{');
    final end = clean.lastIndexOf('}');
    if (start == -1 || end == -1) {
      throw const FormatException('No JSON object');
    }
    return jsonDecode(clean.substring(start, end + 1)) as Map<String, dynamic>;
  }

  String _languageCode(String locale) {
    switch (locale) {
      case 'Arabic':
        return 'ar';
      case 'Hindi':
        return 'hi';
      case 'Urdu':
        return 'ur';
      case 'Malayalam':
        return 'ml';
      case 'Nepali':
        return 'ne';
      case 'Bengali':
        return 'bn';
      default:
        return 'en';
    }
  }
}
