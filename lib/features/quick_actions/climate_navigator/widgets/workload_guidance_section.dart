import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_container.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/home/widgets/home_section_header.dart';
import 'package:raabta/features/quick_actions/climate_navigator/data/acgih_heat_reference_education.dart';
import 'package:raabta/features/quick_actions/climate_navigator/l10n/climate_strings.dart';
import 'package:raabta/features/quick_actions/climate_navigator/services/climate_workload_preferences.dart';
import 'package:raabta/features/quick_actions/climate_navigator/widgets/climate_primitives.dart';

/// Part A — educational workload + ACGIH reference (no WBGT comparison).
class WorkloadGuidanceSection extends StatefulWidget {
  const WorkloadGuidanceSection({
    super.key,
    required this.locale,
    this.onOpenHeatGuide,
  });

  final String locale;
  final VoidCallback? onOpenHeatGuide;

  @override
  State<WorkloadGuidanceSection> createState() => _WorkloadGuidanceSectionState();
}

class _WorkloadGuidanceSectionState extends State<WorkloadGuidanceSection> {
  ClimateWorkloadCategory _category = ClimateWorkloadCategory.unset;
  bool _loading = true;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final prefs = await ClimateWorkloadPreferences.load();
    if (!mounted) return;
    setState(() {
      _category = prefs.category;
      _loading = false;
    });
  }

  Future<void> _select(ClimateWorkloadCategory category) async {
    if (_busy) return;
    setState(() => _busy = true);
    await ClimateWorkloadPreferences.save(category);
    if (!mounted) return;
    setState(() {
      _category = category;
      _busy = false;
    });
  }

  Future<void> _clearChoice() async {
    if (_busy || _category == ClimateWorkloadCategory.unset) return;
    setState(() => _busy = true);
    await ClimateWorkloadPreferences.clear();
    if (!mounted) return;
    setState(() {
      _category = ClimateWorkloadCategory.unset;
      _busy = false;
    });
  }

  String _labelFor(ClimateWorkloadCategory cat) {
    switch (cat) {
      case ClimateWorkloadCategory.unset:
        return '';
      case ClimateWorkloadCategory.light:
        return ClimateStrings.t('workload_option_light', widget.locale);
      case ClimateWorkloadCategory.moderate:
        return ClimateStrings.t('workload_option_moderate', widget.locale);
      case ClimateWorkloadCategory.heavy:
        return ClimateStrings.t('workload_option_heavy', widget.locale);
      case ClimateWorkloadCategory.veryHeavy:
        return ClimateStrings.t('workload_option_very_heavy', widget.locale);
    }
  }

  String _exampleFor(ClimateWorkloadCategory cat) {
    switch (cat) {
      case ClimateWorkloadCategory.light:
        return ClimateStrings.t('workload_example_light', widget.locale);
      case ClimateWorkloadCategory.moderate:
        return ClimateStrings.t('workload_example_moderate', widget.locale);
      case ClimateWorkloadCategory.heavy:
        return ClimateStrings.t('workload_example_heavy', widget.locale);
      case ClimateWorkloadCategory.veryHeavy:
        return ClimateStrings.t('workload_example_very_heavy', widget.locale);
      case ClimateWorkloadCategory.unset:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        HomeSectionHeader(
          overline: ClimateStrings.t('section_workload_overline', widget.locale),
          title: ClimateStrings.t('section_workload_title', widget.locale),
        ),
        const SizedBox(height: AppSpacing.md),
        GlassContainer(
          padding: const EdgeInsets.all(AppSpacing.lg),
          borderRadius: AppSpacing.radiusSm,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                ClimateStrings.t('workload_disclaimer_not_law', widget.locale),
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                ClimateStrings.t(
                  'workload_disclaimer_weather_estimate',
                  widget.locale,
                ),
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                ClimateStrings.t('workload_selector_prompt', widget.locale),
                style: AppTypography.body.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              ...ClimateWorkloadCategory.values
                  .where((c) => c != ClimateWorkloadCategory.unset)
                  .map((cat) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: _WorkloadOptionTile(
                          label: _labelFor(cat),
                          example: _exampleFor(cat),
                          selected: _category == cat,
                          onTap: _busy
                              ? null
                              : () {
                                  climateSelectionHaptic();
                                  _select(cat);
                                },
                        ),
                      )),
              if (_category == ClimateWorkloadCategory.unset) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  ClimateStrings.t('workload_unset_hint', widget.locale),
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
              if (_category != ClimateWorkloadCategory.unset) ...[
                const SizedBox(height: AppSpacing.sm),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: TextButton(
                    onPressed: _busy ? null : _clearChoice,
                    child: Text(
                      ClimateStrings.t('workload_clear_choice', widget.locale),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
              const Divider(height: 1),
              const SizedBox(height: AppSpacing.lg),
              Text(
                ClimateStrings.t('workload_acgih_heading', widget.locale),
                style: AppTypography.body.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                ClimateStrings.t('workload_acgih_cite', widget.locale),
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                ClimateStrings.t('workload_acgih_assumptions', widget.locale),
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              _ReferenceTable(locale: widget.locale),
              const SizedBox(height: AppSpacing.md),
              if (AcgihHeatReferenceEducation.showsNoContinuousScreening(
                _category,
              ))
                Text(
                  ClimateStrings.t(
                    'workload_acgih_no_continuous_screening',
                    widget.locale,
                  ),
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textPrimary,
                    height: 1.4,
                  ),
                ),
              if (widget.onOpenHeatGuide != null) ...[
                const SizedBox(height: AppSpacing.md),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: TextButton(
                    onPressed: widget.onOpenHeatGuide,
                    child: Text(
                      ClimateStrings.t(
                        'workload_open_first_aid',
                        widget.locale,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _ReferenceTable extends StatelessWidget {
  const _ReferenceTable({required this.locale});

  final String locale;

  @override
  Widget build(BuildContext context) {
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(1.2),
        2: FlexColumnWidth(1.2),
      },
      border: TableBorder(
        horizontalInside: BorderSide(
          color: AppColors.textSecondary.withValues(alpha: 0.15),
        ),
      ),
      children: [
        TableRow(
          children: [
            _cell(ClimateStrings.t('workload_acgih_col_category', locale),
                header: true),
            _cell(ClimateStrings.t('workload_acgih_col_action_limit', locale),
                header: true),
            _cell(ClimateStrings.t('workload_acgih_col_tlv', locale),
                header: true),
          ],
        ),
        _dataRow(ClimateWorkloadCategory.light),
        _dataRow(ClimateWorkloadCategory.moderate),
        _dataRow(ClimateWorkloadCategory.heavy),
        _dataRow(ClimateWorkloadCategory.veryHeavy),
      ],
    );
  }

  TableRow _dataRow(ClimateWorkloadCategory cat) {
    final ref = AcgihHeatReferenceEducation.screeningReferenceFor(cat);
    final label = switch (cat) {
      ClimateWorkloadCategory.light =>
        ClimateStrings.t('workload_option_light', locale),
      ClimateWorkloadCategory.moderate =>
        ClimateStrings.t('workload_option_moderate', locale),
      ClimateWorkloadCategory.heavy =>
        ClimateStrings.t('workload_option_heavy', locale),
      ClimateWorkloadCategory.veryHeavy =>
        ClimateStrings.t('workload_option_very_heavy', locale),
      ClimateWorkloadCategory.unset => '',
    };
    final action = ref != null
        ? '${ref.actionLimitC.toStringAsFixed(1)}°C'
        : ClimateStrings.t('workload_acgih_value_not_provided', locale);
    final tlv = ref != null
        ? '${ref.tlvC.toStringAsFixed(1)}°C'
        : ClimateStrings.t('workload_acgih_value_not_provided', locale);
    return TableRow(
      children: [
        _cell(label),
        _cell(action),
        _cell(tlv),
      ],
    );
  }

  Widget _cell(String text, {bool header = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Text(
        text,
        style: (header ? AppTypography.caption : AppTypography.bodySmall).copyWith(
          fontWeight: header ? FontWeight.w700 : FontWeight.w500,
          color: header ? AppColors.textSecondary : AppColors.textPrimary,
        ),
      ),
    );
  }
}

class _WorkloadOptionTile extends StatelessWidget {
  const _WorkloadOptionTile({
    required this.label,
    required this.example,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String example;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? climateAccent.withValues(alpha: 0.12)
          : AppColors.textSecondary.withValues(alpha: 0.06),
      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(
                    selected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                    color: selected ? climateAccent : AppColors.textSecondary,
                    size: 20,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      label,
                      style: AppTypography.body.copyWith(
                        fontWeight:
                            selected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                example,
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
