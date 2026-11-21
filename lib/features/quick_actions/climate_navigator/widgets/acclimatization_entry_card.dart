import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_container.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_primary_button.dart';
import 'package:raabta/features/quick_actions/climate_navigator/l10n/climate_strings.dart';
import 'package:raabta/features/quick_actions/climate_navigator/services/climate_acclimatization_date_format.dart';
import 'package:raabta/features/quick_actions/climate_navigator/services/climate_acclimatization_preferences.dart';
import 'package:raabta/features/quick_actions/climate_navigator/widgets/acclimatization_schedule_panel.dart';
import 'package:raabta/features/quick_actions/climate_navigator/widgets/climate_primitives.dart';

/// Local acclimatization type, start date, and NIOSH/OSHA exposure schedule (A2).
class AcclimatizationEntryCard extends StatefulWidget {
  const AcclimatizationEntryCard({
    super.key,
    required this.locale,
    this.fetchConciergeArrivalDate,
    this.onOpenHeatGuide,
    this.onOutdoorIneligible,
    this.onPlanCleared,
  });

  final String locale;

  /// Called only when the user taps the Concierge prefill control — never on init.
  final Future<DateTime?> Function()? fetchConciergeArrivalDate;
  final VoidCallback? onOpenHeatGuide;
  final VoidCallback? onOutdoorIneligible;
  final VoidCallback? onPlanCleared;

  @override
  State<AcclimatizationEntryCard> createState() =>
      _AcclimatizationEntryCardState();
}

class _AcclimatizationEntryCardState extends State<AcclimatizationEntryCard> {
  ClimateAcclimatizationPreferences? _saved;
  bool _loading = true;
  bool _busy = false;
  String? _errorMessage;

  bool? _outdoorWork;
  ClimateAcclimatizationType? _draftType;
  late DateTime _draftDate;
  bool _editing = false;

  @override
  void initState() {
    super.initState();
    _draftDate = ClimateAcclimatizationPreferences.qatarCalendarDate(
      DateTime.now(),
    );
    _reload();
  }

  Future<void> _reload() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    try {
      final saved = await ClimateAcclimatizationPreferences.load();
      if (!mounted) return;
      setState(() {
        _saved = saved;
        if (saved.outdoorEligibility == ClimateOutdoorEligibility.eligible) {
          _outdoorWork = true;
        } else if (saved.outdoorEligibility ==
            ClimateOutdoorEligibility.ineligible) {
          _outdoorWork = false;
        } else {
          _outdoorWork = saved.isActive ? true : null;
        }
        if (saved.isActive) {
          _draftType = saved.type;
          _draftDate = saved.startDate!;
          _editing = false;
        }
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _errorMessage =
              ClimateStrings.t('acclimat_storage_error', widget.locale);
        });
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showStorageError() {
    setState(() {
      _errorMessage =
          ClimateStrings.t('acclimat_storage_error', widget.locale);
    });
  }

  Future<void> _onOutdoorAnswer(bool worksOutdoor) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _errorMessage = null;
    });
    try {
      final ok =
          await ClimateAcclimatizationPreferences.setWorksOutdoorInHeat(
        worksOutdoor,
      );
      if (!mounted) return;
      if (!ok) {
        _showStorageError();
        return;
      }
      if (!worksOutdoor) {
        setState(() {
          _outdoorWork = false;
          _saved = const ClimateAcclimatizationPreferences(
            status: ClimateAcclimatizationStatus.inactive,
            outdoorEligibility: ClimateOutdoorEligibility.ineligible,
          );
        });
        widget.onOutdoorIneligible?.call();
        return;
      }
      setState(() => _outdoorWork = true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _draftDate,
      firstDate: DateTime(2015),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      helpText: ClimateStrings.t('acclimat_start_date_label', widget.locale),
    );
    if (picked != null && mounted) {
      setState(
        () => _draftDate =
            ClimateAcclimatizationPreferences.qatarCalendarDate(picked),
      );
    }
  }

  Future<void> _prefillFromConcierge() async {
    final loader = widget.fetchConciergeArrivalDate;
    if (loader == null || _busy) return;
    setState(() {
      _busy = true;
      _errorMessage = null;
    });
    try {
      final arrival = await loader();
      if (!mounted) return;
      if (arrival == null) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              ClimateStrings.t(
                'acclimat_concierge_prefill_unavailable',
                widget.locale,
              ),
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
      setState(
        () => _draftDate =
            ClimateAcclimatizationPreferences.qatarCalendarDate(arrival),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ClimateStrings.t(
              'acclimat_concierge_prefill_error',
              widget.locale,
            ),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _savePlan() async {
    final type = _draftType;
    if (type == null || _busy) return;
    setState(() {
      _busy = true;
      _errorMessage = null;
    });
    try {
      final ok = await ClimateAcclimatizationPreferences.saveActivePlan(
        type: type,
        startDate: _draftDate,
      );
      if (!ok) {
        _showStorageError();
        return;
      }
      await _reload();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _clearPlan() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _errorMessage = null;
    });
    try {
      final ok = await ClimateAcclimatizationPreferences.clearActivePlan();
      if (!ok) {
        _showStorageError();
        return;
      }
      if (!mounted) return;
      setState(() {
        _saved = const ClimateAcclimatizationPreferences(
          status: ClimateAcclimatizationStatus.inactive,
          outdoorEligibility: ClimateOutdoorEligibility.unset,
        );
        _outdoorWork = null;
        _draftType = null;
        _draftDate = ClimateAcclimatizationPreferences.qatarCalendarDate(
          DateTime.now(),
        );
        _editing = false;
      });
      widget.onPlanCleared?.call();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String _formatDate(DateTime date) =>
      ClimateAcclimatizationDateFormat.format(date, widget.locale);

  String _typeLabel(ClimateAcclimatizationType type) {
    switch (type) {
      case ClimateAcclimatizationType.newToQatarHeat:
        return ClimateStrings.t('acclimat_choice_new', widget.locale);
      case ClimateAcclimatizationType.returningAfterLeave:
        return ClimateStrings.t('acclimat_choice_returning', widget.locale);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const SizedBox(
        height: 120,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    final saved = _saved;
    final showActiveSummary =
        saved != null && saved.isActive && !_editing;

    return GlassContainer(
      padding: const EdgeInsets.all(AppSpacing.lg),
      borderRadius: AppSpacing.radiusSm,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_errorMessage != null) ...[
            Text(
              _errorMessage!,
              style: AppTypography.caption.copyWith(
                color: AppColors.errorBright,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          if (showActiveSummary) ...[
            Text(
              ClimateStrings.format(
                'acclimat_active_summary',
                widget.locale,
                params: {
                  'type': _typeLabel(saved.type!),
                  'date': _formatDate(saved.startDate!),
                },
              ),
              style: AppTypography.body.copyWith(
                color: AppColors.textPrimary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            AcclimatizationSchedulePanel(
              locale: widget.locale,
              startDate: saved.startDate!,
            ),
            if (widget.onOpenHeatGuide != null) ...[
              const SizedBox(height: AppSpacing.md),
              TextButton(
                onPressed: widget.onOpenHeatGuide,
                child: Text(
                  ClimateStrings.t('acclimat_heat_guide_link', widget.locale),
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            GlassPrimaryButton(
              label: ClimateStrings.t('acclimat_edit', widget.locale),
              onPressed: _busy ? null : () => setState(() => _editing = true),
              expand: true,
            ),
          ] else ...[
            if (_outdoorWork == null) ...[
              Text(
                ClimateStrings.t('acclimat_outdoor_question', widget.locale),
                style: AppTypography.body.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: _AnswerChip(
                      label: ClimateStrings.t(
                        'acclimat_outdoor_yes',
                        widget.locale,
                      ),
                      selected: false,
                      onTap: () {
                        climateSelectionHaptic();
                        _onOutdoorAnswer(true);
                      },
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _AnswerChip(
                      label: ClimateStrings.t(
                        'acclimat_outdoor_no',
                        widget.locale,
                      ),
                      selected: false,
                      onTap: () {
                        climateSelectionHaptic();
                        _onOutdoorAnswer(false);
                      },
                    ),
                  ),
                ],
              ),
            ] else ...[
              Text(
                ClimateStrings.t('acclimat_entry_prompt', widget.locale),
                style: AppTypography.body.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              _TypeOption(
                label: ClimateStrings.t('acclimat_choice_new', widget.locale),
                selected:
                    _draftType == ClimateAcclimatizationType.newToQatarHeat,
                onTap: () {
                  climateSelectionHaptic();
                  setState(
                    () => _draftType = ClimateAcclimatizationType.newToQatarHeat,
                  );
                },
              ),
              const SizedBox(height: AppSpacing.sm),
              _TypeOption(
                label: ClimateStrings.t(
                  'acclimat_choice_returning',
                  widget.locale,
                ),
                selected: _draftType ==
                    ClimateAcclimatizationType.returningAfterLeave,
                onTap: () {
                  climateSelectionHaptic();
                  setState(
                    () => _draftType =
                        ClimateAcclimatizationType.returningAfterLeave,
                  );
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                ClimateStrings.t('acclimat_start_date_label', widget.locale),
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              OutlinedButton(
                onPressed: _busy ? null : _pickDate,
                child: Text(_formatDate(_draftDate)),
              ),
              if (widget.fetchConciergeArrivalDate != null) ...[
                const SizedBox(height: AppSpacing.sm),
                TextButton(
                  onPressed: _busy ? null : _prefillFromConcierge,
                  child: Text(
                    ClimateStrings.t(
                      'acclimat_concierge_prefill',
                      widget.locale,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
              GlassPrimaryButton(
                label: ClimateStrings.t('acclimat_save', widget.locale),
                onPressed: _draftType == null || _busy ? null : _savePlan,
                expand: true,
              ),
              if (_saved?.isActive == true || _editing) ...[
                const SizedBox(height: AppSpacing.sm),
                TextButton(
                  onPressed: _busy ? null : _clearPlan,
                  child: Text(
                    ClimateStrings.t('acclimat_clear', widget.locale),
                  ),
                ),
              ],
            ],
          ],
        ],
      ),
    );
  }
}

class _AnswerChip extends StatelessWidget {
  const _AnswerChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? climateAccent.withValues(alpha: 0.15)
          : AppColors.textSecondary.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.md,
            horizontal: AppSpacing.sm,
          ),
          child: Center(
            child: Text(
              label,
              style: AppTypography.caption.copyWith(
                fontWeight: FontWeight.w700,
                color: selected ? climateAccent : AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TypeOption extends StatelessWidget {
  const _TypeOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

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
          child: Row(
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
                    color: AppColors.textPrimary,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
