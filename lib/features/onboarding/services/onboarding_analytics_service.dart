import 'package:flutter/foundation.dart';

/// Onboarding funnel analytics — debug logging until Firebase Analytics is wired.
abstract final class OnboardingAnalyticsService {
  static void funnelStarted() =>
      debugPrint('[OnboardingAnalytics] funnel_started');

  static void funnelQ1Answered(String contractType) => debugPrint(
        '[OnboardingAnalytics] funnel_q1_answered contract=$contractType',
      );

  static void funnelQ2Answered(String yearsBand) => debugPrint(
        '[OnboardingAnalytics] funnel_q2_answered years=$yearsBand',
      );

  static void funnelSkipped() =>
      debugPrint('[OnboardingAnalytics] funnel_skipped');

  static void funnelCompletedWithEstimate() => debugPrint(
        '[OnboardingAnalytics] funnel_completed_with_estimate',
      );

  static void reengagementSent(String trigger) => debugPrint(
        '[OnboardingAnalytics] reengagement_sent trigger=$trigger',
      );

  static void reengagementOpened(String trigger) => debugPrint(
        '[OnboardingAnalytics] reengagement_opened trigger=$trigger',
      );

  static void reengagementResultedInNewCalculation(String trigger) =>
      debugPrint(
        '[OnboardingAnalytics] reengagement_resulted_in_new_calculation trigger=$trigger',
      );
}
