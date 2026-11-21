import 'package:shared_preferences/shared_preferences.dart';

/// Device-local completion ticks for “Other close-out steps” — never Firestore.
class LeavingQatarCloseoutPrefsService {
  static const prefsKey = 'leaving_qatar_other_closeout_v1';

  Future<Map<String, bool>> load() async {
    final prefs = await SharedPreferences.getInstance();
    return _decode(prefs.getString(prefsKey));
  }

  Future<void> setCompleted(String itemId, bool completed) async {
    final prefs = await SharedPreferences.getInstance();
    final current = _decode(prefs.getString(prefsKey));
    current[itemId] = completed;
    await prefs.setString(prefsKey, _encode(current));
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
