import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:raabta/config/monetization_state.dart';
import 'package:raabta/config/referral_config.dart';
import 'package:raabta/services/referral/pending_referral_store.dart';
import 'package:raabta/services/referral/referral_analytics_service.dart';
import 'package:raabta/services/referral/referral_code_generator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReferrerProfile {
  const ReferrerProfile({
    required this.uid,
    this.displayName,
    this.allowNameInShares = false,
  });

  final String uid;
  final String? displayName;
  final bool allowNameInShares;
}

class ReferralProfileSnapshot {
  const ReferralProfileSnapshot({
    this.referralCode,
    this.referredBy,
    this.successfulReferralsCount = 0,
    this.referralPremiumUntil,
    this.referralAiBoostExpiresAt,
    this.referralAiBoostExtraQuestions = 0,
    this.referralRewardGranted = false,
  });

  final String? referralCode;
  final String? referredBy;
  final int successfulReferralsCount;
  final DateTime? referralPremiumUntil;
  final DateTime? referralAiBoostExpiresAt;
  final int referralAiBoostExtraQuestions;
  final bool referralRewardGranted;

  bool get hasActiveReferralPremium =>
      referralPremiumUntil != null &&
      referralPremiumUntil!.isAfter(DateTime.now());

  bool get hasActiveReferralAiBoost =>
      referralAiBoostExpiresAt != null &&
      referralAiBoostExpiresAt!.isAfter(DateTime.now()) &&
      referralAiBoostExtraQuestions > 0;
}

/// Attribution, lazy code generation, and Premium-tier reward grants.
class ReferralService {
  ReferralService._();

  static final instance = ReferralService._();
  static const _users = 'users';
  static const _referralsSub = 'referrals';

  FirebaseFirestore get _db => FirebaseFirestore.instance;

  /// Lazy-generate referral code on first share action.
  Future<String?> ensureReferralCode(String uid) async {
    final doc = await _db.collection(_users).doc(uid).get();
    final existing = doc.data()?['referralCode'] as String?;
    if (existing != null && existing.trim().isNotEmpty) {
      return existing.trim().toUpperCase();
    }

    final code = ReferralCodeGenerator.fromUid(uid);
    await _db.collection(_users).doc(uid).set({
      'referralCode': code,
    }, SetOptions(merge: true));
    return code;
  }

  Future<ReferrerProfile?> lookupReferrerByCode(String code) async {
    final normalized = code.trim().toUpperCase();
    final snap = await _db
        .collection(_users)
        .where('referralCode', isEqualTo: normalized)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    final doc = snap.docs.first;
    final data = doc.data();
    return ReferrerProfile(
      uid: doc.id,
      displayName: data['displayName'] as String?,
      allowNameInShares: data['allowNameInReferralShares'] as bool? ?? false,
    );
  }

  /// Attach pending invite code once at signup — idempotent.
  Future<void> applyPendingReferralOnSignup(String newUserUid) async {
    final pending = await PendingReferralStore.consume();
    if (pending == null) return;

    final doc = await _db.collection(_users).doc(newUserUid).get();
    if (!doc.exists) return;
    final data = doc.data() ?? {};
    if (data['referredBy'] != null) return;

    final referrer = await lookupReferrerByCode(pending);
    if (referrer == null) return;
    if (referrer.uid == newUserUid) return;

    await _db.collection(_users).doc(newUserUid).set({
      'referredBy': referrer.uid,
      'referredByCode': pending,
      'referredAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await ReferralAnalyticsService.referralSignupAttributed(
      referralCode: pending,
      referrerUid: referrer.uid,
    );
  }

  Future<ReferralProfileSnapshot> loadProfile(String uid) async {
    final doc = await _db.collection(_users).doc(uid).get();
    final data = doc.data() ?? {};
    return ReferralProfileSnapshot(
      referralCode: data['referralCode'] as String?,
      referredBy: data['referredBy'] as String?,
      successfulReferralsCount:
          (data['successfulReferralsCount'] as num?)?.toInt() ?? 0,
      referralPremiumUntil: _readTimestamp(data['referralPremiumUntil']),
      referralAiBoostExpiresAt: _readTimestamp(data['referralAiBoostExpiresAt']),
      referralAiBoostExtraQuestions:
          (data['referralAiBoostExtraQuestions'] as num?)?.toInt() ?? 0,
      referralRewardGranted: data['referralRewardGranted'] as bool? ?? false,
    );
  }

  /// Called when a user completes their first genuine EOSB estimate.
  Future<void> tryGrantRewardsOnFirstEstimate(String uid) async {
    final userRef = _db.collection(_users).doc(uid);
    final userSnap = await userRef.get();
    if (!userSnap.exists) return;

    final userData = userSnap.data() ?? {};
    if (userData['referralRewardGranted'] == true) return;

    final referrerUid = userData['referredBy'] as String?;
    if (referrerUid == null || referrerUid.isEmpty) {
      await userRef.set({
        'referralRewardGranted': true,
        'firstEosbEstimateAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      return;
    }

    final referrerRef = _db.collection(_users).doc(referrerUid);
    final referralDocRef =
        referrerRef.collection(_referralsSub).doc(uid);

    try {
      await _db.runTransaction((tx) async {
        final freshUser = await tx.get(userRef);
        final freshReferrer = await tx.get(referrerRef);
        final referralDoc = await tx.get(referralDocRef);

        if (!freshUser.exists) return;
        final u = freshUser.data()!;
        if (u['referralRewardGranted'] == true) return;
        if (referralDoc.exists) {
          tx.set(userRef, {
            'referralRewardGranted': true,
            'firstEosbEstimateAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
          return;
        }

        if (!freshReferrer.exists) return;
        final r = freshReferrer.data()!;
        final count =
            (r['successfulReferralsCount'] as num?)?.toInt() ?? 0;
        if (count >= ReferralConfig.maxRewardableReferralsPerUser) {
          tx.set(userRef, {
            'referralRewardGranted': true,
            'firstEosbEstimateAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
          return;
        }

        if (!MonetizationState.referralPremiumRewardsEnabled) {
          final days = ReferralConfig.rewardPremiumDays;
          final extra = ReferralConfig.rewardAiBoostExtraQuestions;
          final now = DateTime.now();
          final userUntil = ReferralConfig.extendBoostExpiry(
            existingExpiry: _readTimestamp(u['referralAiBoostExpiresAt']),
            grantDays: days,
            now: now,
          );
          final referrerUntil = ReferralConfig.extendBoostExpiry(
            existingExpiry: _readTimestamp(r['referralAiBoostExpiresAt']),
            grantDays: days,
            now: now,
          );

          tx.set(userRef, {
            'referralRewardGranted': true,
            'firstEosbEstimateAt': FieldValue.serverTimestamp(),
            'referralAiBoostExpiresAt': Timestamp.fromDate(userUntil),
            'referralAiBoostExtraQuestions': extra,
          }, SetOptions(merge: true));

          tx.set(referrerRef, {
            'successfulReferralsCount': count + 1,
            'referralAiBoostExpiresAt': Timestamp.fromDate(referrerUntil),
            'referralAiBoostExtraQuestions': extra,
          }, SetOptions(merge: true));

          tx.set(referralDocRef, {
            'referredUid': uid,
            'rewardedAt': FieldValue.serverTimestamp(),
            'rewardType': 'referral_ai_boost',
            'boostDays': days,
            'boostExtraQuestions': extra,
          });
          return;
        }

        final days = ReferralConfig.rewardPremiumDays;
        final now = DateTime.now();
        final userUntil = _extendPremiumUntil(
          _readPremiumUntil(u['referralPremiumUntil']),
          days,
          now,
        );
        final referrerUntil = _extendPremiumUntil(
          _readPremiumUntil(r['referralPremiumUntil']),
          days,
          now,
        );

        tx.set(userRef, {
          'referralRewardGranted': true,
          'firstEosbEstimateAt': FieldValue.serverTimestamp(),
          'referralPremiumUntil': Timestamp.fromDate(userUntil),
          'isPremium': true,
          'subscriptionTier': ReferralConfig.rewardTier,
        }, SetOptions(merge: true));

        tx.set(referrerRef, {
          'successfulReferralsCount': count + 1,
          'referralPremiumUntil': Timestamp.fromDate(referrerUntil),
          'isPremium': true,
          'subscriptionTier': ReferralConfig.rewardTier,
        }, SetOptions(merge: true));

        tx.set(referralDocRef, {
          'referredUid': uid,
          'rewardedAt': FieldValue.serverTimestamp(),
          'premiumDays': days,
        });
      });

      final profile = await loadProfile(uid);
      if (MonetizationState.referralPremiumRewardsEnabled &&
          profile.referralPremiumUntil != null &&
          profile.referralPremiumUntil!.isAfter(DateTime.now())) {
        await _syncLocalPremiumFlag(true);
      }

      if (MonetizationState.referralPremiumRewardsEnabled) {
        await ReferralAnalyticsService.referralRewardGranted(
          referrerUid: referrerUid,
          referredUid: uid,
          rewardType: 'premium_days',
          durationDays: ReferralConfig.rewardPremiumDays,
        );
      } else {
        await ReferralAnalyticsService.referralRewardGranted(
          referrerUid: referrerUid,
          referredUid: uid,
          rewardType: 'ai_chat_boost',
          durationDays: ReferralConfig.rewardPremiumDays,
          extraQuestions: ReferralConfig.rewardAiBoostExtraQuestions,
        );
      }
    } catch (e, stack) {
      debugPrint('Referral reward grant failed: $e\n$stack');
    }
  }

  DateTime? _readTimestamp(dynamic raw) {
    if (raw is Timestamp) return raw.toDate();
    if (raw is String) return DateTime.tryParse(raw);
    return null;
  }

  DateTime? _readPremiumUntil(dynamic raw) => _readTimestamp(raw);

  DateTime _extendPremiumUntil(
    DateTime? existing,
    int days,
    DateTime now,
  ) {
    final base = (existing != null && existing.isAfter(now))
        ? existing
        : now;
    return base.add(Duration(days: days));
  }

  Future<void> _syncLocalPremiumFlag(bool isPremium) async {
    if (!MonetizationState.grantsPaidEntitlements) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_premium_user', isPremium);
    } catch (_) {}
  }
}
