import 'dart:ui' as ui;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_primary_button.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/features/home/widgets/glass_loading_card.dart';
import 'package:raabta/features/home/widgets/home_section_header.dart';
import 'package:raabta/features/quick_actions/scanner/l10n/scanner_strings.dart';
import 'package:raabta/features/quick_actions/scanner/services/scanner_pdf_service.dart';
import 'package:raabta/features/quick_actions/scanner/utils/document_path_resolver.dart';
import 'package:raabta/features/quick_actions/scanner/widgets/document_thumbnail.dart';
import 'package:raabta/features/quick_actions/scanner/widgets/pdf_export_sheet.dart';
import 'package:raabta/features/quick_actions/scanner/widgets/scanner_primitives.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:share_plus/share_plus.dart';

class PdfStudioScreen extends ConsumerStatefulWidget {
  const PdfStudioScreen({super.key, this.mode = 'merge'});

  final String mode;

  @override
  ConsumerState<PdfStudioScreen> createState() => _PdfStudioScreenState();
}

class _PdfStudioScreenState extends ConsumerState<PdfStudioScreen> {
  /// Selected doc IDs in merge order.
  final _selectionOrder = <String>[];
  String? _resultMessage;
  bool _resultSuccess = false;
  bool _busy = false;
  int? _estimatedSizeKb;
  bool _estimating = false;

  String _title(String locale) {
    switch (widget.mode) {
      case 'split':
        return ScannerStrings.t('action_split', locale);
      case 'compress':
        return ScannerStrings.t('action_compress', locale);
      default:
        return ScannerStrings.t('action_merge', locale);
    }
  }

  String _hint(String locale) {
    switch (widget.mode) {
      case 'split':
        return ScannerStrings.t('pdf_split_hint', locale);
      case 'compress':
        return ScannerStrings.t('pdf_compress_hint', locale);
      default:
        return ScannerStrings.t('pdf_merge_hint', locale);
    }
  }

  void _toggleSelection(String id) {
    setState(() {
      if (_selectionOrder.contains(id)) {
        _selectionOrder.remove(id);
      } else {
        _selectionOrder.add(id);
      }
      _resultMessage = null;
      _estimatedSizeKb = null;
    });
    scannerSelectionHaptic();
    _scheduleSizeEstimate();
  }

  void _reorderSelection(int oldIndex, int newIndex) {
    setState(() {
      final id = _selectionOrder.removeAt(oldIndex);
      _selectionOrder.insert(newIndex, id);
    });
    scannerSelectionHaptic();
  }

  Future<void> _scheduleSizeEstimate() async {
    if (_selectionOrder.isEmpty) return;
    setState(() => _estimating = true);
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (!mounted || _selectionOrder.isEmpty) {
      if (mounted) setState(() => _estimating = false);
      return;
    }
    await _refreshSizeEstimate();
  }

  Future<void> _refreshSizeEstimate() async {
    final docs = _currentDocs;
    if (docs == null || _selectionOrder.isEmpty) {
      if (mounted) setState(() => _estimating = false);
      return;
    }

    final selectedDocs = _orderedSelectedDocs(docs);
    final resolver = ref.read(documentPathResolverProvider);
    final pdfService = ref.read(scannerPdfServiceProvider);

    try {
      final paths = await resolver.resolvePathsFromDocuments(selectedDocs);
      if (paths.isEmpty || !mounted) return;

      final bytes = await pdfService.buildFromImages(
        imagePaths: paths,
        options: PdfBuildOptions(
          compression: widget.mode == 'compress'
              ? PdfCompressionLevel.maximum
              : PdfCompressionLevel.medium,
          includePageNumbers: widget.mode == 'merge',
        ),
      );
      if (mounted) {
        setState(() {
          _estimatedSizeKb = bytes.length ~/ 1024;
          _estimating = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _estimating = false);
    }
  }

  List<QueryDocumentSnapshot>? _currentDocs;

  List<Map<String, dynamic>> _orderedSelectedDocs(
    List<QueryDocumentSnapshot> docs,
  ) {
    final byId = {
      for (final d in docs) d.id: d.data() as Map<String, dynamic>,
    };
    return [
      for (final id in _selectionOrder)
        if (byId.containsKey(id)) byId[id]!,
    ];
  }

  int _selectedPageCount(List<QueryDocumentSnapshot> docs) {
    final byId = {
      for (final d in docs) d.id: d.data() as Map<String, dynamic>,
    };
    var total = 0;
    for (final id in _selectionOrder) {
      final data = byId[id];
      if (data != null) {
        total += DocumentPathResolver.pageCountFor(data);
      }
    }
    return total;
  }

  Future<void> _promptExport(List<QueryDocumentSnapshot> docs) async {
    final locale = AppLocale.normalize(ref.read(userLanguageProvider));
    final defaultCompression = widget.mode == 'compress'
        ? PdfCompressionLevel.maximum
        : PdfCompressionLevel.medium;

    await PdfExportSheet.show(
      context,
      locale: locale,
      initialOptions: PdfBuildOptions(
        compression: defaultCompression,
        includePageNumbers: widget.mode == 'merge',
      ),
      showPageNumbers: widget.mode != 'split',
      onExport: (options) => _runAction(docs, options),
    );
  }

  Future<void> _runAction(
    List<QueryDocumentSnapshot> docs,
    PdfBuildOptions options,
  ) async {
    final locale = AppLocale.normalize(ref.read(userLanguageProvider));
    final pdfService = ref.read(scannerPdfServiceProvider);
    final resolver = ref.read(documentPathResolverProvider);
    final selectedDocs = _orderedSelectedDocs(docs);

    setState(() {
      _busy = true;
      _resultMessage = null;
      _resultSuccess = false;
    });
    scannerLightHaptic();

    try {
      setState(
        () => _resultMessage = ScannerStrings.t('pdf_downloading_pages', locale),
      );
      final paths = await resolver.resolvePathsFromDocuments(selectedDocs);

      if (paths.isEmpty) {
        setState(() {
          _resultMessage = ScannerStrings.t('pdf_no_local_paths', locale);
          _resultSuccess = false;
        });
        return;
      }

      if (widget.mode == 'merge') {
        final bytes = await pdfService.buildFromImages(
          imagePaths: paths,
          options: options,
        );
        final file =
            await pdfService.writeTempPdf(bytes, prefix: 'RAABTA_merged');
        await Share.shareXFiles(
          [XFile(file.path, mimeType: 'application/pdf')],
          subject: 'RAABTA Merged PDF',
        );
        setState(() {
          _resultMessage = ScannerStrings.format(
            'pdf_merged_success',
            {'count': paths.length},
            locale,
          );
          _resultSuccess = true;
        });
        scannerMediumHaptic();
      } else if (widget.mode == 'split') {
        final pdfs = await pdfService.splitImagesToPdfs(
          imagePaths: paths,
          options: options,
        );
        final files = <XFile>[];
        for (var i = 0; i < pdfs.length; i++) {
          final file = await pdfService.writeTempPdf(
            pdfs[i],
            prefix: 'RAABTA_page_${i + 1}',
          );
          files.add(XFile(file.path, mimeType: 'application/pdf'));
        }
        await Share.shareXFiles(files, subject: 'RAABTA Split PDFs');
        setState(() {
          _resultMessage = ScannerStrings.format(
            'pdf_split_success',
            {'count': files.length},
            locale,
          );
          _resultSuccess = true;
        });
        scannerMediumHaptic();
      } else {
        final result = await pdfService.compareCompression(imagePaths: paths);
        final compressed = await pdfService.compressImagesToPdf(
          imagePaths: paths,
          options: options,
        );
        final file = await pdfService.writeTempPdf(
          compressed,
          prefix: 'RAABTA_compressed',
        );
        await Share.shareXFiles(
          [XFile(file.path, mimeType: 'application/pdf')],
          subject: 'RAABTA Compressed PDF',
        );
        setState(() {
          _resultMessage = ScannerStrings.format(
            'pdf_compress_success',
            {
              'original': result.originalBytes ~/ 1024,
              'compressed': result.compressedBytes ~/ 1024,
              'saved': result.savedPercent,
            },
            locale,
          );
          _resultSuccess = true;
        });
        scannerMediumHaptic();
      }
    } catch (_) {
      setState(() {
        _resultMessage = ScannerStrings.t('pdf_failed', locale);
        _resultSuccess = false;
      });
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocale.normalize(ref.watch(userLanguageProvider));
    final isRtl = AppLocale.isRtl(locale);

    return Directionality(
      textDirection: isRtl ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: GlassScreenScaffold(
        title: _title(locale),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        padding: scannerScreenPadding,
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('scanned_documents')
              .orderBy('scanDate', descending: true)
              .limit(30)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Column(
                children: [
                  GlassLoadingCard(height: 72),
                  SizedBox(height: AppSpacing.sm),
                  GlassLoadingCard(height: 72),
                  SizedBox(height: AppSpacing.sm),
                  GlassLoadingCard(height: 72),
                ],
              );
            }

            final docs = snapshot.data!.docs;
            _currentDocs = docs;
            final pageCount = _selectedPageCount(docs);

            return ListView(
              children: [
                Text(
                  _hint(locale),
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textOnGlassMuted,
                  ),
                ),
                if (_selectionOrder.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.md),
                  GlassCard(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    glowColor: scannerAccent,
                    glowIntensity: 0.1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ScannerStrings.format(
                            'pdf_selected_summary',
                            {
                              'docs': _selectionOrder.length,
                              'pages': pageCount,
                            },
                            locale,
                          ),
                          style: AppTypography.subtitle,
                        ),
                        if (_estimating)
                          Padding(
                            padding: const EdgeInsets.only(top: AppSpacing.xs),
                            child: Text(
                              ScannerStrings.t('pdf_estimating', locale),
                              style: AppTypography.caption,
                            ),
                          )
                        else if (_estimatedSizeKb != null)
                          Padding(
                            padding: const EdgeInsets.only(top: AppSpacing.xs),
                            child: Text(
                              ScannerStrings.format(
                                'pdf_estimated_size',
                                {'size': _estimatedSizeKb!},
                                locale,
                              ),
                              style: AppTypography.caption.copyWith(
                                color: AppColors.cyanGlow,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.md),
                if (widget.mode == 'merge' && _selectionOrder.length > 1) ...[
                  HomeSectionHeader(
                    title: ScannerStrings.t('pdf_merge_order', locale),
                    leadingIcon: Icons.swap_vert_rounded,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ReorderableListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    buildDefaultDragHandles: false,
                    itemCount: _selectionOrder.length,
                    onReorderItem: _reorderSelection,
                    itemBuilder: (context, index) {
                      final id = _selectionOrder[index];
                      final doc = docs.firstWhere((d) => d.id == id);
                      final data = doc.data() as Map<String, dynamic>;
                      final name = data['displayName'] as String? ??
                          data['holderName'] as String? ??
                          ScannerStrings.t('document_fallback', locale);
                      return ReorderableDragStartListener(
                        key: ValueKey(id),
                        index: index,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                          child: GlassCard(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.sm,
                            ),
                            child: Row(
                              children: [
                                Text(
                                  '${index + 1}',
                                  style: AppTypography.caption.copyWith(
                                    color: AppColors.cyanGlow,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                DocumentThumbnail(documentData: data),
                                const SizedBox(width: AppSpacing.sm),
                                Expanded(
                                  child: Text(
                                    name,
                                    style: AppTypography.body,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Icon(Icons.drag_handle,
                                    color: AppColors.textOnGlassMuted),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
                for (final doc in docs)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: _DocumentSelectTile(
                      data: doc.data() as Map<String, dynamic>,
                      locale: locale,
                      selected: _selectionOrder.contains(doc.id),
                      onTap: () => _toggleSelection(doc.id),
                    ),
                  ),
                if (_resultMessage != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  ScannerEntranceReveal(
                    key: ValueKey(_resultMessage),
                    child: GlassCard(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      glowColor: _resultSuccess
                          ? AppColors.emeraldGlow
                          : AppColors.errorBright,
                      glowIntensity: 0.12,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            _resultSuccess
                                ? Icons.check_circle_outline
                                : Icons.error_outline,
                            color: _resultSuccess
                                ? AppColors.emeraldGlow
                                : AppColors.errorBright,
                            size: AppSpacing.iconMd,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              _resultMessage!,
                              style: AppTypography.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.lg),
                GlassPrimaryButton(
                  label: _busy
                      ? ScannerStrings.t('pdf_processing', locale)
                      : _title(locale),
                  expand: true,
                  accentColor: scannerAccent,
                  icon: _busy ? null : Icons.check_rounded,
                  onPressed: _busy || _selectionOrder.isEmpty
                      ? null
                      : () => _promptExport(docs),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _DocumentSelectTile extends StatelessWidget {
  const _DocumentSelectTile({
    required this.data,
    required this.locale,
    required this.selected,
    required this.onTap,
  });

  final Map<String, dynamic> data;
  final String locale;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final name = data['displayName'] as String? ??
        data['holderName'] as String? ??
        ScannerStrings.t('document_fallback', locale);
    final docType = data['docType'] as String? ?? '';
    final pages = DocumentPathResolver.pageCountFor(data);

    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      glowColor: selected ? scannerAccent : null,
      glowIntensity: selected ? 0.15 : 0,
      child: Row(
        children: [
          DocumentThumbnail(documentData: data),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTypography.body),
                Text(
                  docType.isEmpty
                      ? ScannerStrings.format(
                          'pages_count',
                          {'count': pages},
                          locale,
                        )
                      : '$docType · ${ScannerStrings.format('pages_count', {'count': pages}, locale)}',
                  style: AppTypography.caption,
                ),
              ],
            ),
          ),
          Icon(
            selected
                ? Icons.check_circle
                : Icons.radio_button_unchecked,
            color: selected ? scannerAccent : AppColors.textOnGlassMuted,
          ),
        ],
      ),
    );
  }
}
