import 'package:raabta/features/home/domain/truth_chip_status.dart';
import 'package:raabta/models/visa_models.dart';
import 'package:raabta/services/legal_deadline_service.dart';

/// Shared day-count bands for Truth Engine Home chips.
///
/// Must stay aligned with existing engine sources — do not change legal math here.
abstract final class TruthChipUrgencyThresholds {
  TruthChipUrgencyThresholds._();

  /// Saved engine data older than this (calendar days) → chip [TruthChipState.stale].
  static const int staleDataAgeDays = 90;

  // --- Visa / document deadline tracker (DocumentDeadline.urgency) ---
  // red: days < 30; amber: 30–90 inclusive; green: > 90

  static const int documentRedBelowDays = 30;
  static const int documentAmberThroughDays = 90;

  /// Mirrors [DocumentDeadline.urgency] for a precomputed [daysRemaining].
  static DeadlineUrgency documentUrgencyForDaysRemaining(int daysRemaining) {
    if (daysRemaining < documentRedBelowDays) return DeadlineUrgency.red;
    if (daysRemaining <= documentAmberThroughDays) {
      return DeadlineUrgency.amber;
    }
    return DeadlineUrgency.green;
  }

  /// Maps document tracker bands to Truth chip surface tone (pills / bar accent).
  static TruthChipTone toneForDocumentUrgency(DeadlineUrgency urgency) {
    return switch (urgency) {
      DeadlineUrgency.red => TruthChipTone.red,
      DeadlineUrgency.amber => TruthChipTone.amber,
      DeadlineUrgency.green => TruthChipTone.ok,
    };
  }

  // --- Truth-engine legal deadlines (LegalDeadlineService.urgencyForDaysRemaining) ---
  // expired: < 0; urgent: ≤ 14; approaching: ≤ 60; informational: > 60

  static LegalDeadlineUrgency legalUrgencyForDaysRemaining(int daysRemaining) {
    return LegalDeadlineService.urgencyForDaysRemaining(daysRemaining);
  }

  static TruthChipTone toneForLegalUrgency(LegalDeadlineUrgency urgency) {
    return switch (urgency) {
      LegalDeadlineUrgency.expired => TruthChipTone.red,
      LegalDeadlineUrgency.urgent => TruthChipTone.red,
      LegalDeadlineUrgency.approaching => TruthChipTone.amber,
      LegalDeadlineUrgency.informational => TruthChipTone.ok,
    };
  }

  /// Calendar days between [anchor] and [now] (date-only), for stale checks.
  static int calendarAgeInDays({
    required DateTime anchor,
    required DateTime now,
  }) {
    final a = DateTime(anchor.year, anchor.month, anchor.day);
    final n = DateTime(now.year, now.month, now.day);
    return n.difference(a).inDays;
  }

  static bool isStale({
    required DateTime? lastSavedAt,
    required DateTime now,
  }) {
    if (lastSavedAt == null) return false;
    return calendarAgeInDays(anchor: lastSavedAt, now: now) >
        staleDataAgeDays;
  }
}
