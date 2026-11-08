import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists per-task checklist completion on `users/{uid}.leavingQatarChecklist`.
class LeavingQatarChecklistService {
  LeavingQatarChecklistService({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  static String prefsKey(String uid) => 'leaving_qatar_checklist_$uid';
  static const firestoreField = 'leavingQatarChecklist';

  Future<Map<String, bool>> load(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    try {
      final snap = await _db.collection('users').doc(uid).get();
      final raw = snap.data()?[firestoreField] as Map<String, dynamic>?;
      if (raw == null) return _loadFromPrefs(prefs, uid);
      final parsed = raw.map(
        (key, value) => MapEntry(key, value == true),
      );
      await prefs.setString(prefsKey(uid), _encode(parsed));
      return parsed;
    } catch (_) {
      return _loadFromPrefs(prefs, uid);
    }
  }

  Stream<Map<String, bool>> watch(String uid) {
    return _db.collection('users').doc(uid).snapshots().map((snap) {
      final raw = snap.data()?[firestoreField] as Map<String, dynamic>?;
      if (raw == null) return const <String, bool>{};
      return raw.map((key, value) => MapEntry(key, value == true));
    });
  }

  Future<void> setCompleted(
    String uid,
    String itemId,
    bool completed,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await load(uid);
    final updated = {...current, itemId: completed};
    await prefs.setString(prefsKey(uid), _encode(updated));
    try {
      await _db.collection('users').doc(uid).set({
        firestoreField: updated,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (_) {}
  }

  Map<String, bool> _loadFromPrefs(SharedPreferences prefs, String uid) {
    final cached = prefs.getString(prefsKey(uid));
    if (cached == null || cached.isEmpty) return const {};
    return _decode(cached);
  }

  String _encode(Map<String, bool> map) {
    if (map.isEmpty) return '';
    return map.entries.map((e) => '${e.key}=${e.value}').join('&');
  }

  Map<String, bool> _decode(String raw) {
    final result = <String, bool>{};
    for (final part in raw.split('&')) {
      if (part.isEmpty) continue;
      final idx = part.indexOf('=');
      if (idx <= 0) continue;
      result[part.substring(0, idx)] = part.substring(idx + 1) == 'true';
    }
    return result;
  }
}
