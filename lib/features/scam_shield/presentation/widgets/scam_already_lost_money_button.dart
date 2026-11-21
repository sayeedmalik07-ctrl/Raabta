import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/scam_shield/domain/evidence/scam_evidence_next_step.dart';
import 'package:raabta/features/scam_shield/domain/scam_shield_models.dart';
import 'package:raabta/features/scam_shield/presentation/l10n/scam_shield_strings.dart';

/// Calm secondary path to incident / reporting help (Phase 27).
abstract final class ScamAlreadyLostMoneyButton {
  static bool shouldShow({
    required ScamShieldRiskLevel risk,
    required ScamEvidenceNextStepKind primaryKind,
  }) {
    if (risk == ScamShieldRiskLevel.low) return false;
    if (primaryKind == ScamEvidenceNextStepKind.incidentResponse) {
      return false;
    }
    return true;
  }

  static void openHelp(BuildContext context) {
    context.push('/scam-shield/incident');
  }
}

class ScamAlreadyLostMoneyTextButton extends StatelessWidget {
  const ScamAlreadyLostMoneyTextButton({
    super.key,
    required this.locale,
  });

  final String locale;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xs),
      child: TextButton(
        onPressed: () => ScamAlreadyLostMoneyButton.openHelp(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              ScamShieldStrings.t('ss_lost_money_cta', locale),
              style: AppTypography.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              ScamShieldStrings.t('ss_lost_money_sub', locale),
              style: AppTypography.caption,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
