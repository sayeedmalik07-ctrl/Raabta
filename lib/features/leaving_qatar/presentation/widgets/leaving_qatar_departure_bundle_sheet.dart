import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_primary_button.dart';
import 'package:raabta/core/widgets/glass_secondary_button.dart';
import 'package:raabta/features/leaving_qatar/data/models/leaving_qatar_models.dart';
import 'package:raabta/features/leaving_qatar/presentation/l10n/leaving_qatar_strings.dart';
import 'package:raabta/features/leaving_qatar/providers/leaving_qatar_providers.dart';
import 'package:raabta/features/leaving_qatar/services/leaving_qatar_departure_bundle_service.dart';
import 'package:raabta/features/quick_actions/scanner/l10n/scanner_strings.dart';
import 'package:raabta/features/quick_actions/scanner/services/scanner_pdf_service.dart';
import 'package:raabta/features/quick_actions/scanner/utils/document_path_resolver.dart';
import 'package:raabta/features/quick_actions/scanner/widgets/pdf_export_sheet.dart';
import 'package:raabta/features/quick_actions/scanner/widgets/scanner_primitives.dart';
import 'package:raabta/providers/auth_providers.dart';
import 'package:share_plus/share_plus.dart';

class LeavingQatarDepartureBundleSheet extends ConsumerStatefulWidget {
  const LeavingQatarDepartureBundleSheet({super.key, required this.locale});

  final String locale;

  static Future<void> show(BuildContext context, {required String locale}) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => LeavingQatarDepartureBundleSheet(locale: locale),
    );
  }

  @override
  ConsumerState<LeavingQatarDepartureBundleSheet> createState() =>
      _LeavingQatarDepartureBundleSheetState();
}

class _LeavingQatarDepartureBundleSheetState
    extends ConsumerState<LeavingQatarDepartureBundleSheet> {
  List<LeavingQatarBundleDocument> _docs = const [];
  Set<LeavingQatarBundleCategory> _missing = const {};
  final _selected = <String>{};
  bool _loading = true;
  bool _exporting = false;
  String? _message;
  bool _success = false;

  @override
  void initState() {
    super.initState();
    _loadDocs();
  }

  Future<void> _loadDocs() async {
    final uid = ref.read(currentUserProvider)?.uid;
    if (uid == null) {
      if (mounted) {
        setState(() {
          _loading = false;
          _docs = const [];
          _missing = LeavingQatarDepartureBundleService.essentialCategories;
        });
      }
      return;
    }

    final service = ref.read(leavingQatarDepartureBundleServiceProvider);
    try {
      final docs = await service.fetchForUser(uid);
      final missing = LeavingQatarDepartureBundleService.missingEssentials(docs);
      if (!mounted) return;
      setState(() {
        _docs = docs;
        _missing = missing;
        _selected
          ..clear()
          ..addAll(docs.map((d) => d.id));
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _message = LeavingQatarStrings.t('lq_bundle_export_failed', widget.locale);
      });
    }
  }

  String _categoryLabel(LeavingQatarBundleCategory category) {
    switch (category) {
      case LeavingQatarBundleCategory.passport:
        return LeavingQatarStrings.t('lq_bundle_cat_passport', widget.locale);
      case LeavingQatarBundleCategory.visa:
        return LeavingQatarStrings.t('lq_bundle_cat_visa', widget.locale);
      case LeavingQatarBundleCategory.qid:
        return LeavingQatarStrings.t('lq_bundle_cat_qid', widget.locale);
      case LeavingQatarBundleCategory.contract:
        return LeavingQatarStrings.t('lq_bundle_cat_contract', widget.locale);
      case LeavingQatarBundleCategory.payslip:
        return LeavingQatarStrings.t('lq_bundle_cat_payslip', widget.locale);
      case LeavingQatarBundleCategory.eosbDoc:
        return LeavingQatarStrings.t('lq_bundle_cat_eosb', widget.locale);
      case LeavingQatarBundleCategory.exitPermit:
        return LeavingQatarStrings.t('lq_bundle_cat_exit_permit', widget.locale);
    }
  }

  String _missingKey(LeavingQatarBundleCategory category) {
    switch (category) {
      case LeavingQatarBundleCategory.passport:
        return 'lq_bundle_missing_passport';
      case LeavingQatarBundleCategory.visa:
        return 'lq_bundle_missing_visa';
      case LeavingQatarBundleCategory.qid:
        return 'lq_bundle_missing_qid';
      default:
        return 'lq_bundle_missing_generic';
    }
  }

  Future<void> _export() async {
    if (_selected.isEmpty) return;

    await PdfExportSheet.show(
      context,
      locale: widget.locale,
      onExport: (options) => _mergeAndShare(options),
    );
  }

  Future<void> _mergeAndShare(PdfBuildOptions options) async {
    final locale = AppLocale.normalize(widget.locale);
    final selectedDocs =
        _docs.where((d) => _selected.contains(d.id)).toList();
    if (selectedDocs.isEmpty) return;

    setState(() {
      _exporting = true;
      _message = LeavingQatarStrings.t('lq_bundle_exporting', locale);
      _success = false;
    });

    try {
      final resolver = ref.read(documentPathResolverProvider);
      final pdfService = ref.read(scannerPdfServiceProvider);
      final paths = await resolver.resolvePathsFromDocuments(
        selectedDocs.map((d) => d.data).toList(),
      );

      if (paths.isEmpty) {
        setState(() {
          _exporting = false;
          _message = ScannerStrings.t('pdf_no_local_paths', locale);
          _success = false;
        });
        return;
      }

      final bytes = await pdfService.buildFromImages(
        imagePaths: paths,
        options: options.copyWith(includePageNumbers: true),
      );
      final file =
          await pdfService.writeTempPdf(bytes, prefix: 'RAABTA_departure');
      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'application/pdf')],
        subject: 'RAABTA Departure Document Bundle',
      );
      scannerMediumHaptic();
      if (!mounted) return;
      setState(() {
        _exporting = false;
        _message = LeavingQatarStrings.tf(
          'lq_bundle_export_success',
          locale,
          {'count': '${paths.length}'},
        );
        _success = true;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _exporting = false;
        _message = LeavingQatarStrings.t('lq_bundle_export_failed', locale);
        _success = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = widget.locale;
    final bottom = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: DraggableScrollableSheet(
        initialChildSize: 0.82,
        minChildSize: 0.45,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return GlassCard(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.lg,
            ),
            borderRadius: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.glassBorder,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  LeavingQatarStrings.t('lq_bundle_review_heading', locale),
                  style: AppTypography.subtitle,
                ),
                const SizedBox(height: 4),
                Text(
                  LeavingQatarStrings.t('lq_bundle_review_hint', locale),
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                if (_loading)
                  const Expanded(
                    child: Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                else
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      children: [
                        if (_missing.isNotEmpty) ...[
                          ..._missing.map(
                            (cat) => Padding(
                              padding: const EdgeInsets.only(
                                bottom: AppSpacing.sm,
                              ),
                              child: _MissingCategoryPrompt(
                                message: LeavingQatarStrings.t(
                                  _missingKey(cat),
                                  locale,
                                ),
                                scanLabel: ScannerStrings.t(
                                  'action_scan',
                                  locale,
                                ),
                                onScan: () {
                                  Navigator.of(context).pop();
                                  context.push('/scanner');
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                        ],
                        if (_docs.isEmpty)
                          Text(
                            LeavingQatarStrings.t('lq_bundle_empty', locale),
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          )
                        else
                          ..._docs.map(
                            (doc) => Padding(
                              padding: const EdgeInsets.only(
                                bottom: AppSpacing.sm,
                              ),
                              child: GlassCard(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.sm,
                                ),
                                glowIntensity: 0.04,
                                child: CheckboxListTile(
                                  value: _selected.contains(doc.id),
                                  onChanged: _exporting
                                      ? null
                                      : (value) {
                                          setState(() {
                                            if (value == true) {
                                              _selected.add(doc.id);
                                            } else {
                                              _selected.remove(doc.id);
                                            }
                                          });
                                        },
                                  title: Text(
                                    doc.label,
                                    style: AppTypography.bodySmall,
                                  ),
                                  subtitle: Text(
                                    _categoryLabel(doc.categoryHint),
                                    style: AppTypography.caption.copyWith(
                                      color: AppColors.textTertiary,
                                    ),
                                  ),
                                  activeColor: AppColors.cyanGlow,
                                  controlAffinity:
                                      ListTileControlAffinity.leading,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                if (_message != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    _message!,
                    style: AppTypography.caption.copyWith(
                      color: _success
                          ? AppColors.emeraldGlow
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.md),
                Text(
                  LeavingQatarStrings.tf(
                    'lq_bundle_selected_count',
                    locale,
                    {'count': '${_selected.length}'},
                  ),
                  style: AppTypography.caption,
                ),
                const SizedBox(height: AppSpacing.sm),
                GlassPrimaryButton(
                  label: LeavingQatarStrings.t('lq_bundle_export_action', locale),
                  onPressed: _exporting || _selected.isEmpty ? null : _export,
                ),
                const SizedBox(height: AppSpacing.sm),
                GlassSecondaryButton(
                  label: LeavingQatarStrings.t('lq_bundle_cancel', locale),
                  onPressed: _exporting
                      ? null
                      : () => Navigator.of(context).pop(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _MissingCategoryPrompt extends StatelessWidget {
  const _MissingCategoryPrompt({
    required this.message,
    required this.scanLabel,
    required this.onScan,
  });

  final String message;
  final String scanLabel;
  final VoidCallback onScan;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      glowColor: AppColors.warning,
      glowIntensity: 0.1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(message, style: AppTypography.bodySmall),
          const SizedBox(height: AppSpacing.sm),
          TextButton.icon(
            onPressed: onScan,
            icon: const Icon(Icons.document_scanner_outlined, size: 18),
            label: Text(scanLabel),
          ),
        ],
      ),
    );
  }
}

extension on PdfBuildOptions {
  PdfBuildOptions copyWith({
    PdfPageFormatOption? format,
    bool? landscape,
    bool? includePageNumbers,
    bool? watermark,
    PdfCompressionLevel? compression,
  }) {
    return PdfBuildOptions(
      format: format ?? this.format,
      landscape: landscape ?? this.landscape,
      includePageNumbers: includePageNumbers ?? this.includePageNumbers,
      watermark: watermark ?? this.watermark,
      compression: compression ?? this.compression,
    );
  }
}
