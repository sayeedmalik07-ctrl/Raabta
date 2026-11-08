import 'package:raabta/features/scam_shield/family_kit/family_verification_models.dart';

class FamilyScenarioStep {
  const FamilyScenarioStep({
    required this.nodeId,
    required this.narrativeKey,
    required this.choices,
    this.isSuccess = false,
  });

  final FamilyScenarioNodeId nodeId;
  final String narrativeKey;
  final List<FamilyScenarioChoice> choices;
  final bool isSuccess;
}

class FamilyScenarioChoice {
  const FamilyScenarioChoice({
    required this.id,
    required this.labelKey,
    required this.nextNodeId,
    this.isCorrect = false,
  });

  final FamilyScenarioChoiceId id;
  final String labelKey;
  final FamilyScenarioNodeId? nextNodeId;
  final bool isCorrect;
}

abstract final class FamilyVerificationScenario {
  static FamilyScenarioStep step(FamilyScenarioNodeId nodeId) {
    return switch (nodeId) {
      FamilyScenarioNodeId.start => const FamilyScenarioStep(
          nodeId: FamilyScenarioNodeId.start,
          narrativeKey: 'ss_fvk_scenario_start',
          choices: [
            FamilyScenarioChoice(
              id: FamilyScenarioChoiceId.sendMoney,
              labelKey: 'ss_fvk_scenario_choice_send',
              nextNodeId: null,
            ),
            FamilyScenarioChoice(
              id: FamilyScenarioChoiceId.stayOnLine,
              labelKey: 'ss_fvk_scenario_choice_stay',
              nextNodeId: null,
            ),
            FamilyScenarioChoice(
              id: FamilyScenarioChoiceId.hangUp,
              labelKey: 'ss_fvk_scenario_choice_hangup',
              nextNodeId: FamilyScenarioNodeId.afterHangUp,
              isCorrect: true,
            ),
          ],
        ),
      FamilyScenarioNodeId.afterHangUp => const FamilyScenarioStep(
          nodeId: FamilyScenarioNodeId.afterHangUp,
          narrativeKey: 'ss_fvk_scenario_after_hangup',
          choices: [
            FamilyScenarioChoice(
              id: FamilyScenarioChoiceId.textBack,
              labelKey: 'ss_fvk_scenario_choice_text',
              nextNodeId: null,
            ),
            FamilyScenarioChoice(
              id: FamilyScenarioChoiceId.callKnownNumber,
              labelKey: 'ss_fvk_scenario_choice_call_known',
              nextNodeId: FamilyScenarioNodeId.afterCallBack,
              isCorrect: true,
            ),
          ],
        ),
      FamilyScenarioNodeId.afterCallBack => const FamilyScenarioStep(
          nodeId: FamilyScenarioNodeId.afterCallBack,
          narrativeKey: 'ss_fvk_scenario_after_callback',
          choices: [
            FamilyScenarioChoice(
              id: FamilyScenarioChoiceId.skipWordSend,
              labelKey: 'ss_fvk_scenario_choice_skip_word',
              nextNodeId: null,
            ),
            FamilyScenarioChoice(
              id: FamilyScenarioChoiceId.askSecretWord,
              labelKey: 'ss_fvk_scenario_choice_ask_word',
              nextNodeId: FamilyScenarioNodeId.complete,
              isCorrect: true,
            ),
          ],
        ),
      FamilyScenarioNodeId.complete => const FamilyScenarioStep(
          nodeId: FamilyScenarioNodeId.complete,
          narrativeKey: 'ss_fvk_scenario_complete',
          choices: [],
          isSuccess: true,
        ),
    };
  }

  static String feedbackKey(FamilyScenarioChoice choice) {
    if (choice.isCorrect) return 'ss_fvk_scenario_feedback_good';
    return switch (choice.id) {
      FamilyScenarioChoiceId.sendMoney => 'ss_fvk_scenario_feedback_send',
      FamilyScenarioChoiceId.stayOnLine => 'ss_fvk_scenario_feedback_stay',
      FamilyScenarioChoiceId.textBack => 'ss_fvk_scenario_feedback_text',
      FamilyScenarioChoiceId.skipWordSend => 'ss_fvk_scenario_feedback_skip',
      _ => 'ss_fvk_scenario_feedback_generic',
    };
  }
}
