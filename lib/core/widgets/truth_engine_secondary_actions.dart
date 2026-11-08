import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';

class TruthEngineSecondaryAction {
  const TruthEngineSecondaryAction({
    required this.label,
    required this.onPressed,
    this.icon,
    this.style = TruthEngineSecondaryActionStyle.outlined,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final TruthEngineSecondaryActionStyle style;
}

enum TruthEngineSecondaryActionStyle {
  outlined,
  textLink,
}

/// Consistent secondary-action footer for Truth Engine result screens.
class TruthEngineSecondaryActions extends StatelessWidget {
  const TruthEngineSecondaryActions({
    super.key,
    required this.actions,
    this.topSpacing = AppSpacing.sm,
  });

  final List<TruthEngineSecondaryAction> actions;
  final double topSpacing;

  @override
  Widget build(BuildContext context) {
    if (actions.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: topSpacing),
        for (var i = 0; i < actions.length; i++) ...[
          if (i > 0) const SizedBox(height: AppSpacing.sm),
          _SecondaryActionButton(action: actions[i]),
        ],
      ],
    );
  }
}

class _SecondaryActionButton extends StatelessWidget {
  const _SecondaryActionButton({required this.action});

  final TruthEngineSecondaryAction action;

  @override
  Widget build(BuildContext context) {
    if (action.style == TruthEngineSecondaryActionStyle.textLink) {
      if (action.icon != null) {
        return TextButton.icon(
          onPressed: action.onPressed,
          icon: Icon(action.icon, size: 18, color: AppColors.cyanGlow),
          label: Text(
            action.label,
            style: AppTypography.bodySmall.copyWith(color: AppColors.cyanGlow),
          ),
        );
      }
      return TextButton(
        onPressed: action.onPressed,
        child: Text(
          action.label,
          style: AppTypography.bodySmall.copyWith(color: AppColors.cyanGlow),
        ),
      );
    }

    if (action.icon != null) {
      return OutlinedButton.icon(
        onPressed: action.onPressed,
        icon: Icon(action.icon),
        label: Text(action.label),
      );
    }
    return OutlinedButton(
      onPressed: action.onPressed,
      child: Text(action.label),
    );
  }
}
