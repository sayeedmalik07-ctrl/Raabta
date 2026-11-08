import 'package:firebase_auth/firebase_auth.dart';
import 'package:raabta/core/persistence/local_data_isolation_keys.dart';
import 'package:raabta/core/persistence/uid_scoped_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Tracks when a user opened the app from an EOSB re-engagement notification.
abstract final class ReengagementSession {
  static Future<void> markOpened(String trigger) async {
    if (trigger.isEmpty) return;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || uid.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    await UidScopedPreferences.setString(
      prefs,
      LocalDataIsolationKeys.eosbReengagementTrigger,
      trigger,
      uid: uid,
    );
  }

  static Future<String?> consumeIfActive() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || uid.isEmpty) return null;
    final prefs = await SharedPreferences.getInstance();
    final trigger = UidScopedPreferences.getString(
      prefs,
      LocalDataIsolationKeys.eosbReengagementTrigger,
      uid: uid,
    );
    if (trigger == null || trigger.isEmpty) return null;
    await UidScopedPreferences.remove(
      prefs,
      LocalDataIsolationKeys.eosbReengagementTrigger,
      uid: uid,
    );
    return trigger;
  }
}
