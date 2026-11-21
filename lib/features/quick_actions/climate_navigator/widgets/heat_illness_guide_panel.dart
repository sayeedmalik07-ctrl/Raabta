import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_container.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_primary_button.dart';
import 'package:raabta/features/quick_actions/climate_navigator/l10n/climate_strings.dart';
import 'package:raabta/features/quick_actions/climate_navigator/widgets/climate_primitives.dart';
import 'package:raabta/models/visa_models.dart';
import 'package:url_launcher/url_launcher.dart';

/// Offline multilingual heat-illness guidance (Part C).
class HeatIllnessGuidePanel extends StatelessWidget {
  const HeatIllnessGuidePanel({
    super.key,
    required this.locale,
  });

  final String locale;

  static Future<void> showSheet(BuildContext context, String locale) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, controller) => Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated.withValues(alpha: 0.98),
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppSpacing.radiusLg),
            ),
            border: Border.all(
              color: climateAccent.withValues(alpha: 0.2),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                const SizedBox(height: AppSpacing.sm),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textOnGlassMuted.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Expanded(
                  child: SingleChildScrollView(
                    controller: controller,
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      0,
                      AppSpacing.lg,
                      AppSpacing.xl,
                    ),
                    child: HeatIllnessGuidePanel(locale: locale),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final emergency = emergencyContacts.first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                ClimateStrings.t('guide_title', locale),
                style: AppTypography.title,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: 3,
              ),
              decoration: BoxDecoration(
                color: AppColors.successBright.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
              ),
              child: Text(
                ClimateStrings.t('guide_offline', locale),
                style: AppTypography.caption.copyWith(
                  color: AppColors.successBright,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        _GuideSection(
          title: ClimateStrings.t('guide_cramps_title', locale),
          symptoms: ClimateStrings.t('guide_cramps_symptoms', locale),
          aid: ClimateStrings.t('guide_cramps_aid', locale),
          accent: AppColors.accentGold,
        ),
        _GuideSection(
          title: ClimateStrings.t('guide_exhaustion_title', locale),
          symptoms: ClimateStrings.t('guide_exhaustion_symptoms', locale),
          aid: ClimateStrings.t('guide_exhaustion_aid', locale),
          accent: AppColors.heatOrange,
        ),
        _GuideSection(
          title: ClimateStrings.t('guide_stroke_title', locale),
          symptoms: ClimateStrings.t('guide_stroke_symptoms', locale),
          aid: ClimateStrings.t('guide_stroke_aid', locale),
          accent: AppColors.errorBright,
        ),
        const SizedBox(height: AppSpacing.md),
        GlassPrimaryButton(
          label: ClimateStrings.t('guide_emergency_call', locale),
          expand: true,
          accentColor: AppColors.errorBright,
          icon: Icons.call_rounded,
          onPressed: () async {
            climateMediumHaptic();
            final uri = Uri.parse('tel:${emergency.number}');
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri);
            }
          },
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          ClimateStrings.t('guide_source_citation', locale),
          style: AppTypography.caption.copyWith(
            color: AppColors.textOnGlassMuted,
            height: 1.45,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

class _GuideSection extends StatelessWidget {
  const _GuideSection({
    required this.title,
    required this.symptoms,
    required this.aid,
    required this.accent,
  });

  final String title;
  final String symptoms;
  final String aid;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: GlassContainer(
        padding: const EdgeInsets.all(AppSpacing.md),
        borderRadius: AppSpacing.radiusSm,
        glowColor: accent,
        glowIntensity: 0.06,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTypography.subtitle.copyWith(color: accent),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              symptoms,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textOnGlassMuted,
                height: 1.45,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              aid,
              style: AppTypography.bodySmall.copyWith(height: 1.45),
            ),
          ],
        ),
      ),
    );
  }
}
