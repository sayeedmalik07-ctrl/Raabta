import 'package:raabta/features/scam_shield/domain/scam_incident_models.dart';

/// Ordered Academy checkpoints — must stay aligned with [ScamAttackStage].
abstract final class ScamShieldAcademyConfig {
  /// One educational checkpoint per live engine stage (same order as enum).
  static const stageCheckpoints = ScamAttackStage.values;

  /// Meta checkpoint after stages — deep-links only, not a [ScamAttackStage].
  static const actionCheckpointId = 'take_action';

  static const impersonationCategories = ScamImpersonationCategory.values;
}
