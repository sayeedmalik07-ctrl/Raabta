import 'package:raabta/features/scam_shield/domain/scam_shield_models.dart';

/// Home anchor / cross-feature alert surface — calm vs elevated only.
enum ScamShieldActiveAlertLevel { calm, elevated }

class ScamShieldActiveAlertState {
  const ScamShieldActiveAlertState({
    required this.level,
    this.displaySeverity = ScamShieldRiskLevel.low,
    this.unacknowledgedCount = 0,
  });

  const ScamShieldActiveAlertState.calm()
      : level = ScamShieldActiveAlertLevel.calm,
        displaySeverity = ScamShieldRiskLevel.low,
        unacknowledgedCount = 0;

  final ScamShieldActiveAlertLevel level;
  final ScamShieldRiskLevel displaySeverity;
  final int unacknowledgedCount;

  bool get isElevated => level == ScamShieldActiveAlertLevel.elevated;
}
