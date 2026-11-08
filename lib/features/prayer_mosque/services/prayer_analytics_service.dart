import 'package:flutter/foundation.dart';

/// Anonymous prayer feature analytics stubs.
class PrayerAnalyticsService {
  static void dashboardVisit() =>
      debugPrint('[PrayerAnalytics] dashboard_visit');

  static void mosqueSearch(String query) =>
      debugPrint('[PrayerAnalytics] mosque_search: $query');

  static void qiblaUsage() => debugPrint('[PrayerAnalytics] qibla_usage');

  static void reminderSet(String type) =>
      debugPrint('[PrayerAnalytics] reminder: $type');

  static void mosqueViewed(String id) =>
      debugPrint('[PrayerAnalytics] mosque_view: $id');
}
