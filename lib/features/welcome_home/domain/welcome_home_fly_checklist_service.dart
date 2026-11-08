import 'package:shared_preferences/shared_preferences.dart';

/// Local-only "Before you fly home" ticks — isolated from Leaving Qatar checklist.
class WelcomeHomeFlyChecklistService {
  static const storageKey = 'welcome_home_fly_checklist_v1';

  static const itemIds = [
    'experience_certificate',
    'contract_settlement_papers',
    'rp_cancellation_passport',
    'document_vault_copies',
    'eosb_entitlement',
    'health_coverage_gap',
  ];

  Future<Map<String, bool>> load() async {
    final prefs = await SharedPreferences.getInstance();
    return _decode(prefs.getString(storageKey));
  }

  Future<void> setItem({required String itemId, required bool completed}) async {
    final prefs = await SharedPreferences.getInstance();
    final current = _decode(prefs.getString(storageKey));
    current[itemId] = completed;
    await prefs.setString(storageKey, _encode(current));
  }

  Map<String, bool> _decode(String? raw) {
    if (raw == null || raw.isEmpty) return {};
    final result = <String, bool>{};
    for (final part in raw.split('&')) {
      if (part.isEmpty) continue;
      final idx = part.indexOf('=');
      if (idx <= 0) continue;
      result[part.substring(0, idx)] = part.substring(idx + 1) == 'true';
    }
    return result;
  }

  String _encode(Map<String, bool> map) {
    if (map.isEmpty) return '';
    return map.entries.map((e) => '${e.key}=${e.value}').join('&');
  }
}
