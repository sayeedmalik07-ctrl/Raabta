import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_primary_button.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/features/eosb/domain/models/overtime_truth_models.dart';
import 'package:raabta/features/eosb/presentation/l10n/eosb_strings.dart';
import 'package:raabta/features/eosb/presentation/widgets/eosb_disclaimer_banner.dart';
import 'package:raabta/features/eosb/presentation/widgets/overtime_day_editor_sheet.dart';
import 'package:raabta/features/eosb/presentation/widgets/overtime_employer_comparison_fields.dart';
import 'package:raabta/features/eosb/presentation/widgets/overtime_month_grid.dart';
import 'package:raabta/features/eosb/presentation/widgets/overtime_month_picker.dart';
import 'package:raabta/features/eosb/providers/eosb_providers.dart';
import 'package:raabta/services/drafts/draft_box_keys.dart';
import 'package:raabta/features/eosb/providers/overtime_truth_providers.dart';

class OvertimeCalendarScreen extends ConsumerWidget {
  const OvertimeCalendarScreen({super.key});

  Future<void> _editDay(
    WidgetRef ref,
    BuildContext context,
    int index,
    OvertimeDayEntry day,
    String locale,
  ) async {
    final dateKey =
        '${day.date.year}-${day.date.month.toString().padLeft(2, '0')}-${day.date.day.toString().padLeft(2, '0')}';

    await showOvertimeDayEditorSheet(
      context: context,
      locale: locale,
      day: day,
      draftFormId: DraftBoxKeys.overtimeCalendarEntry(dateKey),
      onSave: (updated) async {
        ref.read(overtimeTruthProvider.notifier).updateDay(index, updated);
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localeAsync = ref.watch(eosbLocaleProvider);
    final otState = ref.watch(overtimeTruthProvider);
    final record = otState.record;
    final result = otState.result;

    return localeAsync.when(
      loading: () => const GlassScreenScaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => const SizedBox.shrink(),
      data: (locale) {
        final summary = result?.summary;

        return GlassScreenScaffold(
          title: '${EosbStrings.t('ot_calendar_mode', locale)} · ${record.label}',
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          body: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.lg,
                    0,
                  ),
                  children: [
                    EosbDisclaimerBanner(locale: locale),
                    const SizedBox(height: AppSpacing.md),
                    OvertimeMonthPickerField(locale: locale),
                    const SizedBox(height: AppSpacing.md),
                    if (summary != null)
                      _SummaryBar(
                        locale: locale,
                        totalHours: summary.totalHours,
                        totalPayment: summary.totalPayment,
                      ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      EosbStrings.t('ot_calendar_hint', locale),
                      style: AppTypography.caption.copyWith(
                        color: AppColors.cyanGlow,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    OvertimeEmployerComparisonFields(locale: locale),
                    const SizedBox(height: AppSpacing.lg),
                    OvertimeMonthGrid(
                      days: record.days,
                      locale: locale,
                      onDayTap: (index, day) =>
                          _editDay(ref, context, index, day, locale),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: GlassPrimaryButton(
                  label: EosbStrings.t('eosb_calculate_cta', locale),
                  expand: true,
                  accentColor: AppColors.accentGold,
                  icon: Icons.calculate_outlined,
                  onPressed: otState.isCalculating
                      ? null
                      : () async {
                          await ref
                              .read(overtimeTruthProvider.notifier)
                              .calculate();
                          await ref
                              .read(overtimeTruthProvider.notifier)
                              .saveCurrentToHistory();
                          if (context.mounted) {
                            context.push('/eosb/overtime/summary');
                          }
                        },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SummaryBar extends StatelessWidget {
  const _SummaryBar({
    required this.locale,
    required this.totalHours,
    required this.totalPayment,
  });

  final String locale;
  final double totalHours;
  final double totalPayment;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.glassSurface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  EosbStrings.t('ot_total_ot_hours', locale),
                  style: AppTypography.caption,
                ),
                Text(
                  '${totalHours.toStringAsFixed(1)}h',
                  style: AppTypography.title,
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  EosbStrings.t('ot_legal_owed', locale),
                  style: AppTypography.caption,
                ),
                Text(
                  formatEosbCurrency(totalPayment),
                  style: AppTypography.title,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
