import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/telecom_decoder/presentation/l10n/telecom_decoder_strings.dart';

/// Visually distinct warning for easy-to-miss contract traps.
class TelecomTrapCallout extends StatelessWidget {
  const TelecomTrapCallout({
    super.key,
    required this.locale,
    required this.providerLabelKey,
    required this.titleKey,
    required this.bodyKey,
  });

  final String locale;
  final String providerLabelKey;
  final String titleKey;
  final String bodyKey;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: GlassCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        glowColor: AppColors.warning,
        glowIntensity: 0.18,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 22),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: AppColors.warning.withValues(alpha: 0.45),
                          ),
                        ),
                        child: Text(
                          TelecomDecoderStrings.t('td_trap_badge', locale),
                          style: AppTypography.caption.copyWith(
                            color: AppColors.warning,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        TelecomDecoderStrings.t(providerLabelKey, locale),
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textTertiary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        TelecomDecoderStrings.t(titleKey, locale),
                        style: AppTypography.subtitle.copyWith(
                          color: AppColors.warning,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              TelecomDecoderStrings.t(bodyKey, locale),
              style: AppTypography.bodySmall.copyWith(height: 1.45),
            ),
          ],
        ),
      ),
    );
  }
}
