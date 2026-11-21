import 'package:flutter/foundation.dart';

class TripPlannerAnalyticsService {
  static void homeVisit() => debugPrint('[TripAnalytics] home_visit');

  static void tripCreated(String id) =>
      debugPrint('[TripAnalytics] trip_created: $id');

  static void tripShared(String id) =>
      debugPrint('[TripAnalytics] trip_shared: $id');

  static void attractionViewed(String id) =>
      debugPrint('[TripAnalytics] attraction: $id');

  static void officialLinkTapped(String rowId) =>
      debugPrint('[TripAnalytics] official_link row=$rowId');

  static void changeOfPlansApplied(String action) =>
      debugPrint('[TripAnalytics] change_of_plans action=$action');

  static void changeOfPlansUndo() =>
      debugPrint('[TripAnalytics] change_of_plans undo');

  static void flightReminderToggled(bool enabled) =>
      debugPrint('[TripAnalytics] flight_reminder enabled=$enabled');
}
