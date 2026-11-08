import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/trip_planner/domain/models/trip_enums.dart';
import 'package:raabta/features/trip_planner/presentation/l10n/trip_strings.dart';

/// Single-select trip purpose — asked once at creation.
class TripVisitorPurposeSelector extends StatelessWidget {
  const TripVisitorPurposeSelector({
    super.key,
    required this.locale,
    required this.selected,
    required this.onSelected,
  });

  final String locale;
  final TripVisitorPurpose? selected;
  final ValueChanged<TripVisitorPurpose> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          TripStrings.t('visitor_purpose_question', locale),
          style: AppTypography.caption.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: AppSpacing.sm),
        ...TripVisitorPurposeExt.selectable.map((purpose) {
          final isSelected = selected == purpose;
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: InkWell(
              onTap: () async {
                if (purpose.redirectsToProspective) {
                  await showProspectiveRedirectDialog(context, locale);
                  return;
                }
                onSelected(purpose);
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.cyanGlow
                        : AppColors.glassBorder,
                  ),
                  color: isSelected
                      ? AppColors.cyanGlow.withValues(alpha: 0.12)
                      : null,
                ),
                child: Row(
                  children: [
                    Icon(
                      isSelected
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off,
                      size: 18,
                      color: isSelected
                          ? AppColors.cyanGlow
                          : AppColors.textSecondary,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        TripStrings.t(purpose.labelKey, locale),
                        style: AppTypography.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}

Future<void> showProspectiveRedirectDialog(
  BuildContext context,
  String locale,
) async {
  await showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(TripStrings.t('visitor_purpose_relocating_title', locale)),
      content: Text(
        TripStrings.t('visitor_purpose_relocating_body', locale),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text(TripStrings.t('booking_import_cancel', locale)),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(ctx);
            context.push('/prospective');
          },
          child: Text(
            TripStrings.t('visitor_purpose_relocating_cta', locale),
          ),
        ),
      ],
    ),
  );
}

Future<TripVisitorPurpose?> showVisitorPurposeSheet(
  BuildContext context,
  String locale, {
  TripVisitorPurpose? initial,
}) {
  return showModalBottomSheet<TripVisitorPurpose>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) {
      TripVisitorPurpose? draft = initial;
      return StatefulBuilder(
        builder: (context, setState) {
          return Padding(
            padding: EdgeInsets.only(
              left: AppSpacing.lg,
              right: AppSpacing.lg,
              top: AppSpacing.lg,
              bottom: MediaQuery.paddingOf(context).bottom + AppSpacing.lg,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  TripStrings.t('visitor_purpose_sheet_title', locale),
                  style: AppTypography.title,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  TripStrings.t('visitor_purpose_sheet_hint', locale),
                  style: AppTypography.bodySmall,
                ),
                const SizedBox(height: AppSpacing.md),
                TripVisitorPurposeSelector(
                  locale: locale,
                  selected: draft,
                  onSelected: (p) => setState(() => draft = p),
                ),
                const SizedBox(height: AppSpacing.lg),
                FilledButton(
                  onPressed: draft == null
                      ? null
                      : () => Navigator.pop(ctx, draft),
                  child: Text(TripStrings.t('visitor_purpose_confirm', locale)),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
