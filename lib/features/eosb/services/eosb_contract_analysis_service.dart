import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:raabta/data/raabta_ai_brain.dart';
import 'package:raabta/features/eosb/domain/models/eosb_contract_analysis.dart';
import 'package:raabta/features/eosb/domain/services/eosb_salary_claude_consent.dart';
import 'package:raabta/features/eosb/domain/models/eosb_employee_input.dart';
import 'package:raabta/features/eosb/domain/models/eosb_enums.dart';
import 'package:raabta/features/truth_engine/domain/truth_package.dart';
import 'package:raabta/services/ai/claude_ai_service.dart';

/// Stable key when Claude JSON could not be parsed — localize in UI.
const eosbContractAiParseWarningKey = 'eosb_contract_ai_parse_warning';

/// AI-powered contract analysis — structured JSON only.
class EosbContractAnalysisService {
  EosbContractAnalysisService(this._claude, this._salaryConsent);

  final ClaudeAIService _claude;
  final EosbSalaryClaudeConsentGuard _salaryConsent;

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

  Future<EosbContractAnalysis> analyzeDocumentText({
    required String documentText,
    required String documentKind,
    required String language,
  }) async {
    final langCode = _languageCode(language);
    final package = TruthPackage(
      engineType: TruthPackageCatalog.eosb,
      facts: {'documentKind': documentKind, 'documentText': documentText},
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

    final raw = await _salaryConsent.sendClaudeMessage(
      _claude,
      message: prompt,
      language: language,
      requestType: EosbSalarySensitiveClaudeRequestTypes.eosbContractAnalysis,
    );

    return parseContractAnalysisResponse(raw);
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

  @visibleForTesting
  EosbContractAnalysis parseContractAnalysisResponse(String raw) {
    try {
      final json = _extractJson(raw);
      return EosbContractAnalysis.fromJson(json);
    } catch (_) {
      return EosbContractAnalysis(
        warnings: const [eosbContractAiParseWarningKey],
        rawSummary: raw.length > 500 ? raw.substring(0, 500) : raw,
      );
    }
  }

  Map<String, dynamic> _extractJson(String raw) {
    final clean = raw.replaceAll('```json', '').replaceAll('```', '').trim();
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
