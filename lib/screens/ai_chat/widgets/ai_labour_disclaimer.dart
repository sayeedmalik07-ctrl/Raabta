import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/screens/ai_chat/l10n/ai_chat_strings.dart';

class AiLabourDisclaimer extends StatelessWidget {
  const AiLabourDisclaimer({super.key, required this.locale});

  final String locale;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: AppSpacing.xs,
        left: AppSpacing.lg,
        right: AppSpacing.md,
        bottom: AppSpacing.xxs,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 12,
            color: AppColors.textOnGlassMuted.withValues(alpha: 0.8),
          ),
          const SizedBox(width: AppSpacing.xxs),
          Expanded(
            child: Text(
              AiChatStrings.t('ai_labour_disclaimer', locale),
              style: AppTypography.caption.copyWith(
                color: AppColors.textOnGlassMuted,
                fontSize: 10,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
