import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/features/daily_utilities/arabic_phrases/arabic_phrasebook_panel.dart';
import 'package:raabta/features/daily_utilities/l10n/daily_utilities_strings.dart';
import 'package:raabta/providers/visa_providers.dart';

/// Phrasebook-first Arabic Companion — live AI translator is a secondary route.
class ArabicCompanionScreen extends ConsumerWidget {
  const ArabicCompanionScreen({
    super.key,
    this.initialCategoryId,
    this.initialPhraseId,
  });

  final String? initialCategoryId;
  final String? initialPhraseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(userLanguageProvider);

    return GlassScreenScaffold(
      title: DailyUtilitiesStrings.t('companion_title', locale),
      body: ArabicPhrasebookPanel(
        initialCategoryId: initialCategoryId,
        initialPhraseId: initialPhraseId,
        header: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.md,
            AppSpacing.md,
          ),
          child: GlassCard(
            onTap: () => context.push('/arabic-companion/translate'),
            padding: const EdgeInsets.all(AppSpacing.md),
            glowColor: AppColors.cyanGlow,
            glowIntensity: 0.15,
            backgroundColor: AppColors.cyanGlow.withValues(alpha: 0.08),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.cyanGlow.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.translate_rounded,
                    color: AppColors.cyanGlow,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DailyUtilitiesStrings.t(
                          'companion_translate_cta_title',
                          locale,
                        ),
                        style: AppTypography.title.copyWith(fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DailyUtilitiesStrings.t(
                          'companion_translate_cta_subtitle',
                          locale,
                        ),
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textOnGlassMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Colors.white54),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
