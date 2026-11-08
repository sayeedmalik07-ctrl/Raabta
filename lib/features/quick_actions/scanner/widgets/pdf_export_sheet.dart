import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_primary_button.dart';
import 'package:raabta/features/quick_actions/scanner/l10n/scanner_strings.dart';
import 'package:raabta/features/quick_actions/scanner/services/scanner_pdf_service.dart';
import 'package:raabta/features/quick_actions/scanner/widgets/scanner_primitives.dart';

class PdfExportSheet extends StatefulWidget {
  const PdfExportSheet({
    super.key,
    required this.onExport,
    this.locale = 'English',
    this.initialOptions = const PdfBuildOptions(),
    this.showPageNumbers = true,
    this.showLandscape = true,
  });

  final ValueChanged<PdfBuildOptions> onExport;
  final String locale;
  final PdfBuildOptions initialOptions;
  final bool showPageNumbers;
  final bool showLandscape;

  static Future<void> show(
    BuildContext context, {
    required ValueChanged<PdfBuildOptions> onExport,
    String locale = 'English',
    PdfBuildOptions initialOptions = const PdfBuildOptions(),
    bool showPageNumbers = true,
    bool showLandscape = true,
  }) {
    final normalized = AppLocale.normalize(locale);
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PdfExportSheet(
        onExport: onExport,
        locale: normalized,
        initialOptions: initialOptions,
        showPageNumbers: showPageNumbers,
        showLandscape: showLandscape,
      ),
    );
  }

  @override
  State<PdfExportSheet> createState() => _PdfExportSheetState();
}

class _PdfExportSheetState extends State<PdfExportSheet> {
  late var _format = widget.initialOptions.format;
  late var _landscape = widget.initialOptions.landscape;
  late var _pageNumbers = widget.initialOptions.includePageNumbers;
  late var _compression = widget.initialOptions.compression;

  String _t(String key) => ScannerStrings.t(key, widget.locale);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated.withValues(alpha: 0.98),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusLg),
        ),
        border: Border.all(
          color: AppColors.sharePurple.withValues(alpha: 0.2),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textOnGlassMuted,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                _t('pdf_export_title'),
                style: AppTypography.headline2,
              ),
              const SizedBox(height: AppSpacing.md),
              _DropdownField<PdfPageFormatOption>(
                label: _t('export_page_size'),
                value: _format,
                items: [
                  (PdfPageFormatOption.a4, _t('export_format_a4')),
                  (PdfPageFormatOption.a5, _t('export_format_a5')),
                  (PdfPageFormatOption.letter, _t('export_format_letter')),
                  (PdfPageFormatOption.legal, _t('export_format_legal')),
                ],
                onChanged: (v) => setState(() => _format = v),
              ),
              const SizedBox(height: AppSpacing.sm),
              _DropdownField<PdfCompressionLevel>(
                label: _t('export_compression'),
                value: _compression,
                items: [
                  (PdfCompressionLevel.low, _t('export_compression_low')),
                  (PdfCompressionLevel.medium, _t('export_compression_medium')),
                  (PdfCompressionLevel.high, _t('export_compression_high')),
                  (
                    PdfCompressionLevel.maximum,
                    _t('export_compression_maximum'),
                  ),
                ],
                onChanged: (v) => setState(() => _compression = v),
              ),
              if (widget.showLandscape) ...[
                const SizedBox(height: AppSpacing.sm),
                GlassCard(
                  padding: EdgeInsets.zero,
                  child: SwitchListTile(
                    title: Text(
                      _t('export_landscape'),
                      style: AppTypography.body,
                    ),
                    value: _landscape,
                    activeTrackColor: scannerAccent,
                    onChanged: (v) => setState(() => _landscape = v),
                  ),
                ),
              ],
              if (widget.showPageNumbers) ...[
                const SizedBox(height: AppSpacing.sm),
                GlassCard(
                  padding: EdgeInsets.zero,
                  child: SwitchListTile(
                    title: Text(
                      _t('export_page_numbers'),
                      style: AppTypography.body,
                    ),
                    value: _pageNumbers,
                    activeTrackColor: scannerAccent,
                    onChanged: (v) => setState(() => _pageNumbers = v),
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
              GlassPrimaryButton(
                label: _t('export_pdf_cta'),
                expand: true,
                accentColor: scannerAccent,
                icon: Icons.picture_as_pdf_rounded,
                onPressed: () {
                  scannerLightHaptic();
                  Navigator.pop(context);
                  widget.onExport(
                    PdfBuildOptions(
                      format: _format,
                      landscape: _landscape,
                      includePageNumbers: _pageNumbers,
                      compression: _compression,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DropdownField<T> extends StatelessWidget {
  const _DropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final T value;
  final List<(T, String)> items;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      child: DropdownButtonFormField<T>(
        initialValue: value,
        dropdownColor: AppColors.surfaceElevated,
        style: AppTypography.body,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: AppTypography.caption.copyWith(
            color: AppColors.textOnGlassSecondary,
          ),
          border: InputBorder.none,
        ),
        items: [
          for (final item in items)
            DropdownMenuItem(value: item.$1, child: Text(item.$2)),
        ],
        onChanged: (v) {
          if (v != null) onChanged(v);
        },
      ),
    );
  }
}
