import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_primary_button.dart';
import 'package:raabta/features/prospective_migrant/presentation/l10n/prospective_migrant_strings.dart';
import 'package:raabta/features/prospective_migrant/presentation/providers/prospective_migrant_providers.dart';
import 'package:raabta/features/prospective_migrant/services/prospective_arrival_migration_service.dart';

class ProspectiveFlowActions extends ConsumerWidget {
  const ProspectiveFlowActions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(prospectiveLocaleProvider);
    final profileAsync = ref.watch(prospectiveProfileProvider);
    final preview = ref.watch(prospectivePreviewResultProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          ProspectiveMigrantStrings.t('pm_export_pdf_hint', locale),
          style: AppTypography.caption,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.sm),
        OutlinedButton.icon(
          onPressed: profileAsync.isLoading
              ? null
              : () async {
                  final profile = profileAsync.valueOrNull;
                  if (profile == null) return;
                  final pdf = ref.read(prospectivePdfServiceProvider);
                  final file = await pdf.generate(
                    profile: profile,
                    previewResult: preview,
                    locale: locale,
                  );
                  if (!context.mounted) return;
                  await pdf.share(file, locale);
                },
          icon: const Icon(Icons.picture_as_pdf_outlined),
          label: Text(ProspectiveMigrantStrings.t('pm_export_pdf', locale)),
        ),
        const SizedBox(height: AppSpacing.sm),
        GlassPrimaryButton(
          label: ProspectiveMigrantStrings.t('pm_arrived_cta', locale),
          icon: Icons.flight_land_outlined,
          expand: true,
          accentColor: AppColors.purpleGlow,
          onPressed: profileAsync.valueOrNull?.contractIntakeComplete == true
              ? () async {
                  await ProspectiveArrivalMigrationService.markArrivalPending();
                  if (!context.mounted) return;
                  context.go('/login?arrival=1');
                }
              : null,
        ),
      ],
    );
  }
}
