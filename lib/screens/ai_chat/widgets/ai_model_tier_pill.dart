import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/screens/ai_chat/l10n/ai_chat_strings.dart';

class AiModelTierPill extends StatelessWidget {
  const AiModelTierPill({
    super.key,
    required this.locale,
    required this.tier,
    required this.researchMode,
    this.isStreaming = false,
  });

  final String locale;
  final String? tier;
  final bool researchMode;
  final bool isStreaming;

  @override
  Widget build(BuildContext context) {
    if (!isStreaming && tier == null && !researchMode) {
      return const SizedBox.shrink();
    }

    final label = _labelFor(locale);
    final color = researchMode ? AppColors.amberGlow : AppColors.cyanGlow;

    return Container(
      margin: const EdgeInsets.only(right: AppSpacing.xs),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isStreaming)
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: SizedBox(
                width: 10,
                height: 10,
                child: CircularProgressIndicator(
                  strokeWidth: 1.5,
                  color: color,
                ),
              ),
            ),
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  String _labelFor(String locale) {
    if (researchMode) {
      return AiChatStrings.t('ai_tier_research', locale);
    }
    switch (tier?.toLowerCase()) {
      case 'sonnet':
        return AiChatStrings.t('ai_tier_sonnet', locale);
      case 'haiku':
      default:
        return AiChatStrings.t('ai_tier_haiku', locale);
    }
  }
}
