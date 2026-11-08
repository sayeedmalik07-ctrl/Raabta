import 'package:scam_shield_core/features/scam_shield/domain/scam_attack_stage_engine.dart';
import 'package:scam_shield_core/features/scam_shield/domain/scam_incident_models.dart';
import 'package:scam_shield_core/features/scam_shield/domain/scam_sim_swap_models.dart';

/// Tri-state self-report answer — [notSure] is distinct from [no].
enum SimSwapTriStateAnswer {
  yes,
  no,
  notSure,
}

/// Four practical SIM/eSIM warning-sign questions (self-report only).
enum SimSwapSelfReportQuestion {
  suddenNetworkLoss,
  unexpectedSimMessage,
  communicationsStopped,
  behaviorChangedAfterRequest,
}

const simSwapSelfReportQuestions = SimSwapSelfReportQuestion.values;

extension SimSwapSelfReportQuestionX on SimSwapSelfReportQuestion {
  String get labelKey => switch (this) {
        SimSwapSelfReportQuestion.suddenNetworkLoss =>
          'ss_sim_q_sudden_network_loss',
        SimSwapSelfReportQuestion.unexpectedSimMessage =>
          'ss_sim_q_unexpected_sim_message',
        SimSwapSelfReportQuestion.communicationsStopped =>
          'ss_sim_q_communications_stopped',
        SimSwapSelfReportQuestion.behaviorChangedAfterRequest =>
          'ss_sim_q_behavior_changed',
      };

  static const ordered = simSwapSelfReportQuestions;
}

/// User-facing urgency derived from yes-count — not a numeric score.
enum SimSwapSelfReportUrgency {
  calm,
  review,
  promptAction,
}

extension SimSwapSelfReportUrgencyX on SimSwapSelfReportUrgency {
  String get summaryKey => switch (this) {
        SimSwapSelfReportUrgency.calm => 'ss_sim_result_calm',
        SimSwapSelfReportUrgency.review => 'ss_sim_result_review',
        SimSwapSelfReportUrgency.promptAction => 'ss_sim_result_prompt',
      };
}

/// Four tri-state answers for the SIM/eSIM safety check.
class SimSwapSelfReportAnswers {
  const SimSwapSelfReportAnswers({
    this.suddenNetworkLoss,
    this.unexpectedSimMessage,
    this.communicationsStopped,
    this.behaviorChangedAfterRequest,
  });

  const SimSwapSelfReportAnswers.empty() : this();

  final SimSwapTriStateAnswer? suddenNetworkLoss;
  final SimSwapTriStateAnswer? unexpectedSimMessage;
  final SimSwapTriStateAnswer? communicationsStopped;
  final SimSwapTriStateAnswer? behaviorChangedAfterRequest;

  SimSwapTriStateAnswer? answerFor(SimSwapSelfReportQuestion question) =>
      switch (question) {
        SimSwapSelfReportQuestion.suddenNetworkLoss => suddenNetworkLoss,
        SimSwapSelfReportQuestion.unexpectedSimMessage => unexpectedSimMessage,
        SimSwapSelfReportQuestion.communicationsStopped =>
          communicationsStopped,
        SimSwapSelfReportQuestion.behaviorChangedAfterRequest =>
          behaviorChangedAfterRequest,
      };

  SimSwapSelfReportAnswers withAnswer(
    SimSwapSelfReportQuestion question,
    SimSwapTriStateAnswer answer,
  ) {
    return switch (question) {
      SimSwapSelfReportQuestion.suddenNetworkLoss =>
        SimSwapSelfReportAnswers(
          suddenNetworkLoss: answer,
          unexpectedSimMessage: unexpectedSimMessage,
          communicationsStopped: communicationsStopped,
          behaviorChangedAfterRequest: behaviorChangedAfterRequest,
        ),
      SimSwapSelfReportQuestion.unexpectedSimMessage =>
        SimSwapSelfReportAnswers(
          suddenNetworkLoss: suddenNetworkLoss,
          unexpectedSimMessage: answer,
          communicationsStopped: communicationsStopped,
          behaviorChangedAfterRequest: behaviorChangedAfterRequest,
        ),
      SimSwapSelfReportQuestion.communicationsStopped =>
        SimSwapSelfReportAnswers(
          suddenNetworkLoss: suddenNetworkLoss,
          unexpectedSimMessage: unexpectedSimMessage,
          communicationsStopped: answer,
          behaviorChangedAfterRequest: behaviorChangedAfterRequest,
        ),
      SimSwapSelfReportQuestion.behaviorChangedAfterRequest =>
        SimSwapSelfReportAnswers(
          suddenNetworkLoss: suddenNetworkLoss,
          unexpectedSimMessage: unexpectedSimMessage,
          communicationsStopped: communicationsStopped,
          behaviorChangedAfterRequest: answer,
        ),
    };
  }

  int get yesCount => simSwapSelfReportQuestions
      .where((q) => answerFor(q) == SimSwapTriStateAnswer.yes)
      .length;

  bool get isComplete =>
      simSwapSelfReportQuestions.every((q) => answerFor(q) != null);

  bool get hasAnyAnswer =>
      simSwapSelfReportQuestions.any((q) => answerFor(q) != null);

  Iterable<MapEntry<SimSwapSelfReportQuestion, SimSwapTriStateAnswer>>
      get answeredEntries sync* {
    for (final question in simSwapSelfReportQuestions) {
      final answer = answerFor(question);
      if (answer != null) yield MapEntry(question, answer);
    }
  }

  Map<String, String> toJson() => {
        for (final question in simSwapSelfReportQuestions)
          question.name: answerFor(question)?.name ?? '',
      };

  factory SimSwapSelfReportAnswers.fromJson(Map<String, dynamic>? json) {
    if (json == null || json.isEmpty) return const SimSwapSelfReportAnswers.empty();
    SimSwapTriStateAnswer? parse(String? raw) {
      if (raw == null || raw.isEmpty) return null;
      return SimSwapTriStateAnswer.values.firstWhere(
        (e) => e.name == raw,
        orElse: () => SimSwapTriStateAnswer.no,
      );
    }

    return SimSwapSelfReportAnswers(
      suddenNetworkLoss: parse(json[SimSwapSelfReportQuestion.suddenNetworkLoss.name] as String?),
      unexpectedSimMessage: parse(json[SimSwapSelfReportQuestion.unexpectedSimMessage.name] as String?),
      communicationsStopped: parse(json[SimSwapSelfReportQuestion.communicationsStopped.name] as String?),
      behaviorChangedAfterRequest: parse(json[SimSwapSelfReportQuestion.behaviorChangedAfterRequest.name] as String?),
    );
  }
}

/// Pure mapping from self-report answers to existing [SimSwapSymptom] signals.
abstract final class SimSwapSelfReportMapper {
  static SimSwapSelfReportUrgency urgencyFor(int yesCount) {
    if (yesCount >= 2) return SimSwapSelfReportUrgency.promptAction;
    if (yesCount == 1) return SimSwapSelfReportUrgency.review;
    return SimSwapSelfReportUrgency.calm;
  }

  static Set<SimSwapSymptom> symptomsFromAnswers(
    SimSwapSelfReportAnswers answers,
  ) {
    final symptoms = <SimSwapSymptom>{};

    if (answers.suddenNetworkLoss == SimSwapTriStateAnswer.yes) {
      symptoms.add(SimSwapSymptom.noSignal);
    }
    if (answers.unexpectedSimMessage == SimSwapTriStateAnswer.yes) {
      symptoms
        ..add(SimSwapSymptom.simChangeDiscussed)
        ..add(SimSwapSymptom.esimChangeDiscussed);
    }
    if (answers.communicationsStopped == SimSwapTriStateAnswer.yes) {
      symptoms
        ..add(SimSwapSymptom.cannotReceiveSms)
        ..add(SimSwapSymptom.unexpectedOtp);
    }
    if (answers.behaviorChangedAfterRequest == SimSwapTriStateAnswer.yes) {
      symptoms
        ..add(SimSwapSymptom.accountLoginIssues)
        ..add(SimSwapSymptom.numberPortDiscussed);
    }

    return symptoms;
  }

  static SimSwapAnalyzerInput toAnalyzerInput({
    required SimSwapSelfReportAnswers answers,
    ScamQatarTelecomProvider provider = ScamQatarTelecomProvider.unknown,
    String? notes,
  }) {
    return SimSwapAnalyzerInput(
      provider: provider,
      symptoms: symptomsFromAnswers(answers),
      notes: notes,
      yesAnswerCount: answers.yesCount,
      selfReportAnswers: answers,
    );
  }

  /// Maps Yes answers to incident shared-data and outcome signals.
  static ({Set<ScamSharedDataCategory> shared, Set<ScamIncidentOutcome> outcomes})
      incidentSignalsFromAnswers(SimSwapSelfReportAnswers answers) {
    final shared = <ScamSharedDataCategory>{};
    final outcomes = <ScamIncidentOutcome>{};

    if (answers.unexpectedSimMessage == SimSwapTriStateAnswer.yes ||
        answers.behaviorChangedAfterRequest == SimSwapTriStateAnswer.yes) {
      shared.add(ScamSharedDataCategory.simEsimInfo);
    }
    if (answers.suddenNetworkLoss == SimSwapTriStateAnswer.yes ||
        answers.communicationsStopped == SimSwapTriStateAnswer.yes) {
      outcomes.add(ScamIncidentOutcome.simPhoneStopped);
    }
    if (answers.communicationsStopped == SimSwapTriStateAnswer.yes) {
      shared.add(ScamSharedDataCategory.otp);
      outcomes.add(ScamIncidentOutcome.unexpectedOtp);
    }
    if (answers.behaviorChangedAfterRequest == SimSwapTriStateAnswer.yes) {
      outcomes.add(ScamIncidentOutcome.accountLocked);
    }

    return (shared: shared, outcomes: outcomes);
  }

  /// Merges optional SIM self-report into an incident submission input.
  ///
  /// Yes answers add shared/outcome signals. No and Not sure add nothing.
  /// Answers are preserved on the input for history either way.
  static ScamIncidentInput mergeIntoIncidentInput({
    required ScamIncidentInput base,
    SimSwapSelfReportAnswers? simAnswers,
  }) {
    if (simAnswers == null || !simAnswers.hasAnyAnswer) {
      return base;
    }

    final signals = incidentSignalsFromAnswers(simAnswers);
    final mergedShared = {...base.sharedData, ...signals.shared};
    var mergedOutcomes = {...base.outcomes, ...signals.outcomes};

    if (mergedOutcomes.contains(ScamIncidentOutcome.nothingYet) &&
        mergedOutcomes.length > 1) {
      mergedOutcomes = {...mergedOutcomes}..remove(ScamIncidentOutcome.nothingYet);
    }

    return ScamIncidentInput(
      impersonationCategory: base.impersonationCategory,
      contactChannels: base.contactChannels,
      timing: base.timing,
      occurredAt: base.occurredAt,
      sharedData: mergedShared,
      outcomes: mergedOutcomes.isEmpty
          ? base.outcomes
          : mergedOutcomes,
      freeTextNotes: base.freeTextNotes,
      evidenceStatus: base.evidenceStatus,
      simSelfReportAnswers: simAnswers,
    );
  }
}

/// Shared 2+ Yes escalation — used by standalone SIM analyzer and incident assess.
abstract final class SimSwapSelfReportEscalation {
  static ScamIncidentResponseLevel bumpResponseLevel(
    ScamIncidentResponseLevel level,
    int yesCount,
  ) {
    if (yesCount < 2) return level;
    const order = ScamIncidentResponseLevel.values;
    final index = order.indexOf(level);
    if (index < 0 || index >= order.length - 1) return level;
    return order[index + 1];
  }

  static ScamResponsePriority bumpPriority(
    ScamResponsePriority priority,
    int yesCount,
  ) {
    if (yesCount < 2) return priority;
    const order = ScamResponsePriority.values;
    final index = order.indexOf(priority);
    if (index < 0 || index >= order.length - 1) return priority;
    return order[index + 1];
  }

  static ScamIncidentAssessmentResult applyToIncidentResult(
    ScamIncidentAssessmentResult result,
    int yesCount,
  ) {
    if (yesCount < 2) return result;

    final bumpedPriority = bumpPriority(result.responsePriority, yesCount);
    final bumpedLevel = bumpResponseLevel(result.responseLevel, yesCount);

    return ScamIncidentAssessmentResult(
      stage: result.stage,
      responsePriority: bumpedPriority,
      responseLevel: bumpedLevel,
      compoundRisk: result.compoundRisk,
      checklistActionKeys: ScamAttackStageEngine.checklistKeysFor(bumpedLevel),
      stageSummaryKeys: result.stageSummaryKeys,
      chainConfidence: result.chainConfidence,
      confidenceBand: result.confidenceBand,
      evidenceStatus: result.evidenceStatus,
      safeVerificationKeys: result.safeVerificationKeys,
      chainNarrative: result.chainNarrative,
      incidentGroupId: result.incidentGroupId,
    );
  }
}
