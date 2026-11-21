/// Central monetization mode — single switch point for HOLD vs future ACTIVE.
///
/// Activation path (when product is ready):
/// 1. Set [MonetizationConfig.kPremiumTierEnabled] to true
/// 2. Set [monetizationMode] to [MonetizationMode.active]
/// 3. Set [paymentsEnabled] to true
/// 4. Set product states ([premium], [pro], [boost], [businessAdvertising]) to
///    [MonetizationProductState.active]
/// 5. Set [_referralPremiumRewardsWhenActive] to true if referral Premium grants return
/// 6. Mirror the same flags in [services/monetizationHold.js] on the Node backend
library;

import 'package:raabta/config/monetization_config.dart';

/// App-wide monetization lifecycle.
enum MonetizationMode {
  /// Paid products visible as Coming Soon; payments and entitlements disabled.
  hold,

  /// Payments and entitlements follow product state flags.
  active,
}

/// Per-product availability.
enum MonetizationProductState {
  active,
  comingSoon,
  hidden,
}

/// Authoritative client-side monetization configuration.
abstract final class MonetizationState {
  MonetizationState._();

  // ─── Toggle here for future activation ───────────────────────────────────
  static const monetizationMode = MonetizationMode.hold;
  static const paymentsEnabled = false;
  static const _referralPremiumRewardsWhenActive = false;

  /// Routes that must not be reachable when [MonetizationConfig.kPremiumTierEnabled] is false.
  static const premiumTierRoutePaths = <String>[
    '/premium',
    '/boost-listing',
    '/business-advertise',
    '/advertise',
  ];

  static const premium = MonetizationProductState.comingSoon;
  static const pro = MonetizationProductState.comingSoon;
  static const boost = MonetizationProductState.comingSoon;
  static const businessAdvertising = MonetizationProductState.comingSoon;

  /// General Raabta AI (non–CV Maker) monthly successful-request cap during HOLD.
  static const monthlyAiRequestLimit = 30;

  // ─── Derived ─────────────────────────────────────────────────────────────
  static bool get isPremiumTierEnabled => MonetizationConfig.kPremiumTierEnabled;

  static bool get showPremiumTierUi => isPremiumTierEnabled;

  static bool get isHold => monetizationMode == MonetizationMode.hold;

  static bool get canInitiatePayment =>
      isPremiumTierEnabled && paymentsEnabled && !isHold;

  /// Paid tiers must not unlock features while payments are off or tier UI is hidden.
  static bool get grantsPaidEntitlements =>
      isPremiumTierEnabled &&
      paymentsEnabled &&
      monetizationMode == MonetizationMode.active;

  static bool get referralPremiumRewardsEnabled =>
      isPremiumTierEnabled && _referralPremiumRewardsWhenActive;

  static bool isPremiumTierRoute(String location) {
    final path = location.split('?').first;
    for (final route in premiumTierRoutePaths) {
      if (path == route || path.startsWith('$route/')) return true;
    }
    return false;
  }

  /// Redirect target when premium-tier routes are disabled; `null` = allow navigation.
  static String? redirectIfPremiumTierDisabled(String location) {
    if (isPremiumTierEnabled) return null;
    return isPremiumTierRoute(location) ? '/home' : null;
  }

  static bool get showPremiumComingSoon =>
      premium == MonetizationProductState.comingSoon || isHold;

  static bool get showProComingSoon =>
      pro == MonetizationProductState.comingSoon || isHold;

  static bool productVisible(MonetizationProductState state) =>
      state != MonetizationProductState.hidden;

  static String get freeGrowthMessage =>
      'RAABTA is currently free while we grow. Premium features and other paid '
      'services will be introduced in a future update.';
}
