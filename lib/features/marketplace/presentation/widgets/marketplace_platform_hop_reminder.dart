import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/marketplace/presentation/l10n/marketplace_strings.dart';

/// Neutral once-per-listing reminder when a platform-hop signal is detected.
class MarketplacePlatformHopReminder extends StatelessWidget {
  const MarketplacePlatformHopReminder({
    super.key,
    required this.locale,
    required this.onDismiss,
  });

  final String locale;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final title = MarketplaceStrings.t('mp_platform_hop_reminder_title', locale);
    final body = MarketplaceStrings.t('mp_platform_hop_reminder_body', locale);
    final dismissLabel =
        MarketplaceStrings.t('mp_platform_hop_reminder_dismiss', locale);

    return Semantics(
      container: true,
      label: '$title. $body',
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.info.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: AppColors.info.withValues(alpha: 0.35)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ExcludeSemantics(
              child: Icon(
                Icons.info_outline_rounded,
                color: AppColors.info,
                size: 22,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.subtitle.copyWith(
                      color: AppColors.info,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    body,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textOnGlassSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: TextButton(
                      onPressed: onDismiss,
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.info,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                        minimumSize: const Size(48, 40),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        dismissLabel,
                        style: AppTypography.chipLabel.copyWith(
                          color: AppColors.info,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
