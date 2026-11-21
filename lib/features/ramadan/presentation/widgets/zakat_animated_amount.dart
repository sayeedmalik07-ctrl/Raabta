import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/typography/app_typography.dart';

class ZakatAnimatedAmount extends StatelessWidget {
  const ZakatAnimatedAmount({
    super.key,
    required this.amount,
    required this.style,
    this.prefix = 'QAR ',
    this.duration = const Duration(milliseconds: 450),
  });

  final double amount;
  final TextStyle style;
  final String prefix;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(end: amount),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, value, _) {
        return Text(
          '$prefix${value.toStringAsFixed(2)}',
          style: style,
        );
      },
    );
  }
}

class ZakatHeroResultCard extends StatelessWidget {
  const ZakatHeroResultCard({
    super.key,
    required this.meetsNisab,
    required this.zakatDue,
    required this.dueLabel,
    required this.belowNisabLabel,
  });

  final bool meetsNisab;
  final double zakatDue;
  final String dueLabel;
  final String belowNisabLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          meetsNisab ? dueLabel : belowNisabLabel,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        ZakatAnimatedAmount(
          amount: meetsNisab ? zakatDue : 0,
          style: AppTypography.headline1.copyWith(
            color: meetsNisab ? AppColors.accentGold : AppColors.textSecondary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
