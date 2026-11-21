import 'package:flutter/material.dart';
import 'package:raabta/core/typography/app_typography.dart';

class PersonalBudgetAnimatedAmount extends StatelessWidget {
  const PersonalBudgetAnimatedAmount({
    super.key,
    required this.amount,
    required this.style,
    this.prefix = 'QAR ',
    this.suffix = '',
    this.duration = const Duration(milliseconds: 450),
  });

  final double amount;
  final TextStyle style;
  final String prefix;
  final String suffix;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(end: amount),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, value, _) {
        final formatted = value == value.roundToDouble()
            ? value.toStringAsFixed(0)
            : value.toStringAsFixed(2);
        return Text(
          '$prefix$formatted$suffix',
          style: AppTypography.tabular(style),
        );
      },
    );
  }
}
