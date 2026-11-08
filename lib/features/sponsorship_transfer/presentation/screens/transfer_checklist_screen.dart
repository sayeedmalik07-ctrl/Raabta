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
import 'package:raabta/features/case_timeline/presentation/l10n/case_timeline_strings.dart';
import 'package:raabta/features/case_timeline/presentation/navigation/case_timeline_navigation.dart';
import 'package:raabta/features/case_timeline/presentation/widgets/case_timeline_add_entry_sheet.dart';
import 'package:raabta/features/case_timeline/presentation/widgets/case_timeline_link_button.dart';
import 'package:raabta/features/sponsorship_transfer/data/transfer_document_checklist_catalog.dart';
import 'package:raabta/features/sponsorship_transfer/presentation/l10n/sponsorship_transfer_strings.dart';
import 'package:raabta/features/sponsorship_transfer/presentation/widgets/sponsorship_transfer_widgets.dart';
import 'package:raabta/features/sponsorship_transfer/providers/sponsorship_transfer_providers.dart';

class TransferChecklistScreen extends ConsumerWidget {
  const TransferChecklistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localeAsync = ref.watch(sponsorshipTransferLocaleProvider);
    final collected = ref.watch(sponsorshipTransferProvider).checklistCollected;
    final result = ref.watch(sponsorshipTransferProvider).result;

    return localeAsync.when(
      loading: () => const GlassScreenScaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => const SizedBox.shrink(),
      data: (locale) {
        return GlassScreenScaffold(
          title: SponsorshipTransferStrings.t('st_checklist_title', locale),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          padding: const EdgeInsets.all(AppSpacing.lg),
          body: ListView(
            children: [
              SponsorshipTransferDisclaimerBanner(locale: locale),
              const SizedBox(height: AppSpacing.md),
              Text(
                SponsorshipTransferStrings.t('st_checklist_subtitle', locale),
                style: AppTypography.bodySmall,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                SponsorshipTransferStrings.format('st_checklist_progress', locale, {
                  'collected': collected.length.toString(),
                  'total': TransferDocumentChecklistCatalog.all.length.toString(),
                }),
                style: AppTypography.caption.copyWith(color: AppColors.cyanGlow),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                SponsorshipTransferStrings.t('st_checklist_verified_section', locale),
                style: AppTypography.title,
              ),
              const SizedBox(height: AppSpacing.sm),
              for (final def in TransferDocumentChecklistCatalog.verifiedItems) ...[
                _ChecklistTile(def: def, locale: locale, collected: collected),
                const SizedBox(height: AppSpacing.sm),
              ],
              const SizedBox(height: AppSpacing.md),
              Text(
                SponsorshipTransferStrings.t('st_checklist_informal_section', locale),
                style: AppTypography.title.copyWith(color: AppColors.textTertiary),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                SponsorshipTransferStrings.t('st_checklist_informal_note', locale),
                style: AppTypography.caption.copyWith(
                  color: AppColors.textTertiary,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              for (final def in TransferDocumentChecklistCatalog.informalItems) ...[
                _ChecklistTile(def: def, locale: locale, collected: collected),
                const SizedBox(height: AppSpacing.sm),
              ],
              const SizedBox(height: AppSpacing.md),
              if (result != null) ...[
                Text(
                  CaseTimelineStrings.t('ct_subtitle', locale),
                  style: AppTypography.caption,
                ),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    for (final key in [
                      'st_milestone_app_submitted',
                      'st_milestone_employer_sms',
                      'st_milestone_notice_begins',
                      'st_milestone_both_parties_sms',
                    ])
                      ActionChip(
                        label: Text(
                          CaseTimelineStrings.t(key, locale),
                          style: AppTypography.caption,
                        ),
                        onPressed: () => addSponsorshipMilestoneEntry(
                          ref: ref,
                          locale: locale,
                          caseId:
                              CaseTimelineNavigation.sponsorshipCaseIdFromCheckedAt(
                            result.checkedAt,
                          ),
                          titleKey: key,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                CaseTimelineLinkButton(
                  engine: CaseTimelineEngineType.sponsorshipTransfer,
                  caseId: CaseTimelineNavigation.sponsorshipCaseIdFromCheckedAt(
                    result.checkedAt,
                  ),
                  locale: locale,
                ),
                const SizedBox(height: AppSpacing.md),
              ],
              GlassPrimaryButton(
                label: SponsorshipTransferStrings.t('st_documents_title', locale),
                expand: true,
                accentColor: AppColors.chipSponsorshipTransfer,
                icon: Icons.picture_as_pdf_outlined,
                onPressed: () => context.push('/sponsorship-transfer/documents'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ChecklistTile extends ConsumerWidget {
  const _ChecklistTile({
    required this.def,
    required this.locale,
    required this.collected,
  });

  final TransferChecklistItemDef def;
  final String locale;
  final Set<String> collected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accent = def.informal
        ? AppColors.textTertiary
        : AppColors.chipSponsorshipTransfer;

    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      glowColor: accent.withValues(alpha: def.informal ? 0.15 : 0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            value: collected.contains(def.id),
            onChanged: (v) => ref
                .read(sponsorshipTransferProvider.notifier)
                .toggleChecklistItem(def.id, v ?? false),
            title: Text(
              SponsorshipTransferStrings.t(def.titleKey, locale),
              style: AppTypography.body.copyWith(
                fontWeight: FontWeight.w600,
                color: def.informal ? AppColors.textSecondary : null,
              ),
            ),
            subtitle: Text(
              SponsorshipTransferStrings.t(def.subtitleKey, locale),
              style: AppTypography.caption,
            ),
            activeColor: accent,
          ),
          if (def.scannerRoute != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Wrap(
              spacing: 8,
              children: [
                TextButton.icon(
                  onPressed: () => context.push(def.scannerRoute!),
                  icon: const Icon(Icons.document_scanner_outlined, size: 18),
                  label: Text(
                    SponsorshipTransferStrings.t('st_checklist_scan', locale),
                  ),
                ),
                if (def.vaultRoute != null)
                  TextButton.icon(
                    onPressed: () => context.push(def.vaultRoute!),
                    icon: const Icon(Icons.folder_copy_outlined, size: 18),
                    label: Text(
                      SponsorshipTransferStrings.t('st_checklist_open_vault', locale),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
