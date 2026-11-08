abstract final class SensitiveSafetyLockConstants {
  /// Re-authenticate after this long in the background (Phase 34).
  static const backgroundReauthDuration = Duration(minutes: 2);

  static const prefsEnabledKey = 'ss_sensitive_safety_lock_enabled';
  static const prefsOfferShownKey = 'ss_sensitive_safety_lock_offer_shown';

  static const authReason = 'Unlock your safety records';
}
