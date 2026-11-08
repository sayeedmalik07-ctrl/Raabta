import 'package:raabta/features/concierge_90_day/data/models/journey_milestone.dart';
import 'package:raabta/features/concierge_90_day/data/models/journey_progress.dart';

class ConciergeTimelineSnapshot {
  const ConciergeTimelineSnapshot({
    required this.dayOnTimeline,
    required this.currentPhase,
    required this.nextMilestone,
    required this.visibleMilestones,
    required this.completedCount,
    required this.actionableCount,
  });

  final int dayOnTimeline;
  final ConciergePhase currentPhase;
  final JourneyMilestone? nextMilestone;
  final List<JourneyMilestone> visibleMilestones;
  final int completedCount;
  final int actionableCount;
}

/// Calculates day-based stage from arrival or account-creation anchor.
class ConciergeTimelineService {
  const ConciergeTimelineService();

  static const journeyLengthDays = 90;

  int dayOnTimeline(JourneyProgress progress, {DateTime? now}) {
    final anchor = progress.timelineAnchor;
    if (anchor == null) return 1;
    final today = now ?? DateTime.now();
    final days = today.difference(DateTime(
      anchor.year,
      anchor.month,
      anchor.day,
    )).inDays;
    return (days + 1).clamp(1, journeyLengthDays);
  }

  ConciergePhase phaseForDay(int day) {
    if (day <= 3) return ConciergePhase.getOriented;
    if (day <= 7) return ConciergePhase.paperwork;
    if (day <= 14) return ConciergePhase.moneyBasics;
    if (day <= 30) return ConciergePhase.dailyLife;
    if (day <= 45) return ConciergePhase.settlingSpace;
    if (day <= 60) return ConciergePhase.communityExplore;
    return ConciergePhase.knowYourRights;
  }

  String phaseLabelKey(ConciergePhase phase) => switch (phase) {
        ConciergePhase.getOriented => 'concierge_phase_oriented',
        ConciergePhase.paperwork => 'concierge_phase_paperwork',
        ConciergePhase.moneyBasics => 'concierge_phase_money',
        ConciergePhase.dailyLife => 'concierge_phase_daily',
        ConciergePhase.settlingSpace => 'concierge_phase_housing',
        ConciergePhase.communityExplore => 'concierge_phase_community',
        ConciergePhase.knowYourRights => 'concierge_phase_rights',
      };

  bool isMilestoneVisible(JourneyMilestone milestone, int day) =>
      day >= milestone.dayStart;

  bool isMilestoneActionable(JourneyProgress progress, JourneyMilestone m) {
    final status = progress.statusFor(m.id);
    if (status == MilestoneStatus.completed ||
        status == MilestoneStatus.notApplicable) {
      return false;
    }
    return true;
  }

  JourneyMilestone? nextSuggestedMilestone(
    JourneyProgress progress, {
    DateTime? now,
  }) {
    if (progress.conciergeDisabled || progress.journeyCompleted) return null;
    final day = dayOnTimeline(progress, now: now);
    for (final m in JourneyMilestoneCatalog.all) {
      if (!isMilestoneVisible(m, day)) continue;
      if (isMilestoneActionable(progress, m)) return m;
    }
    return null;
  }

  ConciergeTimelineSnapshot buildSnapshot(
    JourneyProgress progress, {
    DateTime? now,
  }) {
    final day = dayOnTimeline(progress, now: now);
    final phase = phaseForDay(day);
    final visible = JourneyMilestoneCatalog.all
        .where((m) => isMilestoneVisible(m, day))
        .toList();
    var completed = 0;
    var actionable = 0;
    for (final m in visible) {
      final s = progress.statusFor(m.id);
      if (s == MilestoneStatus.completed) completed++;
      if (s == MilestoneStatus.pending) actionable++;
    }
    return ConciergeTimelineSnapshot(
      dayOnTimeline: day,
      currentPhase: phase,
      nextMilestone: nextSuggestedMilestone(progress, now: now),
      visibleMilestones: visible,
      completedCount: completed,
      actionableCount: actionable,
    );
  }

  bool isJourneyComplete(JourneyProgress progress, {DateTime? now}) {
    final day = dayOnTimeline(progress, now: now);
    if (day >= journeyLengthDays) return true;
    final visible = JourneyMilestoneCatalog.all
        .where((m) => isMilestoneVisible(m, day));
    return visible.every((m) {
      final s = progress.statusFor(m.id);
      return s == MilestoneStatus.completed ||
          s == MilestoneStatus.notApplicable;
    });
  }
}
