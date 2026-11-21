import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_primary_button.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/features/case_timeline/domain/case_timeline_engine_type.dart';
import 'package:raabta/features/case_timeline/presentation/navigation/case_timeline_navigation.dart';
import 'package:raabta/features/case_timeline/presentation/widgets/case_timeline_link_button.dart';
import 'package:raabta/features/tenancy/data/tenancy_dispute_checklist_catalog.dart';
import 'package:raabta/features/tenancy/domain/models/tenancy_condition_models.dart';
import 'package:raabta/features/tenancy/presentation/l10n/tenancy_strings.dart';
import 'package:raabta/features/tenancy/presentation/widgets/tenancy_widgets.dart';
import 'package:raabta/features/tenancy/providers/tenancy_condition_providers.dart';
import 'package:raabta/features/tenancy/providers/tenancy_providers.dart';

class TenancyDisputeChecklistScreen extends ConsumerWidget {
  const TenancyDisputeChecklistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localeAsync = ref.watch(tenancyLocaleProvider);
    final state = ref.watch(tenancyProvider);
    final collected = state.checklistCollected;
    final recordsAsync = ref.watch(tenancyConditionRecordsProvider);
    final total = TenancyDisputeChecklistCatalog.items.length;

    return localeAsync.when(
      loading: () => const GlassScreenScaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => const SizedBox.shrink(),
      data: (locale) {
        return GlassScreenScaffold(
          title: TenancyStrings.t('tenancy_checklist_title', locale),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          padding: const EdgeInsets.all(AppSpacing.lg),
          body: ListView(
            children: [
              TenancyDisclaimerBanner(locale: locale),
              const SizedBox(height: AppSpacing.md),
              Text(
                TenancyStrings.t('tenancy_checklist_subtitle', locale),
                style: AppTypography.bodySmall,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                TenancyStrings.format('tenancy_checklist_progress', locale, {
                  'collected': collected.length.toString(),
                  'total': total.toString(),
                }),
                style: AppTypography.caption.copyWith(color: AppColors.cyanGlow),
              ),
              const SizedBox(height: AppSpacing.lg),
              for (final def in TenancyDisputeChecklistCatalog.items) ...[
                recordsAsync.when(
                  loading: () => const SizedBox.shrink(),
                  error: (_, _) => const SizedBox.shrink(),
                  data: (records) {
                    final hasCondition = def.id == 'property_condition_record' &&
                        records.any(
                          (r) =>
                              r.recordType ==
                              TenancyConditionRecordType.moveIn,
                        );
                    final isCollected = collected.contains(def.id) ||
                        hasCondition;

                    return GlassCard(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CheckboxListTile(
                            contentPadding: EdgeInsets.zero,
                            value: isCollected,
                            onChanged: def.id == 'property_condition_record' &&
                                    hasCondition
                                ? null
                                : (v) => ref
                                    .read(tenancyProvider.notifier)
                                    .toggleChecklistItem(def.id, v ?? false),
                            title: Text(
                              TenancyStrings.t(def.titleKey, locale),
                              style: AppTypography.body.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              hasCondition
                                  ? TenancyStrings.t(
                                      'tenancy_checklist_condition_ready',
                                      locale,
                                    )
                                  : TenancyStrings.t(def.subtitleKey, locale),
                              style: AppTypography.caption,
                            ),
                            activeColor: AppColors.chipLease,
                          ),
                          if (def.scannerRoute != null) ...[
                            const SizedBox(height: AppSpacing.xs),
                            Wrap(
                              spacing: 8,
                              children: [
                                TextButton.icon(
                                  onPressed: () =>
                                      context.push(def.scannerRoute!),
                                  icon: Icon(
                                    def.id == 'property_condition_record'
                                        ? Icons.photo_camera_outlined
                                        : Icons.document_scanner_outlined,
                                    size: 18,
                                  ),
                                  label: Text(
                                    def.id == 'property_condition_record'
                                        ? TenancyStrings.t(
                                            'tenancy_dashboard_condition_cta',
                                            locale,
                                          )
                                        : TenancyStrings.t(
                                            'tenancy_checklist_scan_lease',
                                            locale,
                                          ),
                                  ),
                                ),
                                if (def.vaultRoute != null)
                                  TextButton.icon(
                                    onPressed: () =>
                                        context.push(def.vaultRoute!),
                                    icon: const Icon(
                                      Icons.folder_copy_outlined,
                                      size: 18,
                                    ),
                                    label: Text(
                                      TenancyStrings.t(
                                        'tenancy_checklist_open_vault',
                                        locale,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.sm),
              ],
              const SizedBox(height: AppSpacing.md),
              if (state.result != null)
                CaseTimelineLinkButton(
                  engine: CaseTimelineEngineType.tenancy,
                  caseId: CaseTimelineNavigation.tenancyCaseIdFromCheckedAt(
                    state.result!.checkedAt,
                  ),
                  locale: locale,
                ),
              const SizedBox(height: AppSpacing.md),
              GlassPrimaryButton(
                label: TenancyStrings.t('tenancy_documents_title', locale),
                expand: true,
                accentColor: AppColors.chipLease,
                icon: Icons.picture_as_pdf_outlined,
                onPressed: () => context.push('/tenancy/documents'),
              ),
            ],
          ),
        );
      },
    );
  }
}
