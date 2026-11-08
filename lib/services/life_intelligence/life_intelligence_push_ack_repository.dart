import 'dart:convert';

import 'package:raabta/services/life_intelligence_signals_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Local acknowledgement ledger for Life Intelligence V2 (My Activity + push).
///
/// Separate from V1 Home Today SharedPreferences cooldown keys and from
/// ScamShield alert acknowledgements.
class LifeIntelligencePushAckRepository {
  LifeIntelligencePushAckRepository(this._prefs);

  final SharedPreferences _prefs;

  static const _ackTokensKey = 'life_intelligence_push_ack_tokens_v2';
  static const _openedTokensKey = 'life_intelligence_push_opened_tokens_v2';

  static String ackTokenFor({
    required LifeIntelligenceSignalType type,
    String? eosbEmployerKey,
    String? healthInsuranceEmployerKey,
  }) {
    return switch (type) {
      LifeIntelligenceSignalType.employerTransferStarted =>
        'employerTransferStarted',
      LifeIntelligenceSignalType.employerNameMismatch =>
        'employerNameMismatch|${eosbEmployerKey?.trim() ?? ''}|${healthInsuranceEmployerKey?.trim() ?? ''}',
    };
  }

  static String sourceIdFor(LifeIntelligenceSignalType type) =>
      switch (type) {
        LifeIntelligenceSignalType.employerTransferStarted =>
          'life_intelligence_employerTransferStarted',
        LifeIntelligenceSignalType.employerNameMismatch =>
          'life_intelligence_employerNameMismatch',
      };

  Future<Set<String>> loadAcknowledgedTokens() async {
    return _loadSet(_ackTokensKey);
  }

  Future<Set<String>> loadOpenedTokens() async {
    return _loadSet(_openedTokensKey);
  }

  Future<bool> isAcknowledged(String token) async {
    final tokens = await loadAcknowledgedTokens();
    return tokens.contains(token);
  }

  Future<void> acknowledge(String token) async {
    if (token.isEmpty) return;
    final current = await loadAcknowledgedTokens();
    if (current.contains(token)) return;
    final next = {...current, token};
    await _prefs.setString(_ackTokensKey, jsonEncode(next.toList()));
  }

  /// Records push open — does not suppress future signals by itself.
  Future<void> recordOpened(String token) async {
    if (token.isEmpty) return;
    final current = await loadOpenedTokens();
    if (current.contains(token)) return;
    final next = {...current, token};
    await _prefs.setString(_openedTokensKey, jsonEncode(next.toList()));
  }

  Future<Set<String>> _loadSet(String key) async {
    final raw = _prefs.getString(key);
    if (raw == null || raw.isEmpty) return {};
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded.map((e) => e.toString()).toSet();
    } catch (_) {
      return {};
    }
  }
}
