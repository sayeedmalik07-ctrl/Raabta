import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Referral funnel analytics — mirrors onboarding/re-engagement debug + Firestore log.
abstract final class ReferralAnalyticsService {
  static Future<void> referralLinkShared({
    required String referralCode,
    required String shareType,
  }) async {
    debugPrint(
      '[ReferralAnalytics] referral_link_shared code=$referralCode type=$shareType',
    );
    await _persist('referral_link_shared', {
      'referralCode': referralCode,
      'shareType': shareType,
    });
  }

  static Future<void> referralLinkOpened(String referralCode) async {
    debugPrint(
      '[ReferralAnalytics] referral_link_opened code=$referralCode',
    );
    await _persist('referral_link_opened', {
      'referralCode': referralCode,
    });
  }

  static Future<void> referralSignupAttributed({
    required String referralCode,
    required String referrerUid,
  }) async {
    debugPrint(
      '[ReferralAnalytics] referral_signup_attributed code=$referralCode referrer=$referrerUid',
    );
    await _persist('referral_signup_attributed', {
      'referralCode': referralCode,
      'referrerUid': referrerUid,
    });
  }

  static Future<void> referralRewardGranted({
    required String referrerUid,
    required String referredUid,
    required String rewardType,
    required int durationDays,
    int? extraQuestions,
  }) async {
    debugPrint(
      '[ReferralAnalytics] referral_reward_granted referrer=$referrerUid '
      'referred=$referredUid type=$rewardType days=$durationDays '
      'extraQuestions=${extraQuestions ?? 0}',
    );
    await _persist('referral_reward_granted', {
      'referrerUid': referrerUid,
      'referredUid': referredUid,
      'rewardType': rewardType,
      'durationDays': durationDays,
      if (extraQuestions != null) 'extraQuestions': extraQuestions,
    });
  }

  static Future<void> _persist(String event, Map<String, dynamic> params) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('analytics_events')
          .add({
        'event': event,
        ...params,
        'createdAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('[ReferralAnalytics] persist failed: $e');
    }
  }
}
