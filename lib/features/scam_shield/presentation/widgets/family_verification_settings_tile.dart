import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/scam_shield/presentation/l10n/family_verification_kit_strings.dart';

class FamilyVerificationSettingsTile extends StatelessWidget {
  const FamilyVerificationSettingsTile({super.key, required this.locale});

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
        onTap: () => context.push('/scam-shield/family-verification'),
        child: Material(
          type: MaterialType.transparency,
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              FamilyVerificationKitStrings.t('ss_fvk_hub_title', locale),
              style: AppTypography.subtitle,
            ),
            subtitle: Text(
              FamilyVerificationKitStrings.t('ss_fvk_hub_sub', locale),
              style: AppTypography.caption,
            ),
            trailing: const Icon(Icons.chevron_right),
          ),
        ),
      ),
    );
  }
}
