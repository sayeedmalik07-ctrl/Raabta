import 'package:raabta/features/case_timeline/domain/case_timeline_engine_type.dart';

/// Builds navigation paths and resolves case ids per Truth Engine.
abstract final class CaseTimelineNavigation {
  static String routePath({
    required CaseTimelineEngineType engine,
    required String caseId,
  }) {
    return '/case-timeline/${engine.storageValue}/$caseId';
  }

  static String eosbCaseIdFromCalculatedAt(DateTime calculatedAt) =>
      calculatedAt.millisecondsSinceEpoch.toString();

  static String tenancyCaseIdFromCheckedAt(DateTime checkedAt) =>
      checkedAt.millisecondsSinceEpoch.toString();

  static String sponsorshipCaseIdFromCheckedAt(DateTime checkedAt) =>
      checkedAt.millisecondsSinceEpoch.toString();

  static String healthDenialCaseId(String baseCaseId) => 'denial_$baseCaseId';
}
