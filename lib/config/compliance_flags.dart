import 'package:cloud_firestore/cloud_firestore.dart';

/// Decision 25 launch-safe gating flags (remote via [admin_config/app_config]).
abstract final class ComplianceFlagKeys {
  static const offersEnabled = 'offersEnabled';
  static const viewingsEnabled = 'viewingsEnabled';
  static const quotesEnabled = 'quotesEnabled';
  static const paidBoostsEnabled = 'paidBoostsEnabled';
  static const businessAdsEnabled = 'businessAdsEnabled';
  static const jobApplicationStatusEnabled = 'jobApplicationStatusEnabled';
  static const businessQuotesEnabled = 'businessQuotesEnabled';
  static const businessAppointmentsEnabled = 'businessAppointmentsEnabled';

  static const all = [
    offersEnabled,
    viewingsEnabled,
    quotesEnabled,
    paidBoostsEnabled,
    businessAdsEnabled,
    jobApplicationStatusEnabled,
    businessQuotesEnabled,
    businessAppointmentsEnabled,
  ];

  static bool defaultForKey(String key) =>
      key == jobApplicationStatusEnabled;
}

/// Resolved compliance flags after fail-closed rules.
class ComplianceFlags {
  const ComplianceFlags({
    required this.offersEnabled,
    required this.viewingsEnabled,
    required this.quotesEnabled,
    required this.paidBoostsEnabled,
    required this.businessAdsEnabled,
    required this.jobApplicationStatusEnabled,
    required this.businessQuotesEnabled,
    required this.businessAppointmentsEnabled,
    required this.configReachable,
    required this.configFresh,
  });

  final bool offersEnabled;
  final bool viewingsEnabled;
  final bool quotesEnabled;
  final bool paidBoostsEnabled;
  final bool businessAdsEnabled;
  final bool jobApplicationStatusEnabled;
  final bool businessQuotesEnabled;
  final bool businessAppointmentsEnabled;

  final bool configReachable;
  /// True when [ComplianceConfigFetch.lastSuccessfulFetchAt] is within [staleAfter].
  final bool configFresh;

  static const staleAfter = Duration(days: 7);

  factory ComplianceFlags.failClosed({
    bool configReachable = false,
    bool configFresh = false,
  }) {
    return ComplianceFlags(
      offersEnabled: false,
      viewingsEnabled: false,
      quotesEnabled: false,
      paidBoostsEnabled: false,
      businessAdsEnabled: false,
      jobApplicationStatusEnabled: true,
      businessQuotesEnabled: false,
      businessAppointmentsEnabled: false,
      configReachable: configReachable,
      configFresh: configFresh,
    );
  }

  /// Resolve flags from Firestore map only (no client fetch-age check).
  factory ComplianceFlags.fromFlagsMap(
    Map<String, bool> raw, {
    required bool configReachable,
    required bool configFresh,
  }) {
    bool flag(String key) {
      if (key == ComplianceFlagKeys.jobApplicationStatusEnabled) {
        return raw[key] ?? true;
      }
      return raw[key] == true;
    }

    return ComplianceFlags(
      offersEnabled: flag(ComplianceFlagKeys.offersEnabled),
      viewingsEnabled: flag(ComplianceFlagKeys.viewingsEnabled),
      quotesEnabled: flag(ComplianceFlagKeys.quotesEnabled),
      paidBoostsEnabled: flag(ComplianceFlagKeys.paidBoostsEnabled),
      businessAdsEnabled: flag(ComplianceFlagKeys.businessAdsEnabled),
      jobApplicationStatusEnabled:
          flag(ComplianceFlagKeys.jobApplicationStatusEnabled),
      businessQuotesEnabled: flag(ComplianceFlagKeys.businessQuotesEnabled),
      businessAppointmentsEnabled:
          flag(ComplianceFlagKeys.businessAppointmentsEnabled),
      configReachable: configReachable,
      configFresh: configFresh,
    );
  }

  /// Legacy parser — used only when recording fetch metadata from Firestore doc.
  static Map<String, bool> parseRaw(Map<String, dynamic>? data) {
    final complianceRaw = data?['complianceFlags'];
    final map = <String, bool>{};
    if (complianceRaw is Map) {
      for (final key in ComplianceFlagKeys.all) {
        if (complianceRaw[key] is bool) {
          map[key] = complianceRaw[key] as bool;
        }
      }
    }
    return map;
  }

  static DateTime? parseComplianceFlagsUpdatedAt(Map<String, dynamic>? data) {
    if (data == null) return null;
    final ts = data['complianceFlagsUpdatedAt'];
    if (ts is Timestamp) return ts.toDate();
    final iso = data['complianceFlagsUpdatedAtIso'];
    if (iso is String) return DateTime.tryParse(iso);
    return null;
  }

  Map<String, bool> toFirestoreMap() => {
        ComplianceFlagKeys.offersEnabled: offersEnabled,
        ComplianceFlagKeys.viewingsEnabled: viewingsEnabled,
        ComplianceFlagKeys.quotesEnabled: quotesEnabled,
        ComplianceFlagKeys.paidBoostsEnabled: paidBoostsEnabled,
        ComplianceFlagKeys.businessAdsEnabled: businessAdsEnabled,
        ComplianceFlagKeys.jobApplicationStatusEnabled:
            jobApplicationStatusEnabled,
        ComplianceFlagKeys.businessQuotesEnabled: businessQuotesEnabled,
        ComplianceFlagKeys.businessAppointmentsEnabled:
            businessAppointmentsEnabled,
      };
}

/// Thrown when a gated write is attempted while the feature flag is off.
class ComplianceFeatureDisabledException implements Exception {
  ComplianceFeatureDisabledException(this.featureKey);

  final String featureKey;

  @override
  String toString() => 'ComplianceFeatureDisabledException($featureKey)';
}
