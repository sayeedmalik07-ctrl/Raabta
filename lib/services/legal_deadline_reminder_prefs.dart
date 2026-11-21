import 'package:shared_preferences/shared_preferences.dart';

/// Opt-in scopes for legal-deadline reminder notifications (default OFF).
enum LegalDeadlineReminderScope {
  eosb('eosb'),
  eosbFinalSettlement('eosb_final_settlement'),
  tenancy('tenancy'),
  tenancyDepositReturn('tenancy_deposit_return'),
  sponsorshipTransfer('sponsorship_transfer');

  const LegalDeadlineReminderScope(this.storageKey);
  final String storageKey;

  String get prefsKey => 'legal_deadline_reminder_$storageKey';
}

abstract final class LegalDeadlineReminderPrefs {
  static Future<bool> isEnabled(LegalDeadlineReminderScope scope) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(scope.prefsKey) ?? false;
  }

  static Future<void> setEnabled(
    LegalDeadlineReminderScope scope,
    bool enabled,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(scope.prefsKey, enabled);
  }
}
