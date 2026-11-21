import 'package:flutter/material.dart';
import 'package:raabta/features/scam_shield/permissions/permission_rationale_models.dart';
import 'package:raabta/features/scam_shield/permissions/permission_rationale_prefs.dart';
import 'package:raabta/features/scam_shield/presentation/widgets/permission_rationale_sheet.dart';

abstract final class PermissionRationaleFlow {
  /// Shows rationale first. Returns true only if user chose Continue.
  static Future<bool> showThenContinue(
    BuildContext context, {
    required PermissionRationaleKind kind,
    required String locale,
  }) async {
    final choice = await PermissionRationaleSheet.show(
      context,
      kind: kind,
      locale: locale,
    );
    if (choice == PermissionRationaleChoice.continueRequested) {
      await PermissionRationalePrefs.record(kind: kind, continued: true);
      return true;
    }
    if (choice == PermissionRationaleChoice.notNow) {
      await PermissionRationalePrefs.record(kind: kind, continued: false);
    }
    return false;
  }
}
