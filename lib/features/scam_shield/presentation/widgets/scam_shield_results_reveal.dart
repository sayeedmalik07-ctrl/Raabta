import 'package:flutter/material.dart';
import 'package:raabta/features/scam_shield/domain/scam_message_sender_type.dart';
import 'package:raabta/features/scam_shield/domain/scam_shield_models.dart';
import 'package:raabta/features/scam_shield/presentation/widgets/scam_shield_assessment_results_view.dart';
import 'package:raabta/features/scam_shield/presentation/widgets/scam_shield_primitives.dart';

/// Results with entrance motion and haptic on elevated risk.
class ScamShieldResultsReveal extends StatefulWidget {
  const ScamShieldResultsReveal({
    super.key,
    required this.result,
    required this.locale,
    required this.maskedInput,
    required this.sourceText,
    this.senderType = ScamMessageSenderType.notSure,
    this.onLegitimateTap,
  });

  final ScamShieldAssessmentResult result;
  final String locale;
  final String maskedInput;
  final String sourceText;
  final ScamMessageSenderType senderType;
  final VoidCallback? onLegitimateTap;

  @override
  State<ScamShieldResultsReveal> createState() => _ScamShieldResultsRevealState();
}

class _ScamShieldResultsRevealState extends State<ScamShieldResultsReveal> {
  @override
  void initState() {
    super.initState();
    if (widget.result.overallRisk == ScamShieldRiskLevel.high ||
        widget.result.scanAnalysis.stop.triggered) {
      scamShieldMediumHaptic();
    } else {
      scamShieldLightHaptic();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScamShieldEntranceReveal(
      child: ScamShieldAssessmentResultsView(
        result: widget.result,
        locale: widget.locale,
        maskedInput: widget.maskedInput,
        sourceText: widget.sourceText,
        senderType: widget.senderType,
        onLegitimateTap: widget.onLegitimateTap,
      ),
    );
  }
}
