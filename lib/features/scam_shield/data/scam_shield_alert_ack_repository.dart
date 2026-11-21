import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Local acknowledgment ledger for ScamShield Home anchor alerts (Option A).
///
/// Stores history entry IDs the user has seen by opening the hub or incident flow.
class ScamShieldAlertAckRepository {
  ScamShieldAlertAckRepository(this._prefs);

  final SharedPreferences _prefs;

  static const _key = 'scam_shield_alert_ack_entry_ids_v1';

  Future<Set<String>> loadAcknowledgedIds() async {
    final raw = _prefs.getString(_key);
    if (raw == null || raw.isEmpty) return {};
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded.map((e) => e.toString()).toSet();
    } catch (_) {
      return {};
    }
  }

  Future<void> acknowledgeIds(Iterable<String> entryIds) async {
    if (entryIds.isEmpty) return;
    final current = await loadAcknowledgedIds();
    final next = {...current, ...entryIds};
    await _prefs.setString(_key, jsonEncode(next.toList()));
  }
}
