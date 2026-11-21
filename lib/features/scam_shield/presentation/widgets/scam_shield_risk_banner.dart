import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/scam_shield/domain/scam_shield_models.dart';
import 'package:raabta/features/scam_shield/presentation/l10n/scam_shield_strings.dart';

Color scamShieldRiskColor(ScamShieldRiskLevel level) {
  return switch (level) {
    ScamShieldRiskLevel.low => AppColors.successBright,
    ScamShieldRiskLevel.medium => AppColors.accentGold,
    ScamShieldRiskLevel.high => AppColors.errorBright,
  };
}

String scamShieldRiskLabelKey(ScamShieldRiskLevel level) {
  return switch (level) {
    ScamShieldRiskLevel.low => 'ss_risk_low',
    ScamShieldRiskLevel.medium => 'ss_risk_medium',
    ScamShieldRiskLevel.high => 'ss_risk_high',
  };
}

class ScamShieldRiskBanner extends StatelessWidget {
  const ScamShieldRiskBanner({
    super.key,
    required this.level,
    required this.locale,
  });

  final ScamShieldRiskLevel level;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final color = scamShieldRiskColor(level);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: color.withValues(alpha: 0.55)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ScamShieldStrings.t('ss_risk_assessment', locale),
            style: AppTypography.caption.copyWith(color: AppColors.textTertiary),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            ScamShieldStrings.t(scamShieldRiskLabelKey(level), locale),
            style: AppTypography.headline2.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            ScamShieldStrings.t('ss_risk_framing', locale),
            style: AppTypography.caption,
          ),
        ],
      ),
    );
  }
}
