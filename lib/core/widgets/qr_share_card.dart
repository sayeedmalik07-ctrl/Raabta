import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

/// Lightweight on-device QR card — accent color + logo embed + PNG/PDF export.
class QrShareCard extends StatefulWidget {
  const QrShareCard({
    super.key,
    required this.title,
    required this.qrData,
    this.subtitle = '',
    this.caption,
    this.screenshotController,
  });

  final String title;
  final String subtitle;
  final String? caption;
  final String qrData;
  final ScreenshotController? screenshotController;

  static const accentOptions = [
    (label: 'Gold', color: AppColors.accentGold),
    (label: 'Purple', color: AppColors.purpleGlow),
    (label: 'Cyan', color: AppColors.cyanGlow),
  ];

  @override
  State<QrShareCard> createState() => QrShareCardState();
}

class QrShareCardState extends State<QrShareCard> {
  Color _accent = QrShareCard.accentOptions.first.color;
  bool _exporting = false;

  ScreenshotController get _capture =>
      widget.screenshotController ?? ScreenshotController();

  Future<Uint8List?> _captureBytes() async {
    return _capture.capture(pixelRatio: 3.0);
  }

  Future<void> exportPng() async {
    setState(() => _exporting = true);
    try {
      if (Platform.isAndroid || Platform.isIOS) {
        await Permission.photos.request();
      }
      final bytes = await _captureBytes();
      if (bytes == null) return;
      await ImageGallerySaverPlus.saveImage(
        bytes,
        quality: 95,
        name: 'RAABTA_QR_${DateTime.now().millisecondsSinceEpoch}',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('QR saved to gallery')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not save QR image')),
        );
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  Future<void> exportPdf() async {
    setState(() => _exporting = true);
    try {
      final bytes = await _captureBytes();
      if (bytes == null) return;

      final doc = pw.Document();
      doc.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(48),
          build: (context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Text(
                widget.title,
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              if (widget.subtitle.isNotEmpty) ...[
                pw.SizedBox(height: 8),
                pw.Text(widget.subtitle, style: const pw.TextStyle(fontSize: 11)),
              ],
              pw.SizedBox(height: 24),
              pw.Center(
                child: pw.Image(
                  pw.MemoryImage(bytes),
                  width: 280,
                  height: 320,
                ),
              ),
            ],
          ),
        ),
      );
      final pdfBytes = await doc.save();
      final dir = await getTemporaryDirectory();
      final file = File(
        '${dir.path}/RAABTA_QR_${DateTime.now().millisecondsSinceEpoch}.pdf',
      );
      await file.writeAsBytes(pdfBytes);
      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'application/pdf', name: '${widget.title}.pdf')],
        subject: widget.title,
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not export QR PDF')),
        );
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  Future<void> shareLink() async {
    await Share.share(widget.qrData, subject: widget.title);
  }

  @override
  Widget build(BuildContext context) {
    return Screenshot(
      controller: _capture,
      child: GlassCard(
        padding: const EdgeInsets.all(AppSpacing.lg),
        glowColor: _accent,
        glowIntensity: 0.12,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.title, style: AppTypography.title, textAlign: TextAlign.center),
            if (widget.subtitle.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                widget.subtitle,
                style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              alignment: WrapAlignment.center,
              children: QrShareCard.accentOptions.map((opt) {
                final selected = opt.color == _accent;
                return ChoiceChip(
                  label: Text(opt.label),
                  selected: selected,
                  onSelected: (_) => setState(() => _accent = opt.color),
                  selectedColor: opt.color.withValues(alpha: 0.25),
                  labelStyle: AppTypography.caption.copyWith(
                    color: selected ? opt.color : AppColors.textSecondary,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(color: _accent.withValues(alpha: 0.35), width: 2),
              ),
              child: QrImageView(
                data: widget.qrData,
                version: QrVersions.auto,
                size: 200,
                backgroundColor: Colors.white,
                eyeStyle: QrEyeStyle(
                  eyeShape: QrEyeShape.square,
                  color: _accent,
                ),
                dataModuleStyle: QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.square,
                  color: _accent,
                ),
                embeddedImage: const AssetImage(
                  'assets/images/raabta_watermark_logo.png',
                ),
                embeddedImageStyle: const QrEmbeddedImageStyle(
                  size: Size(44, 44),
                ),
              ),
            ),
            if (widget.caption != null && widget.caption!.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                widget.caption!,
                style: AppTypography.caption.copyWith(color: AppColors.textTertiary),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            if (_exporting)
              const Padding(
                padding: EdgeInsets.only(bottom: AppSpacing.sm),
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _exporting ? null : exportPng,
                    icon: const Icon(Icons.image_outlined, size: 18),
                    label: const Text('PNG'),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _exporting ? null : exportPdf,
                    icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
                    label: const Text('PDF'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            TextButton.icon(
              onPressed: _exporting ? null : shareLink,
              icon: const Icon(Icons.link, size: 18),
              label: const Text('Share link'),
            ),
          ],
        ),
      ),
    );
  }
}
