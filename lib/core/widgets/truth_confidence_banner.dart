import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/l10n/truth_confidence_strings.dart';
import 'package:raabta/features/truth_engine/presentation/truth_engine_status_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';

/// Visual confidence framing — distinct from violation-severity colors (EOSB amber/red).
enum TruthConfidenceState {
  known,
  possible,
  unknown,
  action,
}

/// Shared Known / Unknown / Possible / Action banner for Truth Engines.
class TruthConfidenceBanner extends StatelessWidget {
  const TruthConfidenceBanner({
    super.key,
    required this.state,
    required this.text,
    this.locale = 'English',
    this.showStateLabel = true,
    this.engine,
  });

  final TruthConfidenceState state;
  final String text;
  final String locale;
  final bool showStateLabel;
  final TruthEngineFamily? engine;

  @override
  Widget build(BuildContext context) {
    final (icon, color, labelKey) = switch (state) {
      TruthConfidenceState.known => (
          Icons.check_circle_outline,
          AppColors.successBright,
          'truth_confidence_known_label',
        ),
      TruthConfidenceState.possible => (
          Icons.lightbulb_outline_rounded,
          AppColors.cyanGlow,
          'truth_confidence_possible_label',
        ),
      TruthConfidenceState.unknown => (
          Icons.help_outline_rounded,
          AppColors.textSecondary,
          'truth_confidence_unknown_label',
        ),
      TruthConfidenceState.action => (
          Icons.playlist_add_check_rounded,
          engine == null
              ? AppColors.chipHealthInsurance
              : TruthEngineStatusColors.engineAccent(engine!),
          'truth_confidence_action_label',
        ),
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppSpacing.sm),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: AppSpacing.iconSm, color: color),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (showStateLabel)
                  Text(
                    TruthConfidenceStrings.t(labelKey, locale),
                    style: AppTypography.caption.copyWith(
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                if (showStateLabel) const SizedBox(height: AppSpacing.xs),
                Text(
                  text,
                  style: AppTypography.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
