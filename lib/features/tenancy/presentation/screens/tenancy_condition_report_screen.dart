import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/widgets/glass_empty_state.dart';
import 'package:raabta/core/widgets/glass_primary_button.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/features/tenancy/domain/models/tenancy_condition_models.dart';
import 'package:raabta/features/tenancy/presentation/l10n/tenancy_strings.dart';
import 'package:raabta/features/tenancy/presentation/widgets/tenancy_widgets.dart';
import 'package:raabta/features/tenancy/providers/tenancy_condition_providers.dart';
import 'package:raabta/features/tenancy/providers/tenancy_providers.dart';
import 'package:raabta/features/tenancy/services/tenancy_pdf_service.dart';

/// Generate and share property condition PDF report.
class TenancyConditionReportScreen extends ConsumerWidget {
  const TenancyConditionReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localeAsync = ref.watch(tenancyLocaleProvider);
    final tenancy = ref.watch(tenancyProvider);
    final recordsAsync = ref.watch(tenancyConditionRecordsProvider);

    return localeAsync.when(
      loading: () => const GlassScreenScaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => const SizedBox.shrink(),
      data: (locale) {
        return GlassScreenScaffold(
          title: TenancyStrings.t('tenancy_condition_report_title', locale),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          body: recordsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) => GlassEmptyState(
              icon: Icons.picture_as_pdf_outlined,
              title: TenancyStrings.t('tenancy_condition_report_empty', locale),
              description: TenancyStrings.t('tenancy_condition_subtitle', locale),
            ),
            data: (records) {
              final moveIn = _latestRecord(
                records,
                TenancyConditionRecordType.moveIn,
              );

              if (moveIn == null) {
                return GlassEmptyState(
                  icon: Icons.picture_as_pdf_outlined,
                  title: TenancyStrings.t(
                    'tenancy_condition_report_empty',
                    locale,
                  ),
                  description: TenancyStrings.t(
                    'tenancy_condition_move_in_hint',
                    locale,
                  ),
                  actionLabel: TenancyStrings.t(
                    'tenancy_condition_start_move_in',
                    locale,
                  ),
                  onAction: () =>
                      context.push('/tenancy/condition/capture?type=moveIn'),
                );
              }

              final moveOut = _latestRecord(
                records,
                TenancyConditionRecordType.moveOut,
              );

              return Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TenancyDisclaimerBanner(locale: locale),
                    const SizedBox(height: 16),
                    Text(TenancyStrings.t('tenancy_condition_report_body', locale)),
                    const Spacer(),
                    GlassPrimaryButton(
                      label: TenancyStrings.t(
                        'tenancy_condition_generate_report',
                        locale,
                      ),
                      icon: Icons.picture_as_pdf_outlined,
                      expand: true,
                      onPressed: () async {
                        final pdf = ref.read(tenancyPdfServiceProvider);
                        final file = await pdf.generateConditionReport(
                          input: tenancy.input,
                          moveIn: moveIn,
                          moveOut: moveOut,
                          locale: locale,
                        );
                        await pdf.shareConditionReport(file, locale: locale);
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}

TenancyConditionRecord? _latestRecord(
  List<TenancyConditionRecord> records,
  TenancyConditionRecordType type,
) {
  final matches = records.where((r) => r.recordType == type).toList();
  return matches.isNotEmpty ? matches.last : null;
}
