import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:raabta/features/profile/privacy/models/privacy_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Reads/writes privacy preferences on `users/{uid}.privacySettings`.
class PrivacySettingsService {
  PrivacySettingsService({
    FirebaseFirestore? firestore,
    SharedPreferences? prefs,
  })  : _db = firestore ?? FirebaseFirestore.instance,
        _prefs = prefs;

  final FirebaseFirestore _db;
  SharedPreferences? _prefs;

  static String cacheKey(String uid) => 'privacy_settings_$uid';

  Future<SharedPreferences> _ensurePrefs() async {
    return _prefs ??= await SharedPreferences.getInstance();
  }

  Future<PrivacySettings> load(String uid) async {
    final prefs = await _ensurePrefs();
    try {
      final snap = await _db.collection('users').doc(uid).get();
      final raw = snap.data()?['privacySettings'] as Map<String, dynamic>?;
      final settings = PrivacySettings.fromFirestore(raw);
      await prefs.setString(cacheKey(uid), _encode(settings));
      return settings;
    } catch (_) {
      final cached = prefs.getString(cacheKey(uid));
      if (cached != null) {
        return _decode(cached);
      }
      return PrivacySettings.defaults;
    }
  }

  Future<void> save(String uid, PrivacySettings settings) async {
    final prefs = await _ensurePrefs();
    await _db.collection('users').doc(uid).set({
      'privacySettings': settings.toFirestore(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    await prefs.setString(cacheKey(uid), _encode(settings));
  }

  Future<bool> isAiPersonalizationEnabled(String uid) async {
    final prefs = await _ensurePrefs();
    final cached = prefs.getString(cacheKey(uid));
    if (cached != null) return _decode(cached).aiPersonalizationEnabled;
    return (await load(uid)).aiPersonalizationEnabled;
  }

  String _encode(PrivacySettings settings) {
    final m = settings.toFirestore();
    return m.entries.map((e) => '${e.key}=${e.value}').join('&');
  }

  PrivacySettings _decode(String raw) {
    final map = <String, dynamic>{};
    for (final part in raw.split('&')) {
      final kv = part.split('=');
      if (kv.length != 2) continue;
      map[kv[0]] = kv[1] == 'true';
    }
    return PrivacySettings.fromFirestore(map);
  }
}
