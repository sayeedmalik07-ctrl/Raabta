import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:raabta/features/concierge_90_day/data/models/journey_milestone.dart';
import 'package:raabta/features/concierge_90_day/data/models/journey_progress.dart';
import 'package:raabta/features/eosb/data/eosb_repository.dart';
import 'package:raabta/features/health_insurance/data/repository/health_insurance_repository.dart';
import 'package:raabta/features/onboarding/services/onboarding_service.dart';
import 'package:raabta/services/ai/user_profile_ai_service.dart';
import 'package:raabta/services/firebase_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Detects milestone completion from existing Raabta data where practical.
class ConciergeCompletionDetector {
  ConciergeCompletionDetector({
    required this.onboarding,
    this.eosbRepository,
    this.healthInsuranceRepository,
  });

  final OnboardingService onboarding;
  final EosbRepository? eosbRepository;
  final HealthInsuranceRepository? healthInsuranceRepository;

  Future<Map<String, MilestoneStatus>> detectAutoCompletions({
    UserAIProfile? profile,
    bool hasScannedDocuments = false,
  }) async {
    final map = <String, MilestoneStatus>{};

    if (profile != null && _profileBasicsComplete(profile)) {
      map[JourneyMilestoneId.profileBasics.name] = MilestoneStatus.completed;
    }

    if (await onboarding.isCompletedLocally()) {
      map[JourneyMilestoneId.eosbOnboarding.name] = MilestoneStatus.completed;
    }

    final eosbInput = eosbRepository?.loadCachedInput();
    if (eosbInput != null && eosbInput.basicSalary > 0) {
      map[JourneyMilestoneId.eosbRevisit.name] = MilestoneStatus.completed;
    }

    if (healthInsuranceRepository?.hasCompletedComplianceCheck() ?? false) {
      map[JourneyMilestoneId.healthInsurance.name] = MilestoneStatus.completed;
    }

    if (hasScannedDocuments) {
      map[JourneyMilestoneId.documentVault.name] = MilestoneStatus.completed;
    }

    return map;
  }

  bool _profileBasicsComplete(UserAIProfile profile) {
    return profile.nationality.trim().isNotEmpty &&
        profile.profession.trim().isNotEmpty;
  }
}

class ConciergeJourneyRepository {
  ConciergeJourneyRepository(this._firestore);

  final FirebaseFirestore _firestore;

  static const collection = 'users';
  static const subDoc = 'onboarding_journey';
  static const progressDoc = 'progress';

  DocumentReference<Map<String, dynamic>> _progressRef(String uid) =>
      _firestore
          .collection(collection)
          .doc(uid)
          .collection(subDoc)
          .doc(progressDoc);

  Stream<JourneyProgress> watchProgress(String uid) {
    return _progressRef(uid).snapshots().map((snap) {
      if (!snap.exists || snap.data() == null) {
        return JourneyProgress();
      }
      return JourneyProgress.fromJson(snap.data()!);
    });
  }

  Future<JourneyProgress> loadProgress(String uid) async {
    try {
      final snap = await _progressRef(uid).get();
      if (!snap.exists || snap.data() == null) {
        return await _seedFromUserDoc(uid);
      }
      return JourneyProgress.fromJson(snap.data()!);
    } catch (_) {
      return JourneyProgress();
    }
  }

  Future<JourneyProgress> _seedFromUserDoc(String uid) async {
    DateTime? createdAt;
    if (FirebaseService.isReady) {
      try {
        final userSnap =
            await _firestore.collection(collection).doc(uid).get();
        final ts = userSnap.data()?['createdAt'];
        if (ts is Timestamp) createdAt = ts.toDate();
      } catch (_) {}
    }
    final progress = JourneyProgress(accountCreatedAt: createdAt);
    await saveProgress(uid, progress);
    return progress;
  }

  Future<void> saveProgress(String uid, JourneyProgress progress) async {
    if (!FirebaseService.isReady) return;
    try {
      await _progressRef(uid).set(progress.toJson(), SetOptions(merge: true));
    } catch (_) {}
  }

  Future<JourneyProgress> mergeAutoDetections(
    String uid,
    Map<String, MilestoneStatus> detected,
    JourneyProgress current,
  ) async {
    if (detected.isEmpty) return current;
    final milestones = Map<String, MilestoneProgressEntry>.from(current.milestones);
    var changed = false;
    for (final entry in detected.entries) {
      final existing = milestones[entry.key];
      if (existing?.status == MilestoneStatus.completed ||
          existing?.status == MilestoneStatus.notApplicable) {
        continue;
      }
      if (entry.value == MilestoneStatus.completed) {
        milestones[entry.key] = MilestoneProgressEntry(
          status: MilestoneStatus.completed,
          completedAt: DateTime.now(),
        );
        changed = true;
      }
    }
    if (!changed) return current;
    final updated = current.copyWith(milestones: milestones);
    await saveProgress(uid, updated);
    return updated;
  }

  Future<void> markMilestone(
    String uid,
    JourneyMilestoneId id,
    MilestoneStatus status,
    JourneyProgress current,
  ) async {
    final milestones = Map<String, MilestoneProgressEntry>.from(current.milestones);
    milestones[id.name] = MilestoneProgressEntry(
      status: status,
      completedAt: status == MilestoneStatus.completed ? DateTime.now() : null,
    );
    await saveProgress(uid, current.copyWith(milestones: milestones));
  }

  Future<void> setArrivalDate(
    String uid,
    DateTime? date, {
    bool skipped = false,
    required JourneyProgress current,
  }) async {
    await saveProgress(
      uid,
      current.copyWith(
        arrivalDate: date,
        arrivalDateSkipped: skipped,
        clearArrivalDate: date == null && skipped,
      ),
    );
  }

  Future<void> disableConcierge(String uid, JourneyProgress current) async {
    await saveProgress(uid, current.copyWith(conciergeDisabled: true));
  }

  Future<bool> hasScannedDocuments(String uid) async {
    if (!FirebaseService.isReady) return false;
    try {
      final snap = await _firestore
          .collection('scanned_documents')
          .where('userId', isEqualTo: uid)
          .limit(1)
          .get();
      return snap.docs.isNotEmpty;
    } catch (_) {
      return false;
    }
  }
}

Future<ConciergeJourneyRepository> createConciergeRepository() async {
  return ConciergeJourneyRepository(FirebaseFirestore.instance);
}

Future<ConciergeCompletionDetector> createCompletionDetector() async {
  final prefs = await SharedPreferences.getInstance();
  return ConciergeCompletionDetector(
    onboarding: OnboardingService.instance,
    eosbRepository: EosbRepository(prefs),
    healthInsuranceRepository: HealthInsuranceRepository(prefs),
  );
}
