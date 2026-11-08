import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/models/advanced_profile.dart';
import 'package:raabta/services/ai/debouncer.dart';
import 'package:raabta/services/ai/expat_score_live_calculator.dart';
import 'package:raabta/services/firebase_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ---------------------------------------------------------------------------
// Models
// ---------------------------------------------------------------------------

class ExpatLifeScore {
  const ExpatLifeScore({
    required this.total,
    required this.career,
    required this.housing,
    required this.financial,
    required this.community,
    required this.health,
    required this.documentation,
    required this.level,
    required this.weeklyGrowth,
    required this.monthlyGrowth,
    required this.lastCalculated,
    this.categoryMeta = const {},
  });

  final double total;
  final double career;
  final double housing;
  final double financial;
  final double community;
  final double health;
  final double documentation;
  final String level;
  final double weeklyGrowth;
  final double monthlyGrowth;
  final DateTime lastCalculated;
  final Map<String, ExpatScoreCategoryMeta> categoryMeta;

  factory ExpatLifeScore.initial() {
    final now = DateTime.now();
    return ExpatLifeScore(
      total: 45,
      career: 10,
      housing: 8,
      financial: 9,
      community: 7,
      health: 5,
      documentation: 6,
      level: 'Settling In',
      weeklyGrowth: 0,
      monthlyGrowth: 0,
      lastCalculated: now,
    );
  }

  ExpatLifeScore copyWith({
    double? total,
    double? career,
    double? housing,
    double? financial,
    double? community,
    double? health,
    double? documentation,
    String? level,
    double? weeklyGrowth,
    double? monthlyGrowth,
    DateTime? lastCalculated,
    Map<String, ExpatScoreCategoryMeta>? categoryMeta,
  }) {
    return ExpatLifeScore(
      total: total ?? this.total,
      career: career ?? this.career,
      housing: housing ?? this.housing,
      financial: financial ?? this.financial,
      community: community ?? this.community,
      health: health ?? this.health,
      documentation: documentation ?? this.documentation,
      level: level ?? this.level,
      weeklyGrowth: weeklyGrowth ?? this.weeklyGrowth,
      monthlyGrowth: monthlyGrowth ?? this.monthlyGrowth,
      lastCalculated: lastCalculated ?? this.lastCalculated,
      categoryMeta: categoryMeta ?? this.categoryMeta,
    );
  }

  Map<String, dynamic> toJson() => {
        'total': total,
        'career': career,
        'housing': housing,
        'financial': financial,
        'community': community,
        'health': health,
        'documentation': documentation,
        'level': level,
        'weeklyGrowth': weeklyGrowth,
        'monthlyGrowth': monthlyGrowth,
        'lastCalculated': lastCalculated.toIso8601String(),
        'categoryMeta': categoryMeta.map(
          (key, value) => MapEntry(key, value.toJson()),
        ),
      };

  factory ExpatLifeScore.fromJson(Map<String, dynamic> json) {
    final rawMeta = json['categoryMeta'];
    final parsedMeta = <String, ExpatScoreCategoryMeta>{};
    if (rawMeta is Map) {
      for (final entry in rawMeta.entries) {
        if (entry.value is Map) {
          parsedMeta[entry.key.toString()] = ExpatScoreCategoryMeta.fromJson(
            Map<String, dynamic>.from(entry.value as Map),
          );
        }
      }
    }

    return ExpatLifeScore(
      total: _toDouble(json['total']),
      career: _toDouble(json['career']),
      housing: _toDouble(json['housing']),
      financial: _toDouble(json['financial']),
      community: _toDouble(json['community']),
      health: _toDouble(json['health']),
      documentation: _toDouble(json['documentation']),
      level: json['level'] as String? ?? 'New Arrival',
      weeklyGrowth: _toDouble(json['weeklyGrowth']),
      monthlyGrowth: _toDouble(json['monthlyGrowth']),
      lastCalculated: _parseDateTime(json['lastCalculated']),
      categoryMeta: parsedMeta,
    );
  }
}

class UserAIProfile {
  const UserAIProfile({
    required this.uid,
    required this.profession,
    required this.yearsExperience,
    required this.preferredArea,
    required this.budgetRange,
    required this.familyStatus,
    required this.nationality,
    required this.language,
    required this.skills,
    required this.certifications,
    required this.interests,
    required this.savedJobIds,
    required this.savedHousingIds,
    required this.savedBusinessIds,
    required this.viewedJobIds,
    required this.viewedHousingIds,
    required this.searchHistory,
    required this.communityGroups,
    required this.lastUpdated,
    required this.score,
    this.advancedProfile,
    this.advancedProfileConsentGiven = false,
    this.advancedProfileConsentDate,
    this.spokenLanguageCodes = const [],
    this.areaCode = '',
  });

  final String uid;
  final String profession;
  final int yearsExperience;
  final String preferredArea;
  final Map<String, num> budgetRange;
  final String familyStatus;
  final String nationality;
  final String language;
  final List<String> skills;
  final List<String> certifications;
  final List<String> interests;
  final List<String> savedJobIds;
  final List<String> savedHousingIds;
  final List<String> savedBusinessIds;
  final List<String> viewedJobIds;
  final List<String> viewedHousingIds;
  final List<String> searchHistory;
  final List<String> communityGroups;
  final DateTime lastUpdated;
  final ExpatLifeScore score;
  final AdvancedProfile? advancedProfile;
  final bool advancedProfileConsentGiven;
  final DateTime? advancedProfileConsentDate;
  final List<String> spokenLanguageCodes;
  final String areaCode;

  factory UserAIProfile.defaultProfile(String uid) {
    return UserAIProfile(
      uid: uid,
      profession: '',
      yearsExperience: 0,
      preferredArea: '',
      budgetRange: const {'min': 0, 'max': 0},
      familyStatus: 'single',
      nationality: '',
      language: 'en',
      skills: const [],
      certifications: const [],
      interests: const [],
      savedJobIds: const [],
      savedHousingIds: const [],
      savedBusinessIds: const [],
      viewedJobIds: const [],
      viewedHousingIds: const [],
      searchHistory: const [],
      communityGroups: const [],
      lastUpdated: DateTime.now(),
      score: ExpatLifeScore.initial(),
    );
  }

  UserAIProfile copyWith({
    String? profession,
    int? yearsExperience,
    String? preferredArea,
    Map<String, num>? budgetRange,
    String? familyStatus,
    String? nationality,
    String? language,
    List<String>? skills,
    List<String>? certifications,
    List<String>? interests,
    List<String>? savedJobIds,
    List<String>? savedHousingIds,
    List<String>? savedBusinessIds,
    List<String>? viewedJobIds,
    List<String>? viewedHousingIds,
    List<String>? searchHistory,
    List<String>? communityGroups,
    DateTime? lastUpdated,
    ExpatLifeScore? score,
    AdvancedProfile? advancedProfile,
    bool? advancedProfileConsentGiven,
    DateTime? advancedProfileConsentDate,
    bool clearAdvancedProfile = false,
    bool clearAdvancedProfileConsentDate = false,
    List<String>? spokenLanguageCodes,
    String? areaCode,
  }) {
    return UserAIProfile(
      uid: uid,
      profession: profession ?? this.profession,
      yearsExperience: yearsExperience ?? this.yearsExperience,
      preferredArea: preferredArea ?? this.preferredArea,
      budgetRange: budgetRange ?? this.budgetRange,
      familyStatus: familyStatus ?? this.familyStatus,
      nationality: nationality ?? this.nationality,
      language: language ?? this.language,
      skills: skills ?? this.skills,
      certifications: certifications ?? this.certifications,
      interests: interests ?? this.interests,
      savedJobIds: savedJobIds ?? this.savedJobIds,
      savedHousingIds: savedHousingIds ?? this.savedHousingIds,
      savedBusinessIds: savedBusinessIds ?? this.savedBusinessIds,
      viewedJobIds: viewedJobIds ?? this.viewedJobIds,
      viewedHousingIds: viewedHousingIds ?? this.viewedHousingIds,
      searchHistory: searchHistory ?? this.searchHistory,
      communityGroups: communityGroups ?? this.communityGroups,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      score: score ?? this.score,
      advancedProfile: clearAdvancedProfile
          ? null
          : (advancedProfile ?? this.advancedProfile),
      advancedProfileConsentGiven:
          advancedProfileConsentGiven ?? this.advancedProfileConsentGiven,
      advancedProfileConsentDate: clearAdvancedProfileConsentDate
          ? null
          : (advancedProfileConsentDate ?? this.advancedProfileConsentDate),
      spokenLanguageCodes: spokenLanguageCodes ?? this.spokenLanguageCodes,
      areaCode: areaCode ?? this.areaCode,
    );
  }

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'profession': profession,
        'yearsExperience': yearsExperience,
        'preferredArea': preferredArea,
        'budgetRange': budgetRange,
        'familyStatus': familyStatus,
        'nationality': nationality,
        'language': language,
        'skills': skills,
        'certifications': certifications,
        'interests': interests,
        'savedJobIds': savedJobIds,
        'savedHousingIds': savedHousingIds,
        'savedBusinessIds': savedBusinessIds,
        'viewedJobIds': viewedJobIds,
        'viewedHousingIds': viewedHousingIds,
        'searchHistory': searchHistory,
        'communityGroups': communityGroups,
        'lastUpdated': lastUpdated.toIso8601String(),
        'score': score.toJson(),
        if (advancedProfile != null && advancedProfile!.hasAnyField)
          'advancedProfile': advancedProfile!.toJson(),
        'advancedProfileConsentGiven': advancedProfileConsentGiven,
        if (advancedProfileConsentDate != null)
          'advancedProfileConsentDate':
              advancedProfileConsentDate!.toIso8601String(),
        'spokenLanguageCodes': spokenLanguageCodes,
        if (areaCode.isNotEmpty) 'areaCode': areaCode,
      };

  factory UserAIProfile.fromJson(Map<String, dynamic> json) {
    final budgetRaw = json['budgetRange'];
    final budget = budgetRaw is Map
        ? Map<String, num>.from(
            budgetRaw.map(
              (key, value) => MapEntry(key.toString(), _toNum(value)),
            ),
          )
        : const {'min': 0, 'max': 5000};

    return UserAIProfile(
      uid: json['uid'] as String? ?? '',
      profession: json['profession'] as String? ?? '',
      yearsExperience: json['yearsExperience'] as int? ?? 0,
      preferredArea: json['preferredArea'] as String? ?? '',
      budgetRange: budget,
      familyStatus: json['familyStatus'] as String? ?? 'single',
      nationality: json['nationality'] as String? ?? '',
      language: json['language'] as String? ?? 'en',
      skills: _toStringList(json['skills']),
      certifications: _toStringList(json['certifications']),
      interests: _toStringList(json['interests']),
      savedJobIds: _toStringList(json['savedJobIds']),
      savedHousingIds: _toStringList(json['savedHousingIds']),
      savedBusinessIds: _toStringList(json['savedBusinessIds']),
      viewedJobIds: _toStringList(json['viewedJobIds']),
      viewedHousingIds: _toStringList(json['viewedHousingIds']),
      searchHistory: _toStringList(json['searchHistory']),
      communityGroups: _toStringList(json['communityGroups']),
      lastUpdated: _parseDateTime(json['lastUpdated']),
      score: json['score'] is Map<String, dynamic>
          ? ExpatLifeScore.fromJson(json['score'] as Map<String, dynamic>)
          : ExpatLifeScore.initial(),
      advancedProfile: json['advancedProfile'] is Map<String, dynamic>
          ? AdvancedProfile.fromJson(
              Map<String, dynamic>.from(json['advancedProfile'] as Map),
            )
          : null,
      advancedProfileConsentGiven:
          json['advancedProfileConsentGiven'] as bool? ?? false,
      advancedProfileConsentDate: json['advancedProfileConsentDate'] != null
          ? _parseDateTime(json['advancedProfileConsentDate'])
          : null,
      spokenLanguageCodes: _toStringList(json['spokenLanguageCodes']),
      areaCode: json['areaCode'] as String? ?? '',
    );
  }
}

// ---------------------------------------------------------------------------
// Saved job toggle results (Jobs hub)
// ---------------------------------------------------------------------------

enum SavedJobToggleOutcome { saved, unsaved }

/// Result of [UserProfileAIService.toggleSavedJob].
class SavedJobToggleResult {
  const SavedJobToggleResult({
    required this.profileReady,
    required this.localUpdated,
    required this.remotePersisted,
    this.outcome,
  });

  /// False when profile is not initialized or auth ownership does not match.
  final bool profileReady;

  /// True when `_cachedProfile` and local cache were updated.
  final bool localUpdated;

  /// True when Firestore accepted the write (false on error or offline Firestore).
  final bool remotePersisted;

  final SavedJobToggleOutcome? outcome;
}

// ---------------------------------------------------------------------------
// Auth-bound profile ownership helpers
// ---------------------------------------------------------------------------

/// UID binding checks shared by profile consumers and the AI profile service.
abstract final class UserProfileOwnership {
  UserProfileOwnership._();

  static String? currentAuthUid() => FirebaseAuth.instance.currentUser?.uid;

  static bool needsInit(UserAIProfile? profile, String? currentUid) {
    if (currentUid == null || currentUid.isEmpty) return false;
    return profile == null || profile.uid != currentUid;
  }

  static bool matches(UserAIProfile profile, String currentUid) {
    return profile.uid == currentUid;
  }

  static bool matchesCurrentAuth(UserAIProfile profile) {
    final authUid = currentAuthUid();
    return authUid != null && profile.uid == authUid;
  }
}

// ---------------------------------------------------------------------------
// Service
// ---------------------------------------------------------------------------

class UserProfileAIService {
  UserProfileAIService({
    FirebaseFirestore? firestore,
    SharedPreferences? prefs,
    Debouncer? saveDebouncer,
    String? Function()? currentAuthUid,
  })  : _firestore = FirebaseService.isReady
            ? (firestore ?? FirebaseFirestore.instance)
            : null,
        _saveDebouncer = saveDebouncer ?? Debouncer(),
        _currentAuthUid = currentAuthUid ?? UserProfileOwnership.currentAuthUid {
    _prefs = prefs;
  }

  static const _profileDocId = 'profile';
  static const _maxSearchHistory = 50;
  static const _maxTrackedIds = 200;
  static const _professionViewThreshold = 3;

  final FirebaseFirestore? _firestore;
  SharedPreferences? _prefs;
  final Debouncer _saveDebouncer;
  final String? Function() _currentAuthUid;

  UserAIProfile? _cachedProfile;
  final Map<String, int> _professionViewCounts = {};
  int _initGeneration = 0;
  Future<void> _profileMutationChain = Future<void>.value();

  /// Test hook: awaited at the start of each queued mutation (ordering tests).
  @visibleForTesting
  Future<void>? debugAwaitBeforeQueuedMutation;

  /// Test hook: replaces Firestore persistence (ordering / failure tests).
  @visibleForTesting
  Future<bool> Function(UserAIProfile profile)? testPersistHandler;

  /// Clears in-memory profile state on auth UID change. Disk caches remain UID-scoped.
  @visibleForTesting
  void clearInMemoryState() {
    _saveDebouncer.cancel();
    _cachedProfile = null;
    _professionViewCounts.clear();
    _initGeneration++;
    _profileMutationChain = Future<void>.value();
  }

  /// Serializes read-modify-commit profile mutations on one lane.
  Future<T> _enqueueProfileMutation<T>(Future<T> Function() action) {
    final hold = debugAwaitBeforeQueuedMutation;
    Future<T> run() async {
      if (hold != null) await hold;
      return action();
    }

    final operation = _profileMutationChain.then((_) => run());
    _profileMutationChain = operation.then((_) {}, onError: (_) {});
    return operation;
  }

  @visibleForTesting
  int get initGeneration => _initGeneration;

  DocumentReference<Map<String, dynamic>>? _profileRef(String uid) {
    if (_firestore == null) return null;
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('ai_profile')
        .doc(_profileDocId);
  }

  String _cacheKey(String uid) => 'user_ai_profile_$uid';

  static String _privacyCacheKey(String uid) => 'privacy_settings_$uid';

  Future<bool> _isPersonalizationEnabled(String uid) async {
    final prefs = await _getPrefs();
    final cached = prefs.getString(_privacyCacheKey(uid));
    if (cached != null && cached.contains('aiPersonalizationEnabled=false')) {
      return false;
    }
    if (_firestore != null) {
      try {
        final snap = await _firestore.collection('users').doc(uid).get();
        final raw = snap.data()?['privacySettings'] as Map<String, dynamic>?;
        if (raw != null && raw['aiPersonalizationEnabled'] == false) {
          return false;
        }
      } catch (_) {}
    }
    return true;
  }

  Future<SharedPreferences> _getPrefs() async {
    return _prefs ??= await SharedPreferences.getInstance();
  }

  /// 1. Initialize profile — load from Firestore or create default.
  Future<UserAIProfile> initProfile(
    String uid, {
    required int initGeneration,
  }) async {
    UserAIProfile? profile;

    final ref = _profileRef(uid);
    if (ref != null) {
      try {
        final snapshot = await ref.get();
        if (snapshot.exists && snapshot.data() != null) {
          profile = UserAIProfile.fromJson(snapshot.data()!);
        }
      } catch (e) {
        debugPrint('UserProfileAIService: Firestore load failed — $e');
      }
    }

    profile ??= await _loadFromCache(uid);
    profile ??= UserAIProfile.defaultProfile(uid);

    if (!_canCommitInit(initGeneration, uid)) {
      return profile;
    }

    final loaded = profile;
    await _enqueueProfileMutation(() async {
      if (!_canCommitInit(initGeneration, uid)) return;
      _cachedProfile = loaded;
      await _cacheLocally(loaded);
    });
    return _cachedProfile ?? loaded;
  }

  /// 2. Track job view and infer profession preferences.
  Future<void> trackJobView(String jobId, Map<String, dynamic> jobData) {
    return _enqueueProfileMutation(
      () => _trackJobViewInQueue(jobId, jobData),
    );
  }

  Future<void> _trackJobViewInQueue(
    String jobId,
    Map<String, dynamic> jobData,
  ) async {
    if (!_ensureOwnedProfile()) return;
    if (!await _isPersonalizationEnabled(_cachedProfile!.uid)) return;
    var profile = _cachedProfile!;

    final viewed = _appendUnique(profile.viewedJobIds, jobId);
    profile = profile.copyWith(viewedJobIds: viewed);

    final extractedSkills = _extractSkills(jobData);
    profile = profile.copyWith(
      skills: _mergeUnique(profile.skills, extractedSkills),
    );

    final profession = _extractProfession(jobData);
    if (profession.isNotEmpty) {
      _professionViewCounts[profession] =
          (_professionViewCounts[profession] ?? 0) + 1;
      if (_professionViewCounts[profession]! >= _professionViewThreshold) {
        profile = profile.copyWith(profession: profession);
      }
    }

    final certifications = _extractCertifications(jobData);
    profile = profile.copyWith(
      certifications: _mergeUnique(profile.certifications, certifications),
    );

    await _commitProfileUpdate(profile, immediate: false);
  }

  /// 3. Track housing view and update area / budget preferences.
  Future<void> trackHousingView(
    String listingId,
    Map<String, dynamic> listingData,
  ) {
    return _enqueueProfileMutation(
      () => _trackHousingViewInQueue(listingId, listingData),
    );
  }

  Future<void> _trackHousingViewInQueue(
    String listingId,
    Map<String, dynamic> listingData,
  ) async {
    if (!_ensureOwnedProfile()) return;
    if (!await _isPersonalizationEnabled(_cachedProfile!.uid)) return;
    var profile = _cachedProfile!;

    final viewed = _appendUnique(profile.viewedHousingIds, listingId);
    profile = profile.copyWith(viewedHousingIds: viewed);

    final area = _extractArea(listingData);
    if (area.isNotEmpty) {
      profile = profile.copyWith(preferredArea: area);
    }

    final price = _extractPrice(listingData);
    if (price != null) {
      profile = profile.copyWith(
        budgetRange: _updateBudgetRange(profile.budgetRange, price),
      );
    }

    await _commitProfileUpdate(profile, immediate: false);
  }

  /// 4. Track business view and update interests.
  Future<void> trackBusinessView(
    String bizId,
    Map<String, dynamic> bizData,
  ) {
    return _enqueueProfileMutation(
      () => _trackBusinessViewInQueue(bizId, bizData),
    );
  }

  Future<void> _trackBusinessViewInQueue(
    String bizId,
    Map<String, dynamic> bizData,
  ) async {
    if (!_ensureOwnedProfile()) return;
    if (!await _isPersonalizationEnabled(_cachedProfile!.uid)) return;
    var profile = _cachedProfile!;

    final businesses = _appendUnique(profile.savedBusinessIds, bizId);
    profile = profile.copyWith(savedBusinessIds: businesses);

    final category = _extractBusinessCategory(bizData);
    if (category.isNotEmpty) {
      profile = profile.copyWith(
        interests: _mergeUnique(profile.interests, [category]),
      );
    }

    await _commitProfileUpdate(profile, immediate: false);
  }

  /// 5. Track search query and parse preferences.
  Future<void> trackSearch(String query) {
    return _enqueueProfileMutation(() => _trackSearchInQueue(query));
  }

  Future<void> _trackSearchInQueue(String query) async {
    if (!_ensureOwnedProfile()) return;
    if (!await _isPersonalizationEnabled(_cachedProfile!.uid)) return;
    var profile = _cachedProfile!;

    final trimmed = query.trim();
    if (trimmed.isEmpty) return;

    final history = List<String>.from(profile.searchHistory);
    history.remove(trimmed);
    history.insert(0, trimmed);
    if (history.length > _maxSearchHistory) {
      history.removeRange(_maxSearchHistory, history.length);
    }
    profile = profile.copyWith(searchHistory: history);

    final parsed = _parseSearchQuery(trimmed);
    if (parsed.profession != null) {
      profile = profile.copyWith(profession: parsed.profession);
    }
    if (parsed.area != null) {
      profile = profile.copyWith(preferredArea: parsed.area);
    }
    if (parsed.keywords.isNotEmpty) {
      profile = profile.copyWith(
        interests: _mergeUnique(profile.interests, parsed.keywords),
      );
    }

    await _commitProfileUpdate(profile, immediate: false);
  }

  /// 6. Track saved item — saved items carry 3x recommendation weight.
  Future<void> trackSave(String type, String id) {
    return _enqueueProfileMutation(() => _trackSaveInQueue(type, id));
  }

  Future<void> _trackSaveInQueue(String type, String id) async {
    if (!_ensureOwnedProfile()) return;
    var profile = _cachedProfile!;

    switch (type) {
      case 'job':
        profile = profile.copyWith(
          savedJobIds: _appendUnique(profile.savedJobIds, id),
          interests: _mergeUnique(profile.interests, ['job:$id', 'job:$id', 'job:$id']),
        );
      case 'housing':
        profile = profile.copyWith(
          savedHousingIds: _appendUnique(profile.savedHousingIds, id),
          interests: _mergeUnique(
            profile.interests,
            ['housing:$id', 'housing:$id', 'housing:$id'],
          ),
        );
      case 'business':
        profile = profile.copyWith(
          savedBusinessIds: _appendUnique(profile.savedBusinessIds, id),
          interests: _mergeUnique(
            profile.interests,
            ['business:$id', 'business:$id', 'business:$id'],
          ),
        );
      default:
        throw ArgumentError('type must be job, housing, or business');
    }

    await _commitProfileUpdate(profile, immediate: false);
  }

  /// Jobs hub — toggle saved state with serialized updates and immediate Firestore sync.
  Future<SavedJobToggleResult> toggleSavedJob(String jobId) {
    return _enqueueProfileMutation(() => _toggleSavedJobInQueue(jobId)).catchError(
      (Object _, StackTrace __) {
        return const SavedJobToggleResult(
          profileReady: false,
          localUpdated: false,
          remotePersisted: false,
        );
      },
    );
  }

  Future<SavedJobToggleResult> _toggleSavedJobInQueue(String jobId) async {
    if (!_ensureOwnedProfile()) {
      return const SavedJobToggleResult(
        profileReady: false,
        localUpdated: false,
        remotePersisted: false,
      );
    }

    var profile = _cachedProfile!;
    final trimmedId = jobId.trim();
    if (trimmedId.isEmpty) {
      return const SavedJobToggleResult(
        profileReady: true,
        localUpdated: false,
        remotePersisted: false,
      );
    }

    final wasSaved = profile.savedJobIds.contains(trimmedId);
    if (wasSaved) {
      profile = profile.copyWith(
        savedJobIds: _removeId(profile.savedJobIds, trimmedId),
      );
    } else {
      profile = profile.copyWith(
        savedJobIds: _appendUnique(profile.savedJobIds, trimmedId),
        interests: _mergeUnique(
          profile.interests,
          ['job:$trimmedId', 'job:$trimmedId', 'job:$trimmedId'],
        ),
      );
    }

    if (!_profileUidMatchesCurrentAuth(profile.uid)) {
      return const SavedJobToggleResult(
        profileReady: false,
        localUpdated: false,
        remotePersisted: false,
      );
    }

    final remotePersisted = await _commitProfileUpdate(
      profile,
      immediate: true,
    );

    return SavedJobToggleResult(
      profileReady: true,
      localUpdated: true,
      remotePersisted: remotePersisted,
      outcome: wasSaved ? SavedJobToggleOutcome.unsaved : SavedJobToggleOutcome.saved,
    );
  }

  /// 7. Return locally cached profile.
  UserAIProfile? getCachedProfile() => _cachedProfile;

  bool cachedProfileMatchesCurrentAuth() {
    final profile = _cachedProfile;
    if (profile == null) return false;
    return _profileUidMatchesCurrentAuth(profile.uid);
  }

  /// Persists a freshly calculated Expat Life Score to Firestore + local cache.
  Future<void> persistCalculatedScore(String uid, ExpatLifeScore score) {
    return _enqueueProfileMutation(() async {
      if (_cachedProfile == null || _cachedProfile!.uid != uid) return;
      final updated = _cachedProfile!.copyWith(score: score);
      await _commitProfileUpdate(updated, immediate: true);
    });
  }

  /// 8. Update specific profile fields.
  Future<void> updateProfile(Map<String, dynamic> updates) {
    return _enqueueProfileMutation(() => _updateProfileInQueue(updates));
  }

  Future<void> _updateProfileInQueue(Map<String, dynamic> updates) async {
    if (!_ensureOwnedProfile()) return;
    var profile = _cachedProfile!;

    if (updates.containsKey('profession')) {
      profile = profile.copyWith(profession: updates['profession'] as String?);
    }
    if (updates.containsKey('yearsExperience')) {
      profile = profile.copyWith(
        yearsExperience: updates['yearsExperience'] as int?,
      );
    }
    if (updates.containsKey('preferredArea')) {
      profile = profile.copyWith(
        preferredArea: updates['preferredArea'] as String?,
      );
    }
    if (updates.containsKey('budgetRange')) {
      final raw = updates['budgetRange'];
      if (raw is Map) {
        profile = profile.copyWith(
          budgetRange: Map<String, num>.from(
            raw.map((k, v) => MapEntry(k.toString(), _toNum(v))),
          ),
        );
      }
    }
    if (updates.containsKey('familyStatus')) {
      profile = profile.copyWith(
        familyStatus: updates['familyStatus'] as String?,
      );
    }
    if (updates.containsKey('nationality')) {
      profile = profile.copyWith(nationality: updates['nationality'] as String?);
    }
    if (updates.containsKey('language')) {
      profile = profile.copyWith(language: updates['language'] as String?);
    }
    if (updates.containsKey('skills')) {
      profile = profile.copyWith(skills: _toStringList(updates['skills']));
    }
    if (updates.containsKey('certifications')) {
      profile = profile.copyWith(
        certifications: _toStringList(updates['certifications']),
      );
    }
    if (updates.containsKey('interests')) {
      profile = profile.copyWith(
        interests: _toStringList(updates['interests']),
      );
    }
    if (updates.containsKey('communityGroups')) {
      profile = profile.copyWith(
        communityGroups: _toStringList(updates['communityGroups']),
      );
    }
    if (updates.containsKey('spokenLanguageCodes')) {
      profile = profile.copyWith(
        spokenLanguageCodes: _toStringList(updates['spokenLanguageCodes']),
      );
    }
    if (updates.containsKey('areaCode')) {
      final code = (updates['areaCode'] as String? ?? '').trim();
      profile = profile.copyWith(
        areaCode: code,
        preferredArea: code.isNotEmpty ? code : profile.preferredArea,
      );
    }
    if (updates.containsKey('score') && updates['score'] is Map) {
      profile = profile.copyWith(
        score: ExpatLifeScore.fromJson(
          Map<String, dynamic>.from(updates['score'] as Map),
        ),
      );
    }

    await _commitProfileUpdate(profile, immediate: true);
  }

  /// Saves optional advanced profile — requires explicit consent.
  Future<void> updateAdvancedProfile({
    required AdvancedProfile profile,
    required bool consentGiven,
  }) {
    return _enqueueProfileMutation(
      () => _updateAdvancedProfileInQueue(
        profile: profile,
        consentGiven: consentGiven,
      ),
    );
  }

  Future<void> _updateAdvancedProfileInQueue({
    required AdvancedProfile profile,
    required bool consentGiven,
  }) async {
    if (!_ensureOwnedProfile()) return;
    if (!consentGiven) {
      throw ArgumentError('Advanced profile requires consent before saving');
    }
    final updated = _cachedProfile!.copyWith(
      advancedProfile: profile.hasAnyField ? profile : null,
      advancedProfileConsentGiven: true,
      advancedProfileConsentDate: DateTime.now(),
    );
    await _commitProfileUpdate(updated, immediate: true);
  }

  /// Clears one advanced profile field; revokes consent if no fields remain.
  Future<void> deleteAdvancedProfileField(String fieldKey) {
    return _enqueueProfileMutation(
      () => _deleteAdvancedProfileFieldInQueue(fieldKey),
    );
  }

  Future<void> _deleteAdvancedProfileFieldInQueue(String fieldKey) async {
    if (!_ensureOwnedProfile()) return;
    final current = _cachedProfile!.advancedProfile ?? const AdvancedProfile();
    final AdvancedProfile next = switch (fieldKey) {
      'jobTitle' => current.copyWith(clearJobTitle: true),
      'industry' => current.copyWith(clearIndustry: true),
      'educationLevel' => current.copyWith(clearEducationLevel: true),
      'salaryComparisonRange' =>
        current.copyWith(clearSalaryComparisonRange: true),
      _ => throw ArgumentError('Unknown advanced profile field: $fieldKey'),
    };

    if (!next.hasAnyField) {
      await _revokeAdvancedProfileConsentInQueue();
      return;
    }

    final updated = _cachedProfile!.copyWith(advancedProfile: next);
    await _commitProfileUpdate(updated, immediate: true);
  }

  /// Revokes consent and deletes all advanced profile fields.
  Future<void> revokeAdvancedProfileConsent() {
    return _enqueueProfileMutation(_revokeAdvancedProfileConsentInQueue);
  }

  Future<void> _revokeAdvancedProfileConsentInQueue() async {
    if (!_ensureOwnedProfile()) return;
    final updated = _cachedProfile!.copyWith(
      clearAdvancedProfile: true,
      advancedProfileConsentGiven: false,
      clearAdvancedProfileConsentDate: true,
    );
    await _commitProfileUpdate(updated, immediate: true);
  }

  /// 9. Comma-separated interest vector for AI prompt context.
  String getInterestVector() {
    final profile = _cachedProfile;
    if (profile == null) return '';

    final weighted = <String>[
      if (profile.profession.isNotEmpty) profile.profession,
      ...profile.skills,
      ...profile.certifications,
      ...profile.interests,
      if (profile.preferredArea.isNotEmpty) profile.preferredArea,
      ...profile.communityGroups,
      for (final id in profile.savedJobIds) ...['job:$id', 'job:$id', 'job:$id'],
      for (final id in profile.savedHousingIds)
        ...['housing:$id', 'housing:$id', 'housing:$id'],
      for (final id in profile.savedBusinessIds)
        ...['business:$id', 'business:$id', 'business:$id'],
    ];

    final advanced = AdvancedProfileSignals.bucketedMap(
      profile: profile.advancedProfile,
      consentGiven: profile.advancedProfileConsentGiven,
    );
    for (final entry in advanced.entries) {
      weighted.add('adv_${entry.key}:${entry.value}');
    }

    return weighted.where((e) => e.trim().isNotEmpty).join(', ');
  }

  void dispose() {
    _saveDebouncer.dispose();
  }

  // -------------------------------------------------------------------------
  // Internal helpers
  // -------------------------------------------------------------------------

  bool _ensureOwnedProfile() {
    if (_cachedProfile == null) return false;
    return _profileUidMatchesCurrentAuth(_cachedProfile!.uid);
  }

  bool _profileUidMatchesCurrentAuth(String uid) {
    final authUid = _currentAuthUid();
    return authUid != null && authUid == uid;
  }

  bool _canCommitInit(int initGeneration, String uid) {
    if (initGeneration != _initGeneration) return false;
    return _profileUidMatchesCurrentAuth(uid);
  }

  /// Commits [profile] to memory, local cache, and optional remote persistence.
  /// Must run inside [_enqueueProfileMutation].
  Future<bool> _commitProfileUpdate(
    UserAIProfile profile, {
    required bool immediate,
  }) async {
    if (!_profileUidMatchesCurrentAuth(profile.uid)) return false;

    final updated = profile.copyWith(lastUpdated: DateTime.now());
    _cachedProfile = updated;
    await _cacheLocally(updated);

    if (immediate) {
      _saveDebouncer.cancel();
      return _persistToFirestore(updated);
    }
    _scheduleDebouncedSave();
    return true;
  }

  void _scheduleDebouncedSave() {
    _saveDebouncer.run(() {
      unawaited(
        _enqueueProfileMutation(_persistDebouncedSnapshotInQueue),
      );
    });
  }

  Future<void> _persistDebouncedSnapshotInQueue() async {
    final profile = _cachedProfile;
    if (profile == null) return;
    if (!_profileUidMatchesCurrentAuth(profile.uid)) return;
    await _persistToFirestore(profile);
  }

  Future<bool> _persistToFirestore(UserAIProfile profile) async {
    if (!_profileUidMatchesCurrentAuth(profile.uid)) return false;

    final handler = testPersistHandler;
    if (handler != null) {
      return handler(profile);
    }

    final ref = _profileRef(profile.uid);
    if (ref == null) return false;

    try {
      await ref.set(profile.toJson(), SetOptions(merge: true));
      return true;
    } catch (e) {
      debugPrint('UserProfileAIService: Firestore save failed — $e');
      return false;
    }
  }

  Future<void> _cacheLocally(UserAIProfile profile) async {
    try {
      final prefs = await _getPrefs();
      await prefs.setString(
        _cacheKey(profile.uid),
        jsonEncode(profile.toJson()),
      );
    } catch (e) {
      debugPrint('UserProfileAIService: cache save failed — $e');
    }
  }

  Future<UserAIProfile?> _loadFromCache(String uid) async {
    try {
      final prefs = await _getPrefs();
      final raw = prefs.getString(_cacheKey(uid));
      if (raw == null) return null;
      return UserAIProfile.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } catch (e) {
      debugPrint('UserProfileAIService: cache load failed — $e');
      return null;
    }
  }

  List<String> _appendUnique(List<String> existing, String id) {
    final updated = List<String>.from(existing);
    updated.remove(id);
    updated.insert(0, id);
    if (updated.length > _maxTrackedIds) {
      updated.removeRange(_maxTrackedIds, updated.length);
    }
    return updated;
  }

  List<String> _removeId(List<String> existing, String id) {
    return existing.where((element) => element != id).toList();
  }

  List<String> _mergeUnique(List<String> existing, List<String> incoming) {
    final set = {...existing, ...incoming.where((e) => e.isNotEmpty)};
    return set.toList();
  }

  Map<String, num> _updateBudgetRange(Map<String, num> current, num price) {
    final min = current['min'] ?? 0;
    final max = current['max'] ?? 5000;
    return {
      'min': price < min ? price : min,
      'max': price > max ? price : max,
    };
  }

  String _extractProfession(Map<String, dynamic> data) {
    for (final key in ['profession', 'title', 'role', 'jobTitle']) {
      final value = data[key];
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
    }
    return '';
  }

  List<String> _extractSkills(Map<String, dynamic> data) {
    final skills = data['skills'];
    if (skills is List) {
      return skills.map((e) => e.toString()).where((e) => e.isNotEmpty).toList();
    }
    final single = data['skill'];
    if (single is String && single.isNotEmpty) return [single];
    return [];
  }

  List<String> _extractCertifications(Map<String, dynamic> data) {
    final certs = data['certifications'] ?? data['certification'];
    if (certs is List) {
      return certs.map((e) => e.toString()).where((e) => e.isNotEmpty).toList();
    }
    if (certs is String && certs.isNotEmpty) return [certs];
    return [];
  }

  String _extractArea(Map<String, dynamic> data) {
    for (final key in ['area', 'location', 'preferredArea', 'city']) {
      final value = data[key];
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
    }
    return '';
  }

  num? _extractPrice(Map<String, dynamic> data) {
    for (final key in ['pricePerMonth', 'price', 'rent', 'monthlyRent']) {
      final value = data[key];
      if (value is num) return value;
      if (value is String) {
        final parsed = num.tryParse(value.replaceAll(RegExp(r'[^\d.]'), ''));
        if (parsed != null) return parsed;
      }
    }
    return null;
  }

  String _extractBusinessCategory(Map<String, dynamic> data) {
    for (final key in ['category', 'type', 'industry', 'businessType']) {
      final value = data[key];
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
    }
    return '';
  }

  _ParsedSearch _parseSearchQuery(String query) {
    final lower = query.toLowerCase();
    String? area;
    String? profession;

    const areas = [
      'al khor',
      'doha',
      'lusail',
      'west bay',
      'the pearl',
      'al wakrah',
      'industrial area',
      'ras laffan',
      'muaither',
      'al sadd',
    ];

    for (final candidate in areas) {
      if (lower.contains(candidate)) {
        area = _titleCase(candidate);
        break;
      }
    }

    const professions = [
      'hse officer',
      'engineer',
      'nurse',
      'driver',
      'teacher',
      'accountant',
      'chef',
      'security',
      'laborer',
      'supervisor',
    ];

    for (final candidate in professions) {
      if (lower.contains(candidate)) {
        profession = _titleCase(candidate);
        break;
      }
    }

    final keywords = lower
        .split(RegExp(r'\s+'))
        .where((w) => w.length > 3)
        .where((w) => !areas.any((a) => w.contains(a.split(' ').first)))
        .take(5)
        .toList();

    return _ParsedSearch(
      area: area,
      profession: profession,
      keywords: keywords,
    );
  }

  String _titleCase(String value) {
    return value
        .split(' ')
        .map(
          (word) => word.isEmpty
              ? word
              : '${word[0].toUpperCase()}${word.substring(1)}',
        )
        .join(' ');
  }
}

class _ParsedSearch {
  const _ParsedSearch({
    this.area,
    this.profession,
    this.keywords = const [],
  });

  final String? area;
  final String? profession;
  final List<String> keywords;
}

// ---------------------------------------------------------------------------
// Riverpod
// ---------------------------------------------------------------------------

final userProfileAIServiceProvider = Provider<UserProfileAIService>((ref) {
  final service = UserProfileAIService();
  ref.onDispose(service.dispose);
  return service;
});

final userAIProfileProvider =
    StateNotifierProvider<UserProfileAINotifier, UserAIProfile?>((ref) {
  return UserProfileAINotifier(ref.watch(userProfileAIServiceProvider));
});

class UserProfileAINotifier extends StateNotifier<UserAIProfile?> {
  UserProfileAINotifier(this._service) : super(null);

  final UserProfileAIService _service;
  int _authGeneration = 0;

  @visibleForTesting
  int get authGeneration => _authGeneration;

  /// Clears provider and service memory on authenticated UID change or logout.
  void resetForAuthChange() {
    _authGeneration++;
    _service.clearInMemoryState();
    state = null;
  }

  Future<void> initProfile(String uid) async {
    final generation = _authGeneration;
    final profile = await _service.initProfile(
      uid,
      initGeneration: generation,
    );
    if (generation != _authGeneration) return;
    if (!UserProfileOwnership.matches(profile, uid)) return;
    state = profile;
  }

  Future<void> trackJobView(String jobId, Map<String, dynamic> jobData) async {
    await _service.trackJobView(jobId, jobData);
    _syncStateFromServiceIfOwned();
  }

  Future<void> trackHousingView(
    String listingId,
    Map<String, dynamic> listingData,
  ) async {
    await _service.trackHousingView(listingId, listingData);
    _syncStateFromServiceIfOwned();
  }

  Future<void> trackBusinessView(
    String bizId,
    Map<String, dynamic> bizData,
  ) async {
    await _service.trackBusinessView(bizId, bizData);
    _syncStateFromServiceIfOwned();
  }

  Future<void> trackSearch(String query) async {
    await _service.trackSearch(query);
    _syncStateFromServiceIfOwned();
  }

  Future<void> trackSave(String type, String id) async {
    await _service.trackSave(type, id);
    _syncStateFromServiceIfOwned();
  }

  Future<SavedJobToggleResult> toggleSavedJob(String jobId) async {
    final result = await _service.toggleSavedJob(jobId);
    if (result.localUpdated) {
      _syncStateFromServiceIfOwned();
    }
    return result;
  }

  UserAIProfile? getCachedProfile() => _service.getCachedProfile();

  Future<void> updateProfile(Map<String, dynamic> updates) async {
    await _service.updateProfile(updates);
    _syncStateFromServiceIfOwned();
  }

  Future<void> updateAdvancedProfile({
    required AdvancedProfile profile,
    required bool consentGiven,
  }) async {
    await _service.updateAdvancedProfile(
      profile: profile,
      consentGiven: consentGiven,
    );
    _syncStateFromServiceIfOwned();
  }

  Future<void> deleteAdvancedProfileField(String fieldKey) async {
    await _service.deleteAdvancedProfileField(fieldKey);
    _syncStateFromServiceIfOwned();
  }

  Future<void> revokeAdvancedProfileConsent() async {
    await _service.revokeAdvancedProfileConsent();
    _syncStateFromServiceIfOwned();
  }

  String getInterestVector() => _service.getInterestVector();

  void _syncStateFromServiceIfOwned() {
    if (!_service.cachedProfileMatchesCurrentAuth()) return;
    final profile = _service.getCachedProfile();
    if (profile != null) state = profile;
  }
}

// ---------------------------------------------------------------------------
// Serialization helpers
// ---------------------------------------------------------------------------

double _toDouble(dynamic value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0;
  return 0;
}

num _toNum(dynamic value) {
  if (value is num) return value;
  if (value is String) return num.tryParse(value) ?? 0;
  return 0;
}

List<String> _toStringList(dynamic value) {
  if (value is List) {
    return value.map((e) => e.toString()).where((e) => e.isNotEmpty).toList();
  }
  return [];
}

DateTime _parseDateTime(dynamic value) {
  if (value is DateTime) return value;
  if (value is Timestamp) return value.toDate();
  if (value is String) {
    return DateTime.tryParse(value) ?? DateTime.now();
  }
  return DateTime.now();
}
