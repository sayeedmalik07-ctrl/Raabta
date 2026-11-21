import 'package:raabta/config/compliance_flags.dart';
import 'package:raabta/config/monetization_state.dart';

/// Process-wide snapshot updated from Firestore admin config stream / startup.
abstract final class ComplianceFlagsGate {
  ComplianceFlagsGate._();

  static ComplianceFlags _current = ComplianceFlags.failClosed();

  static ComplianceFlags get current => _current;

  static void update(ComplianceFlags flags) {
    _current = flags;
  }

  static void requireFlag(bool enabled, String key) {
    if (!enabled) throw ComplianceFeatureDisabledException(key);
  }

  static void requireOffers() =>
      requireFlag(_current.offersEnabled, ComplianceFlagKeys.offersEnabled);

  static void requireViewings() => requireFlag(
        _current.viewingsEnabled,
        ComplianceFlagKeys.viewingsEnabled,
      );

  static void requireServiceQuotes() =>
      requireFlag(_current.quotesEnabled, ComplianceFlagKeys.quotesEnabled);

  static void requireBusinessQuotes() => requireFlag(
        _current.businessQuotesEnabled,
        ComplianceFlagKeys.businessQuotesEnabled,
      );

  static void requireBusinessAppointments() => requireFlag(
        _current.businessAppointmentsEnabled,
        ComplianceFlagKeys.businessAppointmentsEnabled,
      );

  static void requireJobApplicationStatus() => requireFlag(
        _current.jobApplicationStatusEnabled,
        ComplianceFlagKeys.jobApplicationStatusEnabled,
      );

  /// Compile-time monetization hold **and** remote compliance flag.
  static bool get effectivePaidBoosts =>
      MonetizationState.showPremiumTierUi && _current.paidBoostsEnabled;

  static bool get effectiveBusinessAds =>
      MonetizationState.showPremiumTierUi && _current.businessAdsEnabled;

  /// Redirect target when route is gated; `null` if allowed.
  static String? redirectIfGated(String location) {
    final path = location.split('?').first;

    final monetizationRedirect =
        MonetizationState.redirectIfPremiumTierDisabled(path);
    if (monetizationRedirect != null) return monetizationRedirect;

    if (path.startsWith('/boost-listing') && !effectivePaidBoosts) {
      return '/home';
    }
    if ((path == '/business-advertise' || path == '/advertise') &&
        !effectiveBusinessAds) {
      return '/home';
    }

    if (RegExp(r'^/marketplace/listing/[^/]+/offer$').hasMatch(path) &&
        !_current.offersEnabled) {
      return path.replaceFirst('/offer', '');
    }
    if (RegExp(r'^/housing/listing/[^/]+/viewing$').hasMatch(path) &&
        !_current.viewingsEnabled) {
      return path.replaceFirst('/viewing', '');
    }
    if (RegExp(r'^/services/listing/[^/]+/quote$').hasMatch(path) &&
        !_current.quotesEnabled) {
      return path.replaceFirst('/quote', '');
    }
    if (path.startsWith('/businesses/request-quote/') &&
        !_current.businessQuotesEnabled) {
      return '/businesses';
    }
    if (path.startsWith('/businesses/request-appointment/') &&
        !_current.businessAppointmentsEnabled) {
      return '/businesses';
    }

    return null;
  }

  static String resolveNotificationRoute(String route) {
    return redirectIfGated(route) ?? route;
  }

  static bool isStructuredFlowRoute(String route) {
    final path = route.split('?').first;
    return RegExp(r'^/marketplace/listing/[^/]+/offer$').hasMatch(path) ||
        RegExp(r'^/housing/listing/[^/]+/viewing$').hasMatch(path) ||
        RegExp(r'^/services/listing/[^/]+/quote$').hasMatch(path) ||
        path.startsWith('/businesses/request-quote/') ||
        path.startsWith('/businesses/request-appointment/') ||
        RegExp(r'^/jobs/chat/').hasMatch(path) ||
        RegExp(r'^/jobs/listing/[^/]+/applications$').hasMatch(path);
  }
}
