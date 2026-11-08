import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:raabta/features/scam_shield/checkup/scam_checkup_models.dart';
import 'package:raabta/features/scam_shield/permissions/permission_rationale_flow.dart';
import 'package:raabta/features/scam_shield/permissions/permission_rationale_models.dart';

typedef OpenAppSettingsFn = Future<bool> Function();

/// Opens OS settings or in-app guides — never claims to toggle a specific switch.
abstract final class ScamCheckupDeepLinkLauncher {
  static OpenAppSettingsFn? openAppSettingsOverride;

  static Future<void> launch(
    BuildContext context,
    ScamCheckupDeepLink link, {
    required String locale,
  }) async {
    switch (link) {
      case ScamCheckupDeepLink.none:
        return;
      case ScamCheckupDeepLink.openAppSettings:
        final ok = await PermissionRationaleFlow.showThenContinue(
          context,
          kind: PermissionRationaleKind.osSettingsDeepLink,
          locale: locale,
        );
        if (!ok) return;
        await (openAppSettingsOverride ?? openAppSettings)();
      case ScamCheckupDeepLink.officialDirectory:
        if (context.mounted) {
          context.push('/scam-shield/official-directory');
        }
      case ScamCheckupDeepLink.callScreeningGuide:
        if (context.mounted) {
          context.push('/scam-shield/call-screening');
        }
      case ScamCheckupDeepLink.smsFilterGuide:
        if (context.mounted) {
          context.push('/scam-shield/sms-filter-guide');
        }
      case ScamCheckupDeepLink.personalContextSettings:
        if (context.mounted) {
          context.push('/scam-shield/personal-context');
        }
    }
  }
}
