import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:raabta/config/monetization_state.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/core/widgets/hub/hub_loading_placeholder.dart';
import 'package:raabta/core/widgets/hub/hub_typography.dart';
import 'package:raabta/features/jobs/cv_maker/data/cv_repository.dart';
import 'package:raabta/features/jobs/cv_maker/l10n/cv_strings.dart';
import 'package:raabta/features/jobs/cv_maker/providers/cv_providers.dart';
import 'package:raabta/features/jobs/cv_maker/services/cv_import_service.dart';
import 'package:raabta/features/jobs/offer_calculator/l10n/job_offer_calculator_strings.dart';
import 'package:raabta/features/jobs/offer_calculator/presentation/screens/job_offer_calculator_screen.dart';
import 'package:raabta/providers/visa_providers.dart';

class CvStartScreen extends ConsumerStatefulWidget {
  const CvStartScreen({super.key});

  @override
  ConsumerState<CvStartScreen> createState() => _CvStartScreenState();
}

class _CvStartScreenState extends ConsumerState<CvStartScreen> {
  bool _busy = false;
  String? _busyLabel;

  Future<void> _openBuilder(String cvId) async {
    if (!mounted) return;
    await context.push('/jobs/cv-builder?id=$cvId');
  }

  Future<void> _startFromProfile() async {
    final locale = ref.read(userLanguageProvider);
    setState(() {
      _busy = true;
      _busyLabel = CvStrings.t('cv_busy_loading_profile', locale);
    });
    try {
      final ok = await ref.read(cvBuilderProvider.notifier).load(
            intent: CvLoadIntent.profilePrefill,
          );
      if (!mounted) return;
      if (!ok) {
        _showError(
          ref.read(cvBuilderProvider).error ??
              CvStrings.t('cv_error_prefill_profile', locale),
        );
        return;
      }
      final id = ref.read(cvBuilderProvider).cv?.id;
      if (id == null) {
        _showError(CvStrings.t('cv_error_create_from_profile', locale));
        return;
      }
      await _openBuilder(id);
    } finally {
      if (mounted) setState(() {
        _busy = false;
        _busyLabel = null;
      });
    }
  }

  Future<void> _startFromScratch() async {
    final locale = ref.read(userLanguageProvider);
    setState(() {
      _busy = true;
      _busyLabel = CvStrings.t('cv_busy_starting_blank', locale);
    });
    try {
      final id = DateTime.now().millisecondsSinceEpoch.toString();
      final ok = await ref.read(cvBuilderProvider.notifier).load(
            freshId: id,
            intent: CvLoadIntent.scratch,
          );
      if (!mounted) return;
      if (!ok) {
        _showError(
          ref.read(cvBuilderProvider).error ??
              CvStrings.t('cv_error_start_new', locale),
        );
        return;
      }
      await _openBuilder(id);
    } finally {
      if (mounted) setState(() {
        _busy = false;
        _busyLabel = null;
      });
    }
  }

  Future<void> _continueSavedDraft() async {
    final locale = ref.read(userLanguageProvider);
    setState(() {
      _busy = true;
      _busyLabel = CvStrings.t('cv_busy_loading_saved', locale);
    });
    try {
      final latest = await ref.read(cvRepositoryProvider).loadLatest();
      if (!mounted) return;
      if (latest == null) {
        _showError(CvStrings.t('cv_error_no_draft', locale));
        return;
      }
      ref.read(cvBuilderProvider.notifier).adopt(latest);
      await _openBuilder(latest.id);
    } finally {
      if (mounted) setState(() {
        _busy = false;
        _busyLabel = null;
      });
    }
  }

  Future<List<String>?> _pickResumeImages(String locale) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: AppColors.surfaceElevated,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Text(
                CvStrings.t('cv_upload_resume_pages', locale),
                style: AppTypography.subtitle,
              ),
            ),
            if (!Platform.isMacOS)
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: Text(CvStrings.t('cv_upload_take_page', locale)),
                onTap: () => Navigator.pop(ctx, ImageSource.camera),
              ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(CvStrings.t('cv_upload_gallery', locale)),
              subtitle: Text(CvStrings.t('cv_upload_one_per_page', locale)),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return null;

    final picker = ImagePicker();
    if (source == ImageSource.gallery) {
      final images = await picker.pickMultiImage(imageQuality: 90);
      if (images.isEmpty) return null;
      return images.map((x) => x.path).toList();
    }

    final image = await picker.pickImage(source: ImageSource.camera, imageQuality: 90);
    if (image == null) return null;
    return [image.path];
  }

  Future<void> _importReferenceResume() async {
    final locale = ref.read(userLanguageProvider);
    final paths = await _pickResumeImages(locale);
    if (paths == null || paths.isEmpty || !mounted) return;

    setState(() {
      _busy = true;
      _busyLabel = CvStrings.t('cv_busy_reading_document', locale);
    });

    try {
      final cvId = DateTime.now().millisecondsSinceEpoch.toString();
      setState(
        () => _busyLabel = CvStrings.t('cv_busy_extracting_ai', locale),
      );

      final imported = await ref.read(cvImportServiceProvider).extractFromImagePaths(
            imagePaths: paths,
            cvId: cvId,
          );

      setState(() => _busyLabel = CvStrings.t('cv_busy_saving_draft', locale));
      final ok = await ref.read(cvBuilderProvider.notifier).load(imported: imported);
      if (!mounted) return;
      if (!ok) {
        _showError(
          ref.read(cvBuilderProvider).error ??
              CvStrings.t('cv_error_import_save_failed', locale),
        );
        return;
      }

      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: Text(CvStrings.t('cv_import_dialog_title', locale)),
          content: Text(
            CvStrings.t('cv_import_dialog_body', locale),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(CvStrings.t('cv_action_continue_editing', locale)),
            ),
          ],
        ),
      );
      if (mounted) await _openBuilder(cvId);
    } on CvImportException catch (e) {
      if (mounted) _showError(e.message);
    } catch (e) {
      if (mounted) {
        _showError(
          CvStrings.format(
            'cv_error_import_failed',
            locale,
            params: {
              'detail': e.toString().replaceFirst('Exception: ', ''),
            },
          ),
        );
      }
    } finally {
      if (mounted) setState(() {
        _busy = false;
        _busyLabel = null;
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.errorBright,
        duration: const Duration(seconds: 5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(userLanguageProvider);
    final draftAsync = ref.watch(hasDraftCvProvider);
    final vaultAsync = ref.watch(hasSavedCvProvider);

    return GlassScreenScaffold(
      title: CvStrings.t('cv_title_maker', locale),
      titleStyle: HubTypography.hubTitle,
      leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _busy ? null : () => context.pop(),
        ),
        body: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                Text(
                  CvStrings.t('cv_start_headline', locale),
                  style: AppTypography.headline2.copyWith(fontSize: 22),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  MonetizationState.showPremiumTierUi
                      ? CvStrings.t('cv_start_intro_premium', locale)
                      : CvStrings.t('cv_start_intro', locale),
                  style: AppTypography.body.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: AppSpacing.xl),
                _OptionCard(
                  icon: Icons.person_outline,
                  title: CvStrings.t('cv_start_profile_title', locale),
                  subtitle: CvStrings.t('cv_start_profile_subtitle', locale),
                  onTap: _busy ? null : _startFromProfile,
                ),
                const SizedBox(height: AppSpacing.md),
                _OptionCard(
                  icon: Icons.upload_file_outlined,
                  title: CvStrings.t('cv_start_import_title', locale),
                  subtitle: CvStrings.t('cv_start_import_subtitle', locale),
                  onTap: _busy ? null : _importReferenceResume,
                ),
                const SizedBox(height: AppSpacing.md),
                _OptionCard(
                  icon: Icons.edit_note_outlined,
                  title: CvStrings.t('cv_start_scratch_title', locale),
                  subtitle: CvStrings.t('cv_start_scratch_subtitle', locale),
                  onTap: _busy ? null : _startFromScratch,
                ),
                draftAsync.when(
                  loading: () => const SizedBox.shrink(),
                  error: (_, _) => const SizedBox.shrink(),
                  data: (hasDraft) {
                    if (!hasDraft) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.md),
                      child: _OptionCard(
                        icon: Icons.history_edu_outlined,
                        title: CvStrings.t('cv_start_continue_draft_title', locale),
                        subtitle: CvStrings.t('cv_start_continue_draft_subtitle', locale),
                        onTap: _busy ? null : _continueSavedDraft,
                      ),
                    );
                  },
                ),
                vaultAsync.when(
                  loading: () => const SizedBox.shrink(),
                  error: (_, _) => const SizedBox.shrink(),
                  data: (hasVault) {
                    if (!hasVault) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.md),
                      child: _OptionCard(
                        icon: Icons.folder_outlined,
                        title: CvStrings.t('cv_start_vault_title', locale),
                        subtitle: CvStrings.t('cv_start_vault_subtitle', locale),
                        onTap: _busy ? null : () => context.push('/jobs/cv-preview'),
                      ),
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.lg),
                TextButton(
                  onPressed: _busy
                      ? null
                      : () => context.push(JobOfferCalculatorScreen.route()),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.goldFamilyMain,
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    JobOfferCalculatorStrings.t('joc_entry_subtitle', locale),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  CvStrings.t('cv_start_tip_pdf_pages', locale),
                  style: AppTypography.caption.copyWith(color: AppColors.textTertiary),
                ),
              ],
            ),
            if (_busy)
              Container(
                color: Colors.black54,
                alignment: Alignment.center,
                child: GlassCard(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      HubLoadingPlaceholder(
                        width: 220,
                        height: 120,
                        silhouette: HubLoadingSilhouette.formTool,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        _busyLabel ??
                            CvStrings.t('cv_busy_working', locale),
                        style: AppTypography.body,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  const _OptionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        child: GlassCard(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              Icon(icon, color: AppColors.brandFamilyMain, size: 28),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTypography.subtitle),
                    const SizedBox(height: 4),
                    Text(subtitle, style: AppTypography.caption),
                  ],
                ),
              ),
              Icon(
                Directionality.of(context) == TextDirection.rtl
                    ? Icons.chevron_left
                    : Icons.chevron_right,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
