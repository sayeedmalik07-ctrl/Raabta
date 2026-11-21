import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:raabta/config/app_config.dart';
import 'package:url_launcher/url_launcher.dart';

enum AppUpdateOutcome {
  success,
  unavailable,
}

/// Opens the platform store listing so the user can install an update.
class AppUpdateService {
  AppUpdateService._();

  static Future<AppUpdateOutcome> openStoreListing() async {
    final review = InAppReview.instance;
    try {
      if (Platform.isIOS && AppConfig.hasIosAppStoreListing) {
        await review.openStoreListing(appStoreId: AppConfig.iosAppStoreId!);
        return AppUpdateOutcome.success;
      }

      if (Platform.isAndroid) {
        final uri = Uri.parse(
          'https://play.google.com/store/apps/details?id=${AppConfig.androidApplicationId}',
        );
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          return AppUpdateOutcome.success;
        }
      }

      await review.openStoreListing();
      return AppUpdateOutcome.success;
    } catch (e) {
      debugPrint('AppUpdateService: $e');
      return AppUpdateOutcome.unavailable;
    }
  }
}
