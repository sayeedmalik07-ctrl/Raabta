import 'package:hive_flutter/hive_flutter.dart';

/// Local cadence + campaign state for Phase 30 — no server sync.
class SecurityAlertStateRepository {
  SecurityAlertStateRepository({Future<Box<String>> Function()? openBox})
      : _openBox = openBox ?? _defaultOpen;

  static const boxName = 'scam_security_alert_state_v1';

  final Future<Box<String>> Function() _openBox;

  static Future<Box<String>> _defaultOpen() async {
    if (!Hive.isBoxOpen(boxName)) {
      await Hive.openBox<String>(boxName);
    }
    return Hive.box<String>(boxName);
  }

  Future<String?> read(String key) async {
    final box = await _openBox();
    return box.get(key);
  }

  Future<void> write(String key, String? value) async {
    final box = await _openBox();
    if (value == null) {
      await box.delete(key);
    } else {
      await box.put(key, value);
    }
  }

  Future<int> readInt(String key, {int fallback = 0}) async {
    final raw = await read(key);
    return int.tryParse(raw ?? '') ?? fallback;
  }

  Future<void> writeInt(String key, int value) => write(key, value.toString());

  static const lastVariantKey = 'last_variant_key';
  static const lastTopicIdKey = 'last_topic_id';
  static const consecutiveUnopenedKey = 'consecutive_unopened';
  static const tipScheduledAtKey = 'tip_scheduled_at';
  static const tipEngagedAtKey = 'tip_engaged_at';
  static const postIncidentUntilKey = 'post_incident_until';
  static const monthlyCampaignUntilKey = 'monthly_campaign_until';
  static const activeAdvisoryIdKey = 'active_advisory_id';
  static const activeAdvisoryStartedKey = 'active_advisory_started';
  static const userBankFraudLineKey = 'user_bank_fraud_line';
  static const sunsetPausedKey = 'sunset_paused';

  static Future<void> resetForTest() async {
    if (Hive.isBoxOpen(boxName)) {
      await Hive.box<String>(boxName).clear();
    }
  }
}
