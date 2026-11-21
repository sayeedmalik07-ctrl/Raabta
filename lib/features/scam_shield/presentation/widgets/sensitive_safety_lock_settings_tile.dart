import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/scam_shield/presentation/l10n/scam_shield_strings.dart';
import 'package:raabta/features/scam_shield/sensitive_lock/sensitive_safety_auth_client.dart';
import 'package:raabta/features/scam_shield/sensitive_lock/sensitive_safety_data_deleter.dart';
import 'package:raabta/features/scam_shield/sensitive_lock/sensitive_safety_lock_controller.dart';
import 'package:raabta/features/scam_shield/sensitive_lock/sensitive_safety_lock_providers.dart';

class SensitiveSafetyLockSettingsTile extends ConsumerWidget {
  const SensitiveSafetyLockSettingsTile({super.key, required this.locale});

  final String locale;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabledAsync = ref.watch(sensitiveSafetyLockEnabledProvider);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: GlassCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            enabledAsync.when(
              loading: () => const SizedBox(
                height: 48,
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              ),
              error: (_, _) => const SizedBox.shrink(),
              data: (enabled) => Material(
                type: MaterialType.transparency,
                child: SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    ScamShieldStrings.t('ss_sensitive_lock_toggle_title', locale),
                    style: AppTypography.subtitle,
                  ),
                  subtitle: Text(
                    ScamShieldStrings.t('ss_sensitive_lock_toggle_sub', locale),
                    style: AppTypography.caption,
                  ),
                  value: enabled,
                  onChanged: (next) => _onToggle(context, ref, next),
                ),
              ),
            ),
            Text(
              ScamShieldStrings.t('ss_sensitive_lock_privacy_line', locale),
              style: AppTypography.caption.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextButton(
              onPressed: () => _confirmDeleteAll(context, ref),
              child: Text(
                ScamShieldStrings.t('ss_sensitive_delete_all', locale),
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.errorBright,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onToggle(BuildContext context, WidgetRef ref, bool next) async {
    final controller = ref.read(sensitiveSafetyLockControllerProvider);
    if (next) {
      final auth = ref.read(sensitiveSafetyAuthClientProvider);
      if (!await auth.canAuthenticate()) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                ScamShieldStrings.t('ss_sensitive_lock_unavailable', locale),
              ),
            ),
          );
        }
        return;
      }
    }
    final ok = await controller.setEnabled(next);
    if (!ok && next && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ScamShieldStrings.t('ss_sensitive_lock_enable_failed', locale),
          ),
        ),
      );
    }
  }

  Future<void> _confirmDeleteAll(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(ScamShieldStrings.t('ss_sensitive_delete_title', locale)),
        content: Text(ScamShieldStrings.t('ss_sensitive_delete_body', locale)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(ScamShieldStrings.t('ss_sensitive_lock_go_back', locale)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(ScamShieldStrings.t('ss_sensitive_delete_confirm', locale)),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final controller = ref.read(sensitiveSafetyLockControllerProvider);
    final enabled = await controller.isEnabled();
    if (enabled) {
      final reason = ScamShieldStrings.t('ss_sensitive_lock_reason', locale);
      final outcome = await controller.unlock(reason: reason);
      if (outcome != SensitiveSafetyAuthOutcome.success) return;
    }

    await SensitiveSafetyDataDeleter.deleteAll();
    ref.invalidate(sensitiveSafetyLockEnabledProvider);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ScamShieldStrings.t('ss_sensitive_delete_done', locale)),
        ),
      );
    }
  }
}
