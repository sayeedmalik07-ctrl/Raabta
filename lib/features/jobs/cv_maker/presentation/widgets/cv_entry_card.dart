import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/jobs/cv_maker/providers/cv_providers.dart';

class CvEntryCard extends ConsumerWidget {
  const CvEntryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasCvAsync = ref.watch(hasSavedCvProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.md,
        0,
      ),
      child: hasCvAsync.when(
        loading: () => const SizedBox.shrink(),
        error: (_, _) => _card(
          context,
          title: 'Build My CV',
          subtitle: 'AI-assisted CV in minutes — mostly pre-filled from your profile.',
          onTap: () => context.push('/jobs/cv-start'),
        ),
        data: (hasCv) => _card(
          context,
          title: hasCv ? 'View / Update My CV' : 'Build My CV',
          subtitle: hasCv
              ? 'Your CV is saved in Document Vault — update or attach to applications.'
              : 'AI-assisted CV in minutes — mostly pre-filled from your profile.',
          onTap: () => context.push('/jobs/cv-start'),
        ),
      ),
    );
  }

  Widget _card(
    BuildContext context, {
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      borderRadius: AppSpacing.radiusLg,
      glowColor: AppColors.purpleGlow,
      glowIntensity: 0.1,
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.purpleGlow.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: Icon(Icons.description_outlined, color: AppColors.purpleGlow),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.title),
                const SizedBox(height: AppSpacing.xs),
                Text(subtitle, style: AppTypography.body),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}
