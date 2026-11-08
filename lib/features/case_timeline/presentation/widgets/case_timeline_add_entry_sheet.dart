import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_primary_button.dart';
import 'package:raabta/features/case_timeline/data/checklist/case_timeline_checklist_registry.dart';
import 'package:raabta/features/case_timeline/domain/case_timeline_engine_type.dart';
import 'package:raabta/features/case_timeline/domain/case_timeline_entry_type.dart';
import 'package:raabta/features/case_timeline/presentation/l10n/case_timeline_label_resolver.dart';
import 'package:raabta/features/case_timeline/presentation/l10n/case_timeline_strings.dart';
import 'package:raabta/features/case_timeline/presentation/providers/case_timeline_providers.dart';
import 'package:raabta/features/case_timeline/presentation/widgets/case_timeline_vault_picker.dart';
import 'package:raabta/providers/auth_providers.dart';

Future<void> showCaseTimelineAddEntrySheet({
  required BuildContext context,
  required WidgetRef ref,
  required String locale,
  required CaseTimelineEngineType engine,
  required String caseId,
  CaseTimelineEntryType initialType = CaseTimelineEntryType.note,
  String? initialTitle,
  String? initialChecklistItemId,
  DateTime? initialDate,
}) async {
  final titleController = TextEditingController(text: initialTitle ?? '');
  final descController = TextEditingController();
  var entryDate = initialDate ?? DateTime.now();
  var entryType = initialType;
  String? linkedDocId;
  String? checklistItemId = initialChecklistItemId;
  var saving = false;

  final checklist = CaseTimelineChecklistRegistry.itemsFor(engine);

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusLg)),
    ),
    builder: (ctx) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Padding(
            padding: EdgeInsets.only(
              left: AppSpacing.lg,
              right: AppSpacing.lg,
              top: AppSpacing.lg,
              bottom: MediaQuery.viewInsetsOf(context).bottom + AppSpacing.lg,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    CaseTimelineStrings.t('ct_add_entry', locale),
                    style: AppTypography.title,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(CaseTimelineStrings.t('ct_entry_date', locale)),
                    subtitle: Text(
                      MaterialLocalizations.of(context)
                          .formatMediumDate(entryDate),
                    ),
                    trailing: const Icon(Icons.calendar_today_outlined),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: entryDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now().add(const Duration(days: 1)),
                      );
                      if (picked != null) setState(() => entryDate = picked);
                    },
                  ),
                  DropdownButtonFormField<CaseTimelineEntryType>(
                    value: entryType,
                    decoration: InputDecoration(
                      labelText: CaseTimelineStrings.t('ct_entry_type', locale),
                    ),
                    items: CaseTimelineEntryType.values
                        .map(
                          (t) => DropdownMenuItem(
                            value: t,
                            child: Text(
                              CaseTimelineStrings.t(
                                'ct_entry_type_${t.storageValue}',
                                locale,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => entryType = v);
                    },
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: CaseTimelineStrings.t('ct_entry_title', locale),
                      hintText: CaseTimelineStrings.t(
                        'ct_entry_title_hint',
                        locale,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextField(
                    controller: descController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText:
                          CaseTimelineStrings.t('ct_entry_description', locale),
                    ),
                  ),
                  if (checklist.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.sm),
                    DropdownButtonFormField<String?>(
                      value: checklistItemId,
                      decoration: InputDecoration(
                        labelText:
                            CaseTimelineStrings.t('ct_checklist_link', locale),
                      ),
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('—'),
                        ),
                        ...checklist.map(
                          (item) => DropdownMenuItem<String?>(
                            value: item.id,
                            child: Text(
                              CaseTimelineLabelResolver.checklistTitle(
                                engine,
                                item.titleKey,
                                locale,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                      onChanged: (v) => setState(() => checklistItemId = v),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.sm),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final picked = await showCaseTimelineVaultPicker(
                        context,
                        ref,
                        locale,
                      );
                      if (picked != null) {
                        setState(() => linkedDocId = picked);
                      }
                    },
                    icon: const Icon(Icons.attach_file),
                    label: Text(
                      linkedDocId == null
                          ? CaseTimelineStrings.t('ct_attach_document', locale)
                          : '✓ ${CaseTimelineStrings.t('ct_attach_document', locale)}',
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  GlassPrimaryButton(
                    label: saving
                        ? CaseTimelineStrings.t('ct_save', locale)
                        : CaseTimelineStrings.t('ct_save', locale),
                    expand: true,
                    onPressed: saving
                        ? null
                        : () async {
                            final uid = ref.read(currentUserProvider)?.uid;
                            if (uid == null || titleController.text.trim().isEmpty) {
                              return;
                            }
                            setState(() => saving = true);
                            try {
                              await ref
                                  .read(caseTimelineServiceProvider)
                                  .addEntry(
                                    userId: uid,
                                    engineType: engine,
                                    caseId: caseId,
                                    entryDate: entryDate,
                                    entryType: entryType,
                                    title: titleController.text,
                                    description: descController.text,
                                    linkedDocumentRef: linkedDocId,
                                    checklistItemId: checklistItemId,
                                  );
                              if (context.mounted) Navigator.pop(context);
                            } finally {
                              if (context.mounted) {
                                setState(() => saving = false);
                              }
                            }
                          },
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(CaseTimelineStrings.t('ct_cancel', locale)),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );

  titleController.dispose();
  descController.dispose();
}

/// Quick-add sponsorship SMS milestones.
Future<void> addSponsorshipMilestoneEntry({
  required WidgetRef ref,
  required String locale,
  required String caseId,
  required String titleKey,
}) async {
  final uid = ref.read(currentUserProvider)?.uid;
  if (uid == null) return;
  await ref.read(caseTimelineServiceProvider).addEntry(
        userId: uid,
        engineType: CaseTimelineEngineType.sponsorshipTransfer,
        caseId: caseId,
        entryDate: DateTime.now(),
        entryType: CaseTimelineEntryType.milestone,
        title: CaseTimelineStrings.t(titleKey, locale),
      );
}
