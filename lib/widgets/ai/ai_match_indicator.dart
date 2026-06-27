import 'package:flutter/material.dart';
import 'package:raabta/core/design/app_colors.dart';

class AIMatchIndicator extends StatelessWidget {
  const AIMatchIndicator({
    super.key,
    required this.matchScore,
    this.size = 44,
  });

  final int matchScore;
  final double size;

  Color get _scoreColor {
    if (matchScore >= 90) return AppColors.success;
    if (matchScore >= 75) return AppColors.primary;
    if (matchScore >= 60) return AppColors.info;
    if (matchScore >= 45) return AppColors.warning;
    return AppColors.textMuted;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: matchScore / 100,
            strokeWidth: 3,
            backgroundColor: AppColors.border,
            valueColor: AlwaysStoppedAnimation<Color>(_scoreColor),
          ),
          Text(
            '$matchScore%',
            style: TextStyle(
              color: _scoreColor,
              fontSize: size * 0.22,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
