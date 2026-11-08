import 'package:raabta/features/scam_shield/forewarnings/forewarning_models.dart';
import 'package:raabta/features/scam_shield/forewarnings/forewarning_moment_id.dart';
import 'package:raabta/features/scam_shield/forewarnings/forewarning_session.dart';

/// Spaced refresher + dismissal snooze — pure, unit-tested.
abstract final class ForewarningPolicy {
  static const refreshWindowDays = 21;
  static const dismissSnoozeDays = 90;
  static const dismissSnoozeThreshold = 3;

  static bool shouldShow({
    required ForewarningMomentId momentId,
    required ForewarningMomentState state,
    required DateTime now,
    required bool tipsEnabled,
    required bool complianceAllows,
  }) {
    if (!tipsEnabled || !complianceAllows) return false;
    if (ForewarningSession.hasShownThisSession) return false;
    if (state.snoozedUntil != null && now.isBefore(state.snoozedUntil!)) {
      return false;
    }
    if (state.lastShown != null) {
      final days = now.difference(state.lastShown!).inDays;
      if (days < refreshWindowDays) return false;
    }
    return true;
  }

  static int pickVariantIndex({
    required int variantCount,
    required int lastVariantIndex,
  }) {
    if (variantCount <= 0) return 0;
    if (variantCount == 1) return 0;
    var next = (lastVariantIndex + 1) % variantCount;
    if (next == lastVariantIndex) {
      next = (next + 1) % variantCount;
    }
    return next;
  }

  static ForewarningMomentState recordShown({
    required ForewarningMomentState state,
    required DateTime now,
    required int variantIndex,
  }) {
    ForewarningSession.markShown();
    return state.copyWith(
      lastShown: now,
      shownCount: state.shownCount + 1,
      lastVariantIndex: variantIndex,
    );
  }

  static ForewarningMomentState recordDismiss({
    required ForewarningMomentState state,
    required DateTime now,
  }) {
    final dismissCount = state.dismissCount + 1;
    final snooze = dismissCount >= dismissSnoozeThreshold
        ? now.add(const Duration(days: dismissSnoozeDays))
        : state.snoozedUntil;
    return state.copyWith(
      dismissCount: dismissCount,
      snoozedUntil: snooze,
    );
  }
}
