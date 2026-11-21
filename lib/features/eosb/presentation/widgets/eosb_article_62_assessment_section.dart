import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/eosb/presentation/l10n/eosb_strings.dart';
import 'package:raabta/features/eosb/presentation/widgets/calculator_form_widgets.dart';

/// Optional dismissal review when the employer initiated termination.
class EosbArticle62AssessmentSection extends StatelessWidget {
  const EosbArticle62AssessmentSection({
    super.key,
    required this.locale,
    required this.expanded,
    required this.skipped,
    required this.reasonGiven,
    required this.matchesArt61Ground,
    required this.processFollowed,
    required this.onExpand,
    required this.onSkip,
    required this.onReasonGivenChanged,
    required this.onMatchesArt61Changed,
    required this.onProcessFollowedChanged,
  });

  final String locale;
  final bool expanded;
  final bool skipped;
  final bool? reasonGiven;
  final bool? matchesArt61Ground;
  final bool? processFollowed;
  final VoidCallback onExpand;
  final VoidCallback onSkip;
  final ValueChanged<bool?> onReasonGivenChanged;
  final ValueChanged<bool?> onMatchesArt61Changed;
  final ValueChanged<bool?> onProcessFollowedChanged;

  @override
  Widget build(BuildContext context) {
    if (skipped) {
      return Align(
        alignment: Alignment.centerLeft,
        child: TextButton(
          onPressed: onExpand,
          child: Text(EosbStrings.t('eosb_art62_reopen', locale)),
        ),
      );
    }

    if (!expanded) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OutlinedButton.icon(
            onPressed: onExpand,
            icon: const Icon(Icons.help_outline_rounded, size: 18),
            label: Text(EosbStrings.t('eosb_art62_optional_cta', locale)),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: onSkip,
              child: Text(EosbStrings.t('eosb_art62_skip', locale)),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          EosbStrings.t('eosb_art62_section_title', locale),
          style: AppTypography.bodySmall.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.cyanGlow,
          ),
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          EosbStrings.t('eosb_art62_section_sub', locale),
          style: AppTypography.caption,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          EosbStrings.t('eosb_art62_disclaimer', locale),
          style: AppTypography.caption.copyWith(
            color: AppColors.textTertiary,
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _yesNoQuestion(
          question: EosbStrings.t('eosb_art62_q1_reason_given', locale),
          value: reasonGiven,
          onChanged: onReasonGivenChanged,
        ),
        if (reasonGiven == true) ...[
          const SizedBox(height: AppSpacing.md),
          _yesNoQuestion(
            question: EosbStrings.t('eosb_art62_q2_matches_art61', locale),
            subtitle: EosbStrings.t('eosb_art62_art61_grounds_list', locale),
            value: matchesArt61Ground,
            onChanged: onMatchesArt61Changed,
          ),
        ],
        if (reasonGiven != null) ...[
          const SizedBox(height: AppSpacing.md),
          _yesNoQuestion(
            question: EosbStrings.t('eosb_art62_q3_process_followed', locale),
            value: processFollowed,
            onChanged: onProcessFollowedChanged,
          ),
        ],
        const SizedBox(height: AppSpacing.sm),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: onSkip,
            child: Text(EosbStrings.t('eosb_art62_skip', locale)),
          ),
        ),
      ],
    );
  }

  Widget _yesNoQuestion({
    required String question,
    String? subtitle,
    required bool? value,
    required ValueChanged<bool?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          question,
          style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: AppSpacing.xxs),
          Text(subtitle, style: AppTypography.caption),
        ],
        const SizedBox(height: AppSpacing.sm),
        CalculatorChoiceTile<bool?>(
          title: EosbStrings.t('eosb_art62_yes', locale),
          selected: value == true,
          onTap: () => onChanged(true),
        ),
        const SizedBox(height: AppSpacing.sm),
        CalculatorChoiceTile<bool?>(
          title: EosbStrings.t('eosb_art62_no', locale),
          selected: value == false,
          onTap: () => onChanged(false),
        ),
      ],
    );
  }
}
