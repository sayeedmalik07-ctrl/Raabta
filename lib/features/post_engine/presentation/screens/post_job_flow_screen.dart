import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/l10n/app_locale_notifier.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/draft_restore_banner.dart';
import 'package:raabta/core/widgets/glass_primary_button.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/core/widgets/glass_secondary_button.dart';
import 'package:raabta/core/widgets/glass_text_field.dart';
import 'package:raabta/data/models/business_listing.dart';
import 'package:raabta/data/models/job_requirements.dart';
import 'package:raabta/features/post_engine/data/post_duplicate_candidate_loader.dart';
import 'package:raabta/features/post_engine/domain/job_post_business_link.dart';
import 'package:raabta/features/post_engine/domain/post_draft_manager.dart';
import 'package:raabta/features/post_engine/domain/post_engine.dart';
import 'package:raabta/features/saved_search/domain/saved_search_vertical.dart';
import 'package:raabta/features/saved_search/providers/saved_search_providers.dart';
import 'package:raabta/features/post_engine/domain/models/post_publish_models.dart';
import 'package:raabta/features/post_engine/domain/post_draft_publish_state.dart';
import 'package:raabta/features/post_engine/domain/post_publish_coordinator.dart';
import 'package:raabta/features/post_engine/domain/post_publish_engine.dart';
import 'package:raabta/features/post_engine/domain/post_publish_trust_gate.dart';
import 'package:raabta/features/post_engine/domain/post_quality_engine.dart';
import 'package:raabta/features/post_engine/domain/post_trust_engine.dart';
import 'package:raabta/features/post_engine/domain/post_validation_debug.dart';
import 'package:raabta/features/post_engine/domain/post_validation_engine.dart';
import 'package:raabta/features/post_engine/l10n/post_engine_strings.dart';
import 'package:raabta/features/post_engine/presentation/post_draft_relocated_snackbar.dart';
import 'package:raabta/features/post_engine/presentation/post_flow_actions.dart';
import 'package:raabta/services/drafts/draft_service.dart';
import 'package:raabta/features/post_engine/presentation/providers/post_schema_providers.dart';
import 'package:raabta/features/post_engine/presentation/widgets/draft_saved_indicator.dart';
import 'package:raabta/features/post_engine/presentation/widgets/post_combined_category_step.dart';
import 'package:raabta/features/post_engine/presentation/widgets/post_flow_step_indicator.dart';
import 'package:raabta/features/post_engine/presentation/widgets/post_schema_form.dart';
import 'package:raabta/features/post_engine/presentation/widgets/post_vertical_preview.dart';
import 'package:raabta/providers/auth_providers.dart';
import 'package:raabta/providers/business_providers.dart';
import 'package:raabta/providers/jobs_providers.dart';
import 'package:raabta/core/l10n/classifieds_compliance_strings.dart';

enum _JobFlowStep { category, form, preview }

/// Routed job posting flow — extends [PostJobSheet] requirements logic, not a second system.
class PostJobFlowScreen extends ConsumerStatefulWidget {
  const PostJobFlowScreen({
    super.key,
    this.categoryPath,
  });

  final String? categoryPath;

  @override
  ConsumerState<PostJobFlowScreen> createState() => _PostJobFlowScreenState();
}

class _PostJobFlowScreenState extends ConsumerState<PostJobFlowScreen> {
  final Map<String, dynamic> _values = {};
  final GlobalKey<PostSchemaFormState> _formKey = GlobalKey();
  Map<String, String> _errors = {};
  final _skillsController = TextEditingController();
  final _experienceController = TextEditingController();
  final _qualificationsController = TextEditingController();
  final _languagesController = TextEditingController();
  var _housing = false;
  var _flight = false;
  var _medical = false;
  var _other = false;
  late _JobFlowStep _step;
  String? _categoryPath;
  PostDraftManager? _draftManager;
  DateTime? _lastSavedAt;
  DraftRecord? _pendingDraft;
  bool _showRestoreBanner = false;
  bool _publishing = false;
  bool _tradeComplianceAcknowledged = false;
  String? _linkedBusinessId;
  String? _linkedBusinessName;

  static const _wizardSteps = 3;

  @override
  void initState() {
    super.initState();
    _categoryPath = widget.categoryPath?.isNotEmpty == true
        ? widget.categoryPath
        : null;
    _step = _categoryPath == null
        ? _JobFlowStep.category
        : _JobFlowStep.form;
    if (_categoryPath != null) {
      _initDrafts(_categoryPath!);
    }
  }

  void _onCategorySelected(String path) {
    setState(() {
      _categoryPath = path;
      _step = _JobFlowStep.form;
      _values.clear();
      _showRestoreBanner = false;
      _pendingDraft = null;
    });
    _initDrafts(path);
  }

  Future<void> _initDrafts(String categoryPath) async {
    _draftManager?.dispose();
    final manager = PostEngine().drafts(
      vertical: PostVertical.jobs,
      categoryPath: categoryPath,
      onSaved: (at) {
        if (mounted) setState(() => _lastSavedAt = at);
      },
    );
    await manager.init();
    manager.controller.bindControllers(
      [_skillsController, _experienceController, _qualificationsController, _languagesController],
      _serializeAll,
    );
    final draft = await manager.loadRestorableDraft();
    if (!mounted) return;
    if (draft != null) _applyDraft(draft.data);
    setState(() {
      _draftManager = manager;
      if (draft != null) {
        _pendingDraft = draft;
        _showRestoreBanner = true;
        _lastSavedAt = draft.savedAt;
      }
    });
  }

  Map<String, dynamic> _serializeAll() => {
        ..._values,
        if (_linkedBusinessId != null)
          JobPostBusinessLink.linkedBusinessIdDraftKey: _linkedBusinessId,
        if (_linkedBusinessName != null)
          JobPostBusinessLink.linkedBusinessNameDraftKey: _linkedBusinessName,
        'skills': _skillsController.text,
        'experience': _experienceController.text,
        'qualifications': _qualificationsController.text,
        'languages': _languagesController.text,
        'housing': _housing,
        'flight': _flight,
        'medical': _medical,
        'other': _other,
      };

  void _applyDraft(Map<String, dynamic> data) {
    _values
      ..clear()
      ..addAll(Map<String, dynamic>.from(data)
        ..remove('_vertical')
        ..remove('_categoryPath')
        ..remove('_schemaVersion')
        ..remove('skills')
        ..remove('experience')
        ..remove('qualifications')
        ..remove('languages')
        ..remove('housing')
        ..remove('flight')
        ..remove('medical')
        ..remove('other')
        ..remove(JobPostBusinessLink.linkedBusinessIdDraftKey)
        ..remove(JobPostBusinessLink.linkedBusinessNameDraftKey));
    _linkedBusinessId = JobPostBusinessLink.readLinkedBusinessId(data);
    _linkedBusinessName = JobPostBusinessLink.readLinkedBusinessName(data);
    _skillsController.text = data['skills']?.toString() ?? '';
    _experienceController.text = data['experience']?.toString() ?? '';
    _qualificationsController.text = data['qualifications']?.toString() ?? '';
    _languagesController.text = data['languages']?.toString() ?? '';
    _housing = data['housing'] == true;
    _flight = data['flight'] == true;
    _medical = data['medical'] == true;
    _other = data['other'] == true;
  }

  JobRequirementsSpec _requirementsFromForm() {
    return JobRequirementsSpec(
      requiredSkills: JobRequirementsSpec.parseCommaSeparated(_skillsController.text),
      minimumExperience: _experienceController.text.trim(),
      qualifications:
          JobRequirementsSpec.parseCommaSeparated(_qualificationsController.text),
      languageRequirements:
          JobRequirementsSpec.parseCommaSeparated(_languagesController.text),
    );
  }

  List<String> get _benefits {
    final benefits = <String>[];
    if (_housing) benefits.add('Housing');
    if (_flight) benefits.add('Flight');
    if (_medical) benefits.add('Medical');
    if (_other) benefits.add('Other');
    return benefits;
  }

  @override
  void dispose() {
    final draftFormId = _draftManager?.formId;
    _draftManager?.dispose();
    if (draftFormId != null) {
      unawaited(
        DraftService.instance.getDraft(draftFormId).then((record) {
          if (record != null) PostDraftRelocatedSnackbar.markPending();
        }),
      );
    }
    _skillsController.dispose();
    _experienceController.dispose();
    _qualificationsController.dispose();
    _languagesController.dispose();
    super.dispose();
  }

  void _onSchemaChanged(Map<String, dynamic> next) {
    setState(() {
      _values
        ..clear()
        ..addAll(next);
      _errors = {};
    });
    _draftManager?.scheduleSave(_serializeAll());
  }

  void _selectLinkedBusiness(BusinessListing business) {
    setState(() {
      _linkedBusinessId = business.id;
      _linkedBusinessName = business.name;
      _values['company'] = business.name;
    });
    _draftManager?.scheduleSave(_serializeAll());
  }

  void _clearLinkedBusiness() {
    setState(() {
      _linkedBusinessId = null;
      _linkedBusinessName = null;
    });
    _draftManager?.scheduleSave(_serializeAll());
  }

  String? _resumeListingId() {
    final data = _pendingDraft?.data;
    if (data == null) return null;
    return PostDraftPublishState.listingId(data) ??
        PostDraftPublishState.publishId(data);
  }

  Future<void> _publish() async {
    final categoryPath = _categoryPath;
    if (categoryPath == null) return;
    if (_publishing) return;
    _publishing = true;

    final locale = ref.read(appLocaleProvider);
    final requirements = _requirementsFromForm();
    if (!requirements.isSpecified) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(PostEngineStrings.t('requirements_hint', locale))),
      );
      _publishing = false;
      return;
    }

    final schema = await ref.read(
      postCategoryFieldSchemaProvider(
        (
          vertical: PostVertical.jobs,
          categoryPath: categoryPath,
          forServiceRequest: false,
        ),
      ).future,
    );
    final values = _formKey.currentState?.collectValues() ?? _values;
    if (values != _values) {
      setState(() {
        _values
          ..clear()
          ..addAll(values);
      });
    }
    final validation = const PostValidationEngine().validate(
      schema: schema,
      values: values,
      locale: locale,
      debug: true,
      debugVertical: PostVertical.jobs.id,
      debugCategoryPath: categoryPath,
    );
    if (validation.isNotEmpty) {
      PostValidationDebug.logNavigation(
        nextRoute: 'publish',
        allowed: false,
        reason: '${validation.length} validation error(s)',
      );
      setState(() {
        _errors = validation;
        _step = _JobFlowStep.form;
      });
      _publishing = false;
      return;
    }

    PostValidationDebug.logNavigation(nextRoute: 'publish', allowed: true);

    final user = ref.read(currentUserProvider);
    if (user == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(PostEngineStrings.t('sign_in_required', locale))),
      );
      _publishing = false;
      return;
    }

    if (mounted) setState(() {});

    PostTrustEvaluation trust;
    try {
      trust = await PostPublishTrustGate.evaluate(
        vertical: PostVertical.jobs,
        categoryPath: categoryPath,
        fieldValues: values,
        ownerUserId: user.uid,
        locale: locale,
        resumeListingId: _resumeListingId(),
      );
    } on PostDuplicateCandidateLoadException catch (e) {
      if (!mounted) return;
      _publishing = false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${PostEngineStrings.t('publish_failed', locale)}: $e'),
        ),
      );
      return;
    }

    if (!trust.allowed) {
      if (!mounted) return;
      _publishing = false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(trust.userMessage)),
      );
      return;
    }
    if (trust.outcome == PostTrustOutcome.reviewRequired && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(trust.userMessage)),
      );
    }

    final quality = const PostQualityEngine().evaluate(
      schema: schema,
      values: values,
      locale: locale,
    );
    if (!quality.canPublish) {
      if (!mounted) return;
      _publishing = false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(PostEngineStrings.t('quality_publish_blocked', locale)),
        ),
      );
      return;
    }

    if (!_tradeComplianceAcknowledged) {
      if (!mounted) return;
      _publishing = false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ClassifiedsComplianceStrings.t('post_trade_ack_required', locale),
          ),
        ),
      );
      return;
    }

    try {
      final draftManager = _draftManager;
      if (draftManager == null) {
        throw StateError('Draft manager not initialized');
      }
      final coordinator = PostPublishCoordinator(
        draftManager: draftManager,
        engine: ref.read(postEngineProvider).publish,
      );
      final result = await coordinator.publish(
        vertical: PostVertical.jobs,
        categoryPath: categoryPath,
        fieldValues: values,
        ownerUserId: user.uid,
        schema: schema,
        jobRequirements: requirements,
        jobBenefits: _benefits,
        tradeComplianceAcknowledged: _tradeComplianceAcknowledged,
        linkedBusinessId: _linkedBusinessId,
      );

      if (result.shouldEmitSideEffects) {
        PostEngine().analytics.trackPublish(
          verticalId: PostVertical.jobs.id,
          categoryPath: _categoryPath!,
          listingId: result.listingId,
          userId: user.uid,
        );
        unawaited(
          ref.read(savedSearchMatchClientProvider).triggerMatch(
                vertical: SavedSearchVertical.jobs,
                listingId: result.listingId,
                publisherUserId: user.uid,
              ),
        );
      }
      ref.invalidate(jobsRepositoryProvider);
      if (!mounted) return;
      if (result.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(PostEngineStrings.t('publish_success', locale))),
        );
        context.pop();
      }
    } on PostPublishInFlightException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(PostEngineStrings.t('publish_in_flight', locale))),
        );
      }
    } on PostPublishOwnershipException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(PostEngineStrings.t('publish_ownership_denied', locale)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${PostEngineStrings.t('publish_failed', locale)}: $e')),
        );
      }
    } finally {
      _publishing = false;
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(appLocaleProvider);

    if (_step == _JobFlowStep.category || _categoryPath == null) {
      return GlassScreenScaffold(
        title: PostFlowActions.flowTitle(PostVertical.jobs, locale),
        body: PostCombinedCategoryStep(
          vertical: PostVertical.jobs,
          locale: locale,
          totalSteps: _wizardSteps,
          onCategorySelected: _onCategorySelected,
        ),
      );
    }

    final categoryPath = _categoryPath!;
    final schemaAsync = ref.watch(
      postCategoryFieldSchemaProvider(
        (
          vertical: PostVertical.jobs,
          categoryPath: categoryPath,
          forServiceRequest: false,
        ),
      ),
    );

    return GlassScreenScaffold(
      title: PostFlowActions.flowTitle(PostVertical.jobs, locale),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: AppSpacing.md),
          child: DraftSavedIndicator(lastSavedAt: _lastSavedAt, locale: locale),
        ),
      ],
      body: schemaAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(child: Text(PostEngineStrings.t('schema_load_error', locale))),
        data: (schema) {
          final quality = const PostQualityEngine().evaluate(
            schema: schema,
            values: _values,
            locale: locale,
          );

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              if (_showRestoreBanner && _pendingDraft != null)
                DraftRestoreBanner(
                  savedAt: _pendingDraft!.savedAt,
                  onRestore: () {
                    _applyDraft(_pendingDraft!.data);
                    setState(() => _showRestoreBanner = false);
                  },
                  onDiscard: () async {
                    await _draftManager?.clearDraft();
                    if (!mounted) return;
                    setState(() {
                      _showRestoreBanner = false;
                      _pendingDraft = null;
                    });
                  },
                ),
              if (_step == _JobFlowStep.form) ...[
                PostFlowStepIndicator(
                  currentStep: 2,
                  totalSteps: _wizardSteps,
                  stepLabelKey: 'flow_step_details',
                  locale: locale,
                ),
                const SizedBox(height: AppSpacing.md),
                _JobLinkedBusinessSelector(
                  locale: locale,
                  selectedBusinessId: _linkedBusinessId,
                  onSelect: _selectLinkedBusiness,
                  onClear: _clearLinkedBusiness,
                ),
                const SizedBox(height: AppSpacing.md),
                PostSchemaForm(
                  key: _formKey,
                  schema: schema,
                  values: _values,
                  locale: locale,
                  errors: _errors,
                  onChanged: _onSchemaChanged,
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  PostEngineStrings.t('requirements_section', locale),
                  style: AppTypography.title,
                ),
                const SizedBox(height: AppSpacing.sm),
                GlassTextField(
                  controller: _skillsController,
                  label: PostEngineStrings.t('field_skills_comma_separated', locale),
                  onChanged: (_) => _draftManager?.scheduleSave(_serializeAll()),
                ),
                const SizedBox(height: AppSpacing.sm),
                GlassTextField(
                  controller: _experienceController,
                  label: PostEngineStrings.t('field_minimum_experience_label', locale),
                  onChanged: (_) => _draftManager?.scheduleSave(_serializeAll()),
                ),
                const SizedBox(height: AppSpacing.sm),
                GlassTextField(
                  controller: _qualificationsController,
                  label: PostEngineStrings.t('field_qualifications_label', locale),
                  onChanged: (_) => _draftManager?.scheduleSave(_serializeAll()),
                ),
                const SizedBox(height: AppSpacing.sm),
                GlassTextField(
                  controller: _languagesController,
                  label: PostEngineStrings.t('field_language_requirements_label', locale),
                  onChanged: (_) => _draftManager?.scheduleSave(_serializeAll()),
                ),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  children: [
                    FilterChip(
                      label: Text(PostEngineStrings.benefitLabel('housing', locale)),
                      selected: _housing,
                      onSelected: (v) {
                        setState(() => _housing = v);
                        _draftManager?.scheduleSave(_serializeAll());
                      },
                    ),
                    FilterChip(
                      label: Text(PostEngineStrings.benefitLabel('flight', locale)),
                      selected: _flight,
                      onSelected: (v) {
                        setState(() => _flight = v);
                        _draftManager?.scheduleSave(_serializeAll());
                      },
                    ),
                    FilterChip(
                      label: Text(PostEngineStrings.benefitLabel('medical', locale)),
                      selected: _medical,
                      onSelected: (v) {
                        setState(() => _medical = v);
                        _draftManager?.scheduleSave(_serializeAll());
                      },
                    ),
                    FilterChip(
                      label: Text(PostEngineStrings.benefitLabel('other', locale)),
                      selected: _other,
                      onSelected: (v) {
                        setState(() => _other = v);
                        _draftManager?.scheduleSave(_serializeAll());
                      },
                    ),
                  ],
                ),
              ] else
                PostVerticalPreview(
                  vertical: PostVertical.jobs,
                  categoryPath: categoryPath,
                  values: {
                    ..._values,
                    'requirements': _requirementsFromForm().toMatchList(),
                    if (_linkedBusinessName != null)
                      JobPostBusinessLink.linkedBusinessNamePreviewKey:
                          _linkedBusinessName,
                  },
                  locale: locale,
                ),
              const SizedBox(height: AppSpacing.xl),
              if (_step == _JobFlowStep.form) ...[
                GlassSecondaryButton(
                  label: PostFlowActions.previewLabel(PostVertical.jobs, locale),
                  onPressed: () => setState(() => _step = _JobFlowStep.preview),
                ),
                const SizedBox(height: AppSpacing.sm),
                GlassSecondaryButton(
                  label: PostFlowActions.saveDraftLabel(PostVertical.jobs, locale),
                  onPressed: () => _draftManager?.saveDraft(_serializeAll()),
                ),
                const SizedBox(height: AppSpacing.sm),
                GlassPrimaryButton(
                  label: PostFlowActions.publishLabel(PostVertical.jobs, locale),
                  onPressed:
                      quality.canPublish && !_publishing ? _publish : null,
                ),
              ] else ...[
                CheckboxListTile(
                  value: _tradeComplianceAcknowledged,
                  onChanged: (v) => setState(
                    () => _tradeComplianceAcknowledged = v ?? false,
                  ),
                  title: Text(
                    ClassifiedsComplianceStrings.t('post_trade_ack_label', locale),
                    style: AppTypography.bodySmall,
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                ),
                GlassSecondaryButton(
                  label: PostEngineStrings.t('action_back_to_edit', locale),
                  onPressed: () => setState(() => _step = _JobFlowStep.form),
                ),
                const SizedBox(height: AppSpacing.sm),
                GlassPrimaryButton(
                  label: PostFlowActions.publishLabel(PostVertical.jobs, locale),
                  onPressed:
                      quality.canPublish && !_publishing ? _publish : null,
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _JobLinkedBusinessSelector extends ConsumerWidget {
  const _JobLinkedBusinessSelector({
    required this.locale,
    required this.selectedBusinessId,
    required this.onSelect,
    required this.onClear,
  });

  final String locale;
  final String? selectedBusinessId;
  final void Function(BusinessListing business) onSelect;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    if (user == null) {
      return Text(
        'Sign in to optionally link a business you own.',
        style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
      );
    }

    final ownedAsync = ref.watch(userOwnedBusinessesProvider);
    return ownedAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: LinearProgressIndicator(),
      ),
      error: (_, _) => Text(
        'Could not load your businesses. You can still enter a company name below.',
        style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
      ),
      data: (businesses) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Link to your business (optional)',
              style: AppTypography.title,
            ),
            const SizedBox(height: 4),
            Text(
              'Linking is optional. Employer identity status is shown for information only.',
              style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.sm),
            if (businesses.isEmpty)
              Text(
                'You have no business listings yet. Enter a company name below or add a business in the directory.',
                style: AppTypography.caption,
              )
            else ...[
              if (selectedBusinessId != null)
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: onClear,
                    child: const Text('Remove business link'),
                  ),
                ),
              ...businesses.map((business) {
                final selected = business.id == selectedBusinessId;
                final identityStatus =
                    JobPostBusinessLink.employerIdentityStatusLabel(business);
                return Card(
                  color: selected
                      ? AppColors.glassSurface
                      : AppColors.surface.withValues(alpha: 0.6),
                  margin: const EdgeInsets.only(bottom: AppSpacing.xs),
                  child: ListTile(
                    dense: true,
                    selected: selected,
                    title: Text(business.name, style: AppTypography.body),
                    subtitle: Text(
                      'Employer identity: $identityStatus',
                      style: AppTypography.caption,
                    ),
                    trailing: selected
                        ? const Icon(Icons.check_circle_outline, size: 20)
                        : null,
                    onTap: () => onSelect(business),
                  ),
                );
              }),
            ],
          ],
        );
      },
    );
  }
}
