import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_primary_button.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/features/eosb/presentation/l10n/eosb_strings.dart';
import 'package:raabta/features/eosb/presentation/widgets/eosb_disclaimer_banner.dart';
import 'package:raabta/features/eosb/presentation/widgets/overtime_comparison_widget.dart';
import 'package:raabta/features/eosb/presentation/widgets/overtime_confidence_sheet.dart';
import 'package:raabta/features/eosb/presentation/widgets/overtime_month_picker.dart';
import 'package:raabta/features/eosb/providers/eosb_providers.dart';
import 'package:raabta/features/eosb/providers/overtime_truth_providers.dart';

class OvertimeTruthHubScreen extends ConsumerWidget {
  const OvertimeTruthHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localeAsync = ref.watch(eosbLocaleProvider);
    final otState = ref.watch(overtimeTruthProvider);
    final result = otState.result;
    final record = otState.record;

    return localeAsync.when(
      loading: () => const GlassScreenScaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => const SizedBox.shrink(),
      data: (locale) {
        final monthLabel = record.label;
        final estimated = result?.totalLegalOwed ?? 0;
        final confidence = result?.confidenceScore ?? 0;
        final statusKey = result?.statusKey ?? 'ot_status_pending';

        return GlassScreenScaffold(
          title: EosbStrings.t('ot_title', locale),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          padding: const EdgeInsets.all(AppSpacing.lg),
          body: ListView(
            children: [
              Text(
                EosbStrings.t('ot_subtitle', locale),
                style: AppTypography.bodySmall,
              ),
              const SizedBox(height: AppSpacing.md),
              EosbDisclaimerBanner(locale: locale),
              const SizedBox(height: AppSpacing.md),
              OvertimeMonthPickerField(locale: locale),
              const SizedBox(height: AppSpacing.lg),
              GlassCard(
                padding: const EdgeInsets.all(AppSpacing.lg),
                glowColor: AppColors.accentGold,
                glowIntensity: 0.22,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      EosbStrings.t('ot_monthly_estimate', locale),
                      style: AppTypography.bodySmall,
                    ),
                    Text(
                      formatEosbCurrency(estimated),
                      style: AppTypography.display.copyWith(fontSize: 36),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        _HeroChip(
                          icon: Icons.verified_outlined,
                          label:
                              '${EosbStrings.t('ot_confidence', locale)} $confidence%',
                          onTap: result == null
                              ? null
                              : () => showOvertimeConfidenceSheet(
                                    context,
                                    locale: locale,
                                    result: result,
                                  ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        _HeroChip(
                          icon: Icons.event,
                          label: monthLabel,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      EosbStrings.t(statusKey, locale),
                      style: AppTypography.caption.copyWith(
                        color: AppColors.cyanGlow,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                EosbStrings.t('ot_quick_actions', locale),
                style: AppTypography.title,
              ),
              const SizedBox(height: AppSpacing.sm),
              _ActionGrid(
                locale: locale,
                onNew: () => context.push('/eosb/overtime/calendar'),
                onHistory: () => context.push('/eosb/overtime/history'),
                onCompare: () => context.push('/eosb/overtime/input'),
                onPdf: result == null
                    ? null
                    : () => context.push('/eosb/overtime/summary'),
                onShare: result == null
                    ? null
                    : () => context.push('/eosb/overtime/summary'),
                onAi: result == null
                    ? null
                    : () => context.push('/eosb/overtime/ai-review'),
              ),
              const SizedBox(height: AppSpacing.lg),
              GlassPrimaryButton(
                label: EosbStrings.t('ot_employee_info', locale),
                expand: true,
                accentColor: AppColors.cyanGlow,
                icon: Icons.badge_outlined,
                onPressed: () => context.push('/eosb/overtime/employee'),
              ),
              const SizedBox(height: AppSpacing.sm),
              GlassPrimaryButton(
                label: EosbStrings.t('ot_calendar_mode', locale),
                expand: true,
                accentColor: AppColors.accentGold,
                icon: Icons.calendar_month_outlined,
                onPressed: () => context.push('/eosb/overtime/calendar'),
              ),
              const SizedBox(height: AppSpacing.sm),
              GlassPrimaryButton(
                label: EosbStrings.t('ot_import_docs', locale),
                expand: true,
                accentColor: AppColors.sharePurple,
                icon: Icons.document_scanner_outlined,
                onPressed: () => context.push('/eosb/overtime/import'),
              ),
              const SizedBox(height: AppSpacing.sm),
              GlassPrimaryButton(
                label: EosbStrings.t('ot_rounding_hub_button', locale),
                expand: true,
                accentColor: AppColors.info,
                icon: Icons.schedule_outlined,
                onPressed: () => context.push('/eosb/overtime/rounding'),
              ),
              if (result != null) ...[
                const SizedBox(height: AppSpacing.lg),
                Text(
                  EosbStrings.t('ot_employer_comparison', locale),
                  style: AppTypography.title,
                ),
                const SizedBox(height: AppSpacing.sm),
                OvertimeComparisonWidget(
                  comparison: result.comparison,
                  locale: locale,
                  showRoundingLink:
                      result.comparison.hoursGap > 0 ||
                      result.comparison.isUnderpaid,
                  onRoundingTap: () => context.push('/eosb/overtime/rounding'),
                ),
                const SizedBox(height: AppSpacing.sm),
                GlassPrimaryButton(
                  label: EosbStrings.t('ot_monthly_summary', locale),
                  expand: true,
                  accentColor: AppColors.emeraldGlow,
                  icon: Icons.analytics_outlined,
                  onPressed: () => context.push('/eosb/overtime/summary'),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _HeroChip extends StatelessWidget {
  const _HeroChip({
    required this.icon,
    required this.label,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GlassCard(
        onTap: onTap,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        child: Row(
          children: [
            Icon(icon, size: AppSpacing.iconSm, color: AppColors.cyanGlow),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Text(label, style: AppTypography.caption, maxLines: 1),
            ),
            if (onTap != null)
              Icon(
                Icons.info_outline,
                size: 14,
                color: AppColors.textTertiary,
              ),
          ],
        ),
      ),
    );
  }
}

class _ActionGrid extends StatelessWidget {
  const _ActionGrid({
    required this.locale,
    required this.onNew,
    required this.onHistory,
    required this.onCompare,
    this.onPdf,
    this.onShare,
    this.onAi,
  });

  final String locale;
  final VoidCallback onNew;
  final VoidCallback onHistory;
  final VoidCallback onCompare;
  final VoidCallback? onPdf;
  final VoidCallback? onShare;
  final VoidCallback? onAi;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        _QuickTile(
          icon: Icons.add_circle_outline,
          label: EosbStrings.t('ot_new_calc', locale),
          onTap: onNew,
        ),
        _QuickTile(
          icon: Icons.history,
          label: EosbStrings.t('ot_history', locale),
          onTap: onHistory,
        ),
        _QuickTile(
          icon: Icons.compare_arrows,
          label: EosbStrings.t('ot_employer_comparison', locale),
          onTap: onCompare,
        ),
        _QuickTile(
          icon: Icons.picture_as_pdf_outlined,
          label: EosbStrings.t('ot_share_report', locale),
          onTap: onPdf,
          enabled: onPdf != null,
        ),
        _QuickTile(
          icon: Icons.share_outlined,
          label: EosbStrings.t('ot_share_card', locale),
          onTap: onShare,
          enabled: onShare != null,
        ),
        _QuickTile(
          icon: Icons.auto_awesome,
          label: EosbStrings.t('ot_ai_review', locale),
          onTap: onAi,
          enabled: onAi != null,
        ),
      ],
    );
  }
}

class _QuickTile extends StatelessWidget {
  const _QuickTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.enabled = true,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      child: GlassCard(
        onTap: enabled ? onTap : null,
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Opacity(
          opacity: enabled ? 1 : 0.45,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: AppColors.accentGold),
              const SizedBox(height: AppSpacing.sm),
              Text(label, style: AppTypography.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}
