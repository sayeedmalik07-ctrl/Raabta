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
import 'package:raabta/core/widgets/glass_secondary_button.dart';
import 'package:raabta/core/widgets/hub/hub_loading_placeholder.dart';
import 'package:raabta/core/widgets/hub/hub_subscreen_scaffold.dart';
import 'package:raabta/features/home/widgets/home_section_header.dart';
import 'package:raabta/features/quick_actions/scanner/l10n/scanner_strings.dart';
import 'package:raabta/features/quick_actions/scanner/utils/document_path_resolver.dart';
import 'package:raabta/features/quick_actions/scanner/utils/scanner_platform.dart';
import 'package:raabta/features/quick_actions/scanner/widgets/document_thumbnail.dart';
import 'package:raabta/features/quick_actions/scanner/widgets/scanner_feature_empty_state.dart';
import 'package:raabta/features/quick_actions/scanner/widgets/scanner_primitives.dart';
import 'package:raabta/providers/visa_providers.dart';

class ScannerStudioScreen extends ConsumerWidget {
  const ScannerStudioScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = AppLocale.normalize(ref.watch(userLanguageProvider));
    final isRtl = AppLocale.isRtl(locale);
    final isDesktop = isScannerDesktop;

    final createActions = [
      _StudioAction('action_import', Icons.photo_library_rounded,
          '/scanner/capture?import=1', AppColors.accentGold),
      _StudioAction('action_ocr', Icons.text_fields_rounded, '/scanner/ocr',
          AppColors.cyanGlow),
      _StudioAction('action_ai', Icons.auto_awesome_rounded, '/scanner/ai',
          AppColors.tealGlow),
    ];

    final manageActions = [
      _StudioAction('action_merge', Icons.merge_type_rounded,
          '/scanner/pdf-tools?mode=merge', AppColors.emeraldGlow),
      _StudioAction('action_split', Icons.content_cut_rounded,
          '/scanner/pdf-tools?mode=split', AppColors.amberGlow),
      _StudioAction('action_compress', Icons.compress_rounded,
          '/scanner/pdf-tools?mode=compress', AppColors.purpleGlow),
      _StudioAction('action_vault', Icons.folder_special_outlined,
          '/document-vault', AppColors.accentGold),
    ];

    return Directionality(
      textDirection: isRtl ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: HubSubscreenScaffold(
        title: ScannerStrings.t('studio_title', locale),
        subtitle: isDesktop
            ? ScannerStrings.t('desktop_hub_subtitle', locale)
            : ScannerStrings.t('studio_subtitle', locale),
        onBack: () => context.pop(),
        body: Padding(
          padding: scannerScreenPadding,
          child: ListView(
            children: [
            ScannerEntranceReveal(
              delay: const Duration(milliseconds: 60),
              child: isDesktop
                  ? GlassPrimaryButton(
                      label: ScannerStrings.t('action_import', locale),
                      expand: true,
                      accentColor: scannerAccent,
                      icon: Icons.photo_library_rounded,
                      onPressed: () {
                        scannerLightHaptic();
                        context.push('/scanner/capture?import=1');
                      },
                    )
                  : Column(
                      children: [
                        GlassPrimaryButton(
                          label: ScannerStrings.t('action_scan', locale),
                          expand: true,
                          accentColor: scannerAccent,
                          icon: Icons.document_scanner_rounded,
                          onPressed: () {
                            scannerLightHaptic();
                            context.push('/scanner/capture');
                          },
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        SizedBox(
                          width: double.infinity,
                          child: GlassSecondaryButton(
                            label: ScannerStrings.t('action_import', locale),
                            icon: Icons.photo_library_rounded,
                            onPressed: () {
                              scannerLightHaptic();
                              context.push('/scanner/capture?import=1');
                            },
                          ),
                        ),
                      ],
                    ),
            ),
            const SizedBox(height: AppSpacing.xl),
            ScannerEntranceReveal(
              delay: const Duration(milliseconds: 120),
              child: HomeSectionHeader(
                overline: ScannerStrings.t('section_create_overline', locale),
                title: ScannerStrings.t('section_create_title', locale),
                leadingIcon: Icons.add_circle_outline,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _ActionGrid(actions: createActions, locale: locale, baseDelay: 160),
            const SizedBox(height: AppSpacing.xl),
            ScannerEntranceReveal(
              delay: const Duration(milliseconds: 220),
              child: HomeSectionHeader(
                overline: ScannerStrings.t('section_manage_overline', locale),
                title: ScannerStrings.t('section_manage_title', locale),
                leadingIcon: Icons.tune_rounded,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _ActionGrid(actions: manageActions, locale: locale, baseDelay: 260),
            const SizedBox(height: AppSpacing.xl),
            ScannerEntranceReveal(
              delay: const Duration(milliseconds: 320),
              child: HomeSectionHeader(
                title: ScannerStrings.t('recent_documents', locale),
                leadingIcon: Icons.history,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('scanned_documents')
                  .orderBy('scanDate', descending: true)
                  .limit(5)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return HubLoadingPlaceholder(
                    width: MediaQuery.sizeOf(context).width - AppSpacing.xl * 2,
                    height: 88,
                    silhouette: HubLoadingSilhouette.serviceCardRequest,
                  );
                }
                if (snapshot.data!.docs.isEmpty) {
                  return ScannerFeatureEmptyState(
                    icon: Icons.document_scanner_outlined,
                    title: ScannerStrings.t('recent_empty_title', locale),
                    description: ScannerStrings.t('recent_empty_desc', locale),
                    actionLabel: isDesktop
                        ? ScannerStrings.t('action_import', locale)
                        : ScannerStrings.t('action_scan', locale),
                    onAction: () => context.push(
                      isDesktop
                          ? '/scanner/capture?import=1'
                          : '/scanner/capture',
                    ),
                  );
                }
                return Column(
                  children: [
                    for (var i = 0; i < snapshot.data!.docs.length; i++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: ScannerEntranceReveal(
                          delay: Duration(milliseconds: 360 + (i * 50)),
                          child: _RecentDocTile(
                            docId: snapshot.data!.docs[i].id,
                            data: snapshot.data!.docs[i].data()
                                as Map<String, dynamic>,
                            locale: locale,
                            onTap: () => context.push(
                              '/document-vault/${snapshot.data!.docs[i].id}',
                              extra: snapshot.data!.docs[i].data()
                                  as Map<String, dynamic>,
                            ),
                          ),
                        ),
                      ),
                  ],
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

class _ActionGrid extends StatelessWidget {
  const _ActionGrid({
    required this.actions,
    required this.locale,
    required this.baseDelay,
  });

  final List<_StudioAction> actions;
  final String locale;
  final int baseDelay;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: AppSpacing.sm,
      crossAxisSpacing: AppSpacing.sm,
      childAspectRatio: 1.45,
      children: [
        for (var i = 0; i < actions.length; i++)
          ScannerEntranceReveal(
            delay: Duration(milliseconds: baseDelay + (i * 40)),
            child: GlassCard(
              onTap: () {
                scannerSelectionHaptic();
                context.push(actions[i].route);
              },
              padding: const EdgeInsets.all(AppSpacing.md),
              glowColor: actions[i].color,
              glowIntensity: 0.12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(actions[i].icon, color: actions[i].color),
                  const Spacer(),
                  Text(
                    ScannerStrings.t(actions[i].labelKey, locale),
                    style: AppTypography.title.copyWith(fontSize: 13),
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _RecentDocTile extends StatelessWidget {
  const _RecentDocTile({
    required this.docId,
    required this.data,
    required this.locale,
    required this.onTap,
  });

  final String docId;
  final Map<String, dynamic> data;
  final String locale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final title = data['displayName'] as String? ??
        data['holderName'] as String? ??
        ScannerStrings.t('document_fallback', locale);
    final docType = data['docType'] as String? ?? '';
    final pages = DocumentPathResolver.pageCountFor(data);

    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      glowColor: AppColors.brandFamilyMain,
      glowIntensity: 0.08,
      child: Row(
        children: [
          DocumentThumbnail(documentData: data),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.title.copyWith(fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xxs),
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
          Icon(Icons.chevron_right, color: AppColors.textOnGlassMuted),
        ],
      ),
    );
  }
}

class _StudioAction {
  const _StudioAction(this.labelKey, this.icon, this.route, this.color);

  final String labelKey;
  final IconData icon;
  final String route;
  final Color color;
}
