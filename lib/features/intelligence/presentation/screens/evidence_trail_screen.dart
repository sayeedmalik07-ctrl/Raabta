import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_primary_button.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/core/widgets/legal_deadline_engine_widgets.dart';
import 'package:raabta/features/eosb/data/migrant_support_catalog.dart';
import 'package:raabta/features/eosb/providers/eosb_providers.dart';
import 'package:raabta/features/intelligence/presentation/providers/evidence_trail_providers.dart';
import 'package:raabta/features/intelligence/presentation/widgets/evidence_attachment_preview.dart';
import 'package:raabta/models/intelligence/evidence_attachment_metadata.dart';
import 'package:raabta/models/intelligence/evidence_entry.dart';
import 'package:raabta/providers/auth_providers.dart';
import 'package:raabta/services/intelligence/evidence_attachment_service.dart';
import 'package:raabta/services/intelligence/evidence_pdf_service.dart';
import 'package:raabta/services/intelligence/evidence_service.dart';
import 'package:url_launcher/url_launcher.dart';

/// Append-only labour evidence log — deterministic, zero AI.
class EvidenceTrailScreen extends ConsumerStatefulWidget {
  const EvidenceTrailScreen({super.key});

  @override
  ConsumerState<EvidenceTrailScreen> createState() => _EvidenceTrailScreenState();
}

class _EvidenceTrailScreenState extends ConsumerState<EvidenceTrailScreen> {
  bool _exporting = false;
  Map<String, EvidenceAttachmentSummary> _attachmentCache = {};

  Future<void> _openAddEntrySheet() async {
    final uid = ref.read(currentUserProvider)?.uid;
    if (uid == null) return;

    final noteController = TextEditingController();
    var claimType = EvidenceClaimTypes.unpaidWages;
    var entryDate = DateTime.now();
    EvidencePhotoAttachment? attachment;
    var attaching = false;

    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusLg)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            top: AppSpacing.lg,
            bottom: MediaQuery.viewInsetsOf(ctx).bottom + AppSpacing.lg,
          ),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Add evidence entry', style: AppTypography.headline2),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Entries cannot be edited after saving — only added to. '
                      'Write what happened in your own words.',
                      style: AppTypography.caption.copyWith(color: AppColors.warning),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    DropdownButtonFormField<String>(
                      initialValue: claimType,
                      decoration: const InputDecoration(labelText: 'Claim type'),
                      items: EvidenceClaimTypes.all
                          .map(
                            (type) => DropdownMenuItem(
                              value: type,
                              child: Text(EvidenceClaimTypes.labelFor(type)),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setModalState(() => claimType = value);
                      },
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Incident date'),
                      subtitle: Text(
                        '${entryDate.year}-${entryDate.month.toString().padLeft(2, '0')}-${entryDate.day.toString().padLeft(2, '0')}',
                      ),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: entryDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          setModalState(() => entryDate = picked);
                        }
                      },
                    ),
                    TextField(
                      controller: noteController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'Your note (required)',
                        hintText: 'What happened, when, who was involved…',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Optional photo attachment',
                      style: AppTypography.subtitle.copyWith(fontSize: 14),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Photos taken here include a capture timestamp. '
                      'Gallery uploads are supported but labeled as unverified.',
                      style: AppTypography.caption,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: attaching
                                ? null
                                : () async {
                                    final requestLocation =
                                        await showEvidenceLocationCaptureDialog(
                                              context,
                                            ) ??
                                            false;
                                    setModalState(() => attaching = true);
                                    try {
                                      final picked = await ref
                                          .read(
                                            evidenceAttachmentServiceProvider,
                                          )
                                          .captureFromCamera(
                                            requestLocation: requestLocation,
                                          );
                                      if (picked != null) {
                                        setModalState(
                                          () => attachment = picked,
                                        );
                                      }
                                    } finally {
                                      setModalState(() => attaching = false);
                                    }
                                  },
                            icon: const Icon(Icons.photo_camera_outlined),
                            label: const Text('Take photo'),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: attaching
                                ? null
                                : () async {
                                    setModalState(() => attaching = true);
                                    try {
                                      final picked = await ref
                                          .read(
                                            evidenceAttachmentServiceProvider,
                                          )
                                          .pickFromGallery();
                                      if (picked != null) {
                                        setModalState(
                                          () => attachment = picked,
                                        );
                                      }
                                    } finally {
                                      setModalState(() => attaching = false);
                                    }
                                  },
                            icon: const Icon(Icons.photo_library_outlined),
                            label: const Text('From gallery'),
                          ),
                        ),
                      ],
                    ),
                    if (attaching) ...[
                      const SizedBox(height: AppSpacing.sm),
                      const LinearProgressIndicator(minHeight: 2),
                    ],
                    if (attachment != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      EvidenceAttachmentPreview(
                        entry: EvidenceEntry(
                          id: '',
                          userId: uid,
                          entryDate: entryDate,
                          note: '',
                          claimType: claimType,
                          createdAt: DateTime.now(),
                          attachmentDocumentId: attachment!.documentId,
                          attachmentCaptureSource:
                              attachment!.captureSourceValue,
                          attachmentCapturedAt: attachment!.capturedAt,
                          attachmentCapturedLatitude:
                              attachment!.capturedLatitude,
                          attachmentCapturedLongitude:
                              attachment!.capturedLongitude,
                          attachmentUploadedAt: attachment!.uploadedAt,
                        ),
                        summary: EvidenceAttachmentSummary(
                          documentId: attachment!.documentId,
                          label: attachment!.captureSource ==
                                  EvidenceAttachmentCaptureSource.gallery
                              ? 'Gallery photo'
                              : 'Captured photo',
                          localImagePath: attachment!.localImagePath,
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () =>
                              setModalState(() => attachment = null),
                          child: const Text('Remove photo'),
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.lg),
                    GlassPrimaryButton(
                      label: 'Save entry (immutable)',
                      expand: true,
                      onPressed: () => Navigator.pop(ctx, true),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );

    if (saved != true || noteController.text.trim().isEmpty) return;

    try {
      await ref.read(evidenceServiceProvider).recordEntry(
            userId: uid,
            entryDate: entryDate,
            note: noteController.text,
            claimType: claimType,
            attachment: attachment,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Evidence entry saved — cannot be edited')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save entry: $e')),
        );
      }
    }
  }

  Future<Map<String, EvidenceAttachmentSummary>> _loadAttachments(
    List<EvidenceEntry> entries,
  ) async {
    final ids = entries
        .map((e) => e.attachmentDocumentId)
        .whereType<String>()
        .toSet();
    if (ids.isEmpty) return {};

    final summaries = <String, EvidenceAttachmentSummary>{};
    for (final id in ids) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('scanned_documents')
            .doc(id)
            .get();
        if (!doc.exists) continue;
        final data = doc.data() ?? {};
        summaries[id] = EvidenceAttachmentSummary(
          documentId: id,
          label: data['displayName'] as String? ??
              data['holderName'] as String? ??
              id,
          category: data['category'] as String?,
          imageUrl: data['imageUrl'] as String?,
          localImagePath: (data['localImagePath'] as String?) ??
              ((data['pagePaths'] as List?)?.isNotEmpty == true
                  ? (data['pagePaths'] as List).first as String?
                  : null),
        );
      } catch (_) {}
    }
    return summaries;
  }

  Future<void> _refreshAttachmentCache(List<EvidenceEntry> entries) async {
    final loaded = await _loadAttachments(entries);
    if (!mounted) return;
    setState(() => _attachmentCache = loaded);
  }

  Future<void> _exportPdf(List<EvidenceEntry> entries) async {
    if (entries.isEmpty || _exporting) return;
    setState(() => _exporting = true);
    try {
      final attachments = await _loadAttachments(entries);
      final file = await ref.read(evidencePdfServiceProvider).generateTrail(
            entries: entries,
            attachmentsById: attachments,
          );
      await ref.read(evidencePdfServiceProvider).shareTrail(file);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  Future<void> _openOfficialChannel(String? url) async {
    if (url == null || url.isEmpty) return;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final entriesAsync = ref.watch(evidenceEntriesProvider);
    final eosbLocaleAsync = ref.watch(eosbLocaleProvider);
    final eosbInput = ref.watch(eosbProvider).input;
    final ordered = entriesAsync.valueOrNull == null
        ? const <EvidenceEntry>[]
        : EvidenceService.sortedForExport(entriesAsync.valueOrNull!);

    return GlassScreenScaffold(
      title: 'Evidence Trail',
      leading: GlassIconButton(
        icon: Icons.arrow_back,
        tooltip: 'Back',
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: [
        GlassIconButton(
          icon: Icons.picture_as_pdf_outlined,
          tooltip: 'Export PDF',
          onPressed: ordered.isEmpty || _exporting
              ? null
              : () => _exportPdf(ordered),
        ),
      ],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GlassCard(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Build your dispute evidence before you need it',
                  style: AppTypography.subtitle,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Human-written, dated entries with optional Document Vault attachments. '
                  'Entries cannot be edited after saving — add a new entry to supplement.',
                  style: AppTypography.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          eosbLocaleAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
            data: (locale) {
              if (eosbInput.lastWorkingDate == null) {
                return const SizedBox.shrink();
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  LegalDeadlineEngineWidgets.eosb(
                    locale: locale,
                    input: eosbInput,
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
              );
            },
          ),
          Expanded(
            child: entriesAsync.when(
              data: (entries) {
                if (entries.isEmpty) {
                  return Center(
                    child: Text(
                      'No evidence entries yet.\nTap + to log your first incident.',
                      style: AppTypography.body.copyWith(color: AppColors.textTertiary),
                      textAlign: TextAlign.center,
                    ),
                  );
                }
                if (_attachmentCache.isEmpty &&
                    entries.any((e) => e.attachmentDocumentId != null)) {
                  _refreshAttachmentCache(entries);
                }
                final chronological = EvidenceService.sortedForExport(entries);
                return ListView.builder(
                  itemCount: chronological.length,
                  itemBuilder: (context, index) {
                    final entry = chronological[chronological.length - 1 - index];
                    return GlassCard(
                      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            EvidenceClaimTypes.labelFor(entry.claimType),
                            style: AppTypography.title.copyWith(fontSize: 14),
                          ),
                          Text(
                            'Incident: ${entry.entryDate.toLocal().toString().split(' ').first}',
                            style: AppTypography.caption,
                          ),
                          if (entry.supersedesEntryId != null)
                            Text(
                              'Supplements entry ${entry.supersedesEntryId}',
                              style: AppTypography.caption.copyWith(
                                color: AppColors.info,
                              ),
                            ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(entry.note, style: AppTypography.body),
                          if (entry.attachmentDocumentId != null) ...[
                            const SizedBox(height: AppSpacing.sm),
                            EvidenceAttachmentPreview(
                              entry: entry,
                              summary: _attachmentCache[entry.attachmentDocumentId],
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.cyanGlow),
              ),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text('Official channels (Raabta does not file for you)',
              style: AppTypography.caption),
          const SizedBox(height: AppSpacing.xs),
          Wrap(
            spacing: AppSpacing.sm,
            children: MigrantSupportCatalog.qatarProcedureChannels
                .where((c) => c.url != null)
                .map(
                  (channel) => ActionChip(
                    label: Text(channel.titleKey.replaceAll('eosb_qatar_', '')),
                    onPressed: () => _openOfficialChannel(channel.url),
                  ),
                )
                .toList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddEntrySheet,
        backgroundColor: AppColors.cyanGlow,
        icon: const Icon(Icons.add),
        label: const Text('Add entry'),
      ),
    );
  }
}
