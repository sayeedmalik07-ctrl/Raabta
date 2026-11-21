import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_primary_button.dart';
import 'package:raabta/core/widgets/glass_secondary_button.dart';
import 'package:raabta/features/quick_actions/scanner/l10n/scanner_strings.dart';
import 'package:raabta/features/quick_actions/scanner/widgets/highlighted_ocr_text.dart';
import 'package:raabta/features/quick_actions/scanner/widgets/scanner_primitives.dart';
import 'package:share_plus/share_plus.dart';

/// Full-screen OCR detail sheet with highlights and vault link.
class OcrTextDetailSheet extends StatelessWidget {
  const OcrTextDetailSheet({
    super.key,
    required this.title,
    required this.ocrText,
    required this.query,
    required this.locale,
    required this.documentId,
    required this.documentData,
  });

  final String title;
  final String ocrText;
  final String query;
  final String locale;
  final String documentId;
  final Map<String, dynamic> documentData;

  static Future<void> show(
    BuildContext context, {
    required String title,
    required String ocrText,
    required String query,
    required String locale,
    required String documentId,
    required Map<String, dynamic> documentData,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => OcrTextDetailSheet(
        title: title,
        ocrText: ocrText,
        query: query,
        locale: locale,
        documentId: documentId,
        documentData: documentData,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.sizeOf(context).height * 0.85;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Container(
        constraints: BoxConstraints(maxHeight: maxHeight),
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
                Text(title, style: AppTypography.headline2),
                const SizedBox(height: AppSpacing.md),
                Expanded(
                  child: GlassCard(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: SingleChildScrollView(
                      child: HighlightedOcrText(
                        text: ocrText,
                        query: query,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: GlassSecondaryButton(
                        label: ScannerStrings.t('ocr_copy', locale),
                        icon: Icons.copy,
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: ocrText));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                ScannerStrings.t('ocr_copied', locale),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: GlassSecondaryButton(
                        label: ScannerStrings.t('ocr_share', locale),
                        icon: Icons.share,
                        onPressed: () => Share.share(ocrText),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                GlassPrimaryButton(
                  label: ScannerStrings.t('ocr_open_vault', locale),
                  expand: true,
                  accentColor: scannerAccent,
                  icon: Icons.folder_special_outlined,
                  onPressed: () {
                    Navigator.pop(context);
                    context.push(
                      '/document-vault/$documentId',
                      extra: documentData,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
