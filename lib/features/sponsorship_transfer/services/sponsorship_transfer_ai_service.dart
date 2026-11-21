import 'package:flutter/foundation.dart';
import 'package:raabta/features/sponsorship_transfer/data/qatar_sponsorship_transfer_kb.dart';
import 'package:raabta/features/sponsorship_transfer/domain/models/transfer_readiness_input.dart';
import 'package:raabta/features/sponsorship_transfer/domain/models/transfer_readiness_models.dart';
import 'package:raabta/features/sponsorship_transfer/presentation/l10n/sponsorship_transfer_strings.dart';
import 'package:raabta/features/truth_engine/domain/truth_package.dart';
import 'package:raabta/services/ai/claude_ai_service.dart';

class SponsorshipTransferAiReply {
  const SponsorshipTransferAiReply({required this.text, this.fromFallback = false});

  final String text;
  final bool fromFallback;
}

/// Sponsorship transfer legal assistant — Claude with verified-facts-only guardrails.
class SponsorshipTransferAiService {
  SponsorshipTransferAiService(this._claude);

  final ClaudeAIService _claude;

  static const requestType = 'sponsorship_transfer_assistant';

  static const rejectedClaimPatterns = [
    '70%',
    '70 percent',
    'stall rate',
    'applications stall',
    '24 hour',
    '24-hour',
    '24 hours',
    '3 months without',
    'fixer',
  ];

  static const domesticWorkerPatterns = [
    'domestic worker',
    'housemaid',
    'house maid',
    'live-in maid',
    'family driver',
    'domestic staff',
  ];

  @visibleForTesting
  static String buildPrompt({
    required String question,
    required String locale,
    TransferReadinessInput? input,
    TransferReadinessResult? result,
  }) {
    final summary = _readinessSummary(input, result, locale);

    final noticeUnknown = input?.formalNoticeStatus?.name == 'notSure';

    final package = TruthPackage(
      engineType: TruthPackageCatalog.sponsorshipTransfer,
      facts: {
        if (summary != null) 'readinessSummary': summary,
        'userQuestion': question,
      },
      calculation: {
        if (result != null) 'noticeMonths': result.noticeMonths,
        if (result != null) 'permitWindowStatus': result.permitWindowStatus.name,
        if (result != null) 'hasCriticalIssue': result.hasCriticalIssue,
      },
      assumptions: TruthPackageCatalog.sponsorshipAssumptions(
        noticeUnknown: noticeUnknown,
      ),
      unknowns: TruthPackageCatalog.sponsorshipUnknowns(),
      sourceRefs: TruthPackageCatalog.sponsorshipSourceRefs(),
    );

    return TruthPackagePrompt.build(
      package: package,
      locale: locale,
      preamble: QatarSponsorshipTransferKB.buildAssistantContext(
        locale: locale,
        readinessSummary: summary,
      ),
      userQuestion: question,
      trailingInstructions: 'Keep answer practical and concise.',
    );
  }

  static String? _readinessSummary(
    TransferReadinessInput? input,
    TransferReadinessResult? result,
    String locale,
  ) {
    if (input == null && result == null) return null;
    final parts = <String>[];
    if (input?.employmentStartDate != null) {
      parts.add('Employment start: ${input!.employmentStartDate!.toIso8601String().split('T').first}');
    }
    if (input?.residencePermitExpiry != null) {
      parts.add('Permit expiry: ${input!.residencePermitExpiry!.toIso8601String().split('T').first}');
    }
    if (input?.formalNoticeStatus != null) {
      parts.add('Formal notice: ${input!.formalNoticeStatus!.name}');
    }
    if (input?.probationPeriodStatus != null) {
      parts.add('Probation status: ${input!.probationPeriodStatus!.name}');
    }
    if (result != null) {
      if (result.probationNoticeApplies) {
        parts.add('Notice months (Art. 39 probation): ${result.noticeMonths}');
      } else {
        parts.add('Notice months (Law 18/2020 post-probation): ${result.noticeMonths}');
      }
      parts.add('Permit window: ${result.permitWindowStatus.name}');
    }
    return parts.isEmpty ? null : parts.join('\n');
  }

  static bool isRejectedClaimQuestion(String lower) {
    if (lower.contains('stall') &&
        (lower.contains('transfer') || lower.contains('application'))) {
      return true;
    }
    return rejectedClaimPatterns.any(lower.contains);
  }

  static bool isDomesticWorkerQuestion(String lower) {
    return domesticWorkerPatterns.any(lower.contains);
  }

  Future<SponsorshipTransferAiReply> ask({
    required String question,
    required String locale,
    TransferReadinessInput? input,
    TransferReadinessResult? result,
    List<Map<String, String>> conversationHistory = const [],
  }) async {
    final trimmed = question.trim();
    if (trimmed.isEmpty) {
      return SponsorshipTransferAiReply(
        text: SponsorshipTransferStrings.t('st_ai_empty_question', locale),
        fromFallback: true,
      );
    }

    final lower = trimmed.toLowerCase();

    if (isRejectedClaimQuestion(lower)) {
      return SponsorshipTransferAiReply(
        text: SponsorshipTransferStrings.t('st_ai_stall_decline', locale),
        fromFallback: true,
      );
    }

    if (isDomesticWorkerQuestion(lower)) {
      return SponsorshipTransferAiReply(
        text: SponsorshipTransferStrings.t('st_ai_domestic_redirect', locale),
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
      return SponsorshipTransferAiReply(
        text: SponsorshipTransferStrings.t('st_ai_unavailable', locale),
        fromFallback: true,
      );
    }

    return SponsorshipTransferAiReply(text: reply.trim());
  }
}
