import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:raabta/features/profile/privacy/models/privacy_settings.dart';
import 'package:raabta/features/profile/privacy/models/user_data_summary.dart';
import 'package:raabta/features/profile/privacy/services/privacy_settings_service.dart';
import 'package:raabta/features/profile/privacy/services/user_data_service.dart';
import 'package:raabta/features/profile/privacy/services/vault_lock_service.dart';
import 'package:raabta/providers/auth_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

final privacySettingsServiceProvider = Provider<PrivacySettingsService>((ref) {
  return PrivacySettingsService();
});

final userDataServiceProvider = Provider<UserDataService>((ref) {
  return UserDataService();
});

final privacySettingsProvider =
    FutureProvider.autoDispose<PrivacySettings>((ref) async {
  final uid = ref.watch(privacyUserIdProvider);
  if (uid == null) return PrivacySettings.defaults;
  return ref.read(privacySettingsServiceProvider).load(uid);
});

final userDataSummaryProvider =
    FutureProvider.autoDispose<UserDataSummary>((ref) async {
  final uid = ref.watch(privacyUserIdProvider);
  if (uid == null) {
    return const UserDataSummary(
      profileStored: false,
      documentCount: 0,
      aiConversationCount: 0,
      aiMessageCount: 0,
      eosbHistoryCount: 0,
      overtimeHistoryCount: 0,
    );
  }
  return ref.read(userDataServiceProvider).fetchSummary(uid);
});

final privacyUserIdProvider = Provider<String?>((ref) {
  return ref.watch(currentUserProvider)?.uid;
});

final vaultLockServiceProvider = FutureProvider<VaultLockService>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return VaultLockService(prefs);
});

final permissionStatusProvider =
    FutureProvider.autoDispose<Map<Permission, PermissionStatus>>((ref) async {
  final camera = await Permission.camera.status;
  final location = await Permission.locationWhenInUse.status;
  final notifications = await Permission.notification.status;
  return {
    Permission.camera: camera,
    Permission.location: location,
    Permission.notification: notifications,
  };
});

String permissionStatusLabel(PermissionStatus status) {
  return switch (status) {
    PermissionStatus.granted => 'Allowed',
    PermissionStatus.denied => 'Denied',
    PermissionStatus.restricted => 'Restricted',
    PermissionStatus.limited => 'Limited',
    PermissionStatus.permanentlyDenied => 'Blocked',
    PermissionStatus.provisional => 'Provisional',
  };
}

Future<void> openPhonePermissionSettings() => openAppSettings();
