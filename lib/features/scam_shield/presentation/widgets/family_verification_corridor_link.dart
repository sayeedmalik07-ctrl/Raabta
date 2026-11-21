import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/scam_shield/presentation/l10n/family_verification_kit_strings.dart';

class FamilyVerificationCorridorLink extends StatelessWidget {
  const FamilyVerificationCorridorLink({super.key, required this.locale});

  final String locale;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: TextButton.icon(
          onPressed: () => context.push('/scam-shield/family-verification'),
          icon: const Icon(Icons.family_restroom_outlined, size: 18),
          label: Text(
            FamilyVerificationKitStrings.t('ss_fvk_corridor_link', locale),
            style: AppTypography.caption,
          ),
        ),
      ),
    );
  }
}
