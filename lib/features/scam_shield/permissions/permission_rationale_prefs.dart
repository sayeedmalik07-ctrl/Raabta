import 'package:shared_preferences/shared_preferences.dart';
import 'package:raabta/features/scam_shield/permissions/permission_rationale_models.dart';

/// Local-only record of rationale outcomes — no network.
abstract final class PermissionRationalePrefs {
  static String _key(PermissionRationaleKind kind) =>
      'ss_permission_rationale_${kind.name}';

  static Future<void> record({
    required PermissionRationaleKind kind,
    required bool continued,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key(kind),
      continued ? 'continued' : 'not_now',
    );
  }

  static Future<String?> lastOutcome(PermissionRationaleKind kind) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key(kind));
  }
}
