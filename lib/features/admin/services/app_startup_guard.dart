import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:raabta/features/admin/admin_access.dart';
import 'package:raabta/services/auth/auth_session_service.dart';
import 'package:raabta/config/compliance_config_fetch.dart';
import 'package:raabta/config/compliance_flags_gate.dart';
import 'package:raabta/features/admin/models/admin_config.dart';
import 'package:raabta/features/admin/services/admin_repository.dart';
import 'package:raabta/services/notifications/legal_update_notification_service.dart';
import 'package:raabta/services/firebase_service.dart';

enum StartupResult {
  ok,
  maintenance,
  forceUpdate,
  suspended,
}

class AppStartupGuard {
  AppStartupGuard._();

  static AdminAppConfig? _cachedConfig;

  static AdminAppConfig? get cachedConfig => _cachedConfig;

  static Future<StartupResult> check() async {
    if (!FirebaseService.isReady) return StartupResult.ok;

    try {
      final snapshot = await AdminRepository().fetchAppConfigSnapshot();
      _cachedConfig = snapshot.config;
      ComplianceConfigFetch.recordSuccessfulFetch(
        snapshot.config,
        fromCache: snapshot.fromCache,
      );
      ComplianceFlagsGate.update(ComplianceConfigFetch.resolve(snapshot.config));

      final user = AuthSessionService.instance.currentUser;
      if (user != null && !AdminAccess.isAdminUser(user)) {
        if (await _isUserSuspended(user.uid)) {
          return StartupResult.suspended;
        }
      }

      if (snapshot.config.maintenanceMode && !AdminAccess.isCurrentUserAdmin()) {
        return StartupResult.maintenance;
      }

      if (snapshot.config.forceUpdate) {
        final info = await PackageInfo.fromPlatform();
        if (isVersionBelow(info.version, snapshot.config.minimumVersion)) {
          return StartupResult.forceUpdate;
        }
      }

      return StartupResult.ok;
    } catch (_) {
      return StartupResult.ok;
    }
  }

  static Future<bool> _isUserSuspended(String uid) async {
    final snap =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (!snap.exists) return false;
    final data = snap.data() ?? {};
    if (AdminAccess.isAdminUser(AuthSessionService.instance.currentUser)) {
      return false;
    }
    return data['isSuspended'] == true || data['suspended'] == true;
  }

  static bool isVersionBelow(String current, String minimum) {
    final c = _parseVersion(current);
    final m = _parseVersion(minimum);
    for (var i = 0; i < 3; i++) {
      if (c[i] < m[i]) return true;
      if (c[i] > m[i]) return false;
    }
    return false;
  }

  static List<int> _parseVersion(String version) {
    final parts = version.split('+').first.split('.');
    return [
      int.tryParse(parts.elementAtOrNull(0) ?? '0') ?? 0,
      int.tryParse(parts.elementAtOrNull(1) ?? '0') ?? 0,
      int.tryParse(parts.elementAtOrNull(2) ?? '0') ?? 0,
    ];
  }

  static bool isQuickActionRouteEnabled(String route) {
    final config = _cachedConfig ?? const AdminAppConfig();
    final map = {
      '/scanner': 'doc_scanner',
      '/scanner/capture': 'doc_scanner',
      '/barcode-scanner': 'food_inspector',
      '/arabic-companion': 'arabic_companion',
      '/landmark-translator': 'arabic_companion',
      '/bill-splitter': 'bill_splitter',
      '/warranty-shield': 'warranty_shield',
      '/climate-navigator': 'climate_navigator',
      '/queue-avoidance': 'queue_avoidance',
      '/bill-tracker': 'bill_tracker',
    };
    final key = map[route.split('?').first];
    if (key == null) return true;
    return config.isFeatureEnabled(key);
  }
}

class LastActiveTracker extends WidgetsBindingObserver {
  LastActiveTracker._();
  static final LastActiveTracker instance = LastActiveTracker._();

  final _repo = AdminRepository();
  bool _registered = false;

  void register() {
    if (_registered) return;
    _registered = true;
    WidgetsBinding.instance.addObserver(this);
    _touch();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _touch();
    }
  }

  Future<void> _touch() async {
    final uid = AuthSessionService.instance.currentUser?.uid;
    if (uid == null || !FirebaseService.isReady) return;
    try {
      await _repo.touchLastActive(uid);
      unawaited(LegalUpdateNotificationService.checkAndNotifyIfNeeded());
    } catch (_) {}
  }
}

extension _ListElementAtOrNull on List<String> {
  String? elementAtOrNull(int index) =>
      index >= 0 && index < length ? this[index] : null;
}
