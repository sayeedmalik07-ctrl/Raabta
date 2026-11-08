import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/scam_shield/domain/scam_shield_models.dart';
import 'package:raabta/features/scam_shield/presentation/l10n/scam_shield_strings.dart';

/// Three-shape verdict system (Phase 22) — not colour-only.
enum EvidenceVerdictPictogramState {
  stop,
  beCareful,
  noConcerns,
}

abstract final class EvidenceVerdictPictogramResolver {
  static EvidenceVerdictPictogramState fromRisk(ScamShieldRiskLevel level) {
    return switch (level) {
      ScamShieldRiskLevel.high => EvidenceVerdictPictogramState.stop,
      ScamShieldRiskLevel.medium => EvidenceVerdictPictogramState.beCareful,
      ScamShieldRiskLevel.low => EvidenceVerdictPictogramState.noConcerns,
    };
  }

  static String headlineKey(EvidenceVerdictPictogramState state) {
    return switch (state) {
      EvidenceVerdictPictogramState.stop => 'ss_verdict_stop_line',
      EvidenceVerdictPictogramState.beCareful => 'ss_verdict_caution_line',
      EvidenceVerdictPictogramState.noConcerns => 'ss_verdict_clear_line',
    };
  }

  static IconData icon(EvidenceVerdictPictogramState state) {
    return switch (state) {
      EvidenceVerdictPictogramState.stop => Icons.block,
      EvidenceVerdictPictogramState.beCareful => Icons.warning_amber_rounded,
      EvidenceVerdictPictogramState.noConcerns => Icons.task_alt_outlined,
    };
  }

  static Color accent(EvidenceVerdictPictogramState state) {
    return switch (state) {
      EvidenceVerdictPictogramState.stop => AppColors.errorBright,
      EvidenceVerdictPictogramState.beCareful => AppColors.accentGold,
      EvidenceVerdictPictogramState.noConcerns => AppColors.successBright,
    };
  }

  static String semanticsLabel(
    EvidenceVerdictPictogramState state,
    String locale,
  ) {
    return ScamShieldStrings.t(headlineKey(state), locale);
  }
}

class EvidenceVerdictPictogramBanner extends StatelessWidget {
  const EvidenceVerdictPictogramBanner({
    super.key,
    required this.state,
    required this.locale,
    this.excludeFromSemantics = true,
  });

  final EvidenceVerdictPictogramState state;
  final String locale;
  final bool excludeFromSemantics;

  @override
  Widget build(BuildContext context) {
    final icon = EvidenceVerdictPictogramResolver.icon(state);
    final color = EvidenceVerdictPictogramResolver.accent(state);
    final line = ScamShieldStrings.t(
      EvidenceVerdictPictogramResolver.headlineKey(state),
      locale,
    );

    final content = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: state == EvidenceVerdictPictogramState.stop
                ? BoxShape.rectangle
                : BoxShape.circle,
            borderRadius: state == EvidenceVerdictPictogramState.stop
                ? BorderRadius.circular(AppSpacing.radiusSm)
                : null,
            border: Border.all(color: color, width: 2),
            color: color.withValues(alpha: 0.12),
          ),
          alignment: Alignment.center,
          child: Icon(icon, size: 32, color: color),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(
            line,
            style: AppTypography.subtitle.copyWith(color: color),
          ),
        ),
      ],
    );

    if (excludeFromSemantics) {
      return ExcludeSemantics(child: content);
    }
    return Semantics(
      label: EvidenceVerdictPictogramResolver.semanticsLabel(state, locale),
      child: content,
    );
  }
}
