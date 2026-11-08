import 'package:raabta/features/scam_shield/domain/scam_shield_redacted_prompt.dart';
import 'package:raabta/features/scam_shield/domain/scam_shield_sanitized_uri.dart';
import 'package:raabta/features/scam_shield/scam_shield_config.dart';
import 'package:raabta/features/scam_shield/services/scam_web_risk_service.dart';
import 'package:raabta/services/ai/claude_ai_service.dart';

/// Single choke point for ScamShield network egress (AI + Web Risk).
abstract final class ScamShieldOffDeviceGateway {
  static Future<String> sendClassificationPrompt({
    required ClaudeAIService ai,
    required ScamShieldRedactedPrompt prompt,
    required String language,
    required String? userId,
  }) {
    return ai.sendMessage(
      prompt.value,
      language: language,
      requestType: ScamShieldConfig.aiRequestType,
      userId: userId,
    );
  }

  static Future<ScamWebRiskBatchResult> lookupWebRisk({
    required ScamWebRiskService webRiskService,
    required List<ScamShieldSanitizedUri> uris,
    String? userId,
  }) {
    return webRiskService.lookupUris(
      uris: uris,
      userId: userId,
    );
  }
}
