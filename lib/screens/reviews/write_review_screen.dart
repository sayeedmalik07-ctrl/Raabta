import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/glass/glass_container.dart';
import 'package:raabta/core/l10n/common_action_strings.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:raabta/screens/reviews/l10n/workplace_review_strings.dart';

class WriteReviewScreen extends ConsumerStatefulWidget {
  const WriteReviewScreen({super.key});

  @override
  ConsumerState<WriteReviewScreen> createState() => _WriteReviewScreenState();
}

class _WriteReviewScreenState extends ConsumerState<WriteReviewScreen> {
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _reviewController = TextEditingController();
  final TextEditingController _departmentController = TextEditingController();

  double _overallRating = 4;
  double _salaryRating = 4;
  double _housingRating = 3;
  double _managementRating = 4;
  double _workLifeRating = 3;
  String _homeFlightKey = 'yes';
  String _employmentKey = 'current';
  bool _disclaimerAccepted = false;

  static const _homeFlightKeys = ['yes', 'no', 'partial'];
  static const _employmentKeys = ['current', 'former'];

  String _homeFlightLabel(String key, String locale) {
    switch (key) {
      case 'yes':
        return WorkplaceReviewStrings.t('option_yes', locale);
      case 'no':
        return WorkplaceReviewStrings.t('option_no', locale);
      case 'partial':
        return WorkplaceReviewStrings.t('option_partial', locale);
      default:
        return key;
    }
  }

  String _employmentLabel(String key, String locale) {
    switch (key) {
      case 'current':
        return WorkplaceReviewStrings.t('employment_current', locale);
      case 'former':
        return WorkplaceReviewStrings.t('employment_former', locale);
      default:
        return key;
    }
  }

  @override
  void dispose() {
    _companyController.dispose();
    _reviewController.dispose();
    _departmentController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTypography.body.copyWith(color: AppColors.textTertiary),
      border: InputBorder.none,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
    );
  }

  void _submit(String locale) {
    if (_companyController.text.trim().isEmpty) {
      _showError(WorkplaceReviewStrings.t('error_company_required', locale));
      return;
    }
    if (_reviewController.text.trim().length < 100) {
      _showError(WorkplaceReviewStrings.t('error_review_length', locale));
      return;
    }
    if (!_disclaimerAccepted) {
      _showError(WorkplaceReviewStrings.t('error_disclaimer', locale));
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(WorkplaceReviewStrings.t('success_submitted', locale)),
      ),
    );
    Navigator.of(context).pop();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Widget _ratingSlider({
    required String label,
    required double value,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppTypography.body.copyWith(color: AppColors.textPrimary)),
            Text(
              '⭐ ${value.toStringAsFixed(1)}',
              style: AppTypography.subtitle.copyWith(
                color: AppColors.cyanGlow,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Slider(
          value: value,
          min: 1,
          max: 5,
          divisions: 8,
          activeColor: AppColors.cyanGlow,
          inactiveColor: AppColors.glassBorder,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _chipRow({
    required String title,
    required List<String> optionKeys,
    required String selectedKey,
    required String Function(String key) labelForKey,
    required ValueChanged<String> onSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTypography.subtitle.copyWith(
            color: AppColors.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: optionKeys.map((key) {
            final isSelected = selectedKey == key;
            return GlassCard(
              onTap: () => onSelected(key),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              borderRadius: AppSpacing.radiusFull,
              glowColor: isSelected ? AppColors.cyanGlow : null,
              glowIntensity: isSelected ? 0.2 : 0,
              child: Text(
                labelForKey(key),
                style: AppTypography.chipLabel.copyWith(
                  color: isSelected
                      ? AppColors.cyanGlow
                      : AppColors.textSecondary,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _glassField(TextEditingController controller, {
    required String hint,
    int maxLines = 1,
    ValueChanged<String>? onChanged,
  }) {
    return GlassContainer(
      padding: EdgeInsets.zero,
      borderRadius: AppSpacing.radiusSm,
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        onChanged: onChanged,
        style: AppTypography.body.copyWith(color: AppColors.textPrimary),
        decoration: _inputDecoration(hint),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(userLanguageProvider);
    final reviewLength = _reviewController.text.trim().length;

    return GlassScreenScaffold(
      title: WorkplaceReviewStrings.t('write_title', locale),
      leading: GlassIconButton(
        icon: Icons.arrow_back_ios_rounded,
        tooltip: CommonActionStrings.t('action_back', locale),
        onPressed: () => Navigator.of(context).pop(),
      ),
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.xl),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              WorkplaceReviewStrings.t('label_company_name', locale),
              style: AppTypography.subtitle.copyWith(
                color: AppColors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            _glassField(
              _companyController,
              hint: WorkplaceReviewStrings.t('hint_company_name', locale),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              WorkplaceReviewStrings.t('label_ratings', locale),
              style: AppTypography.title,
            ),
            const SizedBox(height: AppSpacing.md),
            GlassCard(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                children: [
                  _ratingSlider(
                    label: WorkplaceReviewStrings.t('rating_overall', locale),
                    value: _overallRating,
                    onChanged: (v) => setState(() => _overallRating = v),
                  ),
                  _ratingSlider(
                    label: WorkplaceReviewStrings.t('rating_salary_paid', locale),
                    value: _salaryRating,
                    onChanged: (v) => setState(() => _salaryRating = v),
                  ),
                  _ratingSlider(
                    label: WorkplaceReviewStrings.t('rating_accommodation', locale),
                    value: _housingRating,
                    onChanged: (v) => setState(() => _housingRating = v),
                  ),
                  _ratingSlider(
                    label: WorkplaceReviewStrings.t('rating_management_hr', locale),
                    value: _managementRating,
                    onChanged: (v) => setState(() => _managementRating = v),
                  ),
                  _ratingSlider(
                    label: WorkplaceReviewStrings.t('rating_work_hours', locale),
                    value: _workLifeRating,
                    onChanged: (v) => setState(() => _workLifeRating = v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            _chipRow(
              title: WorkplaceReviewStrings.t('chip_home_flight', locale),
              optionKeys: _homeFlightKeys,
              selectedKey: _homeFlightKey,
              labelForKey: (key) => _homeFlightLabel(key, locale),
              onSelected: (v) => setState(() => _homeFlightKey = v),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              WorkplaceReviewStrings.t('label_your_review', locale),
              style: AppTypography.subtitle.copyWith(
                color: AppColors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            _glassField(
              _reviewController,
              hint: WorkplaceReviewStrings.t('hint_review', locale),
              maxLines: 5,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              WorkplaceReviewStrings.format(
                'char_minimum',
                locale,
                params: {'count': '$reviewLength'},
              ),
              style: AppTypography.caption.copyWith(
                color: reviewLength >= 100
                    ? AppColors.cyanGlow
                    : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            _chipRow(
              title: WorkplaceReviewStrings.t('chip_employment_status', locale),
              optionKeys: _employmentKeys,
              selectedKey: _employmentKey,
              labelForKey: (key) => _employmentLabel(key, locale),
              onSelected: (v) => setState(() => _employmentKey = v),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              WorkplaceReviewStrings.t('label_department', locale),
              style: AppTypography.subtitle.copyWith(
                color: AppColors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            _glassField(
              _departmentController,
              hint: WorkplaceReviewStrings.t('hint_department', locale),
            ),
            const SizedBox(height: AppSpacing.lg),
            GlassContainer(
              padding: const EdgeInsets.all(AppSpacing.sm),
              borderRadius: AppSpacing.radiusSm,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: _disclaimerAccepted,
                    onChanged: (v) =>
                        setState(() => _disclaimerAccepted = v ?? false),
                    activeColor: AppColors.cyanGlow,
                    checkColor: AppColors.background,
                    side: BorderSide(color: AppColors.textSecondary),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.sm),
                      child: Text(
                        WorkplaceReviewStrings.t('disclaimer', locale),
                        style: AppTypography.bodySmall.copyWith(height: 1.4),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            GlassCard(
              onTap: () => _submit(locale),
              glowColor: AppColors.cyanGlow,
              glowIntensity: 0.25,
              backgroundColor: AppColors.cyanGlow,
              borderRadius: AppSpacing.radiusSm,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: Text(
                WorkplaceReviewStrings.t('submit_anonymously', locale),
                style: AppTypography.button.copyWith(
                  color: AppColors.background,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
