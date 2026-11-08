import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/buddy/domain/buddy_chat_safety_scanner.dart';
import 'package:raabta/features/buddy/presentation/l10n/buddy_strings.dart';

class BuddyChatSafetyBanner extends StatelessWidget {
  const BuddyChatSafetyBanner({
    super.key,
    required this.locale,
    required this.kind,
    required this.onDismiss,
  });

  final String locale;
  final BuddyChatSafetyAdvisoryKind kind;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final titleKey = switch (kind) {
      BuddyChatSafetyAdvisoryKind.platformHop => 'buddy_safety_platform_title',
      BuddyChatSafetyAdvisoryKind.financialPressure =>
        'buddy_safety_financial_title',
    };
    final bodyKey = switch (kind) {
      BuddyChatSafetyAdvisoryKind.platformHop => 'buddy_safety_platform_body',
      BuddyChatSafetyAdvisoryKind.financialPressure =>
        'buddy_safety_financial_body',
    };

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.info.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: AppColors.info, size: 22),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  BuddyStrings.t(titleKey, locale),
                  style: AppTypography.subtitle.copyWith(
                    color: AppColors.info,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  BuddyStrings.t(bodyKey, locale),
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onDismiss,
            icon: const Icon(Icons.close, size: 20),
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }
}
