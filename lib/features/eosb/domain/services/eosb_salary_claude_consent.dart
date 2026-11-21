import 'package:raabta/services/ai/claude_ai_service.dart';

/// Salary-storage consent gate for EOSB/OT Claude requests.
abstract final class EosbSalarySensitiveClaudeRequestTypes {
  static const eosbContractAnalysis = 'eosb_contract_analysis';
  static const eosbOvertimeImport = 'eosb_overtime_import';
  static const eosbOvertimeRoundingExplain = 'eosb_overtime_rounding_explain';

  static const all = <String>{
    eosbContractAnalysis,
    eosbOvertimeImport,
    eosbOvertimeRoundingExplain,
  };
}

/// Thrown when a salary-bearing Claude call is attempted without storage consent.
class EosbSalaryClaudeConsentRequired implements Exception {
  const EosbSalaryClaudeConsentRequired();
}

/// Thrown when a salary-bearing action (e.g. online registration) lacks consent.
class EosbSalaryStorageConsentRequired implements Exception {
  const EosbSalaryStorageConsentRequired();
}

/// Reads persisted salary consent (typically [EosbRepository.salaryConsent]).
typedef EosbSalaryConsentReader = bool Function();

/// Enforces persisted consent immediately before and after Claude transmission.
class EosbSalaryClaudeConsentGuard {
  EosbSalaryClaudeConsentGuard(this._readConsent);

  final EosbSalaryConsentReader _readConsent;

  void requireConsent() {
    if (!_readConsent()) {
      throw const EosbSalaryClaudeConsentRequired();
    }
  }

  Future<String> sendClaudeMessage(
    ClaudeAIService claude, {
    required String message,
    required String language,
    required String requestType,
    String languageCode = 'en',
    List<Map<String, String>> conversationHistory = const [],
    String? userId,
    Map<String, dynamic> userProfile = const {},
  }) async {
    requireConsent();
    final raw = await claude.sendMessage(
      message,
      language: language,
      requestType: requestType,
      languageCode: languageCode,
      conversationHistory: conversationHistory,
      userId: userId,
      userProfile: userProfile,
    );
    try {
      requireConsent();
    } on EosbSalaryClaudeConsentRequired {
      claude.evictResponseCacheForRequest(
        requestType: requestType,
        message: message,
        language: language,
        userId: userId,
      );
      rethrow;
    }
    return raw;
  }
}
