import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/scam_shield/domain/scam_community_correlator.dart';
import 'package:raabta/features/scam_shield/presentation/l10n/scam_shield_strings.dart';

class ScamShieldCommunityCorrelationPanel extends StatelessWidget {
  const ScamShieldCommunityCorrelationPanel({
    super.key,
    required this.correlation,
    required this.locale,
  });

  final ScamCommunityCorrelationResult correlation;
  final String locale;

  @override
  Widget build(BuildContext context) {
    if (!correlation.hasMatches) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          ScamShieldStrings.t('ss_community_heading', locale),
          style: AppTypography.title,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          ScamShieldStrings.t('ss_community_subtitle', locale),
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textOnGlassMuted,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        ...correlation.matches.take(3).map(
          (match) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.groups_outlined, size: 16, color: AppColors.chipLease),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    ScamShieldStrings.t(match.labelKey, locale),
                    style: AppTypography.bodySmall,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          ScamShieldStrings.t('ss_community_disclaimer', locale),
          style: AppTypography.caption.copyWith(
            color: AppColors.textTertiary,
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        OutlinedButton.icon(
          onPressed: () => context.push('/community'),
          icon: const Icon(Icons.forum_outlined, size: 16),
          label: Text(ScamShieldStrings.t('ss_community_open', locale)),
        ),
      ],
    );
  }
}
