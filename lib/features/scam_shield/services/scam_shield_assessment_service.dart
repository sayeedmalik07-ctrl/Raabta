import 'dart:convert';

import 'package:raabta/features/scam_shield/data/scam_shield_verification_channels.dart';
import 'package:raabta/features/scam_shield/domain/scam_conversation_escalation_detector.dart';
import 'package:raabta/features/scam_shield/domain/scam_conversation_models.dart';
import 'package:raabta/features/scam_shield/domain/scam_conversation_turn_parser.dart';
import 'package:raabta/features/scam_shield/domain/scam_input_channel_parser.dart';
import 'package:raabta/features/scam_shield/domain/scam_risk_signal.dart';
import 'package:raabta/features/scam_shield/domain/scam_scan_risk_engine.dart';
import 'package:raabta/features/scam_shield/domain/evidence/generators/sender_channel_evidence.dart';
import 'package:raabta/features/scam_shield/domain/scam_message_sender_type.dart';
import 'package:raabta/features/scam_shield/domain/scam_shield_local_checker.dart';
import 'package:raabta/features/scam_shield/domain/scam_shield_models.dart';
import 'package:raabta/features/scam_shield/domain/scam_trust_label.dart';
import 'package:raabta/features/scam_shield/domain/pii_redactor.dart';
import 'package:raabta/features/scam_shield/domain/scam_shield_redacted_prompt.dart';
import 'package:raabta/features/scam_shield/domain/scam_url_reputation_enricher.dart';
import 'package:raabta/features/scam_shield/services/scam_shield_off_device_gateway.dart';
import 'package:raabta/features/scam_shield/services/scam_web_risk_service.dart';
import 'package:raabta/services/ai/claude_ai_service.dart';

typedef ScamShieldAiCaller = Future<String> Function({
  required ScamShieldRedactedPrompt prompt,
  required String language,
  required String? userId,
});

/// Orchestrates Level 0 local checks and gated Level 1 AI classification.
class ScamShieldAssessmentService {
  ScamShieldAssessmentService({
    required ScamShieldAiCaller classifyWithClaude,
    ScamWebRiskService? webRiskService,
  })  : _classifyWithClaude = classifyWithClaude,
        _webRiskService = webRiskService ?? ScamWebRiskService();

  final ScamShieldAiCaller _classifyWithClaude;
  final ScamWebRiskService _webRiskService;

  static bool shouldCallAi({
    required ScamShieldLocalCheckResult local,
    required ScamShieldContentType contentType,
  }) {
    if (contentType.requiresAiReview) return true;
    return local.flagCount > 0;
  }

  Future<ScamShieldAssessmentResult> assess({
    required String text,
    required ScamShieldContentType contentType,
    required String language,
    required String? userId,
    required bool canUseAi,
    ScamShieldInputChannel inputChannel = ScamShieldInputChannel.pasteText,
    ScamMessageSenderType senderType = ScamMessageSenderType.notSure,
  }) async {
    final parsed = ScamInputChannelParser.parse(
      raw: text,
      channel: inputChannel,
    );
    final trimmed = parsed.normalizedText.trim();
    final conversationParse = ScamConversationTurnParser.parse(trimmed);
    final escalation =
        ScamConversationEscalationDetector.analyze(conversationParse);

    var local = ScamShieldLocalChecker.check(
      text: trimmed,
      contentType: contentType,
    );

    if (escalation.flags.isNotEmpty) {
      final mergedFlags = {...local.redFlags, ...escalation.flags}.toList();
      local = ScamShieldLocalCheckResult(
        signal: ScamShieldLocalSignalX.fromFlagCount(mergedFlags.length),
        redFlags: mergedFlags,
        urlFindings: local.urlFindings,
        flagCount: mergedFlags.length,
      );
    }

    if (local.urlFindings.isNotEmpty) {
      final enrichedFindings = await ScamUrlReputationEnricher.enrichWithWebRisk(
        findings: local.urlFindings,
        webRiskService: _webRiskService,
        userId: userId,
      );
      final mergedFlags = {
        ...local.redFlags,
        for (final finding in enrichedFindings) ...finding.flags,
      }.toList();
      local = ScamShieldLocalCheckResult(
        signal: ScamShieldLocalSignalX.fromFlagCount(mergedFlags.length),
        redFlags: mergedFlags,
        urlFindings: enrichedFindings,
        flagCount: mergedFlags.length,
      );
    }

    var flagsForScan = local.redFlags;
    if (SenderChannelEvidenceGenerator.producesMismatchFlag(
      text: trimmed,
      locale: language,
      senderType: senderType,
      localFlags: flagsForScan,
    )) {
      // Risk merge: antiVerificationInstruction (16) via legacy flag mapping.
      flagsForScan = [...flagsForScan, 'ss_flag_sender_channel_mismatch'];
      local = ScamShieldLocalCheckResult(
        signal: ScamShieldLocalSignalX.fromFlagCount(flagsForScan.length),
        redFlags: flagsForScan,
        urlFindings: local.urlFindings,
        flagCount: flagsForScan.length,
      );
    }

    final scanAnalysis = ScamScanRiskEngine.analyze(
      text: trimmed,
      legacyFlags: flagsForScan,
      urlFindings: local.urlFindings,
    );

    ScamShieldAiAssessment? ai;
    var usedAi = false;
    var aiCapReached = false;

    if (shouldCallAi(local: local, contentType: contentType)) {
      if (canUseAi) {
        final redactedBody = PiiRedactor.redact(trimmed);
        final redactedConversation = conversationParse.hasStructure
            ? _redactConversation(conversationParse)
            : null;
        final prompt = ScamShieldRedactedPrompt.fromBuild(
          buildClaudePrompt(
            text: redactedBody.text,
            language: language,
            contentType: contentType,
            conversation: redactedConversation,
          ),
        );
        final reply = await _classifyWithClaude(
          prompt: prompt,
          language: language,
          userId: userId,
        );
        ai = parseClaudeJson(reply);
        usedAi = ai != null;
      } else {
        aiCapReached = true;
      }
    }

    final overallRisk = scanAnalysis.trustLabel.displayRisk;

    ScamShieldAiSupplementary? aiSupplementary;
    if (ai != null) {
      aiSupplementary = ScamShieldAiSupplementary(
        assessment: ai,
        differsFromDeterministic: ai.riskLevel != overallRisk,
      );
    }

    final signalFlags =
        scanAnalysis.signals.map((s) => s.labelKey).toList(growable: false);
    final redFlags = _mergeRedFlags(
      local: local,
      ai: ai,
      signalFlags: signalFlags,
    );
    final requestedInfo = ai?.requestedInfo ?? _inferRequestedInfo(local);

    return ScamShieldAssessmentResult(
      contentType: contentType,
      overallRisk: overallRisk,
      localCheck: local,
      redFlags: redFlags,
      requestedInfo: requestedInfo,
      urlFindings: local.urlFindings,
      usedAi: usedAi,
      impersonationType: ai?.impersonationType,
      verificationChannelKeys: ScamShieldVerificationChannels.keysFor(
        contentType: contentType,
        impersonationType: ai?.impersonationType,
      ),
      aiCapReached: aiCapReached,
      aiSupplementary: aiSupplementary,
      scanAnalysis: scanAnalysis,
      inputChannel: inputChannel,
      conversationContext: conversationParse.hasStructure
          ? ScamConversationContext(
              turnCount: conversationParse.turns.length,
              confidence: conversationParse.confidence,
              escalationFlags: escalation.flags,
            )
          : null,
    );
  }

  static List<String> _mergeRedFlags({
    required ScamShieldLocalCheckResult local,
    ScamShieldAiAssessment? ai,
    List<String> signalFlags = const [],
  }) {
    final merged = <String>{...signalFlags, ...local.redFlags};
    if (ai != null) {
      for (final flag in ai.redFlags) {
        merged.add(flag);
      }
    }
    return merged.toList();
  }

  static ScamConversationParseResult _redactConversation(
    ScamConversationParseResult parse,
  ) {
    return ScamConversationParseResult(
      turns: [
        for (final turn in parse.turns)
          ScamConversationTurn(
            index: turn.index,
            speaker: turn.speaker,
            text: PiiRedactor.redact(turn.text).text,
          ),
      ],
      confidence: parse.confidence,
    );
  }

  static List<String> _inferRequestedInfo(ScamShieldLocalCheckResult local) {
    final info = <String>[];
    if (local.redFlags.contains('ss_flag_otp')) {
      info.add('ss_requested_credentials');
    }
    if (local.redFlags.contains('ss_flag_unusual_payment') ||
        local.redFlags.contains('ss_flag_upfront_fee')) {
      info.add('ss_requested_money');
    }
    if (local.redFlags.contains('ss_flag_impersonation')) {
      info.add('ss_requested_trust');
    }
    return info;
  }

  static String buildClaudePrompt({
    required String text,
    required String language,
    required ScamShieldContentType contentType,
    ScamConversationParseResult? conversation,
  }) {
    final conversationBlock = _conversationPromptBlock(conversation);
    return '''
You are a scam-risk assessor for Raabta (Qatar expat app). Assess the pasted content for the user — NOT for publication moderation.
Respond ONLY with valid JSON (no markdown, max ~400 tokens):
{
  "riskLevel": "low" | "medium" | "high",
  "redFlags": ["plain language flag 1", "flag 2"],
  "requestedInfo": ["money" | "personal data" | "credentials" | "trust/action"],
  "impersonationType": "government" | "bank" | "employer" | "landlord" | "investment firm" | "other" | null
}

Rules:
- NEVER say "definitely a scam" or "definitely safe" — use risk framing only.
- List red flags found IN the actual pasted text.
- Do NOT invent official phone numbers, URLs, or contact details.
- impersonationType only if the text claims to be from an organization type.
- Content type: ${contentType.name}
- Language context: $language
${conversationBlock.isNotEmpty ? '- When conversation turns are provided, weigh escalation across turns (rapport before sensitive asks, rising urgency, casual-to-financial topic shift).\n' : ''}
Pasted content:
$conversationBlock$text
''';
  }

  static String _conversationPromptBlock(ScamConversationParseResult? conversation) {
    if (conversation == null || !conversation.hasStructure) return '';
    if (conversation.confidence == ScamConversationParseConfidence.low) {
      return '';
    }

    final buffer = StringBuffer('\nConversation turns (chronological, Party A/B labels only):\n');
    for (final turn in conversation.turns) {
      final speaker = ScamConversationTurnParser.speakerLabel(turn.speaker);
      buffer.writeln('${turn.index + 1}. $speaker: ${turn.text}');
    }
    buffer.writeln();
    return buffer.toString();
  }

  static ScamShieldAiAssessment? parseClaudeJson(String reply) {
    try {
      final start = reply.indexOf('{');
      final end = reply.lastIndexOf('}');
      if (start < 0 || end <= start) return null;
      final json =
          jsonDecode(reply.substring(start, end + 1)) as Map<String, dynamic>;

      final riskRaw = (json['riskLevel'] as String? ?? 'low').toLowerCase();
      final risk = switch (riskRaw) {
        'high' => ScamShieldRiskLevel.high,
        'medium' => ScamShieldRiskLevel.medium,
        _ => ScamShieldRiskLevel.low,
      };

      final redFlags = (json['redFlags'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .where((e) => e.isNotEmpty)
          .toList();

      final requestedRaw = json['requestedInfo'] as List<dynamic>? ?? [];
      final requestedInfo = requestedRaw.map((e) {
        final s = e.toString().toLowerCase();
        return switch (s) {
          'money' => 'ss_requested_money',
          'personal data' => 'ss_requested_personal_data',
          'credentials' => 'ss_requested_credentials',
          _ => 'ss_requested_trust',
        };
      }).toList();

      final impersonation = json['impersonationType'] as String?;

      return ScamShieldAiAssessment(
        riskLevel: risk,
        redFlags: redFlags,
        requestedInfo: requestedInfo.toSet().toList(),
        impersonationType: impersonation,
      );
    } catch (_) {
      return null;
    }
  }
}

ScamShieldAssessmentService defaultScamShieldAssessmentService(
  ClaudeAIService ai,
) {
  return ScamShieldAssessmentService(
    classifyWithClaude: ({
      required prompt,
      required language,
      required userId,
    }) async {
      return ScamShieldOffDeviceGateway.sendClassificationPrompt(
        ai: ai,
        prompt: prompt,
        language: language,
        userId: userId,
      );
    },
  );
}
