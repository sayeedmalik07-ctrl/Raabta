import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:raabta/config/app_config.dart';

enum AppReviewOutcome {
  success,
  notPublishedYet,
  unavailable,
}

/// Triggers the native in-app review dialog, or opens the store listing when configured.
///
/// Gated by [AppConfig.showRateApp] — off until Raabta is published.
/// TODO: Re-enable once App Store Connect / Play Console IDs are issued at launch.
Future<AppReviewOutcome> requestAppStoreReview() async {
  if (!AppConfig.showRateApp) {
    return AppReviewOutcome.notPublishedYet;
  }

  final review = InAppReview.instance;
  try {
    if (await review.isAvailable()) {
      await review.requestReview();
      return AppReviewOutcome.success;
    }

    if (Platform.isIOS && !AppConfig.hasIosAppStoreListing) {
      return AppReviewOutcome.notPublishedYet;
    }

    if (Platform.isIOS) {
      await review.openStoreListing(appStoreId: AppConfig.iosAppStoreId!);
    } else {
      await review.openStoreListing();
    }
    return AppReviewOutcome.success;
  } catch (e) {
    debugPrint('AppReviewService: $e');
    if (Platform.isIOS && !AppConfig.hasIosAppStoreListing) {
      return AppReviewOutcome.notPublishedYet;
    }
    return AppReviewOutcome.unavailable;
  }
}
