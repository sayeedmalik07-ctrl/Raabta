import 'package:raabta/config/compliance_flags.dart';
import 'package:raabta/features/admin/models/admin_config.dart';

/// Tracks when the client last **successfully** loaded `admin_config/app_config`.
///
/// Staleness for fail-closed gating is based on [lastSuccessfulFetchAt], not
/// `complianceFlagsUpdatedAt` in Firestore.
abstract final class ComplianceConfigFetch {
  ComplianceConfigFetch._();

  static DateTime? lastSuccessfulFetchAt;
  static AdminAppConfig? _lastConfig;

  /// Records a successful **server** load of `admin_config/app_config`.
  /// Do not call for [SnapshotMetadata.isFromCache] snapshots.
  static void recordSuccessfulFetch(
    AdminAppConfig config, {
    bool fromCache = false,
  }) {
    if (fromCache) return;
    lastSuccessfulFetchAt = DateTime.now();
    _lastConfig = config;
  }

  static void clearForTesting() {
    lastSuccessfulFetchAt = null;
    _lastConfig = null;
  }

  static bool get hasSuccessfulFetch => lastSuccessfulFetchAt != null;

  static bool get isFetchStale {
    final at = lastSuccessfulFetchAt;
    if (at == null) return true;
    return DateTime.now().difference(at) > ComplianceFlags.staleAfter;
  }

  static ComplianceFlags resolve([AdminAppConfig? config]) {
    final cfg = config ?? _lastConfig;
    if (lastSuccessfulFetchAt == null || cfg == null) {
      return ComplianceFlags.failClosed(
        configReachable: cfg?.configDocumentPresent ?? false,
      );
    }
    if (isFetchStale) {
      return ComplianceFlags.failClosed(
        configReachable: cfg.configDocumentPresent,
        configFresh: false,
      );
    }
    if (!cfg.configDocumentPresent) {
      return ComplianceFlags.failClosed(configReachable: false);
    }
    return ComplianceFlags.fromFlagsMap(
      cfg.complianceFlagsRaw,
      configReachable: true,
      configFresh: true,
    );
  }
}
