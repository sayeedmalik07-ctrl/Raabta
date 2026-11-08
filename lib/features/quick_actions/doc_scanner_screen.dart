import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:raabta/config/monetization_state.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_container.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_primary_button.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/core/widgets/glass_secondary_button.dart';
import 'package:raabta/features/quick_actions/scanner/l10n/scanner_strings.dart';
import 'package:raabta/features/quick_actions/scanner/models/scan_filter.dart';
import 'package:raabta/features/quick_actions/scanner/repositories/scanned_document_repository.dart';
import 'package:raabta/features/quick_actions/scanner/services/scanner_ai_service.dart';
import 'package:raabta/features/quick_actions/scanner/services/scanner_image_service.dart';
import 'package:raabta/features/quick_actions/scanner/services/scanner_ocr_service.dart';
import 'package:raabta/features/quick_actions/scanner/services/scanner_pdf_service.dart';
import 'package:raabta/features/quick_actions/scanner/widgets/scan_filter_bar.dart';
import 'package:raabta/features/quick_actions/scanner/widgets/scan_mode_bar.dart';
import 'package:raabta/features/quick_actions/scanner/widgets/scan_page_strip.dart';
import 'package:raabta/features/quick_actions/scanner/widgets/pdf_export_sheet.dart';
import 'package:raabta/features/quick_actions/scanner/widgets/doc_confirm_sheet.dart';
import 'package:raabta/features/quick_actions/scanner/utils/scanner_platform.dart';
import 'package:raabta/features/quick_actions/scanner/widgets/scanner_empty_illustration.dart';
import 'package:raabta/features/quick_actions/scanner/widgets/scanner_primitives.dart';
import 'package:raabta/features/quick_actions/scanner/models/document_intelligence.dart';
import 'package:raabta/models/visa_models.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:raabta/services/ai/document_extraction_service.dart';
import 'package:raabta/services/notifications/notification_service.dart';
import 'package:share_plus/share_plus.dart';

class DocScannerScreen extends ConsumerStatefulWidget {
  const DocScannerScreen({
    super.key,
    this.autoImport = false,
    this.scanSource,
  });

  final bool autoImport;

  /// Entry point hint — e.g. `visa` from Visa & Documents (adds vault tags).
  final String? scanSource;

  @override
  ConsumerState<DocScannerScreen> createState() => _DocScannerScreenState();
}

class _DocScannerScreenState extends ConsumerState<DocScannerScreen> {
  final _imagePicker = ImagePicker();

  String get _locale =>
      AppLocale.normalize(ref.read(userLanguageProvider));

  final List<String> _pagePaths = [];
  var _selectedPageIndex = 0;
  ScanFilter _filter = ScanFilter.original;
  ScanMode _scanMode = ScanMode.document;
  String _extractedText = '';
  String _aiAnalysis = '';
  bool _isScanning = false;
  bool _isProcessing = false;
  bool _isExporting = false;

  String? get _currentPath =>
      _pagePaths.isEmpty ? null : _pagePaths[_selectedPageIndex];

  @override
  void initState() {
    super.initState();
    if (widget.autoImport) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _uploadFromGallery());
    }
  }

  Future<void> _scanWithCamera({bool append = false}) async {
    if (!Platform.isIOS && !Platform.isAndroid) {
      _showSnack(ScannerStrings.t('capture_camera_unavailable', _locale));
      return;
    }

    setState(() {
      _isScanning = true;
      _aiAnalysis = '';
      _extractedText = '';
    });
    try {
      final pictures = await CunningDocumentScanner.getPictures(
        noOfPages: 5,
        isGalleryImportAllowed: true,
      );
      if (pictures != null && pictures.isNotEmpty) {
        setState(() {
          if (!append) _pagePaths.clear();
          _pagePaths.addAll(pictures);
          _selectedPageIndex = append ? _pagePaths.length - pictures.length : 0;
        });
        scannerLightHaptic();
        await _processPages();
      }
    } catch (e) {
      _showSnack(ScannerStrings.t('capture_camera_failed', _locale));
    } finally {
      setState(() => _isScanning = false);
    }
  }

  Future<void> _uploadFromGallery({bool append = false}) async {
    setState(() {
      _isScanning = true;
      _aiAnalysis = '';
      _extractedText = '';
    });
    try {
      final picked = await _imagePicker.pickMultiImage(imageQuality: 90);
      if (picked.isNotEmpty) {
        setState(() {
          if (!append) _pagePaths.clear();
          _pagePaths.addAll(picked.map((f) => f.path));
          _selectedPageIndex = append ? _pagePaths.length - picked.length : 0;
        });
        scannerLightHaptic();
        await _processPages();
      }
    } catch (e) {
      _showSnack(ScannerStrings.t('capture_gallery_failed', _locale));
    } finally {
      setState(() => _isScanning = false);
    }
  }

  Future<void> _processPages() async {
    if (_pagePaths.isEmpty) return;
    setState(() => _isProcessing = true);
    try {
      final ocr = ref.read(scannerOcrServiceProvider);
      final text = await ocr.extractFromPaths(_pagePaths);
      setState(() => _extractedText = text);

      if (text.isNotEmpty) {
        final extraction = ref.read(documentExtractionServiceProvider);
        final intelligence = ref.read(scannerAiServiceProvider);
        final result = await extraction.extractDocumentData(text);
        final insight = await intelligence.analyzeDocument(text);
        setState(() => _aiAnalysis = insight.summary);

        if (mounted) {
          await DocConfirmSheet.show(
            context,
            result,
            (edited, addReminder) async {
              await _saveScannedDocument(edited, addReminder, insight);
            },
          );
        }
      } else if (mounted) {
        await DocConfirmSheet.show(
          context,
          const DocClassificationResult(
            docType: DocType.unknown,
            confidence: 0,
          ),
          (edited, addReminder) async {
            await _saveScannedDocument(
              edited,
              addReminder,
              const DocumentIntelligenceResult(
                documentType: 'unknown',
                summary: 'Saved without OCR text.',
              ),
            );
          },
        );
      }
    } catch (e) {
      _showSnack(ScannerStrings.t('capture_processing_failed', _locale));
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<Uint8List> _processedBytes(String path) async {
    final images = ref.read(scannerImageServiceProvider);
    final premium = await ref.read(isPremiumUserProvider.future);
    var bytes = await images.applyFilter(path, _filter);
    bytes = await images.applyWatermark(bytes, enabled: !premium);
    return bytes;
  }

  Future<void> _exportAsJpg() async {
    final path = _currentPath;
    if (path == null) return;
    setState(() => _isExporting = true);
    try {
      final bytes = await _processedBytes(path);
      final file = File(
        '${Directory.systemTemp.path}/RAABTA_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      await file.writeAsBytes(bytes);
      await Share.shareXFiles([XFile(file.path)]);
      scannerMediumHaptic();
    } catch (e) {
      _showSnack(ScannerStrings.t('capture_jpg_failed', _locale));
    } finally {
      setState(() => _isExporting = false);
    }
  }

  Future<void> _exportAsPdf() async {
    if (_pagePaths.isEmpty) return;
    await PdfExportSheet.show(
      context,
      locale: _locale,
      onExport: (options) async {
        setState(() => _isExporting = true);
        try {
          final premium = await ref.read(isPremiumUserProvider.future);
          final pdf = ref.read(scannerPdfServiceProvider);
          final bytes = await pdf.buildFromImages(
            imagePaths: _pagePaths,
            filter: _filter,
            applyWatermark: !premium,
            options: options,
          );
          final file = await pdf.writeTempPdf(bytes);
          await Share.shareXFiles(
            [XFile(file.path, mimeType: 'application/pdf')],
            subject: 'RAABTA Scanned Document',
          );
          scannerMediumHaptic();
        } catch (e) {
          _showSnack(ScannerStrings.t('capture_pdf_failed', _locale));
        } finally {
          if (mounted) setState(() => _isExporting = false);
        }
      },
    );
  }

  void _reorderPages(int oldIndex, int newIndex) {
    setState(() {
      final item = _pagePaths.removeAt(oldIndex);
      _pagePaths.insert(newIndex, item);
      _selectedPageIndex = newIndex;
    });
  }

  void _resetScan() {
    setState(() {
      _pagePaths.clear();
      _selectedPageIndex = 0;
      _extractedText = '';
      _aiAnalysis = '';
    });
  }

  Future<void> _rotatePage(int index) async {
    final path = _pagePaths[index];
    final bytes = await File(path).readAsBytes();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) return;
    final rotated = img.copyRotate(decoded, angle: 90);
    await File(path).writeAsBytes(img.encodeJpg(rotated, quality: 92));
    setState(() {});
  }

  void _deletePage(int index) {
    setState(() {
      _pagePaths.removeAt(index);
      if (_selectedPageIndex >= _pagePaths.length) {
        _selectedPageIndex = (_pagePaths.length - 1).clamp(0, 999);
      }
    });
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.surfaceElevated,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _saveScannedDocument(
    DocClassificationResult result,
    bool addReminder,
    DocumentIntelligenceResult intelligence,
  ) async {
    try {
      final repo = ref.read(scannedDocumentRepositoryProvider);
      final docId = await repo.save(
        ScannedDocumentSaveRequest(
          classification: result,
          imagePath: _currentPath ?? '',
          pagePaths: List<String>.from(_pagePaths),
          ocrText: _extractedText,
          aiSummary: _aiAnalysis,
          intelligence: intelligence,
          category: widget.scanSource == 'health_insurance_claim'
              ? 'Health Insurance Claim'
              : widget.scanSource == 'tenancy_condition'
                  ? 'Property Condition'
                  : null,
          tags: _tagsForSave(result.docType),
        ),
      );

      final mirrorTypes = widget.scanSource == 'visa'
          ? [
              DocType.qid,
              DocType.visa,
              DocType.labourCard,
              DocType.medicalCertificate,
            ]
          : [DocType.qid, DocType.visa, DocType.labourCard];
      if (mirrorTypes.contains(result.docType) && result.expiryDate != null) {
        final typeDef = _deadlineTypeFor(result.docType);
        await ref.read(documentDeadlinesControllerProvider).addDeadline(
              typeDef: typeDef,
              expiryDate: result.expiryDate!,
            );
      }

      if (addReminder && result.expiryDate != null) {
        final granted = await NotificationService.requestPermission();
        if (granted) {
          await NotificationService.scheduleDocumentExpiryReminders(
            docId: docId,
            docTypeName: _docTypeDisplayName(result.docType),
            expiryDate: result.expiryDate!,
          );
        }
      }

      if (mounted) {
        scannerMediumHaptic();
        if (widget.scanSource == 'tenancy_condition') {
          context.pop(<String, dynamic>{'vaultDocId': docId});
          return;
        }
        _showSnack(ScannerStrings.t('saved_success', _locale));
      }
    } catch (e) {
      if (mounted) {
        _showSnack(ScannerStrings.t('capture_save_failed', _locale));
      }
    }
  }

  List<String> _tagsForSave(DocType type) {
    final tags = <String>[];
    if (widget.scanSource == 'visa') {
      tags.add('visa_documents');
      switch (type) {
        case DocType.qid:
          tags.add('QID');
        case DocType.visa:
          tags.add('Visa');
        case DocType.labourCard:
          tags.add('Iqama');
        case DocType.medicalCertificate:
          tags.add('Medical');
        default:
          break;
      }
    }
    return tags;
  }

  String _docTypeDisplayName(DocType type) {
    switch (type) {
      case DocType.qid:
        return 'Qatar ID (QID)';
      case DocType.passport:
        return 'Passport';
      case DocType.visa:
        return 'Visa';
      case DocType.labourCard:
        return 'Labour Card';
      case DocType.drivingLicense:
        return 'Driving License';
      case DocType.receipt:
        return 'Receipt';
      case DocType.bill:
        return 'Bill';
      case DocType.labReport:
        return 'Lab Report';
      case DocType.prescription:
        return 'Prescription';
      case DocType.medicalCertificate:
        return 'Medical Certificate';
      case DocType.vaccinationRecord:
        return 'Vaccination Record';
      case DocType.healthInsurance:
        return 'Health Insurance';
      case DocType.healthInsuranceClaim:
        return 'Health Insurance Claim';
      case DocType.imagingReport:
        return 'Imaging Report';
      case DocType.bookingConfirmation:
        return 'Booking Confirmation';
      case DocType.unknown:
        return 'Document';
    }
  }

  DocumentDeadlineTypeDef _deadlineTypeFor(DocType type) {
    switch (type) {
      case DocType.qid:
        return documentDeadlineTypes.first;
      case DocType.passport:
        return documentDeadlineTypes[1];
      case DocType.visa:
        return documentDeadlineTypes[6];
      case DocType.labourCard:
        return documentDeadlineTypes[2];
      case DocType.drivingLicense:
        return documentDeadlineTypes[3];
      case DocType.healthInsurance:
        return documentDeadlineTypes[5];
      case DocType.healthInsuranceClaim:
        return documentDeadlineTypes[5];
      case DocType.medicalCertificate:
        return documentDeadlineTypes[5];
      default:
        return documentDeadlineTypes[2];
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocale.normalize(ref.watch(userLanguageProvider));
    final isRtl = AppLocale.isRtl(locale);
    final premiumAsync = ref.watch(isPremiumUserProvider);
    final isDesktop = isScannerDesktop;

    return Directionality(
      textDirection: isRtl ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: GlassScreenScaffold(
        title: ScannerStrings.t('action_scan', locale),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (_pagePaths.isNotEmpty)
            TextButton(
              onPressed: _resetScan,
              child: Text(
                ScannerStrings.t('capture_rescan', locale),
                style: TextStyle(
                  color: AppColors.cyanGlow,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
        padding: scannerScreenPadding,
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ScanModeBar(
                selected: _scanMode,
                locale: locale,
                onSelected: (mode) => setState(() {
                  _scanMode = mode;
                  _filter = mode.filter;
                }),
              ),
              const SizedBox(height: AppSpacing.lg),
              GlassContainer(
                width: double.infinity,
                height: 220,
                padding: EdgeInsets.zero,
                borderRadius: AppSpacing.radiusLg,
                glowColor: AppColors.purpleGlow,
                glowIntensity: 0.12,
                backgroundColor: AppColors.purpleGlow.withValues(alpha: 0.08),
                child: _currentPath != null
                    ? ClipRRect(
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusLg - 2),
                        child: FutureBuilder<Uint8List>(
                          future: _processedBytes(_currentPath!),
                          builder: (context, snap) {
                            if (!snap.hasData) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            return Image.memory(
                              snap.data!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            );
                          },
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ScannerEmptyIllustration(
                            icon: isDesktop
                                ? Icons.photo_library_rounded
                                : Icons.document_scanner_rounded,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.lg,
                            ),
                            child: Text(
                              isDesktop
                                  ? ScannerStrings.t(
                                      'desktop_capture_subtitle',
                                      locale,
                                    )
                                  : ScannerStrings.t(
                                      'studio_subtitle',
                                      locale,
                                    ),
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textOnGlassMuted,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
              ),
              if (_pagePaths.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.lg),
                ScanPageStrip(
                  pagePaths: _pagePaths,
                  selectedIndex: _selectedPageIndex,
                  onSelect: (i) => setState(() => _selectedPageIndex = i),
                  onDelete: _deletePage,
                  onRotate: _rotatePage,
                  onReorder: _reorderPages,
                  locale: locale,
                ),
              ],
              if (_currentPath != null) ...[
                const SizedBox(height: AppSpacing.lg),
                ScanFilterBar(
                  selected: _filter,
                  onSelected: (f) => setState(() => _filter = f),
                  locale: locale,
                ),
              ],
              const SizedBox(height: AppSpacing.md),
              if (_pagePaths.isNotEmpty)
                Row(
                  children: [
                    if (!isDesktop)
                      Expanded(
                        child: GlassSecondaryButton(
                          label: ScannerStrings.t('capture_add_page', locale),
                          icon: Icons.add_a_photo_outlined,
                          onPressed: (_isScanning || _isProcessing)
                              ? null
                              : () => _scanWithCamera(append: true),
                        ),
                      ),
                    if (!isDesktop) const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: GlassSecondaryButton(
                        label: ScannerStrings.t('capture_add_images', locale),
                        icon: Icons.add_photo_alternate_outlined,
                        onPressed: (_isScanning || _isProcessing)
                            ? null
                            : () => _uploadFromGallery(append: true),
                      ),
                    ),
                  ],
                ),
              if (_pagePaths.isNotEmpty) const SizedBox(height: AppSpacing.md),
              if (isDesktop)
                GlassPrimaryButton(
                  label: ScannerStrings.t('action_import', locale),
                  expand: true,
                  accentColor: scannerAccent,
                  icon: Icons.photo_library_rounded,
                  onPressed: (_isScanning || _isProcessing)
                      ? null
                      : _uploadFromGallery,
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: GlassPrimaryButton(
                        label: _isScanning
                            ? ScannerStrings.t('capture_scanning', locale)
                            : ScannerStrings.t('capture_use_camera', locale),
                        expand: true,
                        accentColor: scannerAccent,
                        icon: Icons.camera_alt_rounded,
                        onPressed: (_isScanning || _isProcessing)
                            ? null
                            : _scanWithCamera,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: GlassSecondaryButton(
                        label: ScannerStrings.t('action_import', locale),
                        icon: Icons.photo_library_rounded,
                        onPressed: (_isScanning || _isProcessing)
                            ? null
                            : _uploadFromGallery,
                      ),
                    ),
                  ],
                ),
              if (_isProcessing) ...[
                const SizedBox(height: AppSpacing.xl),
                Center(
                  child: Text(ScannerStrings.t('processing', locale)),
                ),
              ],
              if (_extractedText.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xl),
                ScannerEntranceReveal(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ScannerStrings.t('capture_extracted_text', locale),
                        style: AppTypography.title,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      GlassContainer(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppSpacing.md),
                        borderRadius: AppSpacing.radiusSm,
                        child: Text(
                          _extractedText,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textOnGlassMuted,
                            height: 1.6,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (_aiAnalysis.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.lg),
                ScannerEntranceReveal(
                  delay: const Duration(milliseconds: 80),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ScannerStrings.t('capture_ai_analysis', locale),
                        style: AppTypography.title,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      GlassContainer(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppSpacing.md),
                        borderRadius: AppSpacing.radiusSm,
                        child: Text(
                          _aiAnalysis,
                          style: AppTypography.bodySmall.copyWith(height: 1.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (_currentPath != null && !_isProcessing) ...[
                const SizedBox(height: AppSpacing.lg),
                premiumAsync.when(
                  data: (premium) {
                    if (premium || !MonetizationState.showPremiumTierUi) {
                      return const SizedBox.shrink();
                    }
                    return GlassContainer(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      borderRadius: AppSpacing.radiusSm,
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              ScannerStrings.t('premium_watermark', locale),
                              style: AppTypography.caption,
                            ),
                          ),
                          TextButton(
                            onPressed: () => context.push('/premium'),
                            child: Text(ScannerStrings.t('upgrade', locale)),
                          ),
                        ],
                      ),
                    );
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (_, _) => const SizedBox.shrink(),
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: GlassPrimaryButton(
                        label: _isExporting
                            ? ScannerStrings.t('capture_exporting', locale)
                            : ScannerStrings.t('capture_save_jpg', locale),
                        expand: true,
                        accentColor: scannerAccent,
                        icon: Icons.image_rounded,
                        onPressed: _isExporting ? null : _exportAsJpg,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: GlassSecondaryButton(
                        label: ScannerStrings.t('capture_save_pdf', locale),
                        icon: Icons.picture_as_pdf_rounded,
                        onPressed: _isExporting ? null : _exportAsPdf,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
