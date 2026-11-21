import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/features/scam_shield/permissions/permission_rationale_flow.dart';
import 'package:raabta/features/scam_shield/permissions/permission_rationale_models.dart';
import 'package:raabta/features/scam_shield/presentation/l10n/scam_shield_strings.dart';
import 'package:raabta/features/scam_shield/sensitive_lock/sensitive_safety_lock_controller.dart';
import 'package:raabta/features/scam_shield/sensitive_lock/sensitive_safety_lock_prefs.dart';

/// One-time offer after the first sensitive local save (Phase 27 sheet + Phase 34).
abstract final class SensitiveSafetyLockOffer {
  static Future<void> maybeOfferAfterFirstSensitiveSave(
    BuildContext context,
    WidgetRef ref, {
    required String locale,
  }) async {
    if (await SensitiveSafetyLockPrefs.offerShown()) return;
    if (await SensitiveSafetyLockPrefs.isEnabled()) {
      await SensitiveSafetyLockPrefs.markOfferShown();
      return;
    }
    await SensitiveSafetyLockPrefs.markOfferShown();

    if (!context.mounted) return;
    final choice = await PermissionRationaleFlow.showThenContinue(
      context,
      kind: PermissionRationaleKind.sensitiveSafetyLock,
      locale: locale,
    );
    if (!choice || !context.mounted) return;

    final controller = ref.read(sensitiveSafetyLockControllerProvider);
    final ok = await controller.setEnabled(true);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ScamShieldStrings.t('ss_sensitive_lock_enable_failed', locale),
          ),
        ),
      );
    }
  }
}
