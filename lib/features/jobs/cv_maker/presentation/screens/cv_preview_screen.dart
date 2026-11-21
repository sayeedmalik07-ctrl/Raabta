import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_primary_button.dart';
import 'package:raabta/core/widgets/glass_empty_state.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/core/widgets/hub/hub_loading_placeholder.dart';
import 'package:raabta/core/widgets/hub/hub_typography.dart';
import 'package:raabta/core/widgets/qr_share_sheet.dart';
import 'package:raabta/features/jobs/cv_maker/data/cv_repository.dart';
import 'package:raabta/features/jobs/cv_maker/l10n/cv_strings.dart';
import 'package:raabta/features/jobs/cv_maker/domain/cv_template_catalog.dart';
import 'package:raabta/features/jobs/cv_maker/domain/models/cv_document.dart';
import 'package:raabta/features/jobs/cv_maker/presentation/widgets/cv_ats_badge.dart';
import 'package:raabta/features/jobs/cv_maker/presentation/widgets/cv_builder_form_helpers.dart';
import 'package:raabta/features/jobs/cv_maker/presentation/widgets/cv_preview_content.dart';
import 'package:raabta/features/jobs/cv_maker/providers/cv_providers.dart';
import 'package:raabta/features/jobs/cv_maker/services/cv_analytics_service.dart';
import 'package:raabta/features/jobs/cv_maker/services/cv_export_service.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:raabta/services/qr/vcard_builder.dart';

class CvPreviewScreen extends ConsumerStatefulWidget {
  const CvPreviewScreen({
    super.key,
    this.cvId,
    this.attachJobId,
    @visibleForTesting this.initialEmptyForTest = false,
  });

  final String? cvId;
  final String? attachJobId;

  /// When true (tests only), skips async repository load and shows empty UI.
  @visibleForTesting
  final bool initialEmptyForTest;

  @override
  ConsumerState<CvPreviewScreen> createState() => _CvPreviewScreenState();
}

class _CvPreviewScreenState extends ConsumerState<CvPreviewScreen> {
  CvDocument? _cv;
  bool _loading = true;
  bool _exporting = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialEmptyForTest) {
      _loading = false;
      _cv = null;
      return;
    }
    _load();
  }

  Future<void> _load() async {
    final builderCv = ref.read(cvBuilderProvider).cv;
    if (builderCv != null && (widget.cvId == null || builderCv.id == widget.cvId)) {
      setState(() {
        _cv = builderCv;
        _loading = false;
      });
      return;
    }

    if (widget.cvId != null) {
      final loaded = await ref.read(cvRepositoryProvider).load(widget.cvId!);
      setState(() {
        _cv = loaded;
        _loading = false;
      });
      return;
    }

    final latest = await ref.read(cvRepositoryProvider).loadLatest();
    setState(() {
      _cv = latest;
      _loading = false;
    });
  }

  Future<void> _export({bool attach = false}) async {
    final cv = _cv;
    if (cv == null) return;
    setState(() => _exporting = true);
    // Snapshot at export tap — PDF locale matches language when user exported.
    final locale = AppLocale.normalize(ref.read(userLanguageProvider));
    try {
      final vaultId = await ref
          .read(cvExportServiceProvider)
          .exportToVault(cv, locale: locale);
      final updated = cv.copyWith(vaultDocumentId: vaultId);
      await ref.read(cvRepositoryProvider).save(updated);
      CvAnalyticsService.cvBuilderCompleted();
      if (attach && widget.attachJobId != null) {
        CvAnalyticsService.cvAttachedToApplication(widget.attachJobId!);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              attach
                  ? CvStrings.t('cv_export_success_attach', locale)
                  : CvStrings.t('cv_export_success_vault', locale),
            ),
            backgroundColor: AppColors.success,
          ),
        );
        if (attach) context.pop();
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(CvStrings.t('cv_export_failed', locale)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(userLanguageProvider);

    if (_loading) {
      return GlassScreenScaffold(
        title: CvStrings.t('cv_title_my_cv', locale),
        titleStyle: HubTypography.hubTitle,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        body: const Center(
          child: HubLoadingPlaceholder(
            width: 320,
            height: 200,
            silhouette: HubLoadingSilhouette.formTool,
          ),
        ),
      );
    }

    final cv = _cv;
    if (cv == null) {
      return GlassScreenScaffold(
        title: CvStrings.t('cv_title_my_cv', locale),
        titleStyle: HubTypography.hubTitle,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: GlassEmptyState(
              accent: GlassEmptyStateAccent.brand,
              icon: Icons.description_outlined,
              title: CvStrings.t('cv_preview_empty_title', locale),
              description: CvStrings.t('cv_preview_empty_description', locale),
              actionLabel: CvStrings.t('cv_title_build', locale),
              onAction: () => context.pushReplacement('/jobs/cv-start'),
            ),
          ),
        ),
      );
    }

    return cvJobsToolTheme(
      child: GlassScreenScaffold(
        title: cv.title,
        titleStyle: HubTypography.hubTitle,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        body: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            CvAtsBadge(compatibility: CvAtsCompatibility.forCv(cv)),
            const SizedBox(height: AppSpacing.sm),
            CvPreviewContent(cv: cv),
            if (cv.templateId == CvTemplateId.premium && cv.hasPhoto) ...[
              const SizedBox(height: AppSpacing.md),
              Text(
                CvAtsCompatibility.forCv(cv).hint,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.warning,
                ),
              ),
              TextButton(
                onPressed: () {
                  final modern = cv.copyWith(templateId: CvTemplateId.modern);
                  ref.read(cvBuilderProvider.notifier).updateCv(modern);
                  setState(() => _cv = modern);
                },
                child: Text(
                  CvStrings.t('cv_preview_modern_switch', locale),
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            Text(
              CvStrings.t('cv_preview_disclaimer', locale),
              style: AppTypography.caption.copyWith(color: AppColors.textTertiary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            GlassPrimaryButton(
              label: _exporting
                  ? CvStrings.t('cv_export_saving', locale)
                  : CvStrings.t('cv_export_save_pdf_vault', locale),
              accentColor: AppColors.brandFamilyMain,
              onPressed: _exporting ? null : () => _export(attach: false),
            ),
            const SizedBox(height: AppSpacing.sm),
            OutlinedButton.icon(
              onPressed: _exporting
                  ? null
                  : () {
                      // Snapshot at share tap — PDF share uses locale when user tapped Share.
                      final locale =
                          AppLocale.normalize(ref.read(userLanguageProvider));
                      ref
                          .read(cvExportServiceProvider)
                          .sharePdf(cv, locale: locale);
                    },
              icon: const Icon(Icons.share_outlined),
              label: Text(CvStrings.t('cv_action_share', locale)),
            ),
            const SizedBox(height: AppSpacing.sm),
            OutlinedButton.icon(
              onPressed: () => showQrShareSheet(
                context,
                title: CvStrings.t('cv_qr_title', locale),
                subtitle: cv.fullName.isNotEmpty ? cv.fullName : cv.title,
                caption: CvStrings.t('cv_qr_caption_vcard', locale),
                qrData: VcardBuilder.fromCv(cv),
              ),
              icon: const Icon(Icons.qr_code_2_outlined),
              label: Text(CvStrings.t('cv_action_share_qr', locale)),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextButton(
              onPressed: () => context.push('/jobs/cv-builder?id=${cv.id}'),
              child: Text(CvStrings.t('cv_action_edit', locale)),
            ),
            if (widget.attachJobId != null) ...[
              const SizedBox(height: AppSpacing.md),
              GlassPrimaryButton(
                label: CvStrings.t('cv_action_attach_return', locale),
                accentColor: AppColors.brandFamilyMain,
                onPressed: _exporting ? null : () => _export(attach: true),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
