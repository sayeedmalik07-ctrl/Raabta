import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/scam_shield/checkup/scam_checkup_catalog.dart';
import 'package:raabta/features/scam_shield/checkup/scam_checkup_deep_link.dart';
import 'package:raabta/features/scam_shield/checkup/scam_checkup_models.dart';
import 'package:raabta/features/scam_shield/platform/scam_proactive_protection_platform.dart';
import 'package:raabta/features/scam_shield/presentation/l10n/scam_shield_strings.dart';

class ScamCheckupItemTile extends StatelessWidget {
  const ScamCheckupItemTile({
    super.key,
    required this.item,
    required this.locale,
    required this.checked,
    required this.onCheckedChanged,
    this.proactive,
  });

  final ScamCheckupItem item;
  final String locale;
  final bool checked;
  final ValueChanged<bool> onCheckedChanged;
  final ScamProactiveProtectionStatus? proactive;

  bool get _phase7Locked {
    final key = item.phase7StatusKey;
    if (key == null || proactive == null) return false;
    if (!ScamCheckupCatalog.phase7Detectable(key)) return false;
    return switch (key) {
      ScamCheckupPhase7StatusKey.callScreeningActive =>
        proactive!.callScreeningActive,
      ScamCheckupPhase7StatusKey.smsFilterUserConfirmed =>
        proactive!.smsFilterUserConfirmed,
    };
  }

  @override
  Widget build(BuildContext context) {
    final title = ScamShieldStrings.t(item.titleKey, locale);
    final why = ScamShieldStrings.t(item.whyKey, locale);
    final verifiedLabel = item.lastVerified != null
        ? item.lastVerified!.toIso8601String().split('T').first
        : null;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: GlassCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Material(
              type: MaterialType.transparency,
              child: CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                value: checked || _phase7Locked,
                onChanged: _phase7Locked
                    ? null
                    : (v) => onCheckedChanged(v ?? false),
                title: Text(title, style: AppTypography.subtitle),
                subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(why, style: AppTypography.bodySmall),
                  if (_phase7Locked) ...[
                    const SizedBox(height: 4),
                    Text(
                      ScamShieldStrings.t('ss_checkup_phase7_on', locale),
                      style: AppTypography.caption.copyWith(
                        color: AppColors.success,
                      ),
                    ),
                  ] else ...[
                    const SizedBox(height: 4),
                    Text(
                      ScamShieldStrings.t('ss_checkup_self_attest', locale),
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textTertiary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
              ),
            ),
            Text(
              ScamShieldStrings.t('ss_checkup_steps_may_differ', locale),
              style: AppTypography.caption.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
            if (verifiedLabel != null) ...[
              const SizedBox(height: 4),
              Text(
                ScamShieldStrings.format(
                  'ss_checkup_last_verified',
                  locale,
                  {'date': verifiedLabel},
                ),
                style: AppTypography.caption,
              ),
            ],
            const SizedBox(height: AppSpacing.sm),
            for (var i = 0; i < item.stepKeys.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: Text(
                  '${i + 1}. ${ScamShieldStrings.t(item.stepKeys[i], locale)}',
                  style: AppTypography.bodySmall,
                ),
              ),
            if (item.deepLink != ScamCheckupDeepLink.none)
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: TextButton(
                  onPressed: () =>
                      ScamCheckupDeepLinkLauncher.launch(
                        context,
                        item.deepLink,
                        locale: locale,
                      ),
                  child: Text(
                    ScamShieldStrings.t('ss_checkup_open_settings', locale),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
