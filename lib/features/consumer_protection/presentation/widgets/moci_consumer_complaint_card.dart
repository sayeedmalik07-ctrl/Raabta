import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/consumer_protection/presentation/l10n/consumer_protection_strings.dart';
import 'package:raabta/features/consumer_protection/presentation/screens/consumer_complaint_screen.dart';

/// Reusable MOCI consumer-complaint reference (Law No. 8 of 2008).
///
/// Embed in feature screens or open standalone via [ConsumerComplaintScreen.route].
class MociConsumerComplaintCard extends StatelessWidget {
  const MociConsumerComplaintCard({
    super.key,
    required this.locale,
    this.showRegulatorContrast = true,
    this.showStandaloneLink = false,
  });

  final String locale;
  final bool showRegulatorContrast;
  final bool showStandaloneLink;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      glowColor: AppColors.cyanGlow,
      glowIntensity: 0.14,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.gavel_outlined, color: AppColors.cyanGlow, size: 22),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  ConsumerProtectionStrings.t('cp_card_title', locale),
                  style: AppTypography.subtitle.copyWith(
                    color: AppColors.cyanGlow,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            ConsumerProtectionStrings.t('cp_card_intro', locale),
            style: AppTypography.bodySmall.copyWith(height: 1.45),
          ),
          if (showRegulatorContrast) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              ConsumerProtectionStrings.t('cp_regulators_note', locale),
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
                height: 1.45,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.errorBright.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.errorBright.withValues(alpha: 0.4),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ConsumerProtectionStrings.t('cp_invoice_required_title', locale),
                  style: AppTypography.subtitle.copyWith(
                    color: AppColors.errorBright,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  ConsumerProtectionStrings.t('cp_invoice_required_body', locale),
                  style: AppTypography.bodySmall.copyWith(height: 1.45),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            ConsumerProtectionStrings.t('cp_channels', locale),
            style: AppTypography.bodySmall.copyWith(height: 1.45),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            ConsumerProtectionStrings.t('cp_enforcement', locale),
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
              height: 1.45,
            ),
          ),
          if (showStandaloneLink) ...[
            const SizedBox(height: AppSpacing.sm),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () => context.push(ConsumerComplaintScreen.route),
                child: Text(
                  ConsumerProtectionStrings.t('cp_screen_title', locale),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
