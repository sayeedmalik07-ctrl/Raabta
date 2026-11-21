import 'package:raabta/features/admin/models/admin_config.dart';

/// Firestore [AdminAppConfig] plus snapshot metadata for compliance fetch tracking.
class AdminAppConfigSnapshot {
  const AdminAppConfigSnapshot({
    required this.config,
    required this.fromCache,
  });

  final AdminAppConfig config;
  final bool fromCache;
}
