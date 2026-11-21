import 'package:raabta/features/scam_shield/domain/scam_incident_models.dart';
import 'package:raabta/features/scam_shield/domain/scam_shield_academy_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Local Academy progress only — never touches incident/scan history.
class ScamShieldAcademyProgressRepository {
  static const _actionDoneKey = 'ss_academy_done_take_action';

  Future<Set<String>> loadCompletedIds() async {
    final prefs = await SharedPreferences.getInstance();
    final ids = <String>{};
    for (final stage in ScamShieldAcademyConfig.stageCheckpoints) {
      if (prefs.getBool(_keyForStage(stage)) ?? false) {
        ids.add(stage.name);
      }
    }
    if (prefs.getBool(_actionDoneKey) ?? false) {
      ids.add(ScamShieldAcademyConfig.actionCheckpointId);
    }
    return ids;
  }

  Future<void> markStageRead(ScamAttackStage stage) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyForStage(stage), true);
  }

  Future<void> markActionPanelRead() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_actionDoneKey, true);
  }

  static String _keyForStage(ScamAttackStage stage) =>
      'ss_academy_done_${stage.name}';
}
