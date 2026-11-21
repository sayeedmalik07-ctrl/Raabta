import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/quick_actions/warranty_shield/l10n/warranty_strings.dart';

/// Same placement/style as [EosbDisclaimerBanner] — warranty/consumer-adapted copy.
class WarrantyDisclaimerBanner extends StatelessWidget {
  const WarrantyDisclaimerBanner({super.key, required this.locale});

  final String locale;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      backgroundColor: AppColors.warning.withValues(alpha: 0.1),
      glowColor: AppColors.warning,
      glowIntensity: 0.08,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: AppColors.warning, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              WarrantyStrings.t('warr_claim_disclaimer', locale),
              style: AppTypography.bodySmall.copyWith(color: AppColors.warning),
            ),
          ),
        ],
      ),
    );
  }
}
