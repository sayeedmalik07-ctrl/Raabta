import 'dart:ui' as ui;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/features/home/widgets/glass_loading_card.dart';
import 'package:raabta/features/quick_actions/scanner/l10n/scanner_strings.dart';
import 'package:raabta/features/quick_actions/scanner/widgets/highlighted_ocr_text.dart';
import 'package:raabta/features/quick_actions/scanner/widgets/ocr_text_detail_sheet.dart';
import 'package:raabta/features/quick_actions/scanner/widgets/scanner_feature_empty_state.dart';
import 'package:raabta/features/quick_actions/scanner/widgets/scanner_primitives.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:share_plus/share_plus.dart';

class OcrStudioScreen extends ConsumerStatefulWidget {
  const OcrStudioScreen({super.key});

  @override
  ConsumerState<OcrStudioScreen> createState() => _OcrStudioScreenState();
}

class _OcrStudioScreenState extends ConsumerState<OcrStudioScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocale.normalize(ref.watch(userLanguageProvider));
    final isRtl = AppLocale.isRtl(locale);

    return Directionality(
      textDirection: isRtl ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: GlassScreenScaffold(
        title: ScannerStrings.t('action_ocr', locale),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        padding: scannerScreenPadding,
        body: Column(
          children: [
            GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: TextField(
                controller: _searchController,
                style: AppTypography.body,
                decoration: InputDecoration(
                  hintText: ScannerStrings.t('ocr_search_hint', locale),
                  hintStyle: AppTypography.bodySmall.copyWith(
                    color: AppColors.textOnGlassMuted,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: AppColors.textOnGlassSecondary,
                  ),
                  border: InputBorder.none,
                ),
                onChanged: (v) => setState(() => _query = v.toLowerCase()),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('scanned_documents')
                    .orderBy('scanDate', descending: true)
                    .limit(20)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Column(
                      children: [
                        GlassLoadingCard(height: 120),
                        SizedBox(height: AppSpacing.sm),
                        GlassLoadingCard(height: 120),
                      ],
                    );
                  }
                  final docs = snapshot.data!.docs.where((d) {
                    final ocr =
                        ((d.data() as Map)['ocrText'] as String? ?? '');
                    if (ocr.isEmpty) return false;
                    if (_query.isEmpty) return true;
                    return ocr.toLowerCase().contains(_query);
                  }).toList();

                  if (docs.isEmpty) {
                    return ScannerFeatureEmptyState(
                      icon: Icons.text_fields_rounded,
                      title: ScannerStrings.t('ocr_empty_title', locale),
                      description: ScannerStrings.t('ocr_empty_desc', locale),
                      actionLabel: ScannerStrings.t('action_scan', locale),
                      onAction: () => context.push('/scanner/capture'),
                    );
                  }

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      final data = doc.data() as Map<String, dynamic>;
                      final ocr = data['ocrText'] as String? ?? '';
                      final title = data['holderName'] as String? ??
                          data['docType'] as String? ??
                          ScannerStrings.t('document_fallback', locale);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: ScannerEntranceReveal(
                          delay: Duration(milliseconds: 40 * index),
                          child: GlassCard(
                          onTap: () => OcrTextDetailSheet.show(
                            context,
                            title: title,
                            ocrText: ocr,
                            query: _query,
                            locale: locale,
                            documentId: doc.id,
                            documentData: data,
                          ),
                          padding: const EdgeInsets.all(AppSpacing.md),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      title,
                                      style: AppTypography.title,
                                    ),
                                  ),
                                  Text(
                                    ScannerStrings.t('ocr_view_full', locale),
                                    style: AppTypography.caption.copyWith(
                                      color: AppColors.cyanGlow,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              HighlightedOcrText(
                                text: ocr,
                                query: _query,
                                maxLines: 8,
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Row(
                                children: [
                                  TextButton.icon(
                                    onPressed: () {
                                      Clipboard.setData(
                                        ClipboardData(text: ocr),
                                      );
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            ScannerStrings.t(
                                              'ocr_copied',
                                              locale,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.copy, size: 16),
                                    label: Text(
                                      ScannerStrings.t('ocr_copy', locale),
                                    ),
                                  ),
                                  TextButton.icon(
                                    onPressed: () => Share.share(ocr),
                                    icon: const Icon(Icons.share, size: 16),
                                    label: Text(
                                      ScannerStrings.t('ocr_share', locale),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
