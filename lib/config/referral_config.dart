import 'package:raabta/config/monetization_config.dart';
import 'package:raabta/config/monetization_state.dart';

/// Referral reward constants — confirm values with product before launch.
abstract final class ReferralConfig {
  /// Reward duration for both Premium-days (when tier UI is on) and AI boost grants.
  static const rewardPremiumDays = 7;

  /// Extra daily AI Chat questions added while a referral boost is active.
  static const rewardAiBoostExtraQuestions = 5;

  /// Maximum successful referrals per user that can earn rewards.
  static const maxRewardableReferralsPerUser = 10;

  /// Tier used when [MonetizationState.referralPremiumRewardsEnabled] is true.
  static const rewardTier = 'premium';

  /// Max calendar days into the future a boost expiry may reach when stacking
  /// multiple referral rewards (extend-by-duration, not unlimited stack).
  ///
  /// FLAG (Sayeed): currently `rewardPremiumDays × maxRewardableReferralsPerUser`
  /// (= 70 days with defaults). Confirm before launch.
  static const maxReferralBoostStackDays =
      rewardPremiumDays * maxRewardableReferralsPerUser;

  /// Extends an expiring boost without stacking extra questions indefinitely.
  static DateTime extendBoostExpiry({
    required DateTime? existingExpiry,
    required int grantDays,
    required DateTime now,
  }) {
    final base =
        existingExpiry != null && existingExpiry.isAfter(now) ? existingExpiry : now;
    final candidate = base.add(Duration(days: grantDays));
    final cap = now.add(const Duration(days: maxReferralBoostStackDays));
    return candidate.isAfter(cap) ? cap : candidate;
  }

  static String rewardDescription() {
    if (MonetizationState.referralPremiumRewardsEnabled) {
      return '$rewardPremiumDays days of Premium '
          '(${MonetizationConfig.formatQrPerMonth(MonetizationConfig.premiumMonthlyQr)})';
    }
    return '$rewardAiBoostExtraQuestions extra AI questions/day '
        'for $rewardPremiumDays days';
  }
}
