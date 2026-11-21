import 'dart:convert';

import 'package:raabta/features/trip_planner/domain/models/trip_booking_segment.dart';
import 'package:raabta/features/trip_planner/domain/models/trip_plan.dart';
import 'package:raabta/features/trip_planner/presentation/l10n/trip_strings.dart';
import 'package:raabta/models/notification_models.dart';
import 'package:raabta/services/notification_repository.dart';
import 'package:raabta/services/notifications/notification_type.dart';
import 'package:raabta/services/notifications/quiet_hours_service.dart';
import 'package:raabta/services/notification_background.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Opt-in local flight-check reminders (booking segment datetimes only).
class TripFlightReminderService {
  TripFlightReminderService(this._prefs);

  final SharedPreferences _prefs;

  static const _enabledTripsKey = 'trip_planner_flight_reminder_enabled';

  static const offset24h = Duration(hours: 24);
  static const offset4h = Duration(hours: 4);

  bool isEnabledForTrip(String tripId) {
    return _enabledTripIds().contains(tripId);
  }

  Future<void> setEnabled({
    required String tripId,
    required bool enabled,
    required TripPlan trip,
    required String locale,
  }) async {
    final ids = _enabledTripIds();
    if (enabled) {
      ids.add(tripId);
    } else {
      ids.remove(tripId);
    }
    await _prefs.setStringList(_enabledTripsKey, ids.toList());
    if (enabled) {
      await reconcileForTrip(trip: trip, locale: locale);
    } else {
      await cancelForTrip(trip);
    }
  }

  Future<void> reconcileForTrip({
    required TripPlan trip,
    required String locale,
  }) async {
    await cancelForTrip(trip);
    if (!isEnabledForTrip(trip.id)) return;

    final anchors = _flightAnchors(trip);
    if (anchors.isEmpty) return;

    await RaabtaLocalNotifications.instance.initialize();
    final settings = await _loadNotificationSettings();

    for (final anchor in anchors) {
      for (final offset in [offset24h, offset4h]) {
        final raw = anchor.dateTime.subtract(offset);
        if (raw.isBefore(DateTime.now())) continue;
        final scheduled = QuietHoursService.instance
            .adjustScheduledTime(raw, settings);
        if (scheduled.isBefore(DateTime.now())) continue;

        await RaabtaLocalNotifications.instance.schedule(
          id: _notificationId(
            tripId: trip.id,
            segmentId: anchor.segmentId,
            offset: offset,
          ),
          title: TripStrings.t('trip_flight_reminder_title', locale),
          body: TripStrings.t('trip_flight_reminder_body', locale),
          scheduledDate: scheduled,
          notificationType: NotificationType.general,
          payload: jsonEncode({
            'route':
                '/disruption-readiness/trip?tripId=${Uri.encodeComponent(trip.id)}',
            'type': 'trip_flight_check',
          }),
        );
      }
    }
  }

  Future<void> cancelForTrip(TripPlan trip) async {
    await RaabtaLocalNotifications.instance.initialize();
    for (final segment in trip.bookingSegments) {
      if (segment.type != TripBookingType.flight) continue;
      for (final offset in [offset24h, offset4h]) {
        await RaabtaLocalNotifications.instance.cancel(
          _notificationId(
            tripId: trip.id,
            segmentId: segment.id,
            offset: offset,
          ),
        );
      }
    }
  }

  /// Cancels using segment ids present on the trip, then schedules fresh.
  Future<void> rescheduleAfterTripChange({
    required TripPlan trip,
    required String locale,
  }) async {
    if (!isEnabledForTrip(trip.id)) return;
    await reconcileForTrip(trip: trip, locale: locale);
  }

  static bool tripHasSchedulableFlight(TripPlan trip) {
    return _flightAnchors(trip).isNotEmpty;
  }

  static List<_FlightAnchor> _flightAnchors(TripPlan trip) {
    final now = DateTime.now();
    final out = <_FlightAnchor>[];
    for (final segment in trip.bookingSegments) {
      if (segment.type != TripBookingType.flight) continue;
      final dt = segment.startDateTime;
      if (dt == null || !dt.isAfter(now)) continue;
      out.add(_FlightAnchor(segmentId: segment.id, dateTime: dt));
    }
    return out;
  }

  Set<String> _enabledTripIds() {
    return _prefs.getStringList(_enabledTripsKey)?.toSet() ?? {};
  }

  Future<NotificationSettings> _loadNotificationSettings() async {
    final repo = await createNotificationRepository();
    return repo.getSettings();
  }

  static int _notificationId({
    required String tripId,
    required String segmentId,
    required Duration offset,
  }) {
    final tag = offset == offset24h ? '24h' : '4h';
    return 'trip_flight_${tripId}_${segmentId}_$tag'.hashCode.abs() %
        2147483647;
  }

}

class _FlightAnchor {
  const _FlightAnchor({required this.segmentId, required this.dateTime});

  final String segmentId;
  final DateTime dateTime;
}
