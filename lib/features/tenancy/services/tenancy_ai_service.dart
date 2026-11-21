import 'package:flutter/foundation.dart';
import 'package:raabta/features/tenancy/data/qatar_tenancy_law_kb.dart';
import 'package:raabta/features/tenancy/domain/models/tenancy_compliance_models.dart';
import 'package:raabta/features/tenancy/domain/models/tenancy_lease_input.dart';
import 'package:raabta/features/tenancy/presentation/l10n/tenancy_strings.dart';
import 'package:raabta/features/truth_engine/domain/truth_package.dart';
import 'package:raabta/services/ai/claude_ai_service.dart';

class TenancyAiReply {
  const TenancyAiReply({required this.text, this.fromFallback = false});

  final String text;
  final bool fromFallback;
}

/// Tenancy legal assistant — Claude with verified-facts-only guardrails.
class TenancyAiService {
  TenancyAiService(this._claude);

  final ClaudeAIService _claude;

  static const requestType = 'tenancy_legal_assistant';

  static const outOfScopeTopics = <String>[];

  @visibleForTesting
  static String buildPrompt({
    required String question,
    required String locale,
    TenancyLeaseInput? input,
    TenancyComplianceResult? result,
  }) {
    final leaseSummary = input == null
        ? null
        : [
            if (input.monthlyRent > 0) 'Monthly rent QAR ${input.monthlyRent.toStringAsFixed(0)}',
            if (input.securityDeposit > 0)
              'Deposit QAR ${input.securityDeposit.toStringAsFixed(0)}',
            if (input.landlordName.isNotEmpty) 'Landlord: ${input.landlordName}',
            'Property: ${input.propertyType.name}',
            'Registered: ${input.registrationStatus?.name ?? 'unknown'}',
          ].join('\n');

    final complianceSummary = result == null
        ? null
        : result.items
            .where((i) =>
                i.status.name == 'critical' || i.status.name == 'violation')
            .map((i) => TenancyStrings.t(i.titleKey, locale))
            .join('; ');

    final registrationUnknown =
        input?.registrationStatus?.name == 'notSure' || input?.registrationStatus == null;

    final package = TruthPackage(
      engineType: TruthPackageCatalog.tenancy,
      facts: {
        if (leaseSummary != null) 'leaseSummary': leaseSummary,
        if (complianceSummary?.isNotEmpty == true)
          'complianceFlags': complianceSummary,
        'userQuestion': question,
      },
      calculation: {
        if (result != null)
          'criticalOrViolationCount': result.items
              .where(
                (i) =>
                    i.status.name == 'critical' || i.status.name == 'violation',
              )
              .length,
      },
      assumptions: TruthPackageCatalog.tenancyAssumptions(
        registrationUnknown: registrationUnknown,
      ),
      unknowns: TruthPackageCatalog.tenancyUnknowns(),
      sourceRefs: TruthPackageCatalog.tenancySourceRefs(),
    );

    return TruthPackagePrompt.build(
      package: package,
      locale: locale,
      preamble: QatarTenancyLawKB.buildAssistantContext(
        locale: locale,
        leaseSummary: leaseSummary,
        complianceSummary:
            complianceSummary?.isNotEmpty == true ? complianceSummary : null,
      ),
      userQuestion: question,
      trailingInstructions: 'Keep answer practical and concise.',
    );
  }

  Future<TenancyAiReply> ask({
    required String question,
    required String locale,
    TenancyLeaseInput? input,
    TenancyComplianceResult? result,
    List<Map<String, String>> conversationHistory = const [],
  }) async {
    final trimmed = question.trim();
    if (trimmed.isEmpty) {
      return TenancyAiReply(
        text: TenancyStrings.t('tenancy_ai_empty_question', locale),
        fromFallback: true,
      );
    }

    final lower = trimmed.toLowerCase();
    if (outOfScopeTopics.any(lower.contains)) {
      return TenancyAiReply(
        text: TenancyStrings.t('tenancy_ai_out_of_scope', locale),
        fromFallback: true,
      );
    }

    final prompt = buildPrompt(
      question: trimmed,
      locale: locale,
      input: input,
      result: result,
    );

    final reply = await _claude.sendMessage(
      prompt,
      language: locale,
      requestType: requestType,
      conversationHistory: conversationHistory,
    );

    if (reply.trim().isEmpty || reply == 'Please try again.') {
      return TenancyAiReply(
        text: TenancyStrings.t('tenancy_ai_unavailable', locale),
        fromFallback: true,
      );
    }

    return TenancyAiReply(text: reply.trim());
  }
}
