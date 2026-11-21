import 'package:raabta/features/know_qatar/data/models/know_qatar_moment_models.dart';
import 'package:raabta/features/know_qatar/data/models/know_qatar_persona.dart';
import 'package:raabta/features/know_qatar/domain/services/know_qatar_moments_service.dart';
import 'package:raabta/models/visa_models.dart';

/// Deterministic Next Step — at most one recommendation; no network, no AI.
abstract final class NextStepResolver {
  static const dismissDurationDays = 7;

  static NextStepRecommendation? resolve({
    required List<DocumentDeadline> deadlines,
    required KnowQatarPersona persona,
    required KnowQatarMomentId activeMomentId,
    required Set<String> publishedSectionKeys,
    required String? lastOpenedDestinationKey,
    required int? nextStepHiddenUntilMs,
    required int nowMs,
  }) {
    if (_isDismissed(nextStepHiddenUntilMs, nowMs)) return null;

    final deadlineStep = _deadlineStep(deadlines);
    if (deadlineStep != null) return deadlineStep;

    final momentStep = _momentStep(
      persona: persona,
      activeMomentId: activeMomentId,
      publishedSectionKeys: publishedSectionKeys,
    );
    if (momentStep != null) return momentStep;

    if (lastOpenedDestinationKey != null &&
        lastOpenedDestinationKey.trim().isNotEmpty) {
      final resume = _destinationStep(
        destinationKey: lastOpenedDestinationKey,
        publishedSectionKeys: publishedSectionKeys,
        kind: NextStepKind.lastOpened,
      );
      if (resume != null) return resume;
    }

    return _genericFallback();
  }

  static bool _isDismissed(int? hiddenUntilMs, int nowMs) {
    if (hiddenUntilMs == null || hiddenUntilMs <= 0) return false;
    return nowMs < hiddenUntilMs;
  }

  static NextStepRecommendation? _deadlineStep(List<DocumentDeadline> deadlines) {
    if (deadlines.isEmpty) return null;

    final actionable = deadlines.where((d) => d.daysRemaining < 90).toList();
    if (actionable.isEmpty) return null;

    actionable.sort((a, b) {
      final aExpired = a.daysRemaining < 0;
      final bExpired = b.daysRemaining < 0;
      if (aExpired != bExpired) return aExpired ? -1 : 1;
      if (aExpired && bExpired) {
        return a.daysRemaining.compareTo(b.daysRemaining);
      }
      return a.daysRemaining.compareTo(b.daysRemaining);
    });

    final pick = actionable.first;
    final severity = _severityForDays(pick.daysRemaining);
    return NextStepRecommendation(
      kind: NextStepKind.deadline,
      route: '/visa?deadlineId=${Uri.encodeComponent(pick.id)}',
      titleKey: pick.daysRemaining < 0
          ? 'kq_next_step_deadline_expired'
          : 'kq_next_step_deadline_soon',
      titleParams: {'document': pick.notificationDocumentLabel},
      actionKey: 'kq_next_step_action_open_tracker',
      severity: severity,
      useDeadlineExpiryLabel: true,
    );
  }

  static NextStepSeverity _severityForDays(int days) {
    if (days < 0 || days < 30) return NextStepSeverity.critical;
    if (days <= 90) return NextStepSeverity.amber;
    return NextStepSeverity.neutral;
  }

  static NextStepRecommendation? _momentStep({
    required KnowQatarPersona persona,
    required KnowQatarMomentId activeMomentId,
    required Set<String> publishedSectionKeys,
  }) {
    if (activeMomentId == KnowQatarMomentId.allTopics) {
      return null;
    }
    final momentId = activeMomentId;

    final items = KnowQatarMomentsService.resolveMomentItems(
      momentId: momentId,
      publishedSectionKeys: publishedSectionKeys,
    );
    if (items.isEmpty) return null;

    final first = items.first;
    return NextStepRecommendation(
      kind: NextStepKind.momentItem,
      route: first.route,
      titleKey: 'kq_next_step_moment_item',
      titleParams: {'title': first.titleKey},
      actionKey: 'kq_next_step_action_open',
      severity: NextStepSeverity.neutral,
    );
  }

  static NextStepRecommendation? _destinationStep({
    required String destinationKey,
    required Set<String> publishedSectionKeys,
    required NextStepKind kind,
  }) {
    final item = KnowQatarMomentsService.resolveDestination(
      destinationKey: destinationKey,
      publishedSectionKeys: publishedSectionKeys,
    );
    if (item == null) return null;

    return NextStepRecommendation(
      kind: kind,
      route: item.route,
      titleKey: kind == NextStepKind.lastOpened
          ? 'kq_next_step_continue'
          : 'kq_next_step_moment_item',
      titleParams: {'title': item.titleKey},
      actionKey: 'kq_next_step_action_open',
      severity: NextStepSeverity.neutral,
    );
  }

  static NextStepRecommendation _genericFallback() {
    return const NextStepRecommendation(
      kind: NextStepKind.genericFallback,
      route: '/visa',
      titleKey: 'kq_next_step_fallback_tracker',
      actionKey: 'kq_next_step_action_setup_tracker',
      severity: NextStepSeverity.neutral,
    );
  }
}
