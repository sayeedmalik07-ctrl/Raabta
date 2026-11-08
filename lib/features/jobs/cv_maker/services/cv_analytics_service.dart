import 'package:flutter/foundation.dart';

/// CV Maker analytics — debug logging until Firebase Analytics is wired.
abstract final class CvAnalyticsService {
  static void cvBuilderStarted() =>
      debugPrint('[CvAnalytics] cv_builder_started');

  static void cvBuilderCompleted() =>
      debugPrint('[CvAnalytics] cv_builder_completed');

  static void cvAiAssistUsed(String fieldId) => debugPrint(
        '[CvAnalytics] cv_ai_assist_used field=$fieldId',
      );

  static void cvAttachedToApplication(String jobId) => debugPrint(
        '[CvAnalytics] cv_attached_to_application job=$jobId',
      );
}
