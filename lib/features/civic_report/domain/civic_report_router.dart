import 'package:raabta/features/civic_report/domain/civic_issue_taxonomy.dart';
import 'package:raabta/features/civic_report/domain/civic_report_route_decision.dart';

/// Deterministic routing for Report It Right — delegates to existing Raabta flows.
abstract final class CivicReportRouter {
  static const eosbLabourRoute = '/eosb/warnings';
  static const climateNavigatorRoute = '/climate-navigator';
  static const scamShieldIncidentRoute = '/scam-shield/incident';
  static const emergencyRoute = '/trip-planner/emergency';
  static const tenancyRoute = '/tenancy';
  static const consumerComplaintRoute = '/consumer-complaint';

  static CivicReportRouteDecision decide(CivicIssueTypeId issue) {
    switch (issue) {
      case CivicIssueTypeId.labourEmployerDispute:
        return CivicReportRouteDecision.delegate(
          issue: issue,
          routePath: eosbLabourRoute,
          explanationKey: 'civic_outcome_delegate_eosb',
        );
      case CivicIssueTypeId.heatOutdoorWork:
        return CivicReportRouteDecision.delegate(
          issue: issue,
          routePath: climateNavigatorRoute,
          explanationKey: 'civic_outcome_delegate_climate',
        );
      case CivicIssueTypeId.scamFraudCyber:
        return CivicReportRouteDecision.delegate(
          issue: issue,
          routePath: scamShieldIncidentRoute,
          explanationKey: 'civic_outcome_delegate_scam',
        );
      case CivicIssueTypeId.immediateDanger:
        return CivicReportRouteDecision.delegate(
          issue: issue,
          routePath: emergencyRoute,
          explanationKey: 'civic_outcome_delegate_emergency',
        );
      case CivicIssueTypeId.tenancyLeaseDeposit:
        return CivicReportRouteDecision.delegate(
          issue: issue,
          routePath: tenancyRoute,
          explanationKey: 'civic_outcome_delegate_tenancy',
        );
      case CivicIssueTypeId.consumerDispute:
        return CivicReportRouteDecision.delegate(
          issue: issue,
          routePath: consumerComplaintRoute,
          explanationKey: 'civic_outcome_delegate_consumer',
        );
      case CivicIssueTypeId.otherUnsure:
        return const CivicReportRouteDecision.chooseCategory();
      case CivicIssueTypeId.streetLighting:
      case CivicIssueTypeId.roadDamage:
      case CivicIssueTypeId.drainageSewage:
      case CivicIssueTypeId.waterLeakSupply:
      case CivicIssueTypeId.electricityFault:
      case CivicIssueTypeId.pests:
      case CivicIssueTypeId.abandonedVehicle:
      case CivicIssueTypeId.wasteCollection:
      case CivicIssueTypeId.workersAccommodationSanitation:
        return CivicReportRouteDecision.registry(issue: issue);
    }
  }
}
