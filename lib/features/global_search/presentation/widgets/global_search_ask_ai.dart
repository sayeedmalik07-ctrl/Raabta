import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/global_search/domain/search_ask_ai_result.dart';
import 'package:raabta/features/global_search/presentation/global_search_directional_icons.dart';

/// ASK RAABTA AI card — explicit user action only (S9).
class GlobalSearchAskAiView extends StatelessWidget {
  const GlobalSearchAskAiView({
    super.key,
    required this.offer,
    required this.onTap,
  });

  final SearchAskAiResult offer;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Semantics(
        button: true,
        label: '${offer.displayTitle}. ${offer.displaySubtitle}',
        child: GlassCard(
          onTap: onTap,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              Icon(
                Icons.auto_awesome_outlined,
                size: 24,
                color: AppColors.cyanGlow,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      offer.displayTitle,
                      style: AppTypography.body.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (offer.displaySubtitle.isNotEmpty)
                      Text(
                        offer.displaySubtitle,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              Icon(
                GlobalSearchDirectionalIcons.chevronForward(context),
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
