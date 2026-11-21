import 'dart:ui' as ui;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/core/widgets/glass_secondary_button.dart';
import 'package:raabta/features/home/widgets/glass_loading_card.dart';
import 'package:raabta/features/quick_actions/scanner/l10n/scanner_strings.dart';
import 'package:raabta/features/quick_actions/scanner/models/document_intelligence.dart';
import 'package:raabta/features/quick_actions/scanner/utils/scanner_doc_type_ui.dart';
import 'package:raabta/features/quick_actions/scanner/widgets/document_thumbnail.dart';
import 'package:raabta/features/quick_actions/scanner/widgets/scanner_feature_empty_state.dart';
import 'package:raabta/features/quick_actions/scanner/widgets/scanner_primitives.dart';
import 'package:raabta/providers/visa_providers.dart';

class ScannerAiScreen extends ConsumerWidget {
  const ScannerAiScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = AppLocale.normalize(ref.watch(userLanguageProvider));
    final isRtl = AppLocale.isRtl(locale);

    return Directionality(
      textDirection: isRtl ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: GlassScreenScaffold(
        title: ScannerStrings.t('action_ai', locale),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        padding: scannerScreenPadding,
        body: ListView(
          children: [
            GlassCard(
              padding: const EdgeInsets.all(AppSpacing.md),
              glowColor: scannerAccent,
              glowIntensity: 0.08,
              child: Text(
                ScannerStrings.t('ai_disclaimer', locale),
                style: AppTypography.caption,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('scanned_documents')
                  .orderBy('scanDate', descending: true)
                  .limit(15)
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
                  final intel = (d.data() as Map)['aiIntelligence'];
                  return intel != null;
                }).toList();

                if (docs.isEmpty) {
                  return ScannerFeatureEmptyState(
                    icon: Icons.auto_awesome_outlined,
                    title: ScannerStrings.t('ai_empty_title', locale),
                    description: ScannerStrings.t('ai_empty_desc', locale),
                    actionLabel: ScannerStrings.t('action_scan', locale),
                    onAction: () => context.push('/scanner/capture'),
                  );
                }

                return Column(
                  children: [
                    for (var i = 0; i < docs.length; i++) ...[
                      ScannerEntranceReveal(
                        delay: Duration(milliseconds: 40 * i),
                        child: _InsightCard(
                          documentId: docs[i].id,
                          data: docs[i].data() as Map<String, dynamic>,
                          locale: locale,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                    ],
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({
    required this.documentId,
    required this.data,
    required this.locale,
  });

  final String documentId;
  final Map<String, dynamic> data;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final raw = data['aiIntelligence'];
    if (raw is! Map) {
      return const SizedBox.shrink();
    }
    final intel = DocumentIntelligenceResult.fromJson(
      Map<String, dynamic>.from(raw),
    );
    final docType = data['docType'] as String?;
    final icon = ScannerDocTypeUi.iconFor(docType);
    final featureRoute = ScannerDocTypeUi.featureRouteFor(docType);
    final title = data['displayName'] as String? ??
        data['holderName'] as String? ??
        intel.documentType;

    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      glowColor: scannerAccent,
      glowIntensity: 0.06,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DocumentThumbnail(documentData: data),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(icon, size: AppSpacing.iconSm, color: scannerAccent),
                        const SizedBox(width: AppSpacing.xs),
                        Expanded(
                          child: Text(title, style: AppTypography.title),
                        ),
                      ],
                    ),
                    if (docType != null && docType.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.xxs),
                      Text(docType, style: AppTypography.caption),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(intel.summary, style: AppTypography.bodySmall),
          if (intel.actionItems.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              ScannerStrings.t('ai_action_items', locale),
              style: AppTypography.caption,
            ),
            for (final item in intel.actionItems)
              Text('• $item', style: AppTypography.bodySmall),
          ],
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: GlassSecondaryButton(
                  label: ScannerStrings.t('ai_view_vault', locale),
                  icon: Icons.folder_special_outlined,
                  onPressed: () => context.push(
                    '/document-vault/$documentId',
                    extra: data,
                  ),
                ),
              ),
              if (featureRoute != null) ...[
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: GlassSecondaryButton(
                    label: ScannerStrings.t(
                      ScannerDocTypeUi.featureActionKeyFor(docType),
                      locale,
                    ),
                    icon: featureRoute == '/visa'
                        ? Icons.flight_takeoff
                        : Icons.local_hospital_outlined,
                    onPressed: () => context.push(featureRoute),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
