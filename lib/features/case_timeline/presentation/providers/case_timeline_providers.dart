import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/features/case_timeline/data/case_timeline_repository.dart';
import 'package:raabta/features/case_timeline/domain/case_timeline_engine_type.dart';
import 'package:raabta/features/case_timeline/domain/case_timeline_entry.dart';
import 'package:raabta/features/case_timeline/services/case_timeline_service.dart';
import 'package:raabta/features/case_timeline/services/case_timeline_summary_service.dart';
import 'package:raabta/providers/auth_providers.dart';
import 'package:raabta/services/ai/claude_ai_service.dart';

final caseTimelineRepositoryProvider = Provider<CaseTimelineRepository>(
  (ref) => CaseTimelineRepository(),
);

final caseTimelineServiceProvider = Provider<CaseTimelineService>(
  (ref) => CaseTimelineService(
    repository: ref.watch(caseTimelineRepositoryProvider),
  ),
);

final caseTimelineSummaryServiceProvider =
    Provider<CaseTimelineSummaryService>(
  (ref) => CaseTimelineSummaryService(ref.watch(claudeAIServiceProvider)),
);

typedef CaseTimelineScope = ({
  CaseTimelineEngineType engine,
  String caseId,
});

final caseTimelineEntriesProvider = StreamProvider.family<
    List<CaseTimelineEntry>,
    CaseTimelineScope>((ref, scope) {
  final uid = ref.watch(currentUserProvider)?.uid;
  if (uid == null || uid.isEmpty || scope.caseId.isEmpty) {
    return Stream.value(const []);
  }
  return ref.watch(caseTimelineServiceProvider).watchForCase(
        userId: uid,
        engineType: scope.engine,
        caseId: scope.caseId,
      );
});
