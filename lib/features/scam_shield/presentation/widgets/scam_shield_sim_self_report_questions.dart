import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/scam_shield/domain/scam_sim_swap_self_report.dart';
import 'package:raabta/features/scam_shield/presentation/l10n/scam_shield_strings.dart';

/// Shared four-question SIM/eSIM self-report block.
class ScamShieldSimSelfReportQuestions extends StatelessWidget {
  const ScamShieldSimSelfReportQuestions({
    super.key,
    required this.answers,
    required this.onChanged,
    required this.locale,
    this.compact = false,
  });

  final SimSwapSelfReportAnswers answers;
  final ValueChanged<SimSwapSelfReportAnswers> onChanged;
  final String locale;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!compact) ...[
          Text(
            ScamShieldStrings.t('ss_sim_questions_heading', locale),
            style: AppTypography.subtitle,
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        ...simSwapSelfReportQuestions.map(
          (question) => _QuestionRow(
            question: question,
            selected: answers.answerFor(question),
            locale: locale,
            compact: compact,
            onSelected: (value) => onChanged(answers.withAnswer(question, value)),
          ),
        ),
      ],
    );
  }
}

class _QuestionRow extends StatelessWidget {
  const _QuestionRow({
    required this.question,
    required this.selected,
    required this.locale,
    required this.compact,
    required this.onSelected,
  });

  final SimSwapSelfReportQuestion question;
  final SimSwapTriStateAnswer? selected;
  final String locale;
  final bool compact;
  final ValueChanged<SimSwapTriStateAnswer> onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: compact ? AppSpacing.sm : AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ScamShieldStrings.t(question.labelKey, locale),
            style: compact ? AppTypography.caption : AppTypography.bodySmall,
          ),
          const SizedBox(height: AppSpacing.xs),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: SimSwapTriStateAnswer.values.map((answer) {
              final isSelected = selected == answer;
              return ChoiceChip(
                label: Text(
                  ScamShieldStrings.t(_answerLabelKey(answer), locale),
                  style: AppTypography.caption,
                ),
                selected: isSelected,
                onSelected: (_) => onSelected(answer),
                selectedColor: AppColors.chipLease.withValues(alpha: 0.25),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  static String _answerLabelKey(SimSwapTriStateAnswer answer) => switch (answer) {
        SimSwapTriStateAnswer.yes => 'ss_sim_answer_yes',
        SimSwapTriStateAnswer.no => 'ss_sim_answer_no',
        SimSwapTriStateAnswer.notSure => 'ss_sim_answer_not_sure',
      };
}
