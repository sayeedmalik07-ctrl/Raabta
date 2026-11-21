import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/data/raabta_ai_brain.dart';
import 'package:raabta/features/eosb/domain/services/overtime_rounding_pattern_analyzer.dart';
import 'package:raabta/features/eosb/domain/models/overtime_truth_models.dart';
import 'package:raabta/features/eosb/domain/services/eosb_salary_claude_consent.dart';
import 'package:raabta/features/eosb/providers/eosb_providers.dart';
import 'package:raabta/features/eosb/providers/overtime_truth_providers.dart';
import 'package:raabta/features/eosb/services/overtime_review_template_service.dart';
import 'package:raabta/features/truth_engine/domain/truth_package.dart';
import 'package:raabta/services/ai/claude_ai_service.dart';

/// Import failed (AI, network, or unparseable response) — no raw payload attached.
class OvertimeAiImportFailure implements Exception {
  const OvertimeAiImportFailure();
}

/// Claude is used ONLY for overtime document import — not for reviews.
class OvertimeAiService {
  OvertimeAiService(this._claude, this._salaryConsent);

  final ClaudeAIService _claude;
  final EosbSalaryClaudeConsentGuard _salaryConsent;

  static const _importSchema = '''
Return ONLY valid JSON (no markdown):
{
  "employeeName": "string or null",
  "basicSalary": number or null,
  "totalSalary": number or null,
  "workingHoursPerDay": number or null,
  "workingDaysPerWeek": number or null,
  "employerPaidOvertime": number or null,
  "employerReportedHours": number or null,
  "payrollPeriod": "YYYY-MM or null",
  "overtimeEntries": [{"date":"YYYY-MM-DD","hours":number,"category":"regularDay|weeklyRestDay|publicHoliday|nightShift"}],
  "employerShiftEntries": [{"date":"YYYY-MM-DD","startTime":"HH:mm","endTime":"HH:mm"}],
  "confidence": 0.0-1.0,
  "notes": "string"
}''';

  Future<Map<String, dynamic>> extractFromDocument({
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
Extract overtime-relevant payroll fields from facts.documentText.
$_importSchema''',
    );

    try {
      final raw = await _salaryConsent.sendClaudeMessage(
        _claude,
        message: prompt,
        language: language,
        requestType: EosbSalarySensitiveClaudeRequestTypes.eosbOvertimeImport,
      );
      return _parseJson(raw);
    } on EosbSalaryClaudeConsentRequired {
      rethrow;
    } on OvertimeAiImportFailure {
      rethrow;
    } catch (_) {
      throw const OvertimeAiImportFailure();
    }
  }

  @visibleForTesting
  Map<String, dynamic> parseImportJsonResponse(String raw) => _parseJson(raw);

  Map<String, dynamic> _parseJson(String raw) {
    try {
      var text = raw.trim();
      if (text.isEmpty) {
        throw const OvertimeAiImportFailure();
      }
      if (text.startsWith('```')) {
        text = text.replaceFirst(RegExp(r'^```(?:json)?\s*'), '');
        text = text.replaceFirst(RegExp(r'\s*```$'), '');
      }
      final start = text.indexOf('{');
      final end = text.lastIndexOf('}');
      if (start < 0 || end <= start) {
        throw const OvertimeAiImportFailure();
      }
      text = text.substring(start, end + 1);
      final decoded = jsonDecode(text);
      if (decoded is! Map) {
        throw const OvertimeAiImportFailure();
      }
      return Map<String, dynamic>.from(decoded);
    } on OvertimeAiImportFailure {
      rethrow;
    } on FormatException {
      throw const OvertimeAiImportFailure();
    }
  }

  static const requestTypeRoundingExplain = 'eosb_overtime_rounding_explain';

  /// Explain-only — receives aggregated pattern summary, never raw shift rows.
  Future<String> explainRoundingPattern({
    required OvertimeRoundingPatternResult pattern,
    required String locale,
  }) async {
    final package = TruthPackage(
      engineType: TruthPackageCatalog.eosb,
      facts: const {},
      calculation: {
        'dualShiftCount': pattern.dualShiftCount,
        'clockInEmployerFavorCount': pattern.clockInEmployerFavorCount,
        'clockOutEmployerFavorCount': pattern.clockOutEmployerFavorCount,
        'avgClockInLossMinutes': pattern.avgClockInLossMinutes,
        'avgClockOutLossMinutes': pattern.avgClockOutLossMinutes,
        'avgTotalMinutesLostPerShift': pattern.avgTotalMinutesLostPerShift,
        'estimatedQarImpact': pattern.estimatedQarImpact,
        'patternDirection': pattern.direction.name,
        'currency': pattern.currency,
      },
      assumptions: TruthPackageCatalog.eosbOvertimeRoundingAssumptions(),
      unknowns: TruthPackageCatalog.eosbOvertimeRoundingUnknowns(),
      sourceRefs: TruthPackageCatalog.eosbSourceRefs(),
    );

    final reply = await _salaryConsent.sendClaudeMessage(
      _claude,
      message: TruthPackagePrompt.build(
        package: package,
        locale: locale,
        trailingInstructions: '''
- Restate what the calculation numbers mean — do NOT accuse the employer of fraud or theft.
- Do NOT invent shift times, policies, or legal violations not in the package.
- Keep it brief (4–6 sentences).''',
      ),
      language: locale,
      requestType: requestTypeRoundingExplain,
    );

    return reply.trim();
  }

  String _languageCode(String locale) {
    return switch (locale) {
      'Arabic' => 'ar',
      'Hindi' => 'hi',
      'Urdu' => 'ur',
      'Malayalam' => 'ml',
      'Nepali' => 'ne',
      'Bengali' => 'bn',
      _ => 'en',
    };
  }
}

final overtimeAiServiceProvider = Provider<OvertimeAiService>((ref) {
  return OvertimeAiService(
    ref.watch(claudeAIServiceProvider),
    ref.watch(eosbSalaryClaudeConsentGuardProvider),
  );
});

class OvertimeAiReviewRequest {
  const OvertimeAiReviewRequest({this.forceRegenerate = false});

  final bool forceRegenerate;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OvertimeAiReviewRequest &&
          forceRegenerate == other.forceRegenerate;

  @override
  int get hashCode => forceRegenerate.hashCode;
}

final overtimeReviewTemplateProvider = Provider(
  (_) => const OvertimeReviewTemplateService(),
);

final overtimeAiReviewProvider =
    Provider.family<OvertimeAiReview?, OvertimeAiReviewRequest>((ref, request) {
      final localeAsync = ref.watch(eosbLocaleProvider);
      final result = ref.watch(overtimeTruthProvider).result;
      final locale = localeAsync.valueOrNull ?? 'English';

      if (result == null) return null;

      return ref
          .watch(overtimeReviewTemplateProvider)
          .generate(result: result, locale: locale);
    });
