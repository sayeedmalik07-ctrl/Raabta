import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_primary_button.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/features/trip_planner/presentation/l10n/trip_strings.dart';
import 'package:raabta/features/trip_planner/providers/trip_planner_providers.dart';
import 'package:raabta/models/visa_models.dart';
import 'package:url_launcher/url_launcher.dart';

class TravelEmergencyScreen extends ConsumerWidget {
  const TravelEmergencyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(tripPlannerProvider).preferences.locale;

    return GlassScreenScaffold(
      title: TripStrings.t('travel_emergency', locale),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.pop(),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      body: ListView(
        children: [
          GlassCard(
            padding: const EdgeInsets.all(AppSpacing.md),
            glowColor: AppColors.errorBright,
            glowIntensity: 0.15,
            child: Text(
              TripStrings.t('travel_emergency_desc', locale),
              style: AppTypography.body,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          ...emergencyContacts.map(
            (c) => GlassCard(
              margin: const EdgeInsets.only(bottom: AppSpacing.sm),
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(c.name, style: AppTypography.title),
                        Text(c.description, style: AppTypography.bodySmall),
                      ],
                    ),
                  ),
                  GlassPrimaryButton(
                    label: c.number,
                    accentColor: AppColors.errorBright,
                    onPressed: () async {
                      final uri = Uri.parse('tel:${c.number}');
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          GlassPrimaryButton(
            label: TripStrings.t('travel_prayer_mosque', locale),
            icon: Icons.mosque_outlined,
            expand: true,
            onPressed: () => context.push('/prayer-mosque'),
          ),
          const SizedBox(height: AppSpacing.sm),
          GlassPrimaryButton(
            label: TripStrings.t('travel_document_vault', locale),
            icon: Icons.folder_outlined,
            expand: true,
            onPressed: () => context.push('/document-vault'),
          ),
        ],
      ),
    );
  }
}
