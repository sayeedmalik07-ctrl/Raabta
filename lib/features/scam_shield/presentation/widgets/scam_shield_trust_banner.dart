import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/trust_label.dart';
import 'package:raabta/features/scam_shield/domain/scam_authority_matcher.dart';
import 'package:raabta/features/scam_shield/domain/scam_social_engineering_scorer.dart';
import 'package:raabta/features/scam_shield/domain/scam_scan_risk_engine.dart';
import 'package:raabta/features/scam_shield/domain/scam_trust_label.dart';
import 'package:raabta/features/scam_shield/presentation/l10n/scam_shield_strings.dart';
import 'package:raabta/features/scam_shield/presentation/widgets/scam_shield_primitives.dart';
import 'package:raabta/features/scam_shield/presentation/widgets/scam_shield_risk_banner.dart';

class ScamShieldTrustBanner extends StatelessWidget {
  const ScamShieldTrustBanner({
    super.key,
    required this.analysis,
    required this.locale,
  });

  final ScamScanRiskAnalysis analysis;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final label = analysis.trustLabel;
    final color = label == ScamTrustLabel.verified
        ? AppColors.success
        : scamShieldRiskColor(label.displayRisk);

    final details = <Widget>[];

    if (analysis.authorityMatch.verifiedChannel &&
        analysis.authorityMatch.primaryEntryNameKey != null) {
      details.add(const SizedBox(height: AppSpacing.sm));
      details.add(
        TrustLabel(
          type: TrustLabelType.official,
          locale: locale,
          sourceName: ScamShieldStrings.t(
            analysis.authorityMatch.primaryEntryNameKey!,
            locale,
          ),
          showDetail: true,
        ),
      );
    }

    if (analysis.authorityMatch.kind == ScamAuthorityMatchKind.domainMismatch) {
      details.add(const SizedBox(height: AppSpacing.xs));
      details.add(
        Text(
          ScamShieldStrings.t('ss_auth_mismatch_warning', locale),
          style: AppTypography.bodySmall.copyWith(color: AppColors.warning),
        ),
      );
    }

    details.add(const SizedBox(height: AppSpacing.xs));
    details.add(
      Text(
        ScamShieldStrings.t('ss_se_band_label', locale).replaceAll(
          '{band}',
          ScamShieldStrings.t(analysis.socialScore.band.labelKey, locale),
        ),
        style: AppTypography.bodySmall.copyWith(
          color: AppColors.textOnGlassMuted,
        ),
      ),
    );

    return ScamShieldVerdictCard(
      overline: ScamShieldStrings.t('ss_raabta_assessment', locale),
      headline: ScamShieldStrings.t(label.labelKey, locale),
      accentColor: color,
      subtitle: ScamShieldStrings.t(label.confidenceBandKey, locale),
      leadingIcon: Icons.shield_outlined,
      details: details,
    );
  }
}
