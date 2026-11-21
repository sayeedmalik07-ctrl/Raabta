import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/config/compliance_config_fetch.dart';
import 'package:raabta/config/compliance_flags.dart';
import 'package:raabta/config/compliance_flags_gate.dart';
import 'package:raabta/features/admin/models/admin_config.dart';
import 'package:raabta/features/admin/models/admin_app_config_snapshot.dart';
import 'package:raabta/features/admin/providers/admin_providers.dart';
import 'package:raabta/features/admin/services/app_startup_guard.dart';

final complianceFlagsProvider = Provider<ComplianceFlags>((ref) {
  final config = ref.watch(adminAppConfigProvider).valueOrNull ??
      _configFromStartupCache() ??
      const AdminAppConfig();
  return config.complianceFlags;
});

AdminAppConfig? _configFromStartupCache() {
  final cached = AppStartupGuard.cachedConfig;
  if (cached == null) return null;
  return cached;
}

/// Keeps [ComplianceFlagsGate] in sync with Firestore config.
final complianceFlagsSyncProvider = Provider<void>((ref) {
  ref.listen<AsyncValue<AdminAppConfigSnapshot>>(
    adminAppConfigSnapshotProvider,
    (_, next) {
      final snapshot = next.valueOrNull;
      if (snapshot != null) {
        ComplianceConfigFetch.recordSuccessfulFetch(
          snapshot.config,
          fromCache: snapshot.fromCache,
        );
        ComplianceFlagsGate.update(
          ComplianceConfigFetch.resolve(snapshot.config),
        );
        return;
      }
      final cached = AppStartupGuard.cachedConfig;
      if (cached != null) {
        ComplianceFlagsGate.update(ComplianceConfigFetch.resolve(cached));
      } else {
        ComplianceFlagsGate.update(ComplianceFlags.failClosed());
      }
    },
  );
});
