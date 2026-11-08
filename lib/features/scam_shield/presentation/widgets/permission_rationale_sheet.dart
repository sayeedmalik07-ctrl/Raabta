import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_primary_button.dart';
import 'package:raabta/features/scam_shield/permissions/permission_rationale_models.dart';
import 'package:raabta/features/scam_shield/presentation/l10n/scam_shield_strings.dart';

abstract final class PermissionRationaleSheet {
  static Future<PermissionRationaleChoice?> show(
    BuildContext context, {
    required PermissionRationaleKind kind,
    required String locale,
  }) {
    return showModalBottomSheet<PermissionRationaleChoice>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) {
        final prefix = _prefixFor(kind);
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              AppSpacing.lg,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  ScamShieldStrings.t('${prefix}_title', locale),
                  style: AppTypography.title,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  ScamShieldStrings.t('${prefix}_why', locale),
                  style: AppTypography.bodySmall,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  ScamShieldStrings.t('${prefix}_reads', locale),
                  style: AppTypography.bodySmall,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  ScamShieldStrings.t('${prefix}_never', locale),
                  style: AppTypography.bodySmall,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  ScamShieldStrings.t('${prefix}_turn_off', locale),
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                GlassPrimaryButton(
                  label: ScamShieldStrings.t('ss_permission_continue', locale),
                  expand: true,
                  onPressed: () => Navigator.of(ctx).pop(
                    PermissionRationaleChoice.continueRequested,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(
                    PermissionRationaleChoice.notNow,
                  ),
                  child: Text(
                    ScamShieldStrings.t('ss_permission_not_now', locale),
                    style: AppTypography.bodySmall,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static String _prefixFor(PermissionRationaleKind kind) {
    return switch (kind) {
      PermissionRationaleKind.androidCallScreening =>
        'ss_permission_call_screening',
      PermissionRationaleKind.iosSmsFilterSettings =>
        'ss_permission_sms_settings',
      PermissionRationaleKind.osSettingsDeepLink => 'ss_permission_os_settings',
      PermissionRationaleKind.localNotifications =>
        'ss_permission_notifications',
      PermissionRationaleKind.sensitiveSafetyLock =>
        'ss_permission_sensitive_lock',
    };
  }
}
