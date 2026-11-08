import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/scam_shield/presentation/l10n/scam_shield_strings.dart';

/// Quiet navigation row in the ScamShield hub settings strip (not Home).
class ScamCheckupSettingsTile extends StatelessWidget {
  const ScamCheckupSettingsTile({super.key, required this.locale});

  final String locale;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        onTap: () => context.push('/scam-shield/checkup'),
        child: Material(
          type: MaterialType.transparency,
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              ScamShieldStrings.t('ss_checkup_hub_title', locale),
              style: AppTypography.subtitle,
            ),
            subtitle: Text(
              ScamShieldStrings.t('ss_checkup_hub_sub', locale),
              style: AppTypography.caption,
            ),
            trailing: const Icon(Icons.chevron_right),
          ),
        ),
      ),
    );
  }
}
