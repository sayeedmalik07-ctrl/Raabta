import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/home/widgets/score_ring_painter.dart';
import 'package:raabta/features/home/widgets/status_badge.dart';
import 'package:raabta/features/trip_planner/domain/models/trip_readiness_models.dart';
import 'package:raabta/features/trip_planner/presentation/l10n/trip_strings.dart';

class TripReadinessSummaryCard extends StatelessWidget {
  const TripReadinessSummaryCard({
    super.key,
    required this.tripId,
    required this.locale,
    required this.result,
    this.compact = false,
    this.onTap,
  });

  final String tripId;
  final String locale;
  final TripReadinessResult result;
  final bool compact;
  final VoidCallback? onTap;

  static const _ringSize = 96.0;

  @override
  Widget build(BuildContext context) {
    final ringColor = _ringColor(result.percent);

    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      glowColor: ringColor,
      glowIntensity: 0.15,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              SizedBox(
                width: _ringSize,
                height: _ringSize,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: const Size(_ringSize, _ringSize),
                      painter: ScoreRingPainter(
                        progress: result.percent / 100,
                        strokeWidth: 10,
                        glowColor: ringColor,
                      ),
                    ),
                    Text(
                      '${result.percent}%',
                      style: AppTypography.title.copyWith(fontSize: 22),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      TripStrings.t('readiness_title', locale),
                      style: AppTypography.title,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      result.remainingCount == 0
                          ? TripStrings.t('readiness_all_done', locale)
                          : TripStrings.format('readiness_remaining', locale, {
                              'count': '${result.remainingCount}',
                            }),
                      style: AppTypography.bodySmall,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    StatusBadge(
                      label: TripStrings.format(
                        'readiness_complete_count',
                        locale,
                        {
                          'done': '${result.completeCount}',
                          'total': '${result.applicableCount}',
                        },
                      ),
                      color: ringColor,
                      icon: Icons.checklist_rounded,
                    ),
                  ],
                ),
              ),
              if (onTap != null) const Icon(Icons.chevron_right),
            ],
          ),
          if (!compact) ...[
            const SizedBox(height: AppSpacing.md),
            ...result.items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: _CategoryRow(item: item, locale: locale),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _ringColor(int percent) {
    if (percent >= 100) return AppColors.successBright;
    if (percent >= 50) return AppColors.accentGold;
    return AppColors.errorBright;
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({required this.item, required this.locale});

  final TripReadinessItem item;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(item.status);
    final title = TripStrings.t(_categoryLabelKey(item.category), locale);
    final detail = item.detailKey == null
        ? ''
        : TripStrings.t(item.detailKey!, locale);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(_statusIcon(item.status), color: color, size: 18),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTypography.bodySmall.copyWith(fontSize: 13)),
              if (detail.isNotEmpty)
                Text(detail, style: AppTypography.caption),
            ],
          ),
        ),
        StatusBadge(
          label: TripStrings.t(
            item.isComplete ? 'readiness_status_done' : 'readiness_status_todo',
            locale,
          ),
          color: color,
        ),
      ],
    );
  }

  String _categoryLabelKey(TripReadinessCategory category) {
    return switch (category) {
      TripReadinessCategory.passportValidity => 'readiness_cat_passport',
      TripReadinessCategory.visaEntry => 'readiness_cat_visa',
      TripReadinessCategory.flightBooked => 'readiness_cat_flight',
      TripReadinessCategory.accommodationBooked => 'readiness_cat_hotel',
      TripReadinessCategory.travelInsurance => 'readiness_cat_insurance',
      TripReadinessCategory.insuranceCancellationCoverage =>
        'readiness_cat_insurance_cancellation',
      TripReadinessCategory.connectivity => 'readiness_cat_connectivity',
      TripReadinessCategory.currencyReady => 'readiness_cat_currency',
      TripReadinessCategory.emergencyContacts => 'readiness_cat_emergency',
    };
  }

  Color _statusColor(TripReadinessItemStatus status) {
    return switch (status) {
      TripReadinessItemStatus.complete => AppColors.successBright,
      TripReadinessItemStatus.attention => AppColors.accentGold,
      TripReadinessItemStatus.blocked => AppColors.errorBright,
      TripReadinessItemStatus.incomplete => AppColors.textSecondary,
    };
  }

  IconData _statusIcon(TripReadinessItemStatus status) {
    return switch (status) {
      TripReadinessItemStatus.complete => Icons.check_circle_outline,
      TripReadinessItemStatus.attention => Icons.warning_amber_rounded,
      TripReadinessItemStatus.blocked => Icons.error_outline,
      TripReadinessItemStatus.incomplete => Icons.radio_button_unchecked,
    };
  }
}

/// Navigates to the action route for a readiness item, or toggles manual checks via callback.
void handleReadinessItemTap(
  BuildContext context, {
  required TripReadinessItem item,
  required VoidCallback? onManualToggle,
}) {
  final isManualOnly = switch (item.category) {
    TripReadinessCategory.travelInsurance ||
    TripReadinessCategory.insuranceCancellationCoverage ||
    TripReadinessCategory.connectivity ||
    TripReadinessCategory.currencyReady ||
    TripReadinessCategory.emergencyContacts =>
      true,
    _ => false,
  };

  if (isManualOnly) {
    onManualToggle?.call();
    return;
  }

  if (item.status == TripReadinessItemStatus.attention &&
      (item.category == TripReadinessCategory.passportValidity ||
          item.category == TripReadinessCategory.visaEntry)) {
    onManualToggle?.call();
    return;
  }

  final route = item.actionRoute;
  if (route != null) context.push(route);
}
