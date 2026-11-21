import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/data/categories/job_categories.dart';
import 'package:raabta/models/advanced_profile.dart';
import 'package:raabta/providers/auth_providers.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:raabta/screens/profile/l10n/profile_strings.dart';
import 'package:raabta/services/ai/user_profile_ai_service.dart';

/// Collapsed-by-default optional advanced profile section on Profile screen.
class AdvancedProfileCard extends ConsumerStatefulWidget {
  const AdvancedProfileCard({super.key});

  @override
  ConsumerState<AdvancedProfileCard> createState() =>
      _AdvancedProfileCardState();
}

class _AdvancedProfileCardState extends ConsumerState<AdvancedProfileCard> {
  bool _expanded = false;
  bool _consent = false;
  bool _saving = false;
  bool _hydrated = false;

  late final TextEditingController _jobTitleController;
  String? _industry;
  String? _education;
  String? _salaryRange;

  @override
  void initState() {
    super.initState();
    _jobTitleController = TextEditingController();
  }

  @override
  void dispose() {
    _jobTitleController.dispose();
    super.dispose();
  }

  void _hydrateFromProfile(UserAIProfile profile) {
    if (_hydrated) return;
    _hydrated = true;
    _consent = profile.advancedProfileConsentGiven;
    final adv = profile.advancedProfile;
    _jobTitleController.text = adv?.jobTitle ?? '';
    _industry = adv?.industry;
    _education = adv?.educationLevel;
    _salaryRange = adv?.salaryComparisonRange;
  }

  Future<void> _save(String locale) async {
    if (!_consent) return;
    setState(() => _saving = true);
    try {
      final profile = AdvancedProfile(
        jobTitle: _jobTitleController.text.trim().isEmpty
            ? null
            : _jobTitleController.text.trim(),
        industry: _industry,
        educationLevel: _education,
        salaryComparisonRange: _salaryRange,
      );
      await ref.read(userAIProfileProvider.notifier).updateAdvancedProfile(
            profile: profile,
            consentGiven: true,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ProfileStrings.t('adv_saved', locale)),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String _educationLabel(String key, String locale) => switch (key) {
        AdvancedEducationLevel.highSchool =>
          ProfileStrings.t('adv_edu_high_school', locale),
        AdvancedEducationLevel.diploma =>
          ProfileStrings.t('adv_edu_diploma', locale),
        AdvancedEducationLevel.bachelors =>
          ProfileStrings.t('adv_edu_bachelors', locale),
        AdvancedEducationLevel.masters =>
          ProfileStrings.t('adv_edu_masters', locale),
        AdvancedEducationLevel.doctorate =>
          ProfileStrings.t('adv_edu_doctorate', locale),
        AdvancedEducationLevel.other =>
          ProfileStrings.t('adv_edu_other', locale),
        _ => key,
      };

  String _salaryLabel(String key, String locale) => switch (key) {
        AdvancedSalaryRange.under3000 =>
          ProfileStrings.t('adv_salary_under_3000', locale),
        AdvancedSalaryRange.r3000_5999 =>
          ProfileStrings.t('adv_salary_3000_5999', locale),
        AdvancedSalaryRange.r6000_8999 =>
          ProfileStrings.t('adv_salary_6000_8999', locale),
        AdvancedSalaryRange.r10000_14999 =>
          ProfileStrings.t('adv_salary_10000_14999', locale),
        AdvancedSalaryRange.r15000_24999 =>
          ProfileStrings.t('adv_salary_15000_24999', locale),
        AdvancedSalaryRange.r25000Plus =>
          ProfileStrings.t('adv_salary_25000_plus', locale),
        _ => key,
      };

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(userLanguageProvider);
    final profile = ref.watch(userAIProfileProvider);
    final user = ref.watch(currentUserProvider);

    if (user == null) return const SizedBox.shrink();
    if (profile != null) _hydrateFromProfile(profile);

    final fieldsEnabled = _consent && !_saving;
    final industries = kJobCategories.where((c) => c != 'All').toList();

    return GlassCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ProfileStrings.t('adv_profile_title', locale),
                          style: AppTypography.subtitle,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          ProfileStrings.t('adv_profile_subtitle', locale),
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
          if (_expanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      ProfileStrings.t('adv_profile_consent_label', locale),
                      style: AppTypography.bodySmall,
                    ),
                    value: _consent,
                    onChanged: _saving
                        ? null
                        : (value) async {
                            if (!value) {
                              await ref
                                  .read(userAIProfileProvider.notifier)
                                  .revokeAdvancedProfileConsent();
                              setState(() {
                                _consent = false;
                                _jobTitleController.clear();
                                _industry = null;
                                _education = null;
                                _salaryRange = null;
                              });
                              return;
                            }
                            setState(() => _consent = true);
                          },
                  ),
                  if (!_consent) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      ProfileStrings.t('adv_profile_consent_required', locale),
                      style: AppTypography.caption.copyWith(
                        color: AppColors.warning,
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.md),
                  TextField(
                    controller: _jobTitleController,
                    enabled: fieldsEnabled,
                    decoration: InputDecoration(
                      labelText:
                          ProfileStrings.t('adv_field_job_title', locale),
                      hintText: ProfileStrings.t(
                        'adv_field_job_title_hint',
                        locale,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _DropdownField<String>(
                    label: ProfileStrings.t('adv_field_industry', locale),
                    value: _industry,
                    enabled: fieldsEnabled,
                    unsetLabel: ProfileStrings.t('adv_unset', locale),
                    items: industries,
                    itemLabel: (v) => v,
                    onChanged: (v) => setState(() => _industry = v),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _DropdownField<String>(
                    label: ProfileStrings.t('adv_field_education', locale),
                    value: _education,
                    enabled: fieldsEnabled,
                    unsetLabel: ProfileStrings.t('adv_unset', locale),
                    items: AdvancedEducationLevel.values,
                    itemLabel: (v) => _educationLabel(v, locale),
                    onChanged: (v) => setState(() => _education = v),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _DropdownField<String>(
                    label: ProfileStrings.t('adv_field_salary_range', locale),
                    value: _salaryRange,
                    enabled: fieldsEnabled,
                    unsetLabel: ProfileStrings.t('adv_unset', locale),
                    items: AdvancedSalaryRange.values,
                    itemLabel: (v) => _salaryLabel(v, locale),
                    onChanged: (v) => setState(() => _salaryRange = v),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    ProfileStrings.t('adv_field_salary_helper', locale),
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  FilledButton(
                    onPressed: fieldsEnabled ? () => _save(locale) : null,
                    child: _saving
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(ProfileStrings.t('adv_save', locale)),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DropdownField<T> extends StatelessWidget {
  const _DropdownField({
    required this.label,
    required this.value,
    required this.enabled,
    required this.unsetLabel,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
  });

  final String label;
  final T? value;
  final bool enabled;
  final String unsetLabel;
  final List<T> items;
  final String Function(T) itemLabel;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T?>(
      initialValue: value,
      decoration: InputDecoration(labelText: label),
      isExpanded: true,
      items: [
        DropdownMenuItem<T?>(
          value: null,
          child: Text(unsetLabel),
        ),
        for (final item in items)
          DropdownMenuItem<T?>(
            value: item,
            child: Text(itemLabel(item)),
          ),
      ],
      onChanged: enabled ? onChanged : null,
    );
  }
}

/// Dismissible soft nudge — never blocks underlying features.
class AdvancedProfileNudgeBanner extends ConsumerStatefulWidget {
  const AdvancedProfileNudgeBanner({super.key});

  @override
  ConsumerState<AdvancedProfileNudgeBanner> createState() =>
      _AdvancedProfileNudgeBannerState();
}

class _AdvancedProfileNudgeBannerState
    extends ConsumerState<AdvancedProfileNudgeBanner> {
  bool _dismissed = false;

  @override
  Widget build(BuildContext context) {
    if (_dismissed) return const SizedBox.shrink();

    final locale = ref.watch(userLanguageProvider);
    final profile = ref.watch(userAIProfileProvider);
    if (profile == null) return const SizedBox.shrink();
    if (profile.advancedProfileConsentGiven &&
        (profile.advancedProfile?.filledFieldCount ?? 0) >= 2) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: GlassCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        glowColor: AppColors.cyanGlow,
        glowIntensity: 0.08,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              ProfileStrings.t('adv_nudge_title', locale),
              style: AppTypography.subtitle,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              ProfileStrings.t('adv_nudge_body', locale),
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                TextButton(
                  onPressed: () => context.push('/profile'),
                  child: Text(ProfileStrings.t('adv_nudge_action', locale)),
                ),
                TextButton(
                  onPressed: () => setState(() => _dismissed = true),
                  child: Text(ProfileStrings.t('adv_nudge_dismiss', locale)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
