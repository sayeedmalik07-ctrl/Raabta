import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';

/// Reuses the [AlertDialog] confirm pattern from
/// [PrivacyDashboardScreen] (`_confirm` / delete-account dialogs).
Future<bool> showSensitiveActionConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Confirm',
  String cancelLabel = 'Cancel',
  bool destructive = false,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(cancelLabel),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(
            confirmLabel,
            style: destructive
                ? const TextStyle(color: AppColors.error)
                : null,
          ),
        ),
      ],
    ),
  );
  return result == true;
}
