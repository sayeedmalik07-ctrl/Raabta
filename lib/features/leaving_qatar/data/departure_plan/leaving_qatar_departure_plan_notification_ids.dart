import 'dart:convert';

import 'package:raabta/features/leaving_qatar/data/departure_plan/leaving_qatar_departure_plan_models.dart';

/// Stable local notification IDs for Leaving Qatar Departure Plan reminders.
///
/// Repository audit (fixed bands elsewhere):
/// - 1000–1999 document expiry ([NotificationIds.documentExpiryId])
/// - 2000–2999 bill split
/// - 3000–3999 heat / hydration
/// - 5000–8999 bills ([notification_engine] _billNotificationId)
/// - 5200+ product expiry offsets
/// - 9000+ warranty, 12000+ document deadlines, 16000+ legal, 17000+ viewing
/// - Trip flight uses hash-mod (not a reserved band)
///
/// **22000–22999** is reserved for departure-plan reminder calendar days only.
abstract final class LeavingQatarDeparturePlanNotificationIds {
  static const payloadType = 'lq_departure_plan_reminder';

  static const idMin = 22000;
  static const idMax = 22999;
  static const capacity = idMax - idMin + 1;

  /// Epoch for civil-day ordinals (UTC, date-only).
  static final _epochUtc = DateTime.utc(2000, 1, 1);

  static bool isOwned(int id) => id >= idMin && id <= idMax;

  /// Pre-hash scheme — cancel on reconcile for migration only.
  static int legacyNotificationIdForDateKey(String qatarDateKey) {
    return 'lq_departure_plan_rem_$qatarDateKey'.hashCode.abs() % 2147483647;
  }

  /// Stable ID from `YYYY-MM-DD` (not Dart [String.hashCode]).
  static int notificationIdForDateKey(String qatarDateKey) {
    final ordinal = civilDayOrdinal(qatarDateKey);
    if (ordinal == null) {
      throw ArgumentError.value(qatarDateKey, 'qatarDateKey', 'invalid date');
    }
    return idMin + (ordinal % capacity);
  }

  /// Assigns distinct owned IDs for all [dateKeys] scheduled together.
  ///
  /// Linear-probes within [idMin]..[idMax] on ordinal collision.
  static Map<String, int> assignDistinctIds(Iterable<String> dateKeys) {
    final sorted = dateKeys.toList()..sort();
    final out = <String, int>{};
    final used = <int>{};
    for (final key in sorted) {
      final base = notificationIdForDateKey(key);
      var id = base;
      var probe = 0;
      while (used.contains(id)) {
        probe++;
        if (probe >= capacity) {
          throw StateError(
            'Departure plan reminder ID capacity exceeded ($capacity slots)',
          );
        }
        id = idMin + ((base - idMin + probe) % capacity);
      }
      used.add(id);
      out[key] = id;
    }
    return out;
  }

  /// UTC civil days since 2000-01-01 for valid ISO date keys.
  static int? civilDayOrdinal(String qatarDateKey) {
    if (!LeavingQatarDeparturePlanDate.isValidIsoDate(qatarDateKey)) {
      return null;
    }
    final parts = qatarDateKey.split('-');
    final date = DateTime.utc(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
    return date.difference(_epochUtc).inDays;
  }

  static bool isDeparturePlanPayload(String? payload) {
    if (payload == null || payload.isEmpty) return false;
    try {
      final decoded = jsonDecode(payload);
      if (decoded is! Map) return false;
      return decoded['type'] == payloadType;
    } catch (_) {
      return false;
    }
  }
}
