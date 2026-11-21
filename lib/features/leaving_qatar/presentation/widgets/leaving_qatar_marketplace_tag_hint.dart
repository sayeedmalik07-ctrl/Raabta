import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/community/presentation/l10n/community_strings.dart';

/// Optional hint near Leaving Qatar checklist — tag suggestion only, never auto-applies.
class LeavingQatarMarketplaceTagHint extends StatelessWidget {
  const LeavingQatarMarketplaceTagHint({super.key, required this.locale});

  final String locale;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      glowColor: AppColors.info,
      glowIntensity: 0.1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.sell_outlined, color: AppColors.info, size: 20),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  CommunityStrings.t(
                    'community_leaving_qatar_tag_hint_title',
                    locale,
                  ),
                  style: AppTypography.subtitle.copyWith(
                    color: AppColors.info,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            CommunityStrings.t('community_leaving_qatar_tag_hint_body', locale),
            style: AppTypography.bodySmall.copyWith(height: 1.45),
          ),
        ],
      ),
    );
  }
}
