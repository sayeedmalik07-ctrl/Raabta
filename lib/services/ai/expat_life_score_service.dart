import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/services/ai/user_profile_ai_service.dart';
import 'package:raabta/services/firebase_service.dart';

// ---------------------------------------------------------------------------
// Models
// ---------------------------------------------------------------------------

class ScoreAction {
  const ScoreAction({
    required this.title,
    required this.description,
    required this.pointsGain,
    required this.actionType,
    required this.estimatedTime,
  });

  final String title;
  final String description;
  final int pointsGain;
  final String actionType;
  final String estimatedTime;

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'pointsGain': pointsGain,
        'actionType': actionType,
        'estimatedTime': estimatedTime,
      };
}

class Achievement {
  const Achievement({
    required this.id,
    required this.title,
    required this.emoji,
    required this.unlocked,
    this.unlockedAt,
  });

  final String id;
  final String title;
  final String emoji;
  final bool unlocked;
  final DateTime? unlockedAt;

  Achievement copyWith({bool? unlocked, DateTime? unlockedAt}) {
    return Achievement(
      id: id,
      title: title,
      emoji: emoji,
      unlocked: unlocked ?? this.unlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'emoji': emoji,
        'unlocked': unlocked,
        if (unlockedAt != null) 'unlockedAt': unlockedAt!.toIso8601String(),
      };

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      emoji: json['emoji'] as String? ?? '🏅',
      unlocked: json['unlocked'] as bool? ?? false,
      unlockedAt: json['unlockedAt'] != null
          ? DateTime.tryParse(json['unlockedAt'] as String)
          : null,
    );
  }
}

class AchievementCheckResult {
  const AchievementCheckResult({
    required this.achievements,
    required this.newlyUnlocked,
  });

  final List<Achievement> achievements;
  final List<Achievement> newlyUnlocked;
}

class ExpatScoreState {
  const ExpatScoreState({
    this.score,
    this.achievements = const [],
    this.improvementActions = const [],
    this.pendingNotifications = const [],
  });

  final ExpatLifeScore? score;
  final List<Achievement> achievements;
  final List<ScoreAction> improvementActions;
  final List<Achievement> pendingNotifications;

  ExpatScoreState copyWith({
    ExpatLifeScore? score,
    List<Achievement>? achievements,
    List<ScoreAction>? improvementActions,
    List<Achievement>? pendingNotifications,
  }) {
    return ExpatScoreState(
      score: score ?? this.score,
      achievements: achievements ?? this.achievements,
      improvementActions: improvementActions ?? this.improvementActions,
      pendingNotifications: pendingNotifications ?? this.pendingNotifications,
    );
  }
}

/// Engagement flags stored in [UserAIProfile.interests] using `key:value` tags.
class _ProfileSignals {
  _ProfileSignals.fromProfile(UserAIProfile profile)
      : profile = profile,
        interestSet = profile.interests.map((e) => e.toLowerCase()).toSet();

  final UserAIProfile profile;
  final Set<String> interestSet;

  bool hasFlag(String key) =>
      interestSet.contains(key.toLowerCase()) ||
      interestSet.any((i) => i.startsWith('$key:'));

  int countFlag(String prefix) {
    for (final interest in interestSet) {
      if (interest.startsWith('$prefix:')) {
        return int.tryParse(interest.split(':').last) ?? 0;
      }
    }
    return hasFlag(prefix) ? 1 : 0;
  }

  bool get housingConfirmed => hasFlag('profile:housing_confirmed');
  bool get housingReviewWritten => hasFlag('profile:housing_review');
  bool get moneyTransferSet => hasFlag('profile:money_transfer');
  bool get exchangeAlertsActive => hasFlag('profile:exchange_alerts');
  bool get savingsGoalSet => hasFlag('profile:savings_goal');
  bool get insuranceStatusConfirmed => hasFlag('profile:insurance_status');
  bool get doctorPreferenceSet => hasFlag('profile:doctor_preference');
  bool get medicalInsuranceConfirmed => hasFlag('profile:medical_insurance');
  bool get emergencyContactsSaved => hasFlag('profile:emergency_contacts');
  bool get iqamaExpirySet => hasFlag('profile:iqama_expiry');
  bool get passportExpirySet => hasFlag('profile:passport_expiry');
  bool get qidInfoAdded => hasFlag('profile:qid_info');
  bool get workPermitTracked => hasFlag('profile:work_permit');

  int get communityPostCount => countFlag('profile:community_posts');
  int get questionsAnswered => countFlag('profile:questions_answered');
  int get eventsAttended => countFlag('profile:events_attended');
  int get referralCount => countFlag('profile:referral_count');

  bool get budgetRangeSet {
    final min = profile.budgetRange['min'] ?? 0;
    final max = profile.budgetRange['max'] ?? 0;
    return min > 0 || max > 0;
  }

  bool get preferredAreaSet =>
      profile.preferredArea.trim().isNotEmpty &&
      profile.preferredArea.toLowerCase() != 'unknown';
}

// ---------------------------------------------------------------------------
// Service
// ---------------------------------------------------------------------------

class ExpatLifeScoreService {
  ExpatLifeScoreService({FirebaseFirestore? firestore})
      : _firestore = FirebaseService.isReady
            ? (firestore ?? FirebaseFirestore.instance)
            : null;

  final FirebaseFirestore? _firestore;

  static final _launchMonth = DateTime(2025, 6, 1);

  /// Calculates the full expat life score including growth metrics.
  Future<ExpatLifeScore> calculateScore(UserAIProfile profile) async {
    final signals = _ProfileSignals.fromProfile(profile);
    final breakdown = _calculateBreakdown(signals);

    final career = breakdown['career']!;
    final housing = breakdown['housing']!;
    final financial = breakdown['financial']!;
    final community = breakdown['community']!;
    final health = breakdown['health']!;
    final documentation = breakdown['documentation']!;

    final total = (career + housing + financial + community + health + documentation)
        .clamp(0, 100)
        .toDouble();

    final weeklyGrowth = await _calculateWeeklyGrowth(profile.uid, total);
    final monthlyGrowth = await _calculateMonthlyGrowth(profile.uid, total);

    await _saveScoreSnapshot(profile.uid, total);

    return ExpatLifeScore(
      total: total,
      career: career,
      housing: housing,
      financial: financial,
      community: community,
      health: health,
      documentation: documentation,
      level: _resolveLevel(total),
      weeklyGrowth: weeklyGrowth,
      monthlyGrowth: monthlyGrowth,
      lastCalculated: DateTime.now(),
    );
  }

  /// Returns prioritized actions that would increase the score the most.
  List<ScoreAction> getImprovementActions(UserAIProfile profile) {
    final signals = _ProfileSignals.fromProfile(profile);
    final actions = <ScoreAction>[];

    if (!signals.iqamaExpirySet) {
      actions.add(
        const ScoreAction(
          title: 'Set your Iqama expiry date',
          description: 'Get reminders before your Iqama expires',
          pointsGain: 3,
          actionType: 'set_reminder',
          estimatedTime: '1 min',
        ),
      );
    }

    if (profile.communityGroups.isEmpty) {
      final groupName = _suggestedCommunityGroup(profile.nationality);
      actions.add(
        ScoreAction(
          title: 'Join $groupName group',
          description: 'Connect with expats who share your background',
          pointsGain: 5,
          actionType: 'join_group',
          estimatedTime: '1 tap',
        ),
      );
    }

    if (profile.skills.length < 3) {
      actions.add(
        const ScoreAction(
          title: 'Complete your skills profile',
          description:
              'Add HSE, safety or other skills to improve job matches',
          pointsGain: 5,
          actionType: 'fill_profile',
          estimatedTime: '2 min',
        ),
      );
    }

    if (profile.profession.trim().isEmpty) {
      actions.add(
        const ScoreAction(
          title: 'Add your profession',
          description: 'Help Raabta AI personalize jobs and services for you',
          pointsGain: 5,
          actionType: 'fill_profile',
          estimatedTime: '1 min',
        ),
      );
    }

    if (profile.certifications.isEmpty) {
      actions.add(
        const ScoreAction(
          title: 'Add certifications',
          description: 'NEBOSH, IOSH and other certs boost career score',
          pointsGain: 5,
          actionType: 'fill_profile',
          estimatedTime: '2 min',
        ),
      );
    }

    if (profile.viewedJobIds.length < 5) {
      actions.add(
        const ScoreAction(
          title: 'Explore job listings',
          description: 'View 5+ jobs to activate your job search score',
          pointsGain: 5,
          actionType: 'fill_profile',
          estimatedTime: '5 min',
        ),
      );
    }

    if (profile.savedJobIds.isEmpty) {
      actions.add(
        const ScoreAction(
          title: 'Save a job you like',
          description: 'Saved jobs count toward your career engagement score',
          pointsGain: 5,
          actionType: 'fill_profile',
          estimatedTime: '1 min',
        ),
      );
    }

    if (!signals.housingConfirmed) {
      actions.add(
        const ScoreAction(
          title: 'Confirm your current housing',
          description: 'Unlock housing insights tailored to your area',
          pointsGain: 8,
          actionType: 'fill_profile',
          estimatedTime: '2 min',
        ),
      );
    }

    if (profile.savedHousingIds.isEmpty && profile.viewedHousingIds.isEmpty) {
      actions.add(
        const ScoreAction(
          title: 'Browse housing listings',
          description: 'Search and save listings to improve housing score',
          pointsGain: 5,
          actionType: 'fill_profile',
          estimatedTime: '3 min',
        ),
      );
    }

    if (!signals.budgetRangeSet) {
      actions.add(
        const ScoreAction(
          title: 'Set your monthly budget',
          description: 'Get better housing and salary recommendations',
          pointsGain: 5,
          actionType: 'fill_profile',
          estimatedTime: '1 min',
        ),
      );
    }

    if (!signals.moneyTransferSet) {
      actions.add(
        const ScoreAction(
          title: 'Set money transfer preference',
          description: 'Track remittance options on the Money screen',
          pointsGain: 5,
          actionType: 'fill_profile',
          estimatedTime: '2 min',
        ),
      );
    }

    if (!signals.exchangeAlertsActive) {
      actions.add(
        const ScoreAction(
          title: 'Enable exchange rate alerts',
          description: 'Stay updated on QAR exchange rates',
          pointsGain: 5,
          actionType: 'set_reminder',
          estimatedTime: '1 min',
        ),
      );
    }

    if (signals.questionsAnswered == 0) {
      actions.add(
        const ScoreAction(
          title: 'Answer a question on Ask Qatar',
          description: 'Help fellow expats and boost community score',
          pointsGain: 3,
          actionType: 'join_group',
          estimatedTime: '2 min',
        ),
      );
    }

    if (!signals.doctorPreferenceSet) {
      actions.add(
        const ScoreAction(
          title: 'Set doctor language preference',
          description: 'Find doctors who speak your language',
          pointsGain: 5,
          actionType: 'fill_profile',
          estimatedTime: '1 min',
        ),
      );
    }

    if (!signals.passportExpirySet) {
      actions.add(
        const ScoreAction(
          title: 'Add passport expiry date',
          description: 'Never miss a renewal deadline',
          pointsGain: 3,
          actionType: 'set_reminder',
          estimatedTime: '1 min',
        ),
      );
    }

    if (signals.referralCount < 5) {
      actions.add(
        ScoreAction(
          title: 'Refer a friend to Raabta',
          description:
              'Earn points — ${5 - signals.referralCount} more referrals to unlock Ambassador',
          pointsGain: 5,
          actionType: 'refer_friend',
          estimatedTime: '1 min',
        ),
      );
    }

    actions.sort((a, b) => b.pointsGain.compareTo(a.pointsGain));
    return actions.take(8).toList();
  }

  /// Checks achievements, persists unlocks, and returns newly unlocked items.
  Future<AchievementCheckResult> checkAchievements(UserAIProfile profile) async {
    final signals = _ProfileSignals.fromProfile(profile);
    final score = profile.score.total;

    final definitions = _achievementDefinitions(profile, signals, score);
    final stored = await _loadStoredAchievements(profile.uid);

    final results = <Achievement>[];
    final newlyUnlocked = <Achievement>[];

    for (final def in definitions) {
      final existing = stored[def.id];
      final wasUnlocked = existing?.unlocked ?? false;
      final isUnlocked = def.unlocked || wasUnlocked;

      Achievement achievement;
      if (isUnlocked && !wasUnlocked) {
        achievement = def.copyWith(
          unlocked: true,
          unlockedAt: DateTime.now(),
        );
        newlyUnlocked.add(achievement);
        await _saveAchievement(profile.uid, achievement);
        _notifyAchievementUnlocked(achievement);
      } else if (existing != null) {
        achievement = existing;
      } else {
        achievement = def;
        if (isUnlocked) {
          await _saveAchievement(profile.uid, def);
        }
      }

      results.add(achievement);
    }

    return AchievementCheckResult(
      achievements: results,
      newlyUnlocked: newlyUnlocked,
    );
  }

  // -------------------------------------------------------------------------
  // Category scoring
  // -------------------------------------------------------------------------

  Map<String, double> _calculateBreakdown(_ProfileSignals signals) {
    return {
      'career': _scoreCareer(signals),
      'housing': _scoreHousing(signals),
      'financial': _scoreFinancial(signals),
      'community': _scoreCommunity(signals),
      'health': _scoreHealth(signals),
      'documentation': _scoreDocumentation(signals),
    };
  }

  double _scoreCareer(_ProfileSignals signals) {
    var score = 0.0;
    final profile = signals.profile;

    if (profile.profession.trim().isNotEmpty) score += 5;
    if (profile.skills.length >= 3) score += 5;
    if (profile.certifications.isNotEmpty) score += 5;
    if (profile.viewedJobIds.length >= 5) score += 5;
    if (profile.savedJobIds.isNotEmpty) score += 5;

    return score.clamp(0, 25);
  }

  double _scoreHousing(_ProfileSignals signals) {
    var score = 0.0;
    final profile = signals.profile;

    if (signals.preferredAreaSet) score += 5;
    if (signals.housingConfirmed) score += 8;
    if (profile.savedHousingIds.isNotEmpty ||
        profile.viewedHousingIds.length >= 3) {
      score += 5;
    }
    if (signals.housingReviewWritten) score += 2;

    return score.clamp(0, 20);
  }

  double _scoreFinancial(_ProfileSignals signals) {
    var score = 0.0;

    if (signals.budgetRangeSet) score += 5;
    if (signals.moneyTransferSet) score += 5;
    if (signals.exchangeAlertsActive) score += 5;
    if (signals.savingsGoalSet) score += 3;
    if (signals.insuranceStatusConfirmed) score += 2;

    return score.clamp(0, 20);
  }

  double _scoreCommunity(_ProfileSignals signals) {
    var score = 0.0;
    final groups = signals.profile.communityGroups.length;

    if (groups >= 1) score += 5;
    if (groups >= 3) score += 3;
    if (signals.communityPostCount > 0) score += 2;
    if (signals.questionsAnswered > 0) score += 3;
    if (signals.eventsAttended > 0) score += 2;

    return score.clamp(0, 15);
  }

  double _scoreHealth(_ProfileSignals signals) {
    var score = 0.0;

    if (signals.doctorPreferenceSet) score += 5;
    if (signals.medicalInsuranceConfirmed) score += 3;
    if (signals.emergencyContactsSaved) score += 2;

    return score.clamp(0, 10);
  }

  double _scoreDocumentation(_ProfileSignals signals) {
    var score = 0.0;

    if (signals.iqamaExpirySet) score += 3;
    if (signals.passportExpirySet) score += 3;
    if (signals.qidInfoAdded) score += 2;
    if (signals.workPermitTracked) score += 2;

    return score.clamp(0, 10);
  }

  String _resolveLevel(double total) {
    if (total <= 20) return 'New Arrival 🆕';
    if (total <= 40) return 'Settling In 🏠';
    if (total <= 60) return 'Growing Strong 📈';
    if (total <= 80) return 'Established Resident 🏆';
    return 'Qatar Pro ⭐';
  }

  // -------------------------------------------------------------------------
  // Score history (Firestore)
  // -------------------------------------------------------------------------

  CollectionReference<Map<String, dynamic>>? _scoreHistoryRef(String uid) {
    if (_firestore == null) return null;
    return _firestore.collection('users').doc(uid).collection('score_history');
  }

  CollectionReference<Map<String, dynamic>>? _achievementsRef(String uid) {
    if (_firestore == null) return null;
    return _firestore.collection('users').doc(uid).collection('achievements');
  }

  Future<void> _saveScoreSnapshot(String uid, double total) async {
    final ref = _scoreHistoryRef(uid);
    if (ref == null) return;

    final now = DateTime.now();
    final docId = _dateKey(now);

    try {
      await ref.doc(docId).set({
        'total': total,
        'recordedAt': now.toIso8601String(),
        'weekDate': docId,
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('ExpatLifeScoreService: score snapshot save failed — $e');
    }
  }

  Future<double> _calculateWeeklyGrowth(String uid, double currentTotal) async {
    final past = await _fetchScoreNearDate(
      uid,
      DateTime.now().subtract(const Duration(days: 7)),
    );
    if (past == null) return 0;
    return currentTotal - past;
  }

  Future<double> _calculateMonthlyGrowth(String uid, double currentTotal) async {
    final past = await _fetchScoreNearDate(
      uid,
      DateTime.now().subtract(const Duration(days: 30)),
    );
    if (past == null) return 0;
    return currentTotal - past;
  }

  Future<double?> _fetchScoreNearDate(String uid, DateTime targetDate) async {
    final ref = _scoreHistoryRef(uid);
    if (ref == null) return null;

    try {
      final targetKey = _dateKey(targetDate);
      final exact = await ref.doc(targetKey).get();
      if (exact.exists && exact.data()?['total'] != null) {
        return (exact.data()!['total'] as num).toDouble();
      }

      final snapshot = await ref
          .where(
            'recordedAt',
            isLessThanOrEqualTo: targetDate.toIso8601String(),
          )
          .orderBy('recordedAt', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;
      return (snapshot.docs.first.data()['total'] as num?)?.toDouble();
    } catch (e) {
      debugPrint('ExpatLifeScoreService: score history fetch failed — $e');
      return null;
    }
  }

  String _dateKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  // -------------------------------------------------------------------------
  // Achievements
  // -------------------------------------------------------------------------

  List<Achievement> _achievementDefinitions(
    UserAIProfile profile,
    _ProfileSignals signals,
    double score,
  ) {
    final allDocsTracked = signals.iqamaExpirySet &&
        signals.passportExpirySet &&
        signals.qidInfoAdded &&
        signals.workPermitTracked;

    return [
      Achievement(
        id: 'early_adopter',
        title: 'Early Adopter',
        emoji: '🌟',
        unlocked: profile.lastUpdated.isBefore(_launchMonth.add(const Duration(days: 31))),
      ),
      Achievement(
        id: 'job_seeker',
        title: 'Job Seeker',
        emoji: '💼',
        unlocked: profile.viewedJobIds.length >= 10,
      ),
      Achievement(
        id: 'home_hunter',
        title: 'Home Hunter',
        emoji: '🏠',
        unlocked: profile.savedHousingIds.length >= 3,
      ),
      Achievement(
        id: 'connector',
        title: 'Connector',
        emoji: '🤝',
        unlocked: profile.communityGroups.length >= 3,
      ),
      Achievement(
        id: 'community_star',
        title: 'Community Star',
        emoji: '⭐',
        unlocked: signals.communityPostCount >= 5,
      ),
      Achievement(
        id: 'document_pro',
        title: 'Document Pro',
        emoji: '📋',
        unlocked: allDocsTracked,
      ),
      Achievement(
        id: 'ambassador',
        title: 'Ambassador',
        emoji: '🌍',
        unlocked: signals.referralCount >= 5,
      ),
      Achievement(
        id: 'qatar_pro',
        title: 'Qatar Pro',
        emoji: '🏆',
        unlocked: score >= 80,
      ),
    ];
  }

  Future<Map<String, Achievement>> _loadStoredAchievements(String uid) async {
    final ref = _achievementsRef(uid);
    if (ref == null) return {};

    try {
      final snapshot = await ref.get();
      return {
        for (final doc in snapshot.docs)
          doc.id: Achievement.fromJson({...doc.data(), 'id': doc.id}),
      };
    } catch (e) {
      debugPrint('ExpatLifeScoreService: achievements load failed — $e');
      return {};
    }
  }

  Future<void> _saveAchievement(String uid, Achievement achievement) async {
    final ref = _achievementsRef(uid);
    if (ref == null) return;

    try {
      await ref.doc(achievement.id).set(achievement.toJson(), SetOptions(merge: true));
    } catch (e) {
      debugPrint('ExpatLifeScoreService: achievement save failed — $e');
    }
  }

  void _notifyAchievementUnlocked(Achievement achievement) {
    debugPrint(
      '🏅 Achievement unlocked: ${achievement.emoji} ${achievement.title}',
    );
  }

  String _suggestedCommunityGroup(String nationality) {
    final lower = nationality.toLowerCase();
    if (lower.contains('india')) return 'Indians in Qatar';
    if (lower.contains('pakistan')) return 'Pakistanis in Qatar';
    if (lower.contains('bangladesh')) return 'Bangladeshis in Qatar';
    if (lower.contains('nepal')) return 'Nepalis in Qatar';
    if (lower.contains('philippine') || lower.contains('filipino')) {
      return 'Filipinos in Qatar';
    }
    if (lower.contains('kenya')) return 'Kenyans in Qatar';
    return 'your community';
  }
}

// ---------------------------------------------------------------------------
// Riverpod
// ---------------------------------------------------------------------------

final expatLifeScoreServiceProvider = Provider<ExpatLifeScoreService>((ref) {
  return ExpatLifeScoreService();
});

final expatLifeScoreProvider =
    StateNotifierProvider<ExpatLifeScoreNotifier, ExpatScoreState>((ref) {
  return ExpatLifeScoreNotifier(ref.watch(expatLifeScoreServiceProvider));
});

class ExpatLifeScoreNotifier extends StateNotifier<ExpatScoreState> {
  ExpatLifeScoreNotifier(this._service) : super(const ExpatScoreState());

  final ExpatLifeScoreService _service;

  /// Recalculates score, achievements, and improvement actions.
  Future<void> refresh(UserAIProfile profile) async {
    final score = await _service.calculateScore(profile);
    final actions = _service.getImprovementActions(
      profile.copyWith(score: score),
    );
    final achievementResult = await _service.checkAchievements(
      profile.copyWith(score: score),
    );

    state = ExpatScoreState(
      score: score,
      achievements: achievementResult.achievements,
      improvementActions: actions,
      pendingNotifications: achievementResult.newlyUnlocked,
    );
  }

  /// Clears pending achievement notifications after UI displays them.
  void clearPendingNotifications() {
    state = state.copyWith(pendingNotifications: const []);
  }

  List<ScoreAction> get improvementActions => state.improvementActions;

  List<Achievement> get achievements => state.achievements;

  ExpatLifeScore? get score => state.score;
}
