import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/home/widgets/score_ring_painter.dart';
import 'package:raabta/features/leaving_qatar/data/departure_plan/leaving_qatar_departure_plan_catalog.dart';
import 'package:raabta/features/leaving_qatar/data/departure_plan/leaving_qatar_departure_plan_models.dart';
import 'package:raabta/features/leaving_qatar/data/departure_plan/leaving_qatar_departure_plan_reminder_engine.dart';
import 'package:raabta/features/leaving_qatar/services/leaving_qatar_departure_plan_reminder_service.dart';
import 'package:raabta/features/leaving_qatar/presentation/departure_plan/leaving_qatar_departure_plan_navigation.dart';
import 'package:raabta/features/leaving_qatar/presentation/l10n/leaving_qatar_strings.dart';
import 'package:raabta/features/leaving_qatar/providers/leaving_qatar_providers.dart';

class LeavingQatarDeparturePlanSection extends ConsumerWidget {
  const LeavingQatarDeparturePlanSection({
    super.key,
    required this.locale,
    this.timelineSectionKey,
    this.closeoutSectionKey,
  });

  final String locale;
  final GlobalKey? timelineSectionKey;
  final GlobalKey? closeoutSectionKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final planAsync = ref.watch(leavingQatarDeparturePlanProvider);

    return planAsync.when(
      loading: () => GlassCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                LeavingQatarStrings.t('lq_dp_loading', locale),
                style: AppTypography.bodySmall,
              ),
            ),
          ],
        ),
      ),
      error: (_, _) => GlassCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Text(
          LeavingQatarStrings.t('lq_dp_load_error', locale),
          style: AppTypography.bodySmall.copyWith(color: AppColors.warning),
        ),
      ),
      data: (state) => _DeparturePlanBody(
        locale: locale,
        state: state,
        timelineSectionKey: timelineSectionKey,
        closeoutSectionKey: closeoutSectionKey,
      ),
    );
  }
}

class _DeparturePlanBody extends ConsumerWidget {
  const _DeparturePlanBody({
    required this.locale,
    required this.state,
    this.timelineSectionKey,
    this.closeoutSectionKey,
  });

  final String locale;
  final LeavingQatarDeparturePlanState state;
  final GlobalKey? timelineSectionKey;
  final GlobalKey? closeoutSectionKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalogIds = LeavingQatarDeparturePlanCatalog.itemIds;
    final done = state.completedCountAmong(catalogIds);
    final total = catalogIds.length;
    final percent = total == 0 ? 0 : ((done / total) * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LeavingQatarStrings.t('lq_dp_section_title', locale),
          style: AppTypography.subtitle,
        ),
        const SizedBox(height: 4),
        Text(
          LeavingQatarStrings.t('lq_dp_section_subtitle', locale),
          style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 4),
        Text(
          LeavingQatarStrings.t('lq_dp_separate_state_note', locale),
          style: AppTypography.caption.copyWith(
            color: AppColors.textTertiary,
            fontStyle: FontStyle.italic,
            height: 1.35,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        GlassCard(
          padding: const EdgeInsets.all(AppSpacing.md),
          glowColor: AppColors.purpleGlow,
          glowIntensity: 0.1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 56,
                    height: 56,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CustomPaint(
                          size: const Size(56, 56),
                          painter: ScoreRingPainter(
                            progress: percent / 100,
                            strokeWidth: 6,
                            glowColor: AppColors.purpleGlow,
                          ),
                        ),
                        Text(
                          '$percent%',
                          style: AppTypography.caption.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      LeavingQatarStrings.tf(
                        'lq_dp_progress',
                        locale,
                        {'done': '$done', 'total': '$total'},
                      ),
                      style: AppTypography.bodySmall,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              _DateControl(locale: locale, plannedDate: state.plannedDepartureDate),
              const SizedBox(height: AppSpacing.md),
              _ReminderOptIn(locale: locale, plan: state),
              const SizedBox(height: AppSpacing.sm),
              _ExportPdfButton(locale: locale, plan: state),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        ...LeavingQatarDeparturePlanCatalog.items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: _PlanItemTile(
              key: ValueKey('departure_plan_item_${item.id}'),
              locale: locale,
              item: item,
              completed: state.isCompleted(item.id),
              timelineSectionKey: timelineSectionKey,
              closeoutSectionKey: closeoutSectionKey,
            ),
          ),
        ),
      ],
    );
  }
}

class _DateControl extends ConsumerWidget {
  const _DateControl({
    required this.locale,
    required this.plannedDate,
  });

  final String locale;
  final String? plannedDate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateLabel = plannedDate == null
        ? LeavingQatarStrings.t('lq_dp_date_not_set', locale)
        : plannedDate!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LeavingQatarStrings.t('lq_dp_date_heading', locale),
          style: AppTypography.caption.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: Text(
                dateLabel,
                style: AppTypography.bodySmall,
              ),
            ),
            TextButton(
              onPressed: () => _pickDate(context, ref),
              child: Text(LeavingQatarStrings.t('lq_dp_date_pick', locale)),
            ),
            if (plannedDate != null)
              TextButton(
                onPressed: () => _clearDate(context, ref),
                child: Text(LeavingQatarStrings.t('lq_dp_date_clear', locale)),
              ),
          ],
        ),
      ],
    );
  }

  Future<void> _pickDate(BuildContext context, WidgetRef ref) async {
    final now = DateTime.now();
    final initial = plannedDate != null
        ? DateTime.tryParse(plannedDate!) ?? now
        : now.add(const Duration(days: 30));
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 3),
    );
    if (picked == null || !context.mounted) return;
    final iso = LeavingQatarDeparturePlanDate.formatDateOnly(picked);
    final ok = await ref
        .read(leavingQatarDeparturePlanControllerProvider.notifier)
        .setPlannedDepartureDate(iso, locale: locale);
    if (!context.mounted) return;
    if (!ok) {
      _showSaveFailed(context);
    }
  }

  Future<void> _clearDate(BuildContext context, WidgetRef ref) async {
    final ok = await ref
        .read(leavingQatarDeparturePlanControllerProvider.notifier)
        .setPlannedDepartureDate(null, locale: locale);
    if (!context.mounted) return;
    if (!ok) {
      _showSaveFailed(context);
    }
  }

  void _showSaveFailed(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(LeavingQatarStrings.t('lq_dp_save_failed', locale)),
      ),
    );
  }
}

class _PlanItemTile extends ConsumerStatefulWidget {
  const _PlanItemTile({
    super.key,
    required this.locale,
    required this.item,
    required this.completed,
    this.timelineSectionKey,
    this.closeoutSectionKey,
  });

  final String locale;
  final DeparturePlanItemDefinition item;
  final bool completed;
  final GlobalKey? timelineSectionKey;
  final GlobalKey? closeoutSectionKey;

  @override
  ConsumerState<_PlanItemTile> createState() => _PlanItemTileState();
}

class _PlanItemTileState extends ConsumerState<_PlanItemTile> {
  bool? _pendingCompleted;
  bool _saving = false;

  bool get _displayCompleted => _pendingCompleted ?? widget.completed;

  @override
  void didUpdateWidget(covariant _PlanItemTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.completed != widget.completed && !_saving) {
      _pendingCompleted = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final timingLabel = widget.item.timingBasis ==
            DeparturePlanTimingBasis.official
        ? LeavingQatarStrings.t('lq_dp_timing_official', widget.locale)
        : LeavingQatarStrings.t('lq_dp_timing_suggested', widget.locale);

    final actionLabel = _actionLabel();

    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      glowIntensity: _displayCompleted ? 0.1 : 0.04,
      glowColor:
          _displayCompleted ? AppColors.emeraldGlow : AppColors.glassBorder,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: _displayCompleted,
                onChanged: _saving ? null : (value) => _onToggle(value ?? false),
                activeColor: AppColors.emeraldGlow,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      LeavingQatarStrings.departurePlanItemTitle(
                        widget.item.id,
                        widget.locale,
                      ),
                      style: AppTypography.subtitle.copyWith(
                        fontSize: 14,
                        decoration: _displayCompleted
                            ? TextDecoration.lineThrough
                            : null,
                        color: _displayCompleted
                            ? AppColors.textTertiary
                            : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      timingLabel,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: OutlinedButton.icon(
              onPressed: () => LeavingQatarDeparturePlanNavigation.openItem(
                context: context,
                item: widget.item,
                timelineSectionKey: widget.timelineSectionKey,
                closeoutSectionKey: widget.closeoutSectionKey,
              ),
              icon: const Icon(Icons.arrow_forward_rounded, size: 18),
              label: Text(actionLabel),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.cyanGlow,
                side: BorderSide(
                  color: AppColors.cyanGlow.withValues(alpha: 0.45),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _actionLabel() {
    switch (widget.item.navigationTarget) {
      case DeparturePlanNavigationTarget.officialPortal:
        return LeavingQatarStrings.t(
          'lq_dp_action_official_portal',
          widget.locale,
        );
      case DeparturePlanNavigationTarget.inScreenTimeline:
      case DeparturePlanNavigationTarget.inScreenCloseout:
        return LeavingQatarStrings.t(
          'lq_dp_action_view_on_page',
          widget.locale,
        );
      case DeparturePlanNavigationTarget.externalRoute:
        return LeavingQatarStrings.t('lq_dp_action_open', widget.locale);
    }
  }

  Future<void> _onToggle(bool value) async {
    setState(() {
      _pendingCompleted = value;
      _saving = true;
    });
    final ok = await ref
        .read(leavingQatarDeparturePlanControllerProvider.notifier)
        .setItemCompleted(
          itemId: widget.item.id,
          completed: value,
          locale: widget.locale,
        );
    if (!mounted) return;
    setState(() => _saving = false);
    if (ok) {
      setState(() => _pendingCompleted = null);
      return;
    }
    setState(() => _pendingCompleted = widget.completed);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          LeavingQatarStrings.t('lq_dp_save_failed', widget.locale),
        ),
      ),
    );
  }
}

class _ExportPdfButton extends ConsumerStatefulWidget {
  const _ExportPdfButton({
    required this.locale,
    required this.plan,
  });

  final String locale;
  final LeavingQatarDeparturePlanState plan;

  @override
  ConsumerState<_ExportPdfButton> createState() => _ExportPdfButtonState();
}

class _ExportPdfButtonState extends ConsumerState<_ExportPdfButton> {
  bool _exporting = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: LeavingQatarStrings.t('lq_dp_export_pdf', widget.locale),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: _exporting ? null : _export,
          icon: _exporting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.picture_as_pdf_outlined, size: 18),
          label: Text(LeavingQatarStrings.t('lq_dp_export_pdf', widget.locale)),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.sharePurple,
            side: BorderSide(
              color: AppColors.sharePurple.withValues(alpha: 0.45),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }

  Future<void> _export() async {
    setState(() => _exporting = true);
    try {
      final export = ref.read(leavingQatarDeparturePlanExportServiceProvider);
      await export.sharePdf(plan: widget.plan, locale: widget.locale);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            LeavingQatarStrings.t('lq_dp_export_failed', widget.locale),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }
}

class _ReminderOptIn extends ConsumerWidget {
  const _ReminderOptIn({
    required this.locale,
    required this.plan,
  });

  final String locale;
  final LeavingQatarDeparturePlanState plan;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reminderAsync = ref.watch(leavingQatarDeparturePlanReminderServiceProvider);

    return reminderAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => Text(
        LeavingQatarStrings.t('lq_dp_reminder_load_error', locale),
        style: AppTypography.caption.copyWith(color: AppColors.warning),
      ),
      data: (service) {
        final hasDate = plan.plannedDepartureDate != null;
        final canSchedule = hasDate &&
            LeavingQatarDeparturePlanReminderEngine.hasSchedulableDays(
              plan: plan,
            );
        final enabled = service.isEnabled;
        final toggleEnabled = hasDate && (canSchedule || enabled);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(
              label: LeavingQatarStrings.t('lq_dp_reminder_toggle_label', locale),
              child: SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: enabled,
                onChanged: toggleEnabled
                    ? (value) => _onToggle(context, ref, service, value)
                    : null,
                title: Text(
                  LeavingQatarStrings.t('lq_dp_reminder_toggle_label', locale),
                  style: AppTypography.bodySmall,
                ),
                subtitle: Text(
                  _subtitle(
                    hasDate: hasDate,
                    canSchedule: canSchedule,
                    locale: locale,
                  ),
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textTertiary,
                    height: 1.35,
                  ),
                ),
              ),
            ),
            Text(
              LeavingQatarStrings.t('lq_dp_reminder_permission_note', locale),
              style: AppTypography.caption.copyWith(
                color: AppColors.textTertiary,
                fontStyle: FontStyle.italic,
                height: 1.35,
              ),
            ),
          ],
        );
      },
    );
  }

  String _subtitle({
    required bool hasDate,
    required bool canSchedule,
    required String locale,
  }) {
    if (!hasDate) {
      return LeavingQatarStrings.t('lq_dp_reminder_need_date', locale);
    }
    if (!canSchedule) {
      return LeavingQatarStrings.t('lq_dp_reminder_none_eligible', locale);
    }
    return LeavingQatarStrings.t('lq_dp_reminder_toggle_sub', locale);
  }

  Future<void> _onToggle(
    BuildContext context,
    WidgetRef ref,
    LeavingQatarDeparturePlanReminderService service,
    bool value,
  ) async {
    try {
      await service.setEnabled(enabled: value, plan: plan, locale: locale);
      ref.invalidate(leavingQatarDeparturePlanReminderServiceProvider);
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            LeavingQatarStrings.t('lq_dp_reminder_schedule_failed', locale),
          ),
        ),
      );
    }
  }
}
