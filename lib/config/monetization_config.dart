/// Single source of truth for Raabta monetization prices (QAR / displayed as QR).
///
/// Update prices here only — screens and revenue estimates should read from this file.
class MonetizationConfig {
  MonetizationConfig._();

  /// Master kill switch for Premium/Pro subscription UI and paid-tier behavior.
  /// Flip to `true` to re-enable monetization surfaces without code changes elsewhere.
  static const bool kPremiumTierEnabled = false;

  static const currencyLabel = 'QR';

  // ─── Premium subscription (monthly list prices) ───────────────────────────
  static const premiumMonthlyQr = 25;
  static const proMonthlyQr = 99;

  /// Yearly billing — same ~35% discount as the subscription screen toggle.
  static const yearlyDiscountFraction = 0.35;

  static int get premiumYearlyQr =>
      (premiumMonthlyQr * 12 * (1 - yearlyDiscountFraction)).round();

  static int get proYearlyQr =>
      (proMonthlyQr * 12 * (1 - yearlyDiscountFraction)).round();

  static int premiumPrice({required bool yearly}) =>
      yearly ? premiumYearlyQr : premiumMonthlyQr;

  static int proPrice({required bool yearly}) =>
      yearly ? proYearlyQr : proMonthlyQr;

  // ─── Listing boost (one-time) ─────────────────────────────────────────────
  static const boostStarterQr = 10;
  static const boostPopularQr = 20;
  static const boostPremiumQr = 60;

  /// Strikethrough anchor for the popular boost package.
  static const boostPopularCompareAtQr = 30;

  static const boostStarterDays = 3;
  static const boostPopularDays = 7;
  static const boostPremiumDays = 30;

  // ─── Business advertising (monthly) ───────────────────────────────────────
  static const businessFeaturedQr = 200;
  static const businessSpotlightQr = 500;
  static const businessBannerQr = 1000;

  // ─── Admin revenue estimate (MRR from subscribers) ────────────────────────
  static int estimatedMonthlyRevenueQr({
    required int premiumSubscribers,
    required int proSubscribers,
  }) =>
      (premiumSubscribers * premiumMonthlyQr) +
      (proSubscribers * proMonthlyQr);

  static String formatQr(int amount, {String? suffix}) {
    final base = '$amount $currencyLabel';
    if (suffix == null || suffix.isEmpty) return base;
    return '$base$suffix';
  }

  static String formatQrPerMonth(int amount) => formatQr(amount, suffix: '/mo');

  static String formatQrPerMonthShort(int amount) =>
      formatQr(amount, suffix: '/month');
}
