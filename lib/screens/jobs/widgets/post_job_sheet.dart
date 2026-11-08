import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/mixins/draft_persistence_mixin.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/data/categories/job_categories.dart';
import 'package:raabta/data/models/job_requirements.dart';
import 'package:raabta/providers/jobs_providers.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:raabta/screens/jobs/l10n/jobs_strings.dart';
import 'package:raabta/services/drafts/draft_box_keys.dart';

abstract final class PostJobSheet {
  static Future<void> show(BuildContext context, WidgetRef ref) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        final viewInsets = MediaQuery.viewInsetsOf(ctx);
        return Padding(
          padding: EdgeInsets.only(bottom: viewInsets.bottom),
          child: _PostJobSheetBody(parentContext: context, ref: ref),
        );
      },
    );
  }
}

class _PostJobSheetBody extends StatefulWidget {
  const _PostJobSheetBody({required this.parentContext, required this.ref});

  final BuildContext parentContext;
  final WidgetRef ref;

  @override
  State<_PostJobSheetBody> createState() => _PostJobSheetBodyState();
}

class _PostJobSheetBodyState extends State<_PostJobSheetBody> {
  final _titleController = TextEditingController();
  final _companyController = TextEditingController();
  final _salaryController = TextEditingController();
  final _locationController = TextEditingController(text: 'Qatar');
  final _descriptionController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _skillsController = TextEditingController();
  final _experienceController = TextEditingController();
  final _qualificationsController = TextEditingController();
  final _languagesController = TextEditingController();
  var _housing = false;
  var _flight = false;
  var _medical = false;
  var _other = false;
  var _category = kJobCategories.length > 1 ? kJobCategories[1] : 'General';
  var _submitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _companyController.dispose();
    _salaryController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _whatsappController.dispose();
    _skillsController.dispose();
    _experienceController.dispose();
    _qualificationsController.dispose();
    _languagesController.dispose();
    super.dispose();
  }

  List<String> get _benefits {
    final benefits = <String>[];
    if (_housing) benefits.add('Housing');
    if (_flight) benefits.add('Flight');
    if (_medical) benefits.add('Medical');
    if (_other) benefits.add('Other');
    return benefits;
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

  Future<void> _submit(DraftSheetHandle draft, String locale) async {
    if (_titleController.text.trim().isEmpty ||
        _companyController.text.trim().isEmpty ||
        _whatsappController.text.trim().isEmpty) {
      ScaffoldMessenger.of(widget.parentContext).showSnackBar(
        SnackBar(
          content: Text(JobsStrings.t('jobs_validation_required_fields', locale)),
        ),
      );
      return;
    }

    final requirements = _requirementsFromForm();
    if (!requirements.isSpecified) {
      ScaffoldMessenger.of(widget.parentContext).showSnackBar(
        SnackBar(
          content: Text(JobsStrings.t('jobs_validation_requirements', locale)),
        ),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      await widget.ref.read(jobsRepositoryProvider).createJob(
            title: _titleController.text,
            company: _companyController.text,
            salary: _salaryController.text.isEmpty
                ? 'Contact for salary'
                : _salaryController.text,
            location: _locationController.text,
            description: _descriptionController.text,
            contact: _whatsappController.text,
            category: _category,
            benefits: _benefits,
            requirements: requirements,
          );
      await draft.clearDraft();
      if (mounted) Navigator.pop(context);
      if (widget.parentContext.mounted) {
        ScaffoldMessenger.of(widget.parentContext).showSnackBar(
          SnackBar(
            content: Text(JobsStrings.t('jobs_post_success', locale)),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (widget.parentContext.mounted) {
        ScaffoldMessenger.of(widget.parentContext).showSnackBar(
          SnackBar(
            content: Text('${JobsStrings.t('jobs_post_failed', locale)}: $e'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setSheetState) {
        final locale = widget.ref.watch(userLanguageProvider);
        return DraftAwareSheet(
          formId: DraftBoxKeys.postJobComposer,
          controllers: [
            _titleController,
            _companyController,
            _salaryController,
            _locationController,
            _descriptionController,
            _whatsappController,
            _skillsController,
            _experienceController,
            _qualificationsController,
            _languagesController,
          ],
          serialize: () => {
            'title': _titleController.text,
            'company': _companyController.text,
            'salary': _salaryController.text,
            'location': _locationController.text,
            'description': _descriptionController.text,
            'whatsapp': _whatsappController.text,
            'skills': _skillsController.text,
            'experience': _experienceController.text,
            'qualifications': _qualificationsController.text,
            'languages': _languagesController.text,
            'housing': _housing,
            'flight': _flight,
            'medical': _medical,
            'other': _other,
            'category': _category,
          },
          applyDraft: (data) {
            setSheetState(() {
              _titleController.text = data['title']?.toString() ?? '';
              _companyController.text = data['company']?.toString() ?? '';
              _salaryController.text = data['salary']?.toString() ?? '';
              _locationController.text = data['location']?.toString() ?? 'Qatar';
              _descriptionController.text = data['description']?.toString() ?? '';
              _whatsappController.text = data['whatsapp']?.toString() ?? '';
              _skillsController.text = data['skills']?.toString() ?? '';
              _experienceController.text = data['experience']?.toString() ?? '';
              _qualificationsController.text =
                  data['qualifications']?.toString() ?? '';
              _languagesController.text = data['languages']?.toString() ?? '';
              _housing = data['housing'] == true;
              _flight = data['flight'] == true;
              _medical = data['medical'] == true;
              _other = data['other'] == true;
              _category = data['category']?.toString() ??
                  (kJobCategories.length > 1 ? kJobCategories[1] : 'General');
            });
          },
          builder: (context, draft) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              child: SingleChildScrollView(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      JobsStrings.t('jobs_post_sheet_title', locale),
                      style: AppTypography.headline1,
                    ),
                    const SizedBox(height: 16),
                    _field(
                      _titleController,
                      JobsStrings.t('jobs_field_title', locale),
                    ),
                    const SizedBox(height: 10),
                    _field(
                      _companyController,
                      JobsStrings.t('jobs_field_company', locale),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: _category,
                      decoration: InputDecoration(
                        labelText: JobsStrings.t('jobs_field_category', locale),
                      ),
                      items: kJobCategories
                          .where((c) => c != 'All')
                          .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (v) {
                        if (v == null) return;
                        setSheetState(() => _category = v);
                        draft.notifyChanged();
                      },
                    ),
                    const SizedBox(height: 10),
                    _field(
                      _salaryController,
                      JobsStrings.t('jobs_field_salary', locale),
                    ),
                    const SizedBox(height: 10),
                    _field(
                      _locationController,
                      JobsStrings.t('jobs_field_location', locale),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      JobsStrings.t('jobs_benefits_heading', locale),
                      style: AppTypography.body,
                    ),
                    Wrap(
                      spacing: 8,
                      children: [
                        _benefitChip(
                          'Housing',
                          _housing,
                          (v) => _housing = v,
                          setSheetState,
                          draft,
                          locale,
                        ),
                        _benefitChip(
                          'Flight',
                          _flight,
                          (v) => _flight = v,
                          setSheetState,
                          draft,
                          locale,
                        ),
                        _benefitChip(
                          'Medical',
                          _medical,
                          (v) => _medical = v,
                          setSheetState,
                          draft,
                          locale,
                        ),
                        _benefitChip(
                          'Other',
                          _other,
                          (v) => _other = v,
                          setSheetState,
                          draft,
                          locale,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      JobsStrings.t('jobs_requirements_heading', locale),
                      style: AppTypography.subtitle,
                    ),
                    const SizedBox(height: 8),
                    _field(
                      _skillsController,
                      JobsStrings.t('jobs_field_skills', locale),
                    ),
                    const SizedBox(height: 10),
                    _field(
                      _experienceController,
                      JobsStrings.t('jobs_field_experience', locale),
                    ),
                    const SizedBox(height: 10),
                    _field(
                      _qualificationsController,
                      JobsStrings.t('jobs_field_qualifications', locale),
                    ),
                    const SizedBox(height: 10),
                    _field(
                      _languagesController,
                      JobsStrings.t('jobs_field_languages', locale),
                    ),
                    const SizedBox(height: 10),
                    _field(
                      _descriptionController,
                      JobsStrings.t('jobs_field_description', locale),
                      maxLines: 4,
                    ),
                    const SizedBox(height: 10),
                    _field(
                      _whatsappController,
                      JobsStrings.t('jobs_field_whatsapp', locale),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _submitting ? null : () => _submit(draft, locale),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.cyanGlow,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text(
                          _submitting
                              ? JobsStrings.t('jobs_posting', locale)
                              : JobsStrings.t('jobs_post_job', locale),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _benefitChip(
    String token,
    bool selected,
    ValueChanged<bool> onChanged,
    StateSetter setSheetState,
    DraftSheetHandle draft,
    String locale,
  ) {
    return FilterChip(
      label: Text(JobsStrings.benefitLabel(token, locale)),
      selected: selected,
      onSelected: (v) {
        setSheetState(() => onChanged(v));
        draft.notifyChanged();
      },
      selectedColor: AppColors.cyanGlow.withValues(alpha: 0.2),
    );
  }

  Widget _field(
    TextEditingController controller,
    String hint, {
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(hintText: hint),
    );
  }
}
