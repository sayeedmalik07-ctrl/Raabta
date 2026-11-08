import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/jobs/cv_maker/domain/models/cv_document.dart';
import 'package:raabta/features/jobs/esco_match/domain/services/esco_skill_gap_service.dart';
import 'package:raabta/features/jobs/esco_match/presentation/l10n/esco_match_strings.dart';
import 'package:raabta/features/jobs/esco_match/presentation/widgets/esco_match_breakdown.dart';
import 'package:raabta/features/jobs/esco_match/providers/esco_match_providers.dart';
import 'package:raabta/services/ai/user_profile_ai_service.dart';

/// CV Maker panel — essential ESCO skills missing for the user's target role.
class EscoSkillGapPanel extends ConsumerWidget {
  const EscoSkillGapPanel({
    super.key,
    required this.cv,
    required this.locale,
    this.profileProfession,
  });

  final CvDocument cv;
  final String locale;
  final String? profileProfession;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gapService = ref.watch(escoSkillGapServiceProvider);
    final result = gapService.analyzeForCv(
      cv: cv,
      profileProfession: profileProfession,
      locale: locale,
    );

    if (result.noTargetRole) {
      return _infoCard(
        EscoMatchStrings.t('esco_gap_no_role', locale),
        AppColors.textSecondary,
      );
    }

    if (result.unmapped) {
      return _infoCard(
        EscoMatchStrings.tf(
          'esco_gap_unmapped_role',
          locale,
          {'role': result.targetRoleInput},
        ),
        AppColors.warning,
      );
    }

    if (!result.hasInsight) return const SizedBox.shrink();

    final roleLabel = gapService.occupationLabel(result.targetOccupation!, locale);

    if (result.missingSkills.isEmpty) {
      return _infoCard(
        EscoMatchStrings.tf('esco_gap_all_matched', locale, {'role': roleLabel}),
        AppColors.success,
      );
    }

    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.insights_outlined, color: AppColors.cyanGlow, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  EscoMatchStrings.tf(
                    'esco_gap_title',
                    locale,
                    {'role': roleLabel},
                  ),
                  style: AppTypography.subtitle.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            EscoMatchStrings.t('esco_gap_subtitle', locale),
            style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.sm),
          EscoMatchBreakdown(
            matchedSkills: result.matchedSkills,
            missingSkills: result.missingSkills,
            blockedQualifications: const [],
            overlapPercent: result.matchedSkills.isEmpty
                ? 0
                : ((result.matchedSkills.length /
                            (result.matchedSkills.length +
                                result.missingSkills.length)) *
                        100)
                    .round(),
            locale: locale,
            maxPerSection: EscoSkillGapService.displayLimit,
          ),
        ],
      ),
    );
  }

  Widget _infoCard(String message, Color accent) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: accent, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

/// Reads profile profession for gap analysis when CV has no experience title.
final cvGapProfileProfessionProvider = Provider<String?>((ref) {
  final profile = ref.watch(userAIProfileProvider);
  final profession = profile?.profession.trim();
  if (profession == null || profession.isEmpty) return null;
  return profession;
});
