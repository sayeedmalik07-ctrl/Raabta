import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:raabta/models/intelligence/permission_level.dart';
import 'package:raabta/services/firebase_service.dart';

/// Audit trail for confirm/execute sensitive actions.
///
/// [AdminRepository.writeAdminAuditLog] targets `admin_audit_log` with
/// admin-only fields — not suitable for end-user actions. This extends the
/// existing `users/{uid}/analytics_events` subcollection (same pattern as
/// [ReferralAnalyticsService]) with structured sensitive-action events.
abstract final class SensitiveActionAuditService {
  static const collection = 'analytics_events';

  static Future<void> log({
    required String actionId,
    required PermissionLevel level,
    String? referenceId,
    Map<String, dynamic>? metadata,
  }) async {
    if (level != PermissionLevel.confirm && level != PermissionLevel.execute) {
      return;
    }

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || !FirebaseService.isReady) return;

    final payload = {
      'event': 'sensitive_action_${level.name}',
      'actionId': actionId,
      'permissionLevel': level.name,
      'referenceId': ?referenceId,
      ...?metadata,
      'createdAt': DateTime.now().toIso8601String(),
    };

    debugPrint('[SensitiveActionAudit] $actionId level=${level.name}');

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection(collection)
          .add(payload);
    } catch (e) {
      debugPrint('[SensitiveActionAudit] persist failed: $e');
    }
  }
}

/// Stable action identifiers for audit rows.
abstract final class SensitiveActionIds {
  static const deleteAccount = 'delete_account';
  static const boostListingPayment = 'boost_listing_tap_payment';
  static const premiumSubscriptionPayment = 'premium_subscription_tap_payment';
  static const tenancyDisputeShare = 'tenancy_dispute_packet_share';
  static const sponsorshipPacketShare = 'sponsorship_transfer_packet_share';
  static const healthInsuranceViolationShare = 'health_insurance_violation_share';
}
