import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:raabta/services/auth/auth_session_service.dart';
import 'package:http/http.dart' as http;
import 'package:raabta/config/app_config.dart';
import 'package:raabta/features/admin/models/admin_app_config_snapshot.dart';
import 'package:raabta/features/admin/models/admin_config.dart';
import 'package:raabta/features/admin/models/admin_stats.dart';
import 'package:raabta/features/admin/models/admin_broadcast_models.dart';
import 'package:raabta/features/admin/models/legal_change_monitor_models.dart';
import 'package:raabta/models/admin_report_model.dart';
import 'package:raabta/models/notification_models.dart';
import 'package:raabta/services/firebase_service.dart';
import 'package:raabta/data/models/employer_identity_verification.dart';
import 'package:raabta/services/notifications/notification_engine.dart';

enum EmployerIdentityVerificationAction { verify, reject, revoke }

class EmployerIdentityVerificationUpdateException implements Exception {
  EmployerIdentityVerificationUpdateException(this.message);

  final String message;

  @override
  String toString() => message;
}

class AdminRepository {
  AdminRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;
  static const _configDoc = 'admin_config/app_config';

  DocumentReference<Map<String, dynamic>> get _configRef =>
      _db.doc(_configDoc);

  Future<AdminAppConfigSnapshot> fetchAppConfigSnapshot() async {
    if (!FirebaseService.isReady) {
      return const AdminAppConfigSnapshot(
        config: AdminAppConfig(),
        fromCache: false,
      );
    }
    final snap = await _configRef.get();
    if (!snap.exists) {
      return AdminAppConfigSnapshot(
        config: const AdminAppConfig(),
        fromCache: snap.metadata.isFromCache,
      );
    }
    return AdminAppConfigSnapshot(
      config: AdminAppConfig.fromFirestore(snap.data()),
      fromCache: snap.metadata.isFromCache,
    );
  }

  Future<AdminAppConfig> fetchAppConfig() async {
    return (await fetchAppConfigSnapshot()).config;
  }

  Stream<AdminAppConfigSnapshot> watchAppConfigSnapshots() {
    if (!FirebaseService.isReady) {
      return Stream.value(
        const AdminAppConfigSnapshot(config: AdminAppConfig(), fromCache: false),
      );
    }
    return _configRef.snapshots().map(
          (snap) => AdminAppConfigSnapshot(
            config: snap.exists
                ? AdminAppConfig.fromFirestore(snap.data())
                : const AdminAppConfig(),
            fromCache: snap.metadata.isFromCache,
          ),
        );
  }

  Stream<AdminAppConfig> watchAppConfig() {
    return watchAppConfigSnapshots().map((snapshot) => snapshot.config);
  }

  Future<void> updateAppConfig(Map<String, dynamic> patch) async {
    await _configRef.set(patch, SetOptions(merge: true));
  }

  Future<void> updateComplianceFlags(Map<String, bool> flags) async {
    await _configRef.set(
      {
        'complianceFlags': flags,
        'complianceFlagsUpdatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  Future<AdminDashboardStats> fetchDashboardStats() async {
    if (!FirebaseService.isReady) return const AdminDashboardStats();

    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final weekStart = todayStart.subtract(Duration(days: now.weekday - 1));
    final dayAgo = now.subtract(const Duration(hours: 24));

    final usersSnap = await _db.collection('users').limit(500).get();
    var newToday = 0;
    var newWeek = 0;
    var active24h = 0;
    var premium = 0;
    var pro = 0;

    for (final doc in usersSnap.docs) {
      final d = doc.data();
      final created = _parseDate(d['createdAt']);
      if (created != null) {
        if (!created.isBefore(todayStart)) newToday++;
        if (!created.isBefore(weekStart)) newWeek++;
      }
      final lastActive = _parseDate(d['lastActive']) ?? _parseDate(d['lastLogin']);
      if (lastActive != null && lastActive.isAfter(dayAgo)) active24h++;

      final tier = _subscriptionTier(d);
      if (tier == 'premium') premium++;
      if (tier == 'pro') pro++;
    }

    final listingsSnap = await _db.collection('listings').limit(500).get();
    var housingPending = 0;
    for (final doc in listingsSnap.docs) {
      final status = doc.data()['status'] as String? ?? 'approved';
      if (status == 'pending' || status == 'hidden_pending_review') {
        housingPending++;
      }
    }

    final jobsSnap = await _db.collection('jobs').limit(500).get();
    var jobsActive = 0;
    var jobsExpired = 0;
    for (final doc in jobsSnap.docs) {
      final status = doc.data()['status'] as String? ?? 'active';
      if (status == 'expired') {
        jobsExpired++;
      } else {
        jobsActive++;
      }
    }

    final businessSnap = await _db.collection('businesses').limit(500).get();
    var bizApproved = 0;
    var bizPending = 0;
    for (final doc in businessSnap.docs) {
      final data = doc.data();
      final status = data['status'] as String? ?? 'approved';
      final verification = data['verificationStatus'] as String?;
      if (status == 'pending' || verification == 'pending_review') {
        bizPending++;
      } else if (status != 'rejected' && verification != 'rejected') {
        bizApproved++;
      }
    }

    QuerySnapshot<Map<String, dynamic>>? reportsSnap;
    try {
      reportsSnap = await _db
          .collection('reports')
          .where('status', isEqualTo: 'open')
          .limit(200)
          .get();
    } catch (_) {}
    final openReports = reportsSnap?.docs.length ?? 0;

    return AdminDashboardStats(
      totalUsers: usersSnap.docs.length,
      newUsersToday: newToday,
      newUsersThisWeek: newWeek,
      activeUsers24h: active24h,
      businessApproved: bizApproved,
      businessPending: bizPending,
      jobsActive: jobsActive,
      jobsExpired: jobsExpired,
      housingTotal: listingsSnap.docs.length,
      housingPending: housingPending,
      openReports: openReports,
      premiumSubscribers: premium,
      proSubscribers: pro,
    );
  }

  Future<({List<AdminUserRow> users, DocumentSnapshot? lastDoc})> fetchUsersPage({
    required int pageSize,
    DocumentSnapshot? startAfter,
    String query = '',
  }) async {
    if (!FirebaseService.isReady) {
      return (users: <AdminUserRow>[], lastDoc: null);
    }

    Query<Map<String, dynamic>> q =
        _db.collection('users').orderBy('createdAt', descending: true);

    if (startAfter != null) {
      q = q.startAfterDocument(startAfter);
    }

    final snap = await q.limit(pageSize).get();
    var rows = snap.docs.map(_mapUser).toList();

    final qLower = query.trim().toLowerCase();
    if (qLower.isNotEmpty) {
      rows = rows.where((u) {
        return u.displayName.toLowerCase().contains(qLower) ||
            u.email.toLowerCase().contains(qLower) ||
            u.phone.contains(qLower) ||
            u.uid.contains(qLower);
      }).toList();
    }

    final lastDoc = snap.docs.isEmpty ? null : snap.docs.last;
    return (users: rows, lastDoc: lastDoc);
  }

  Future<AdminUserRow?> fetchUser(String uid) async {
    final snap = await _db.collection('users').doc(uid).get();
    if (!snap.exists) return null;
    return _mapUser(snap);
  }

  Future<void> updateUserSubscription(String uid, String tier) async {
    final updates = <String, dynamic>{
      'subscriptionTier': tier,
      'subscription': tier == 'free' ? 'free' : tier,
      'isPremium': tier == 'premium' || tier == 'pro',
      'isPro': tier == 'pro',
      'updatedAt': FieldValue.serverTimestamp(),
    };
    await _db.collection('users').doc(uid).set(updates, SetOptions(merge: true));
  }

  Future<void> setUserSuspended(String uid, bool suspended) async {
    await _db.collection('users').doc(uid).set({
      'isSuspended': suspended,
      'suspended': suspended,
      'status': suspended ? 'suspended' : 'active',
      if (suspended) 'suspendReason': 'Suspended by admin',
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> touchLastActive(String uid) async {
    await _db.collection('users').doc(uid).set({
      'lastActive': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> fetchModerationItems(
    String collection, {
    int limit = 50,
  }) async {
    if (collection == 'listings') {
      return _fetchListingModerationItems(limit: limit);
    }

    final snap = await _db.collection(collection).limit(limit).get();
    final docs = snap.docs.toList();
    docs.sort((a, b) {
      final sa = _moderationStatus(a.data(), collection);
      final sb = _moderationStatus(b.data(), collection);
      return _statusOrder(sa).compareTo(_statusOrder(sb));
    });
    return docs;
  }

  Future<void> moderateItem({
    required String collection,
    required String docId,
    required String status,
    required String adminUid,
    String? reason,
  }) async {
    final updates = <String, dynamic>{
      'reviewedBy': adminUid,
      'reviewedAt': FieldValue.serverTimestamp(),
      if (reason != null && reason.isNotEmpty) 'reviewReason': reason,
    };

    if (collection == 'businesses') {
      updates['verificationStatus'] =
          status == 'approved' ? 'approved' : 'rejected';
      if (status == 'rejected') {
        updates['status'] = 'rejected';
      }
      await _db.collection('business_moderation_queue').doc(docId).set({
        'status': status,
        'reviewedBy': adminUid,
        'reviewedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } else if (collection == 'listings') {
      updates['status'] = status;
      await _db.collection('listing_moderation_queue').doc(docId).set({
        'status': status,
        'reviewedBy': adminUid,
        'reviewedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } else {
      updates['status'] = status;
    }

    await _db.collection(collection).doc(docId).set(
          updates,
          SetOptions(merge: true),
        );
  }

  Future<void> updateEmployerIdentityVerification({
    required String businessId,
    required EmployerIdentityVerificationAction action,
    required String adminUid,
    String? reason,
  }) async {
    if (adminUid.isEmpty) {
      throw EmployerIdentityVerificationUpdateException(
        'Admin UID is required for employer identity verification',
      );
    }

    final docRef = _db.collection('businesses').doc(businessId);
    final snap = await docRef.get();
    if (!snap.exists) {
      throw EmployerIdentityVerificationUpdateException(
        'Business not found: $businessId',
      );
    }

    final data = snap.data() ?? {};
    final rawIdentity = data['employerIdentityVerification'];
    final current = EmployerIdentityVerification.fromFirestore(rawIdentity);
    final currentStatus = current?.status;

    final Map<String, dynamic> identityMap;
    switch (action) {
      case EmployerIdentityVerificationAction.verify:
        if (currentStatus == EmployerIdentityVerificationStatus.verified) {
          throw EmployerIdentityVerificationUpdateException(
            'Employer identity is already verified',
          );
        }
        identityMap = {
          'status': EmployerIdentityVerificationStatus.verified.storageValue,
          'verifiedAt': FieldValue.serverTimestamp(),
          'verifiedBy': adminUid,
        };
        break;
      case EmployerIdentityVerificationAction.reject:
        if (currentStatus == EmployerIdentityVerificationStatus.verified) {
          throw EmployerIdentityVerificationUpdateException(
            'Revoke verified employer identity before rejecting',
          );
        }
        if (currentStatus == EmployerIdentityVerificationStatus.rejected) {
          throw EmployerIdentityVerificationUpdateException(
            'Employer identity is already rejected',
          );
        }
        identityMap = {
          'status': EmployerIdentityVerificationStatus.rejected.storageValue,
          'rejectedAt': FieldValue.serverTimestamp(),
          'rejectedBy': adminUid,
          if (reason != null && reason.isNotEmpty) 'rejectionReason': reason,
        };
        break;
      case EmployerIdentityVerificationAction.revoke:
        if (currentStatus != EmployerIdentityVerificationStatus.verified) {
          throw EmployerIdentityVerificationUpdateException(
            'Only verified employer identity can be revoked',
          );
        }
        final rawMap = rawIdentity is Map
            ? Map<String, dynamic>.from(rawIdentity)
            : <String, dynamic>{};
        identityMap = {
          'status': EmployerIdentityVerificationStatus.revoked.storageValue,
          if (rawMap['verifiedAt'] != null) 'verifiedAt': rawMap['verifiedAt'],
          if (rawMap['verifiedBy'] != null) 'verifiedBy': rawMap['verifiedBy'],
          'revokedAt': FieldValue.serverTimestamp(),
          'revokedBy': adminUid,
          if (reason != null && reason.isNotEmpty)
            'revocationReason': reason,
        };
        break;
    }

    await docRef.set(
      {'employerIdentityVerification': identityMap},
      SetOptions(merge: true),
    );
  }

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
      _fetchListingModerationItems({
    int limit = 50,
  }) async {
    final queueSnap =
        await _db.collection('listing_moderation_queue').limit(limit).get();
    final docs = <QueryDocumentSnapshot<Map<String, dynamic>>>[];
    final seen = <String>{};

    for (final queueDoc in queueSnap.docs) {
      final listingId =
          queueDoc.data()['listingId'] as String? ?? queueDoc.id;
      if (seen.contains(listingId)) continue;

      final listingDoc =
          await _db.collection('listings').doc(listingId).get();
      if (listingDoc.exists) {
        docs.add(queueDoc);
        seen.add(listingId);
      }
    }

    if (docs.length < limit) {
      final pendingSnap = await _db
          .collection('listings')
          .where('status', isEqualTo: 'pending')
          .limit(limit)
          .get();
      for (final doc in pendingSnap.docs) {
        if (seen.add(doc.id)) {
          docs.add(doc);
        }
      }
    }

    docs.sort((a, b) {
      final sa = _moderationStatus(a.data(), 'listings');
      final sb = _moderationStatus(b.data(), 'listings');
      return _statusOrder(sa).compareTo(_statusOrder(sb));
    });

    if (docs.length <= limit) return docs;
    return docs.sublist(0, limit);
  }

  Future<List<AdminReportModel>> fetchReports({int limit = 50}) async {
    try {
      final snap = await _db
          .collection('reports')
          .limit(limit)
          .get();
      final docs = snap.docs.toList()
        ..sort((a, b) {
          final ta = AdminReportModel.fromFirestore(a).createdAt;
          final tb = AdminReportModel.fromFirestore(b).createdAt;
          if (ta == null && tb == null) return 0;
          if (ta == null) return 1;
          if (tb == null) return -1;
          return tb.compareTo(ta);
        });
      return docs.map(AdminReportModel.fromFirestore).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> submitReport(AdminReportModel report) async {
    await _db.collection('reports').add(report.toFirestore());
  }

  Future<void> updateReportStatus({
    required String reportId,
    required String status,
    required String adminUid,
    String? note,
  }) async {
    await _db.collection('reports').doc(reportId).set({
      'status': status,
      'reviewedBy': adminUid,
      'reviewedAt': FieldValue.serverTimestamp(),
      if (note != null) 'resolutionNote': note,
    }, SetOptions(merge: true));
  }

  Future<void> createBroadcast({
    required String title,
    required String body,
    required String adminUid,
  }) async {
    await _db.collection('broadcasts').add({
      'title': title,
      'body': body,
      'createdBy': adminUid,
      'createdAt': FieldValue.serverTimestamp(),
      'route': '/notifications',
    });
  }

  /// Firestore trigger path for [NotificationEngine.sendAdminBroadcast].
  Future<String> createAdminBroadcastRequest({
    required String title,
    required String body,
    required String adminUid,
    required AdminBroadcastTarget target,
    String route = '/notifications',
  }) async {
    final ref = await _db.collection('admin_broadcasts').add({
      'title': title,
      'body': body,
      'route': route,
      'targetMode': target.firestoreValue,
      'createdBy': adminUid,
      'createdAt': FieldValue.serverTimestamp(),
      'status': 'pending',
    });
    return ref.id;
  }

  /// Resolves recipient user IDs. Preference filtering happens in the engine/backend.
  Future<List<String>> resolveAdminBroadcastTargets(
    AdminBroadcastTarget target,
  ) async {
    if (!FirebaseService.isReady) return [];
    final snap = await _db.collection('users').limit(500).get();
    if (target == AdminBroadcastTarget.allUsers) {
      return snap.docs.map((d) => d.id).toList();
    }
    final ids = <String>[];
    for (final doc in snap.docs) {
      if (await _isAdminBroadcastOptedIn(doc.reference)) {
        ids.add(doc.id);
      }
    }
    return ids;
  }

  Future<bool> _isAdminBroadcastOptedIn(
    DocumentReference<Map<String, dynamic>> userRef,
  ) async {
    final prefs =
        await userRef.collection('notification_preferences').doc('settings').get();
    if (prefs.exists) {
      return prefs.data()?['adminAnnouncement'] as bool? ?? true;
    }
    final settings =
        await userRef.collection('settings').doc('notifications').get();
    if (settings.exists) {
      return settings.data()?['adminAnnouncement'] as bool? ?? true;
    }
    return true;
  }

  /// Sends via [SmartNotificationEngine] and logs to [admin_audit_log] on success.
  Future<void> sendAdminBroadcast({
    required String title,
    required String body,
    required String adminUid,
    required String adminEmail,
    required AdminBroadcastTarget target,
  }) async {
    final broadcastId = await createAdminBroadcastRequest(
      title: title,
      body: body,
      adminUid: adminUid,
      target: target,
    );

    final targetUserIds = await resolveAdminBroadcastTargets(target);
    if (targetUserIds.isEmpty) {
      await _db.collection('admin_broadcasts').doc(broadcastId).set(
        {'status': 'failed', 'error': 'no_targets'},
        SetOptions(merge: true),
      );
      throw Exception('No eligible users found for this broadcast');
    }

    final result = await NotificationEngine.instance.send(
      SmartNotificationRequest(
        type: NotificationType.adminAnnouncement,
        title: title,
        body: body,
        route: '/notifications',
        dedupKey: 'admin_$broadcastId',
        remoteUserIds: targetUserIds,
        data: {'broadcastId': broadcastId},
      ),
    );

    if (!result.sent) {
      await _db.collection('admin_broadcasts').doc(broadcastId).set(
        {'status': 'failed', 'error': result.reason ?? 'delivery_failed'},
        SetOptions(merge: true),
      );
      throw Exception(result.reason ?? 'Broadcast delivery failed');
    }

    await _db.collection('admin_broadcasts').doc(broadcastId).set(
      {
        'status': 'sent',
        'recipientCount': targetUserIds.length,
        'sentAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    await writeAdminAuditLog(
      adminUid: adminUid,
      adminEmail: adminEmail,
      action: 'adminBroadcast',
      targetType: 'broadcast',
      referenceId: broadcastId,
      metadata: {
        'title': title,
        'body': body,
        'targetMode': target.firestoreValue,
        'recipientCount': targetUserIds.length,
      },
    );
  }

  Future<void> writeAdminAuditLog({
    required String adminUid,
    required String adminEmail,
    required String action,
    required String targetType,
    required String referenceId,
    Map<String, dynamic>? metadata,
  }) async {
    await _db.collection('admin_audit_log').add({
      'adminUid': adminUid,
      'adminEmail': adminEmail,
      'action': action,
      'targetType': targetType,
      'referenceId': referenceId,
      if (metadata != null) 'metadata': metadata,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<List<AdminAuditLogEntry>> fetchBroadcastAuditHistory({
    int limit = 25,
  }) async {
    if (!FirebaseService.isReady) return [];
    try {
      final snap = await _db
          .collection('admin_audit_log')
          .where('action', isEqualTo: 'adminBroadcast')
          .limit(limit)
          .get();
      final entries =
          snap.docs.map(AdminAuditLogEntry.fromFirestore).toList();
      entries.sort(
        (a, b) =>
            (b.timestamp ?? DateTime(0)).compareTo(a.timestamp ?? DateTime(0)),
      );
      return entries;
    } catch (_) {
      return [];
    }
  }

  AdminUserRow _mapUser(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return AdminUserRow(
      uid: doc.id,
      displayName: d['displayName'] as String? ??
          d['name'] as String? ??
          'User ${doc.id.substring(0, 6)}',
      email: d['email'] as String? ?? '',
      phone: d['phone'] as String? ?? d['phoneNumber'] as String? ?? '',
      subscriptionTier: _subscriptionTier(d),
      status: _userStatus(d),
      createdAt: _parseDate(d['createdAt']),
      lastActive: _parseDate(d['lastActive']),
      lastLogin: _parseDate(d['lastLogin']),
      points: d['points'] as int?,
      level: d['level'] as String?,
      nationality: d['nationality'] as String?,
      language: d['language'] as String?,
      raw: d,
    );
  }

  static String _subscriptionTier(Map<String, dynamic> d) {
    final tier = d['subscriptionTier'] as String?;
    if (tier != null && tier.isNotEmpty) return tier;
    if (d['isPro'] == true || d['subscription'] == 'pro') return 'pro';
    if (d['isPremium'] == true || d['subscription'] == 'premium') {
      return 'premium';
    }
    return 'free';
  }

  static String _userStatus(Map<String, dynamic> d) {
    if (d['isSuspended'] == true || d['suspended'] == true) {
      return 'suspended';
    }
    if (d['banned'] == true || d['status'] == 'banned') return 'banned';
    return d['status'] as String? ?? 'active';
  }

  static DateTime? _parseDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  static String _moderationStatus(
    Map<String, dynamic> data,
    String collection,
  ) {
    if (collection == 'businesses') {
      return data['verificationStatus'] as String? ??
          data['status'] as String? ??
          'approved';
    }
    return data['status'] as String? ?? 'approved';
  }

  static int _statusOrder(String status) {
    switch (status) {
      case 'pending':
      case 'pending_review':
      case 'hidden_pending_review':
        return 0;
      case 'approved':
      case 'active':
        return 1;
      case 'rejected':
      case 'expired':
        return 2;
      default:
        return 3;
    }
  }
}

class AdminApiService {
  AdminApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<String?> _idToken() async {
    try {
      return await AuthSessionService.instance.getIdToken();
    } catch (_) {
      return null;
    }
  }

  Future<void> deleteUserAccount(String uid) async {
    final token = await _idToken();
    if (token == null) throw Exception('Not authenticated');

    final response = await _client.post(
      Uri.parse('${AppConfig.backendUrl}/api/admin/delete-user'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'uid': uid, 'confirm': 'DELETE'}),
    );

    if (response.statusCode >= 400) {
      final body = jsonDecode(response.body) as Map<String, dynamic>? ?? {};
      throw Exception(body['error'] ?? 'Delete failed (${response.statusCode})');
    }
  }

  Future<AiUsageStats> fetchAiUsageStats() async {
    final token = await _idToken();
    if (token == null) {
      return const AiUsageStats(loggingAvailable: false);
    }

    final response = await _client.get(
      Uri.parse('${AppConfig.backendUrl}/api/admin/ai-usage'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 501) {
      return const AiUsageStats(loggingAvailable: false);
    }
    if (response.statusCode >= 400) {
      return const AiUsageStats(loggingAvailable: false);
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final daily = (body['dailyCalls'] as List<dynamic>? ?? [])
        .map((e) {
          final m = e as Map<String, dynamic>;
          return DailyAiUsage(
            date: DateTime.parse(m['date'] as String),
            count: m['count'] as int? ?? 0,
          );
        })
        .toList();

    final byFeature = <String, int>{};
    final featureRaw = body['byFeature'] as Map<String, dynamic>? ?? {};
    for (final entry in featureRaw.entries) {
      byFeature[entry.key] = entry.value as int? ?? 0;
    }

    final byModel = <String, int>{};
    final modelRaw = body['byModel'] as Map<String, dynamic>? ?? {};
    for (final entry in modelRaw.entries) {
      byModel[entry.key] = entry.value as int? ?? 0;
    }

    final topUsers = (body['topUsers'] as List<dynamic>? ?? [])
        .map((e) {
          final m = e as Map<String, dynamic>;
          return TopAiUser(
            userId: m['userId'] as String? ?? '',
            displayName: m['displayName'] as String? ?? 'Unknown',
            count: m['count'] as int? ?? 0,
          );
        })
        .toList();

    return AiUsageStats(
      loggingAvailable: body['loggingAvailable'] as bool? ?? true,
      dailyCalls: daily,
      byFeature: byFeature,
      byModel: byModel,
      topUsers: topUsers,
      costPer1kTokens:
          (body['costPer1kTokens'] as num?)?.toDouble() ?? 0.05,
      estimatedCostQr:
          (body['estimatedCostQr'] as num?)?.toDouble() ?? 0,
    );
  }

  Future<int> fetchAiCallsToday() async {
    final stats = await fetchAiUsageStats();
    if (!stats.loggingAvailable || stats.dailyCalls.isEmpty) return 0;
    final today = DateTime.now();
    for (final day in stats.dailyCalls) {
      if (day.date.year == today.year &&
          day.date.month == today.month &&
          day.date.day == today.day) {
        return day.count;
      }
    }
    return 0;
  }

  Future<void> sendBroadcast({
    required String title,
    required String body,
  }) async {
    final token = await _idToken();
    if (token == null) throw Exception('Not authenticated');

    final response = await _client.post(
      Uri.parse('${AppConfig.backendUrl}/api/admin/broadcast'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'title': title, 'body': body, 'route': '/notifications'}),
    );

    if (response.statusCode >= 400) {
      final decoded = jsonDecode(response.body) as Map<String, dynamic>? ?? {};
      throw Exception(decoded['error'] ?? 'Broadcast failed');
    }
  }

  Future<List<LegalMonitorReviewItem>> fetchLegalMonitorQueue({
    bool pendingOnly = true,
  }) async {
    final token = await _idToken();
    if (token == null) return [];

    final uri = Uri.parse(
      '${AppConfig.backendUrl}/api/admin/legal-change-monitor/queue'
      '?pending=${pendingOnly ? '1' : '0'}',
    );
    final response = await _client.get(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode >= 400) return [];

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final items = body['items'] as List<dynamic>? ?? [];
    return items
        .map((e) {
          final m = e as Map<String, dynamic>;
          final id = m['id'] as String? ?? '';
          return LegalMonitorReviewItem.fromJson(id, m);
        })
        .toList();
  }

  Future<List<LegalMonitorSourceStatus>> fetchLegalMonitorSources() async {
    final token = await _idToken();
    if (token == null) return [];

    final response = await _client.get(
      Uri.parse('${AppConfig.backendUrl}/api/admin/legal-change-monitor/sources'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode >= 400) return [];

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final sources = body['sources'] as List<dynamic>? ?? [];
    return sources
        .map((e) => LegalMonitorSourceStatus.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<LegalMonitorRunSummary?> runLegalMonitor({
    Map<String, String>? simulateChanges,
    List<String>? sourceIds,
    bool skipTriage = false,
  }) async {
    final token = await _idToken();
    if (token == null) throw Exception('Not authenticated');

    final response = await _client.post(
      Uri.parse('${AppConfig.backendUrl}/api/admin/legal-change-monitor/run'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        if (sourceIds != null) 'sourceIds': sourceIds,
        if (simulateChanges != null) 'simulateChanges': simulateChanges,
        'skipTriage': skipTriage,
      }),
    );

    if (response.statusCode >= 400) {
      final decoded = jsonDecode(response.body) as Map<String, dynamic>? ?? {};
      throw Exception(decoded['error'] ?? 'Monitor run failed');
    }

    return LegalMonitorRunSummary.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<void> submitLegalMonitorReview({
    required String itemId,
    required String decision,
  }) async {
    final token = await _idToken();
    if (token == null) throw Exception('Not authenticated');

    final response = await _client.post(
      Uri.parse(
        '${AppConfig.backendUrl}/api/admin/legal-change-monitor/queue/$itemId/review',
      ),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'decision': decision}),
    );

    if (response.statusCode >= 400) {
      final decoded = jsonDecode(response.body) as Map<String, dynamic>? ?? {};
      throw Exception(decoded['error'] ?? 'Review submit failed');
    }
  }

  Future<void> notifyLegalSourceVerified({
    required String sourceId,
    required DateTime verifiedAt,
  }) async {
    final token = await _idToken();
    if (token == null) return;

    final response = await _client.post(
      Uri.parse('${AppConfig.backendUrl}/api/admin/legal-source-verified'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'sourceId': sourceId,
        'verifiedAt': verifiedAt.toIso8601String(),
      }),
    );

    if (response.statusCode >= 400) {
      debugPrint(
        'Legal source notify failed: ${response.statusCode} ${response.body}',
      );
    }
  }
}
