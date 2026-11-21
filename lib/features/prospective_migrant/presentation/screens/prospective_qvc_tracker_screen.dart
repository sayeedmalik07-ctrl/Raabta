import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/features/prospective_migrant/data/qvc_stage_catalog.dart';
import 'package:raabta/features/prospective_migrant/domain/models/prospective_profile.dart';
import 'package:raabta/features/prospective_migrant/presentation/l10n/prospective_migrant_strings.dart';
import 'package:raabta/features/prospective_migrant/presentation/providers/prospective_migrant_providers.dart';
import 'package:raabta/features/prospective_migrant/presentation/widgets/prospective_flow_actions.dart';
import 'package:url_launcher/url_launcher.dart';

class ProspectiveQvcTrackerScreen extends ConsumerWidget {
  const ProspectiveQvcTrackerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(prospectiveLocaleProvider);
    final profile = ref.watch(prospectiveProfileProvider).valueOrNull ??
        const ProspectiveProfile();

    return GlassScreenScaffold(
      title: ProspectiveMigrantStrings.t('pm_qvc_heading', locale),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.pop(),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      body: ListView(
        children: [
          Text(
            ProspectiveMigrantStrings.t('pm_qvc_subtitle', locale),
            style: AppTypography.bodySmall,
          ),
          const SizedBox(height: AppSpacing.lg),
          ...QvcStageCatalog.steps.map((step) {
            final done = profile.qvcStepsChecked[step.id] == true;
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: GlassCard(
                padding: const EdgeInsets.all(AppSpacing.md),
                glowColor: done ? AppColors.success : AppColors.info,
                glowIntensity: done ? 0.14 : 0.08,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CheckboxListTile(
                      value: done,
                      onChanged: (v) => _toggle(ref, profile, step.id, v ?? false),
                      title: Text(
                        ProspectiveMigrantStrings.t(step.titleKey, locale),
                        style: AppTypography.subtitle,
                      ),
                      subtitle: Text(
                        ProspectiveMigrantStrings.t(step.descriptionKey, locale),
                        style: AppTypography.bodySmall,
                      ),
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                    ),
                    if (step.url != null)
                      TextButton(
                        onPressed: () async {
                          final uri = Uri.tryParse(step.url!);
                          if (uri != null && await canLaunchUrl(uri)) {
                            await launchUrl(
                              uri,
                              mode: LaunchMode.externalApplication,
                            );
                          }
                        },
                        child: Text(step.url!),
                      ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: AppSpacing.xl),
          const ProspectiveFlowActions(),
        ],
      ),
    );
  }

  Future<void> _toggle(
    WidgetRef ref,
    ProspectiveProfile profile,
    String stepId,
    bool value,
  ) async {
    final updated = Map<String, bool>.from(profile.qvcStepsChecked);
    updated[stepId] = value;
    await ref
        .read(prospectiveProfileProvider.notifier)
        .save(profile.copyWith(qvcStepsChecked: updated));
  }
}
