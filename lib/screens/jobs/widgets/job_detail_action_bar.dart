import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/l10n/common_action_strings.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/data/models/job_listing.dart';
import 'package:raabta/screens/jobs/l10n/jobs_strings.dart';

/// Scrolls the detail sheet to the native application block (no submit duplication).
void scrollToJobDetailApplicationSection(GlobalKey applicationSectionKey) {
  final targetContext = applicationSectionKey.currentContext;
  if (targetContext == null) return;
  Scrollable.ensureVisible(
    targetContext,
    duration: const Duration(milliseconds: 320),
    curve: Curves.easeInOut,
    alignment: 0.15,
  );
}

/// Sticky hub kit DetailActionBar for job listing sheets.
class JobDetailActionBar extends StatelessWidget {
  const JobDetailActionBar({
    super.key,
    required this.job,
    required this.locale,
    required this.isSaved,
    required this.onSave,
    required this.onShare,
    required this.onNativeApplyPrimary,
  });

  final JobListing job;
  final String locale;
  final bool isSaved;
  final VoidCallback onSave;
  final VoidCallback onShare;
  final VoidCallback onNativeApplyPrimary;

  static const Key barKey = Key('jobs_detail_action_bar');
  static const Key primaryButtonKey = Key('jobs_detail_action_bar_primary');
  static const Key saveButtonKey = Key('jobs_detail_action_bar_save');
  static const Key shareButtonKey = Key('jobs_detail_action_bar_share');

  static const double _compactLayoutMaxWidth = 360;

  /// Bottom [ListView] padding so tail sections stay above the sticky bar + safe area.
  static double scrollBottomInset(BuildContext context, {required JobListing job}) {
    final width = MediaQuery.sizeOf(context).width;
    final compact = width < _compactLayoutMaxWidth;
    const primaryBlockHeight = 48.0;
    const iconActionHeight = 48.0;
    const innerVerticalPadding = AppSpacing.sm * 2;
    final actionHeight = compact
        ? primaryBlockHeight + AppSpacing.sm + iconActionHeight
        : iconActionHeight;
    final safeBottom = MediaQuery.paddingOf(context).bottom;
    return actionHeight + innerVerticalPadding + safeBottom + AppSpacing.sm;
  }

  @override
  Widget build(BuildContext context) {
    final aggregated = !job.supportsApplicationTracking;
    final primaryLabel = aggregated
        ? JobsStrings.t('jobs_employer_apply_unavailable_title', locale)
        : JobsStrings.t('jobs_apply', locale);
    final saveLabel = isSaved
        ? CommonActionStrings.t('action_saved', locale)
        : CommonActionStrings.t('action_save', locale);
    final shareLabel = CommonActionStrings.t('action_share', locale);
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Material(
      key: barKey,
      color: AppColors.surface,
      elevation: 8,
      shadowColor: Colors.black26,
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              AppSpacing.sm,
            ),
            child: FocusTraversalGroup(
              policy: ReadingOrderTraversalPolicy(),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final compact = constraints.maxWidth < _compactLayoutMaxWidth;
                  final primary = FocusTraversalOrder(
                    order: const NumericFocusOrder(1),
                    child: _PrimaryButton(
                      aggregated: aggregated,
                      label: primaryLabel,
                      onNativeApply: onNativeApplyPrimary,
                    ),
                  );

                  final save = FocusTraversalOrder(
                    order: const NumericFocusOrder(2),
                    child: _IconActionButton(
                      key: saveButtonKey,
                      icon: isSaved ? Icons.favorite : Icons.favorite_border,
                      label: saveLabel,
                      color: isSaved
                          ? AppColors.brandFamilyMain
                          : AppColors.textSecondary,
                      onPressed: onSave,
                    ),
                  );

                  final share = FocusTraversalOrder(
                    order: const NumericFocusOrder(3),
                    child: _IconActionButton(
                      key: shareButtonKey,
                      icon: Icons.share_outlined,
                      label: shareLabel,
                      color: AppColors.textSecondary,
                      onPressed: onShare,
                    ),
                  );

                  if (compact) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        primary,
                        const SizedBox(height: AppSpacing.sm),
                        Row(
                          children: [
                            Expanded(child: save),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(child: share),
                          ],
                        ),
                      ],
                    );
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(child: primary),
                      const SizedBox(width: AppSpacing.sm),
                      save,
                      const SizedBox(width: AppSpacing.xs),
                      share,
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.aggregated,
    required this.label,
    required this.onNativeApply,
  });

  final bool aggregated;
  final String label;
  final VoidCallback onNativeApply;

  @override
  Widget build(BuildContext context) {
    final textScaler = MediaQuery.textScalerOf(context);
    final style = AppTypography.subtitle.copyWith(
      fontWeight: FontWeight.w700,
      fontSize: textScaler.scale(15).clamp(13.0, 20.0),
    );

    if (aggregated) {
      return Semantics(
        button: true,
        enabled: false,
        label: label,
        excludeSemantics: true,
        child: FilledButton.icon(
          key: JobDetailActionBar.primaryButtonKey,
          onPressed: null,
          icon: const Icon(Icons.open_in_new, size: 18),
          label: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
          style: FilledButton.styleFrom(
            disabledBackgroundColor: AppColors.surfaceElevated,
            disabledForegroundColor: AppColors.textSecondary,
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      );
    }

    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: FilledButton.icon(
        key: JobDetailActionBar.primaryButtonKey,
        onPressed: onNativeApply,
        icon: const Icon(Icons.send_outlined, size: 18),
        label: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: style),
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.brandFamilyMain,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}

class _IconActionButton extends StatelessWidget {
  const _IconActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: Tooltip(
        message: label,
        child: IconButton.filledTonal(
          onPressed: onPressed,
          icon: Icon(icon, color: color),
          style: IconButton.styleFrom(
            foregroundColor: color,
            minimumSize: const Size(48, 48),
          ),
        ),
      ),
    );
  }
}
