import 'package:raabta/features/scam_shield/checkup/scam_checkup_models.dart';

abstract final class ScamCheckupRecheckBannerLogic {
  static const reviewIntervalDays = 180;
  static const dismissCooldownDays = 30;

  static bool shouldShowHubBanner({
    required ScamCheckupState state,
    required DateTime now,
  }) {
    final last = state.lastReviewAt;
    if (last == null) return false;
    if (now.difference(last).inDays < reviewIntervalDays) return false;
    final dismissed = state.recheckBannerDismissedAt;
    if (dismissed != null &&
        now.difference(dismissed).inDays < dismissCooldownDays) {
      return false;
    }
    return true;
  }
}
