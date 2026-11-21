import 'package:raabta/features/case_timeline/domain/case_timeline_checklist_item.dart';
import 'package:raabta/features/case_timeline/domain/case_timeline_entry.dart';

class CaseTimelineGapItem {
  const CaseTimelineGapItem({
    required this.def,
    required this.covered,
  });

  final CaseTimelineChecklistItemDef def;
  final bool covered;
}

/// Deterministic set-difference against an engine's hardcoded checklist.
abstract final class CaseTimelineGapAnalyzer {
  static List<CaseTimelineGapItem> analyze({
    required List<CaseTimelineChecklistItemDef> checklist,
    required List<CaseTimelineEntry> entries,
  }) {
    final coveredIds = entries
        .map((e) => e.checklistItemId)
        .whereType<String>()
        .where((id) => id.isNotEmpty)
        .toSet();

    return checklist
        .map(
          (def) => CaseTimelineGapItem(
            def: def,
            covered: coveredIds.contains(def.id),
          ),
        )
        .toList();
  }

  static Set<String> coveredChecklistIds(List<CaseTimelineEntry> entries) {
    return entries
        .map((e) => e.checklistItemId)
        .whereType<String>()
        .where((id) => id.isNotEmpty)
        .toSet();
  }
}
