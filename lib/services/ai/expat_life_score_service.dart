import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/features/visa/data/deadline_tracker_repository.dart';
import 'package:raabta/services/ai/expat_score_live_calculator.dart';
import 'package:raabta/services/ai/expat_score_live_inputs_loader.dart';
import 'package:raabta/services/ai/expat_score_signal_enricher.dart';
import 'package:raabta/features/home/l10n/home_recommendation_strings.dart';
import 'package:raabta/services/ai/user_profile_ai_service.dart';
import 'package:raabta/services/firebase_service.dart';

// ---------------------------------------------------------------------------
// Models
// ---------------------------------------------------------------------------

/// Neutral routing target for Expat Score actions — not localized display text.
abstract final class ExpatScoreRouteTarget {
  static const community = 'community';
  static const visa = 'visa';
  static const jobs = 'jobs';
  static const refer = 'refer';
  static const tool = 'tool';
}

class ScoreAction {
  const ScoreAction({
    required this.title,
    required this.description,
    required this.pointsGain,
    required this.actionType,
    required this.estimatedTime,
    this.routeTarget = ExpatScoreRouteTarget.tool,
  });

  final String title;
  final String description;
  final int pointsGain;
  final String actionType;
  final String estimatedTime;
  final String routeTarget;

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'pointsGain': pointsGain,
        'actionType': actionType,
        'estimatedTime': estimatedTime,
        'routeTarget': routeTarget,
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

class ExpatScoreHistoryPoint {
  const ExpatScoreHistoryPoint({
    required this.date,
    required this.total,
  });

  final DateTime date;
  final double total;
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
    // Ignore factory default max-only ranges — user must set a real minimum.
    return min > 0;
  }

  bool get preferredAreaSet =>
      profile.preferredArea.trim().isNotEmpty &&
      profile.preferredArea.toLowerCase() != 'unknown';
}

// ---------------------------------------------------------------------------
// Service
// ---------------------------------------------------------------------------

class ExpatLifeScoreService {
  ExpatLifeScoreService({
    FirebaseFirestore? firestore,
    DeadlineTrackerRepository? deadlineRepo,
  })  : _firestore = FirebaseService.isReady
            ? (firestore ?? FirebaseFirestore.instance)
            : null,
        _deadlineRepo = deadlineRepo ?? DeadlineTrackerRepository();

  final FirebaseFirestore? _firestore;
  final DeadlineTrackerRepository _deadlineRepo;

  DeadlineTrackerRepository get deadlineRepo => _deadlineRepo;

  static final _launchMonth = DateTime(2025, 6, 1);

  /// Calculates the full expat life score from live repository data.
  ///
  /// Pass [preloadedInputs] in tests to avoid Firestore/SharedPreferences I/O.
  Future<ExpatLifeScore> calculateScore(
    UserAIProfile profile, {
    bool interestsEnriched = false,
    ExpatScoreLiveInputs? preloadedInputs,
  }) async {
    final scoringProfile = interestsEnriched
        ? profile
        : profile.copyWith(
            interests: await ExpatScoreSignalEnricher.enrichInterests(
              profile: profile,
              deadlineRepo: _deadlineRepo,
            ),
          );

    final baseInputs = preloadedInputs ??
        await ExpatScoreLiveInputsLoader.load(
          profile: scoringProfile,
          firestore: _firestore,
          deadlineRepo: _deadlineRepo,
        );

    final scoredRisks = scoreRisksForExpatInputs(baseInputs);
    final consistencyInsights = scoreConsistencyForExpatInputs(baseInputs);
    final inputs = baseInputs.copyWith(
      scoredRisks: scoredRisks,
      consistencyInsights: consistencyInsights,
    );

    final liveResult = const ExpatScoreLiveCalculator().compute(inputs);
    return _finalizeScore(scoringProfile.uid, liveResult);
  }

  Future<ExpatLifeScore> _finalizeScore(
    String uid,
    ExpatScoreLiveResult liveResult,
  ) async {
    final breakdown = liveResult.breakdown;

    final career = breakdown['career']!;
    final housing = breakdown['housing']!;
    final financial = breakdown['financial']!;
    final community = breakdown['community']!;
    final health = breakdown['health']!;
    final documentation = breakdown['documentation']!;

    final total = (career + housing + financial + community + health + documentation)
        .clamp(0, 100)
        .toDouble();

    final weeklyGrowth = await _calculateWeeklyGrowth(uid, total);
    final monthlyGrowth = await _calculateMonthlyGrowth(uid, total);

    await _saveScoreSnapshot(uid, total, breakdown);

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
      categoryMeta: liveResult.categoryMeta,
    );
  }

  /// Recent daily score snapshots for trend charts (oldest → newest).
  Future<List<ExpatScoreHistoryPoint>> fetchRecentHistory(
    String uid, {
    int limit = 14,
  }) async {
    final ref = _scoreHistoryRef(uid);
    if (ref == null || uid.isEmpty) return const [];

    try {
      final snapshot = await ref
          .orderBy('recordedAt', descending: true)
          .limit(limit)
          .get();

      final points = snapshot.docs.map((doc) {
        final data = doc.data();
        final recordedAt = data['recordedAt'];
        DateTime date;
        if (recordedAt is String) {
          date = DateTime.tryParse(recordedAt) ?? DateTime.now();
        } else {
          date = DateTime.now();
        }
        return ExpatScoreHistoryPoint(
          date: date,
          total: (data['total'] as num?)?.toDouble() ?? 0,
        );
      }).toList();

      return points.reversed.toList();
    } catch (e) {
      debugPrint('ExpatLifeScoreService: history fetch failed — $e');
      return const [];
    }
  }

  /// Returns prioritized actions that would increase the score the most.
  List<ScoreAction> getImprovementActions(
    UserAIProfile profile, {
    String locale = 'English',
  }) {
    final signals = _ProfileSignals.fromProfile(profile);
    final actions = <ScoreAction>[];

    ScoreAction localized({
      required String titleKey,
      required String descKey,
      required String timeKey,
      required int pointsGain,
      required String actionType,
      String routeTarget = ExpatScoreRouteTarget.tool,
      Map<String, String> params = const {},
    }) {
      return ScoreAction(
        title: HomeRecommendationStrings.format(titleKey, locale, params: params),
        description:
            HomeRecommendationStrings.format(descKey, locale, params: params),
        pointsGain: pointsGain,
        actionType: actionType,
        estimatedTime: HomeRecommendationStrings.t(timeKey, locale),
        routeTarget: routeTarget,
      );
    }

    if (!signals.iqamaExpirySet) {
      actions.add(
        localized(
          titleKey: 'improve_iqama_title',
          descKey: 'improve_iqama_desc',
          timeKey: 'time_1_min',
          pointsGain: 3,
          actionType: 'set_reminder',
          routeTarget: ExpatScoreRouteTarget.visa,
        ),
      );
    }

    if (profile.communityGroups.isEmpty) {
      final groupName = _suggestedCommunityGroup(profile.nationality, locale);
      actions.add(
        localized(
          titleKey: 'improve_join_group_title',
          descKey: 'improve_join_group_desc',
          timeKey: 'time_1_tap',
          pointsGain: 5,
          actionType: 'join_group',
          routeTarget: ExpatScoreRouteTarget.community,
          params: {'groupName': groupName},
        ),
      );
    }

    if (profile.skills.length < 3) {
      actions.add(
        localized(
          titleKey: 'improve_skills_title',
          descKey: 'improve_skills_desc',
          timeKey: 'time_2_min',
          pointsGain: 5,
          actionType: 'fill_profile',
        ),
      );
    }

    if (profile.profession.trim().isEmpty) {
      actions.add(
        localized(
          titleKey: 'improve_profession_title',
          descKey: 'improve_profession_desc',
          timeKey: 'time_1_min',
          pointsGain: 5,
          actionType: 'fill_profile',
        ),
      );
    }

    if (profile.certifications.isEmpty) {
      actions.add(
        localized(
          titleKey: 'improve_certs_title',
          descKey: 'improve_certs_desc',
          timeKey: 'time_2_min',
          pointsGain: 5,
          actionType: 'fill_profile',
        ),
      );
    }

    if (profile.viewedJobIds.length < 5) {
      actions.add(
        localized(
          titleKey: 'improve_explore_jobs_title',
          descKey: 'improve_explore_jobs_desc',
          timeKey: 'time_5_min',
          pointsGain: 5,
          actionType: 'fill_profile',
          routeTarget: ExpatScoreRouteTarget.jobs,
        ),
      );
    }

    if (profile.savedJobIds.isEmpty) {
      actions.add(
        localized(
          titleKey: 'improve_save_job_title',
          descKey: 'improve_save_job_desc',
          timeKey: 'time_1_min',
          pointsGain: 5,
          actionType: 'fill_profile',
          routeTarget: ExpatScoreRouteTarget.jobs,
        ),
      );
    }

    if (!signals.housingConfirmed) {
      actions.add(
        localized(
          titleKey: 'improve_housing_title',
          descKey: 'improve_housing_desc',
          timeKey: 'time_2_min',
          pointsGain: 8,
          actionType: 'fill_profile',
        ),
      );
    }

    if (profile.savedHousingIds.isEmpty && profile.viewedHousingIds.isEmpty) {
      actions.add(
        localized(
          titleKey: 'improve_browse_housing_title',
          descKey: 'improve_browse_housing_desc',
          timeKey: 'time_3_min',
          pointsGain: 5,
          actionType: 'fill_profile',
        ),
      );
    }

    if (!signals.budgetRangeSet) {
      actions.add(
        localized(
          titleKey: 'improve_budget_title',
          descKey: 'improve_budget_desc',
          timeKey: 'time_1_min',
          pointsGain: 5,
          actionType: 'fill_profile',
        ),
      );
    }

    if (!signals.moneyTransferSet) {
      actions.add(
        localized(
          titleKey: 'improve_transfer_title',
          descKey: 'improve_transfer_desc',
          timeKey: 'time_2_min',
          pointsGain: 5,
          actionType: 'fill_profile',
        ),
      );
    }

    if (!signals.exchangeAlertsActive) {
      actions.add(
        localized(
          titleKey: 'improve_exchange_title',
          descKey: 'improve_exchange_desc',
          timeKey: 'time_1_min',
          pointsGain: 5,
          actionType: 'set_reminder',
        ),
      );
    }

    if (signals.questionsAnswered == 0) {
      actions.add(
        localized(
          titleKey: 'improve_ask_qatar_title',
          descKey: 'improve_ask_qatar_desc',
          timeKey: 'time_2_min',
          pointsGain: 3,
          actionType: 'join_group',
          routeTarget: ExpatScoreRouteTarget.community,
        ),
      );
    }

    if (!signals.doctorPreferenceSet) {
      actions.add(
        localized(
          titleKey: 'improve_doctor_title',
          descKey: 'improve_doctor_desc',
          timeKey: 'time_1_min',
          pointsGain: 5,
          actionType: 'fill_profile',
        ),
      );
    }

    if (!signals.passportExpirySet) {
      actions.add(
        localized(
          titleKey: 'improve_passport_title',
          descKey: 'improve_passport_desc',
          timeKey: 'time_1_min',
          pointsGain: 3,
          actionType: 'set_reminder',
          routeTarget: ExpatScoreRouteTarget.visa,
        ),
      );
    }

    if (signals.referralCount < 5) {
      actions.add(
        localized(
          titleKey: 'improve_refer_title',
          descKey: 'improve_refer_desc',
          timeKey: 'time_1_min',
          pointsGain: 5,
          actionType: 'refer_friend',
          routeTarget: ExpatScoreRouteTarget.refer,
          params: {'remaining': '${5 - signals.referralCount}'},
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
  // Level + score history
  // -------------------------------------------------------------------------

  String _resolveLevel(double total) {
    if (total <= 20) return 'New Arrival 🆕';
    if (total <= 40) return 'Settling In 🏠';
    if (total <= 79) return 'Growing Strong 📈';
    if (total <= 94) return 'Established Resident 🏆';
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

  Future<void> _saveScoreSnapshot(
    String uid,
    double total,
    Map<String, double> breakdown,
  ) async {
    final ref = _scoreHistoryRef(uid);
    if (ref == null) return;

    final now = DateTime.now();
    final docId = _dateKey(now);

    try {
      await ref.doc(docId).set({
        'total': total,
        'career': breakdown['career'],
        'housing': breakdown['housing'],
        'financial': breakdown['financial'],
        'community': breakdown['community'],
        'health': breakdown['health'],
        'documentation': breakdown['documentation'],
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
        title: '',
        emoji: '🌟',
        unlocked: profile.lastUpdated.isBefore(_launchMonth.add(const Duration(days: 31))),
      ),
      Achievement(
        id: 'job_seeker',
        title: '',
        emoji: '💼',
        unlocked: profile.viewedJobIds.length >= 10,
      ),
      Achievement(
        id: 'home_hunter',
        title: '',
        emoji: '🏠',
        unlocked: profile.savedHousingIds.length >= 3,
      ),
      Achievement(
        id: 'connector',
        title: '',
        emoji: '🤝',
        unlocked: profile.communityGroups.length >= 3,
      ),
      Achievement(
        id: 'community_star',
        title: '',
        emoji: '⭐',
        unlocked: signals.communityPostCount >= 5,
      ),
      Achievement(
        id: 'document_pro',
        title: '',
        emoji: '📋',
        unlocked: allDocsTracked,
      ),
      Achievement(
        id: 'ambassador',
        title: '',
        emoji: '🌍',
        unlocked: signals.referralCount >= 5,
      ),
      Achievement(
        id: 'qatar_pro',
        title: '',
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

  String _suggestedCommunityGroup(String nationality, String locale) {
    final lower = nationality.toLowerCase();
    if (lower.contains('india')) return 'Indians in Qatar';
    if (lower.contains('pakistan')) return 'Pakistanis in Qatar';
    if (lower.contains('bangladesh')) return 'Bangladeshis in Qatar';
    if (lower.contains('nepal')) return 'Nepalis in Qatar';
    if (lower.contains('philippine') || lower.contains('filipino')) {
      return 'Filipinos in Qatar';
    }
    if (lower.contains('kenya')) return 'Kenyans in Qatar';
    return HomeRecommendationStrings.t('community_group_fallback', locale);
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
  return ExpatLifeScoreNotifier(
    ref.watch(expatLifeScoreServiceProvider),
    ref.watch(userProfileAIServiceProvider),
  );
});

class ExpatLifeScoreNotifier extends StateNotifier<ExpatScoreState> {
  ExpatLifeScoreNotifier(this._service, this._profileService)
      : super(const ExpatScoreState());

  final ExpatLifeScoreService _service;
  final UserProfileAIService _profileService;

  /// Recalculates score, achievements, and improvement actions.
  Future<void> refresh(UserAIProfile profile) async {
    final enrichedInterests = await ExpatScoreSignalEnricher.enrichInterests(
      profile: profile,
      deadlineRepo: _service.deadlineRepo,
    );
    final scoringProfile = profile.copyWith(interests: enrichedInterests);
    final score = await _service.calculateScore(
      scoringProfile,
      interestsEnriched: true,
    );
    final achievementResult = await _service.checkAchievements(scoringProfile);

    await _profileService.persistCalculatedScore(scoringProfile.uid, score);

    state = ExpatScoreState(
      score: score,
      achievements: achievementResult.achievements,
      improvementActions: const [],
      pendingNotifications: achievementResult.newlyUnlocked,
    );
  }

  /// Clears pending achievement notifications after UI displays them.
  void clearPendingNotifications() {
    state = state.copyWith(pendingNotifications: const []);
  }

  /// Resets in-memory score state on authenticated UID change or logout.
  void resetForAuthChange() {
    state = const ExpatScoreState();
  }

  /// Loads score from [profile] when the dashboard has no cached calculation yet.
  Future<void> refreshIfEmpty(UserAIProfile profile) async {
    if (state.score != null) return;

    final persisted = profile.score;
    final hasPersistedScore = persisted.lastCalculated.isAfter(
      DateTime.now().subtract(const Duration(days: 30)),
    );
    if (hasPersistedScore && persisted.total > 0) {
      state = ExpatScoreState(score: persisted);
    }

    await refresh(profile);
  }

  List<ScoreAction> get improvementActions => state.improvementActions;

  List<Achievement> get achievements => state.achievements;

  ExpatLifeScore? get score => state.score;
}
