import 'package:raabta/features/civic_report/domain/civic_issue_taxonomy.dart';

enum CivicReportOutcomeKind {
  delegateExistingRoute,
  registryChannels,
  manualTemplate,
  chooseCategory,
}

class CivicReportRouteDecision {
  const CivicReportRouteDecision._({
    required this.kind,
    required this.issue,
    this.routePath,
    required this.explanationKey,
  });

  const CivicReportRouteDecision.delegate({
    required CivicIssueTypeId issue,
    required String routePath,
    required String explanationKey,
  }) : this._(
          kind: CivicReportOutcomeKind.delegateExistingRoute,
          issue: issue,
          routePath: routePath,
          explanationKey: explanationKey,
        );

  const CivicReportRouteDecision.registry({
    required CivicIssueTypeId issue,
  }) : this._(
          kind: CivicReportOutcomeKind.registryChannels,
          issue: issue,
          explanationKey: 'civic_outcome_registry_intro',
        );

  const CivicReportRouteDecision.manual({
    required CivicIssueTypeId issue,
    String explanationKey = 'civic_outcome_manual_intro',
  }) : this._(
          kind: CivicReportOutcomeKind.manualTemplate,
          issue: issue,
          explanationKey: explanationKey,
        );

  const CivicReportRouteDecision.chooseCategory()
      : this._(
          kind: CivicReportOutcomeKind.chooseCategory,
          issue: CivicIssueTypeId.otherUnsure,
          explanationKey: 'civic_outcome_other_unsure',
        );

  final CivicReportOutcomeKind kind;
  final CivicIssueTypeId issue;
  final String? routePath;
  final String explanationKey;
}
