import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:raabta/features/admin/models/admin_config.dart';
import 'package:raabta/features/admin/providers/admin_providers.dart';
import 'package:raabta/features/admin/services/app_startup_guard.dart';

class AppUpdateInfo {
  const AppUpdateInfo({
    required this.currentVersion,
    required this.latestVersion,
    required this.isRequired,
  });

  final String currentVersion;
  final String latestVersion;
  final bool isRequired;
}

final packageInfoProvider = FutureProvider<PackageInfo>((ref) async {
  return PackageInfo.fromPlatform();
});

/// Live update status from admin config + installed app version.
final appUpdateInfoProvider = Provider<AppUpdateInfo?>((ref) {
  final config = ref.watch(adminAppConfigProvider).valueOrNull ??
      AppStartupGuard.cachedConfig ??
      const AdminAppConfig();
  final packageInfo = ref.watch(packageInfoProvider).valueOrNull;
  if (packageInfo == null) return null;

  final available = AppStartupGuard.isVersionBelow(
    packageInfo.version,
    config.minimumVersion,
  );
  if (!available) return null;

  return AppUpdateInfo(
    currentVersion: packageInfo.version,
    latestVersion: config.minimumVersion,
    isRequired: config.forceUpdate,
  );
});
