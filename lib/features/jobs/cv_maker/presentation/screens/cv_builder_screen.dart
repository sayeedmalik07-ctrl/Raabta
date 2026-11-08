import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:raabta/config/monetization_state.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/mixins/draft_persistence_mixin.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_primary_button.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/core/widgets/hub/hub_loading_placeholder.dart';
import 'package:raabta/core/widgets/hub/hub_typography.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/features/eosb/presentation/widgets/before_you_sign_section.dart';
import 'package:raabta/features/jobs/cv_maker/domain/cv_template_catalog.dart';
import 'package:raabta/features/jobs/cv_maker/l10n/cv_strings.dart';
import 'package:raabta/features/jobs/cv_maker/domain/models/cv_document.dart';
import 'package:raabta/features/jobs/cv_maker/presentation/widgets/cv_template_picker.dart';
import 'package:raabta/services/drafts/draft_box_keys.dart';
import 'package:raabta/services/drafts/draft_service.dart';
import 'package:raabta/features/jobs/cv_maker/presentation/widgets/cv_ai_assist_button.dart';
import 'package:raabta/features/jobs/cv_maker/presentation/widgets/cv_builder_form_helpers.dart';
import 'package:raabta/features/jobs/cv_maker/presentation/widgets/cv_month_year_picker.dart';
import 'package:raabta/features/jobs/cv_maker/providers/cv_providers.dart';
import 'package:raabta/features/jobs/cv_maker/services/cv_ai_service.dart';
import 'package:raabta/features/jobs/cv_maker/services/cv_photo_service.dart';
import 'package:raabta/features/jobs/esco_match/presentation/widgets/esco_skill_gap_panel.dart';
import 'package:raabta/providers/visa_providers.dart';

class CvBuilderScreen extends ConsumerStatefulWidget {
  const CvBuilderScreen({super.key, this.cvId});

  final String? cvId;

  @override
  ConsumerState<CvBuilderScreen> createState() => _CvBuilderScreenState();
}

class _CvBuilderScreenState extends ConsumerState<CvBuilderScreen>
    with DraftPersistenceMixin {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _locationCtrl;
  late final TextEditingController _linkedInCtrl;
  late final TextEditingController _summaryCtrl;
  late final TextEditingController _hardSkillsCtrl;
  late final TextEditingController _toolsSkillsCtrl;
  late final TextEditingController _softSkillsCtrl;
  CvTemplateId _template = CvTemplateId.modern;
  CvSummaryFormat _summaryFormat = CvSummaryFormat.paragraph;
  bool _initialized = false;
  String? _syncedCvId;
  String? _draftFormId;
  bool _draftSetup = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _emailCtrl = TextEditingController();
    _phoneCtrl = TextEditingController();
    _locationCtrl = TextEditingController();
    _linkedInCtrl = TextEditingController();
    _summaryCtrl = TextEditingController();
    _hardSkillsCtrl = TextEditingController();
    _toolsSkillsCtrl = TextEditingController();
    _softSkillsCtrl = TextEditingController();
    Future.microtask(_ensureLoaded);
  }

  Future<void> _ensureLoaded() async {
    final current = ref.read(cvBuilderProvider);
    if (widget.cvId != null &&
        current.cv?.id == widget.cvId &&
        !current.isLoading) {
      return;
    }
    await ref.read(cvBuilderProvider.notifier).load(
          existingCvId: widget.cvId,
          intent: widget.cvId == null ? CvLoadIntent.profilePrefill : CvLoadIntent.existing,
        );
  }

  @override
  void dispose() {
    disposeDraftMixin();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _locationCtrl.dispose();
    _linkedInCtrl.dispose();
    _summaryCtrl.dispose();
    _hardSkillsCtrl.dispose();
    _toolsSkillsCtrl.dispose();
    _softSkillsCtrl.dispose();
    super.dispose();
  }

  void _syncFromCv(CvDocument cv) {
    if (_initialized && _syncedCvId == cv.id) return;
    _nameCtrl.text = cv.fullName;
    _emailCtrl.text = cv.email;
    _phoneCtrl.text = cv.phone;
    _locationCtrl.text = cv.location;
    _linkedInCtrl.text = cv.linkedInUrl;
    _summaryCtrl.text = cv.professionalSummary;
    _hardSkillsCtrl.text = cv.skills.hardSkills.join(', ');
    _toolsSkillsCtrl.text = cv.skills.toolsSoftware.join(', ');
    _softSkillsCtrl.text = cv.skills.softSkills.join(', ');
    _template = cv.templateId;
    _summaryFormat = cv.summaryFormat;
    _initialized = true;
    _syncedCvId = cv.id;
  }

  CvDocument _buildCvFromForm(CvDocument base) {
    return base.copyWith(
      fullName: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      location: _locationCtrl.text.trim(),
      linkedInUrl: _linkedInCtrl.text.trim(),
      professionalSummary: _summaryCtrl.text.trim(),
      summaryFormat: _summaryFormat,
      skills: CvSkills(
        hardSkills: parseCommaList(_hardSkillsCtrl.text),
        toolsSoftware: parseCommaList(_toolsSkillsCtrl.text),
        softSkills: parseCommaList(_softSkillsCtrl.text),
      ),
      templateId: _template,
    );
  }

  void _patchCv(CvDocument cv) {
    ref.read(cvBuilderProvider.notifier).updateCv(_buildCvFromForm(cv));
    notifyDraftChanged();
  }

  Future<void> _ensureDraftPersistence(CvDocument cv) async {
    if (_draftSetup) return;
    _draftSetup = true;
    _draftFormId = DraftBoxKeys.cvMaker(cv.id);
    await setupDraftPersistence(
      formId: _draftFormId!,
      controllers: [
        _nameCtrl,
        _emailCtrl,
        _phoneCtrl,
        _locationCtrl,
        _linkedInCtrl,
        _summaryCtrl,
        _hardSkillsCtrl,
        _toolsSkillsCtrl,
        _softSkillsCtrl,
      ],
      serialize: () {
        final current = ref.read(cvBuilderProvider).cv;
        final built = current != null ? _buildCvFromForm(current) : cv;
        return {'cv': built.toJson()};
      },
      applyDraft: (data) {
        final raw = data['cv'];
        if (raw is! Map) return;
        try {
          final restored = CvDocument.fromJson(Map<String, dynamic>.from(raw));
          final photoPath = restored.photoLocalPath;
          final safePath = photoPath != null &&
                  DraftService.filterExistingPaths([photoPath]).isEmpty
              ? null
              : photoPath;
          ref.read(cvBuilderProvider.notifier).updateCv(
                restored.copyWith(photoLocalPath: safePath),
              );
          _initialized = false;
          _syncedCvId = null;
        } catch (_) {}
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(userLanguageProvider);
    final state = ref.watch(cvBuilderProvider);

    if (state.isLoading) {
      return GlassScreenScaffold(
        title: CvStrings.t('cv_title_build', locale),
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

    final cv = state.cv;
    if (cv == null) {
      return GlassScreenScaffold(
        title: CvStrings.t('cv_title_build', locale),
        titleStyle: HubTypography.hubTitle,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  state.error ??
                      CvStrings.t('cv_builder_load_failed', locale),
                  textAlign: TextAlign.center,
                  style: AppTypography.body,
                ),
                const SizedBox(height: AppSpacing.md),
                OutlinedButton(
                  onPressed: _ensureLoaded,
                  child: Text(CvStrings.t('cv_action_try_again', locale)),
                ),
                const SizedBox(height: AppSpacing.sm),
                TextButton(
                  onPressed: () => context.go('/jobs/cv-start'),
                  child: Text(CvStrings.t('cv_action_back_start', locale)),
                ),
              ],
            ),
          ),
        ),
      );
    }

    _syncFromCv(cv);
    final working = _buildCvFromForm(cv);
    unawaited(_ensureDraftPersistence(cv));

    return cvJobsToolTheme(
      child: GlassScreenScaffold(
        title: CvStrings.t('cv_title_build', locale),
        titleStyle: HubTypography.hubTitle,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        body: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            if (draftRestoreBanner != null) draftRestoreBanner!,
            GlassCard(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    CvStrings.t('cv_builder_complete_sections', locale),
                    style: AppTypography.title,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    CvStrings.t('cv_builder_sections_helper', locale),
                    style: AppTypography.body.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            cvBuilderSectionTitle('Template'),
            CvTemplatePicker(
              cv: working,
              selected: _template,
              locale: locale,
              onSelected: (id) {
                setState(() => _template = id);
                _patchCv(cv);
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            cvBuilderSectionTitle('Contact Information'),
            cvBuilderField(label: CvStrings.t('cv_field_full_name', locale), controller: _nameCtrl, onChanged: (_) => _patchCv(cv)),
            cvBuilderField(label: CvStrings.t('cv_field_phone', locale), controller: _phoneCtrl, keyboardType: TextInputType.phone, onChanged: (_) => _patchCv(cv)),
            cvBuilderField(label: CvStrings.t('cv_field_email', locale), controller: _emailCtrl, keyboardType: TextInputType.emailAddress, onChanged: (_) => _patchCv(cv)),
            cvBuilderField(label: CvStrings.t('cv_field_location', locale), controller: _locationCtrl, onChanged: (_) => _patchCv(cv)),
            cvBuilderField(label: CvStrings.t('cv_field_linkedin', locale), controller: _linkedInCtrl, keyboardType: TextInputType.url, onChanged: (_) => _patchCv(cv)),
            _PhotoSection(cv: working, onChanged: (updated) {
              ref.read(cvBuilderProvider.notifier).updateCv(_buildCvFromForm(updated));
            }),
            const SizedBox(height: AppSpacing.lg),
            cvBuilderSectionTitle('Professional Summary'),
            SegmentedButton<CvSummaryFormat>(
              segments: [
                ButtonSegment(
                  value: CvSummaryFormat.paragraph,
                  label: Text(CvStrings.t('cv_format_paragraph', locale)),
                ),
                ButtonSegment(
                  value: CvSummaryFormat.bullets,
                  label: Text(CvStrings.t('cv_format_bullets', locale)),
                ),
              ],
              selected: {_summaryFormat},
              onSelectionChanged: (s) {
                setState(() => _summaryFormat = s.first);
                _patchCv(cv);
              },
            ),
            const SizedBox(height: AppSpacing.sm),
            cvBuilderField(
              label: _summaryFormat == CvSummaryFormat.bullets
                  ? 'Summary (one bullet per line)'
                  : 'Summary paragraph',
              controller: _summaryCtrl,
              maxLines: 5,
              onChanged: (_) => _patchCv(cv),
            ),
            CvAiAssistButton(
              cv: working,
              fieldId: CvAssistField.summary.id,
              roughInput: _summaryCtrl.text,
              contextFacts: ref.read(cvAiServiceProvider).contextForSummary(working),
              onSelected: (text) {
                _summaryCtrl.text = text;
                _patchCv(cv);
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            cvBuilderSectionTitle('Work Experience'),
            if (cv.experience.isEmpty)
              Text(
                'No roles pre-filled — add experience below or update your EOSB profile.',
                style: AppTypography.caption,
              ),
            ...cv.experience.asMap().entries.map(
              (entry) => _ExperienceEditor(
                index: entry.key,
                exp: entry.value,
                cv: working,
                locale: locale,
                onChanged: (updated) {
                  final list = [...cv.experience];
                  list[entry.key] = updated;
                  ref.read(cvBuilderProvider.notifier).updateCv(
                        _buildCvFromForm(cv).copyWith(experience: list),
                      );
                },
              ),
            ),
            OutlinedButton.icon(
              onPressed: () {
                ref.read(cvBuilderProvider.notifier).updateCv(
                      _buildCvFromForm(cv).copyWith(
                        experience: [...cv.experience, const CvExperience()],
                      ),
                    );
                setState(() => _initialized = true);
              },
              icon: const Icon(Icons.add),
              label: Text(CvStrings.t('cv_add_experience', locale)),
            ),
            const SizedBox(height: AppSpacing.lg),
            cvBuilderSectionTitle('Education'),
            ...cv.education.asMap().entries.map(
              (entry) => _EducationEditor(
                edu: entry.value,
                locale: locale,
                onChanged: (updated) {
                  final list = [...cv.education];
                  list[entry.key] = updated;
                  ref.read(cvBuilderProvider.notifier).updateCv(
                        _buildCvFromForm(cv).copyWith(education: list),
                      );
                },
              ),
            ),
            OutlinedButton.icon(
              onPressed: () {
                ref.read(cvBuilderProvider.notifier).updateCv(
                      _buildCvFromForm(cv).copyWith(
                        education: [...cv.education, const CvEducation()],
                      ),
                    );
              },
              icon: const Icon(Icons.add),
              label: Text(CvStrings.t('cv_add_education', locale)),
            ),
            const SizedBox(height: AppSpacing.lg),
            cvBuilderSectionTitle('Skills'),
            cvBuilderField(
              label: CvStrings.t('cv_field_hard_skills', locale),
              controller: _hardSkillsCtrl,
              onChanged: (_) => _patchCv(cv),
            ),
            cvBuilderField(
              label: CvStrings.t('cv_field_tools', locale),
              controller: _toolsSkillsCtrl,
              onChanged: (_) => _patchCv(cv),
            ),
            cvBuilderField(
              label: CvStrings.t('cv_field_soft_skills', locale),
              controller: _softSkillsCtrl,
              onChanged: (_) => _patchCv(cv),
            ),
            CvAiAssistButton(
              cv: working,
              fieldId: CvAssistField.skills.id,
              roughInput: '${_hardSkillsCtrl.text}, ${_toolsSkillsCtrl.text}',
              contextFacts: ref.read(cvAiServiceProvider).contextForSkills(working),
              onSelected: (text) {
                _hardSkillsCtrl.text = text;
                _patchCv(cv);
              },
            ),
            const SizedBox(height: AppSpacing.md),
            EscoSkillGapPanel(
              cv: working,
              locale: locale,
              profileProfession: ref.watch(cvGapProfileProfessionProvider),
            ),
            const SizedBox(height: AppSpacing.lg),
            cvBuilderSectionTitle('Certifications & Licenses (optional)'),
            ...cv.certifications.asMap().entries.map(
              (entry) => _CertificationEditor(
                cert: entry.value,
                locale: locale,
                onChanged: (updated) {
                  final list = [...cv.certifications];
                  list[entry.key] = updated;
                  ref.read(cvBuilderProvider.notifier).updateCv(
                        _buildCvFromForm(cv).copyWith(certifications: list),
                      );
                },
                onRemove: () {
                  final list = [...cv.certifications]..removeAt(entry.key);
                  ref.read(cvBuilderProvider.notifier).updateCv(
                        _buildCvFromForm(cv).copyWith(certifications: list),
                      );
                },
              ),
            ),
            OutlinedButton.icon(
              onPressed: () {
                ref.read(cvBuilderProvider.notifier).updateCv(
                      _buildCvFromForm(cv).copyWith(
                        certifications: [...cv.certifications, const CvCertification()],
                      ),
                    );
              },
              icon: const Icon(Icons.add),
              label: Text(CvStrings.t('cv_add_certification', locale)),
            ),
            const SizedBox(height: AppSpacing.lg),
            cvBuilderSectionTitle('Projects (optional)'),
            ...cv.projects.asMap().entries.map(
              (entry) => _ProjectEditor(
                project: entry.value,
                locale: locale,
                onChanged: (updated) {
                  final list = [...cv.projects];
                  list[entry.key] = updated;
                  ref.read(cvBuilderProvider.notifier).updateCv(
                        _buildCvFromForm(cv).copyWith(projects: list),
                      );
                },
                onRemove: () {
                  final list = [...cv.projects]..removeAt(entry.key);
                  ref.read(cvBuilderProvider.notifier).updateCv(
                        _buildCvFromForm(cv).copyWith(projects: list),
                      );
                },
              ),
            ),
            OutlinedButton.icon(
              onPressed: () {
                ref.read(cvBuilderProvider.notifier).updateCv(
                      _buildCvFromForm(cv).copyWith(
                        projects: [...cv.projects, const CvProject()],
                      ),
                    );
              },
              icon: const Icon(Icons.add),
              label: Text(CvStrings.t('cv_add_project', locale)),
            ),
            const SizedBox(height: AppSpacing.lg),
            cvBuilderSectionTitle('Languages (optional)'),
            ...cv.languageEntries.asMap().entries.map(
              (entry) => _LanguageEditor(
                entry: entry.value,
                locale: locale,
                onChanged: (updated) {
                  final list = [...cv.languageEntries];
                  list[entry.key] = updated;
                  ref.read(cvBuilderProvider.notifier).updateCv(
                        _buildCvFromForm(cv).copyWith(languageEntries: list),
                      );
                },
                onRemove: () {
                  final list = [...cv.languageEntries]..removeAt(entry.key);
                  ref.read(cvBuilderProvider.notifier).updateCv(
                        _buildCvFromForm(cv).copyWith(languageEntries: list),
                      );
                },
              ),
            ),
            OutlinedButton.icon(
              onPressed: () {
                ref.read(cvBuilderProvider.notifier).updateCv(
                      _buildCvFromForm(cv).copyWith(
                        languageEntries: [
                          ...cv.languageEntries,
                          const CvLanguageEntry(),
                        ],
                      ),
                    );
              },
              icon: const Icon(Icons.add),
              label: Text(CvStrings.t('cv_add_language', locale)),
            ),
            const SizedBox(height: AppSpacing.xl),
            GlassPrimaryButton(
              label: CvStrings.t('cv_action_preview_export', locale),
              accentColor: AppColors.brandFamilyMain,
              onPressed: () async {
                final built = _buildCvFromForm(cv);
                ref.read(cvBuilderProvider.notifier).updateCv(built);
                await ref.read(cvBuilderProvider.notifier).persist();
                await clearFormDraft();
                if (context.mounted) {
                  context.push('/jobs/cv-preview?id=${built.id}');
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // Template picker moved to CvTemplatePicker widget.
}

class _PhotoSection extends ConsumerWidget {
  const _PhotoSection({required this.cv, required this.onChanged});

  final CvDocument cv;
  final ValueChanged<CvDocument> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(userLanguageProvider);
    final supportsPhoto = cv.templateId.supportsPhoto;
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(CvStrings.t('cv_photo_optional', locale), style: AppTypography.subtitle),
          const SizedBox(height: 4),
          Text(
            'Photos are common for some regions and industries but can affect ATS parsing for corporate/international roles — include only if appropriate for your target role.',
            style: AppTypography.caption.copyWith(color: AppColors.textTertiary),
          ),
          if (!supportsPhoto && MonetizationState.showPremiumTierUi) ...[
            const SizedBox(height: 4),
            Text(
              'Switch to the Premium template to show a photo on your CV.',
              style: AppTypography.caption.copyWith(color: AppColors.accentGold),
            ),
          ],
          if (supportsPhoto &&
              cv.photoLocalPath != null &&
              cv.photoLocalPath!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                File(cv.photoLocalPath!),
                width: 72,
                height: 72,
                fit: BoxFit.cover,
              ),
            ),
          ],
          if (supportsPhoto) ...[
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: () async {
                    final source = await showModalBottomSheet<ImageSource>(
                      context: context,
                      backgroundColor: AppColors.surfaceElevated,
                      builder: (ctx) => SafeArea(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              leading: const Icon(Icons.photo_camera_outlined),
                              title: Text(CvStrings.t('cv_photo_take', locale)),
                              onTap: () => Navigator.pop(ctx, ImageSource.camera),
                            ),
                            ListTile(
                              leading: const Icon(Icons.photo_library_outlined),
                              title: Text(CvStrings.t('cv_photo_gallery', locale)),
                              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
                            ),
                          ],
                        ),
                      ),
                    );
                    if (source == null) return;
                    final path = await ref.read(cvPhotoServiceProvider).pickAndSaveForCv(
                          cvId: cv.id,
                          source: source,
                        );
                    if (path != null) onChanged(cv.copyWith(photoLocalPath: path));
                  },
                  icon: const Icon(Icons.photo_outlined, size: 18),
                  label: Text(CvStrings.t('cv_photo_upload', locale)),
                ),
                if (cv.photoLocalPath != null && cv.photoLocalPath!.isNotEmpty) ...[
                  const SizedBox(width: AppSpacing.sm),
                  TextButton(
                    onPressed: () async {
                      await ref.read(cvPhotoServiceProvider).deleteLocal(cv.photoLocalPath);
                      onChanged(cv.copyWith(clearPhotoLocalPath: true, clearPhotoStorageUrl: true));
                    },
                    child: Text(CvStrings.t('cv_action_remove', locale)),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _ExperienceEditor extends ConsumerStatefulWidget {
  const _ExperienceEditor({
    required this.index,
    required this.exp,
    required this.cv,
    required this.locale,
    required this.onChanged,
  });

  final int index;
  final CvExperience exp;
  final CvDocument cv;
  final String locale;
  final ValueChanged<CvExperience> onChanged;

  @override
  ConsumerState<_ExperienceEditor> createState() => _ExperienceEditorState();
}

class _ExperienceEditorState extends ConsumerState<_ExperienceEditor> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _employerCtrl;
  late final TextEditingController _locationCtrl;
  late final TextEditingController _respCtrl;
  late final TextEditingController _achCtrl;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.exp.jobTitle);
    _employerCtrl = TextEditingController(text: widget.exp.employer);
    _locationCtrl = TextEditingController(text: widget.exp.location);
    _respCtrl = TextEditingController(text: bulletsToText(widget.exp.displayResponsibilities));
    _achCtrl = TextEditingController(text: bulletsToText(widget.exp.displayAchievements));
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _employerCtrl.dispose();
    _locationCtrl.dispose();
    _respCtrl.dispose();
    _achCtrl.dispose();
    super.dispose();
  }

  void _emit(CvExperience base) {
    widget.onChanged(
      base.copyWith(
        jobTitle: _titleCtrl.text.trim(),
        employer: _employerCtrl.text.trim(),
        location: _locationCtrl.text.trim(),
        responsibilities: parseBulletLines(_respCtrl.text),
        achievements: parseBulletLines(_achCtrl.text),
        bullets: const [],
        description: '',
      ),
    );
  }

  Future<void> _pickStart(CvExperience exp) async {
    final picked = await showCvMonthYearPicker(context, initial: exp.startDate);
    if (picked != null) _emit(exp.copyWith(startDate: picked));
  }

  Future<void> _pickEnd(CvExperience exp) async {
    final picked = await showCvMonthYearPicker(context, initial: exp.endDate);
    if (picked != null) _emit(exp.copyWith(endDate: picked, isCurrent: false));
  }

  @override
  Widget build(BuildContext context) {
    final exp = widget.exp;
    final locale = widget.locale;
    final validation = exp.dateValidationError;

    return cvBuilderSubCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          cvBuilderField(label: CvStrings.t('cv_field_job_title', locale), controller: _titleCtrl, onChanged: (_) => _emit(exp)),
          cvBuilderField(
            label: CvStrings.t('cv_field_company', locale),
            controller: _employerCtrl,
            onChanged: (_) {
              setState(() {});
              _emit(exp);
            },
          ),
          BeforeYouSignSection(
            locale: AppLocale.normalize(ref.watch(userLanguageProvider)),
            employerName: _employerCtrl.text,
          ),
          cvBuilderField(label: CvStrings.t('cv_field_location_short', locale), controller: _locationCtrl, onChanged: (_) => _emit(exp)),
          Row(
            children: [
              Expanded(
                child: cvMonthYearField(
                  label: CvStrings.t('cv_field_start_date', locale),
                  value: exp.startDate,
                  onTap: () => _pickStart(exp),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: cvMonthYearField(
                  label: CvStrings.t('cv_field_end_date', locale),
                  value: exp.isCurrent ? null : exp.endDate,
                  enabled: !exp.isCurrent,
                  onTap: () => _pickEnd(exp),
                ),
              ),
            ],
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              CvStrings.t('cv_field_currently_working', locale),
              style: AppTypography.bodySmall,
            ),
            value: exp.isCurrent,
            onChanged: (v) => _emit(
              exp.copyWith(isCurrent: v, clearEndDate: v),
            ),
          ),
          if (validation != null)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Text(
                validation,
                style: AppTypography.caption.copyWith(color: AppColors.errorBright),
              ),
            ),
          cvBuilderField(
            label: CvStrings.t('cv_field_responsibilities', locale),
            controller: _respCtrl,
            maxLines: 5,
            onChanged: (_) => _emit(exp),
          ),
          if (widget.index < 3)
            CvAiAssistButton(
              cv: widget.cv,
              fieldId: cvAssistFieldResponsibilities(widget.index),
              roughInput: _respCtrl.text,
              contextFacts: ref.read(cvAiServiceProvider).contextForExperience(
                    exp.copyWith(responsibilities: parseBulletLines(_respCtrl.text)),
                    fieldKind: 'responsibilities',
                  ),
              onSelected: (text) {
                _respCtrl.text = text;
                _emit(exp);
              },
            ),
          cvBuilderField(
            label: CvStrings.t('cv_field_achievements', locale),
            controller: _achCtrl,
            maxLines: 5,
            hint: 'Include metrics only if they are true.',
            onChanged: (_) => _emit(exp),
          ),
          if (widget.index < 3)
            CvAiAssistButton(
              cv: widget.cv,
              fieldId: cvAssistFieldAchievements(widget.index),
              roughInput: _achCtrl.text,
              contextFacts: ref.read(cvAiServiceProvider).contextForExperience(
                    exp.copyWith(achievements: parseBulletLines(_achCtrl.text)),
                    fieldKind: 'achievements',
                  ),
              onSelected: (text) {
                _achCtrl.text = text;
                _emit(exp);
              },
            ),
        ],
      ),
    );
  }
}

class _EducationEditor extends StatefulWidget {
  const _EducationEditor({
    required this.edu,
    required this.locale,
    required this.onChanged,
  });

  final CvEducation edu;
  final String locale;
  final ValueChanged<CvEducation> onChanged;

  @override
  State<_EducationEditor> createState() => _EducationEditorState();
}

class _EducationEditorState extends State<_EducationEditor> {
  late final TextEditingController _degreeCtrl;
  late final TextEditingController _schoolCtrl;
  late final TextEditingController _locCtrl;
  late bool _showYear;
  DateTime? _gradDate;

  @override
  void initState() {
    super.initState();
    _degreeCtrl = TextEditingController(text: widget.edu.qualification);
    _schoolCtrl = TextEditingController(text: widget.edu.institution);
    _locCtrl = TextEditingController(text: widget.edu.institutionLocation);
    _gradDate = widget.edu.graduationDate;
    _showYear = widget.edu.showGraduationYear;
  }

  @override
  void dispose() {
    _degreeCtrl.dispose();
    _schoolCtrl.dispose();
    _locCtrl.dispose();
    super.dispose();
  }

  void _emit() {
    widget.onChanged(
      widget.edu.copyWith(
        qualification: _degreeCtrl.text.trim(),
        institution: _schoolCtrl.text.trim(),
        institutionLocation: _locCtrl.text.trim(),
        graduationDate: _gradDate,
        year: _gradDate != null ? '${_gradDate!.year}' : '',
        showGraduationYear: _showYear,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = widget.locale;
    return cvBuilderSubCard(
      child: Column(
        children: [
          cvBuilderField(label: CvStrings.t('cv_field_degree', locale), controller: _degreeCtrl, onChanged: (_) => _emit()),
          cvBuilderField(label: CvStrings.t('cv_field_school', locale), controller: _schoolCtrl, onChanged: (_) => _emit()),
          cvBuilderField(label: CvStrings.t('cv_field_school_location', locale), controller: _locCtrl, onChanged: (_) => _emit()),
          cvMonthYearField(
            label: CvStrings.t('cv_field_graduation', locale),
            value: _gradDate,
            onTap: () async {
              final picked = await showCvMonthYearPicker(context, initial: _gradDate);
              if (picked != null) {
                setState(() => _gradDate = picked);
                _emit();
              }
            },
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              CvStrings.t('cv_field_show_grad_year', locale),
              style: AppTypography.bodySmall,
            ),
            value: _showYear,
            onChanged: (v) {
              setState(() => _showYear = v);
              _emit();
            },
          ),
        ],
      ),
    );
  }
}

class _CertificationEditor extends StatefulWidget {
  const _CertificationEditor({
    required this.cert,
    required this.locale,
    required this.onChanged,
    required this.onRemove,
  });

  final CvCertification cert;
  final String locale;
  final ValueChanged<CvCertification> onChanged;
  final VoidCallback onRemove;

  @override
  State<_CertificationEditor> createState() => _CertificationEditorState();
}

class _CertificationEditorState extends State<_CertificationEditor> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _issuerCtrl;
  DateTime? _issueDate;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.cert.name);
    _issuerCtrl = TextEditingController(text: widget.cert.issuer);
    _issueDate = widget.cert.issueDate;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _issuerCtrl.dispose();
    super.dispose();
  }

  void _emit() {
    widget.onChanged(
      widget.cert.copyWith(
        name: _nameCtrl.text.trim(),
        issuer: _issuerCtrl.text.trim(),
        issueDate: _issueDate,
        year: _issueDate != null ? '${_issueDate!.year}' : '',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = widget.locale;
    return cvBuilderSubCard(
      child: Column(
        children: [
          cvBuilderField(label: CvStrings.t('cv_field_cert_name', locale), controller: _nameCtrl, onChanged: (_) => _emit()),
          cvBuilderField(label: CvStrings.t('cv_field_issuer', locale), controller: _issuerCtrl, onChanged: (_) => _emit()),
          cvMonthYearField(
            label: CvStrings.t('cv_field_issue_date', locale),
            value: _issueDate,
            onTap: () async {
              final picked = await showCvMonthYearPicker(context, initial: _issueDate);
              if (picked != null) {
                setState(() => _issueDate = picked);
                _emit();
              }
            },
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: widget.onRemove,
              child: Text(CvStrings.t('cv_action_remove', locale)),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProjectEditor extends StatefulWidget {
  const _ProjectEditor({
    required this.project,
    required this.locale,
    required this.onChanged,
    required this.onRemove,
  });

  final CvProject project;
  final String locale;
  final ValueChanged<CvProject> onChanged;
  final VoidCallback onRemove;

  @override
  State<_ProjectEditor> createState() => _ProjectEditorState();
}

class _ProjectEditorState extends State<_ProjectEditor> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _urlCtrl;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.project.title);
    _descCtrl = TextEditingController(text: widget.project.description);
    _urlCtrl = TextEditingController(text: widget.project.url);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _urlCtrl.dispose();
    super.dispose();
  }

  void _emit() {
    widget.onChanged(
      widget.project.copyWith(
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        url: _urlCtrl.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = widget.locale;
    return cvBuilderSubCard(
      child: Column(
        children: [
          cvBuilderField(label: CvStrings.t('cv_field_project_title', locale), controller: _titleCtrl, onChanged: (_) => _emit()),
          cvBuilderField(label: CvStrings.t('cv_field_description', locale), controller: _descCtrl, maxLines: 3, onChanged: (_) => _emit()),
          cvBuilderField(label: CvStrings.t('cv_field_url', locale), controller: _urlCtrl, onChanged: (_) => _emit()),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: widget.onRemove,
              child: Text(CvStrings.t('cv_action_remove', locale)),
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguageEditor extends StatefulWidget {
  const _LanguageEditor({
    required this.entry,
    required this.locale,
    required this.onChanged,
    required this.onRemove,
  });

  final CvLanguageEntry entry;
  final String locale;
  final ValueChanged<CvLanguageEntry> onChanged;
  final VoidCallback onRemove;

  @override
  State<_LanguageEditor> createState() => _LanguageEditorState();
}

class _LanguageEditorState extends State<_LanguageEditor> {
  late final TextEditingController _langCtrl;
  late final TextEditingController _profCtrl;

  @override
  void initState() {
    super.initState();
    _langCtrl = TextEditingController(text: widget.entry.language);
    _profCtrl = TextEditingController(text: widget.entry.proficiency);
  }

  @override
  void dispose() {
    _langCtrl.dispose();
    _profCtrl.dispose();
    super.dispose();
  }

  void _emit() {
    widget.onChanged(
      widget.entry.copyWith(
        language: _langCtrl.text.trim(),
        proficiency: _profCtrl.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = widget.locale;
    return cvBuilderSubCard(
      child: Column(
        children: [
          cvBuilderField(label: CvStrings.t('cv_field_language', locale), controller: _langCtrl, onChanged: (_) => _emit()),
          cvBuilderField(label: CvStrings.t('cv_field_proficiency', locale), controller: _profCtrl, onChanged: (_) => _emit()),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: widget.onRemove,
              child: Text(CvStrings.t('cv_action_remove', locale)),
            ),
          ),
        ],
      ),
    );
  }
}
