import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/services/ai/debouncer.dart';
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
      };

  factory ExpatLifeScore.fromJson(Map<String, dynamic> json) {
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

  factory UserAIProfile.defaultProfile(String uid) {
    return UserAIProfile(
      uid: uid,
      profession: '',
      yearsExperience: 0,
      preferredArea: 'Al Khor',
      budgetRange: const {'min': 0, 'max': 5000},
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
      preferredArea: json['preferredArea'] as String? ?? 'Al Khor',
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
    );
  }
}

// ---------------------------------------------------------------------------
// Service
// ---------------------------------------------------------------------------

class UserProfileAIService {
  UserProfileAIService({
    FirebaseFirestore? firestore,
    this._prefs,
    Debouncer? saveDebouncer,
  })  : _firestore = FirebaseService.isReady
            ? (firestore ?? FirebaseFirestore.instance)
            : null,
        _saveDebouncer = saveDebouncer ?? Debouncer();

  static const _profileDocId = 'profile';
  static const _maxSearchHistory = 50;
  static const _maxTrackedIds = 200;
  static const _professionViewThreshold = 3;

  final FirebaseFirestore? _firestore;
  SharedPreferences? _prefs;
  final Debouncer _saveDebouncer;

  UserAIProfile? _cachedProfile;
  final Map<String, int> _professionViewCounts = {};

  DocumentReference<Map<String, dynamic>>? _profileRef(String uid) {
    if (_firestore == null) return null;
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('ai_profile')
        .doc(_profileDocId);
  }

  String _cacheKey(String uid) => 'user_ai_profile_$uid';

  Future<SharedPreferences> _getPrefs() async {
    return _prefs ??= await SharedPreferences.getInstance();
  }

  /// 1. Initialize profile — load from Firestore or create default.
  Future<UserAIProfile> initProfile(String uid) async {
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

    _cachedProfile = profile;
    await _cacheLocally(profile);
    return profile;
  }

  /// 2. Track job view and infer profession preferences.
  Future<void> trackJobView(String jobId, Map<String, dynamic> jobData) async {
    _ensureProfile();
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

    await _applyProfileUpdate(profile);
  }

  /// 3. Track housing view and update area / budget preferences.
  Future<void> trackHousingView(
    String listingId,
    Map<String, dynamic> listingData,
  ) async {
    _ensureProfile();
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

    await _applyProfileUpdate(profile);
  }

  /// 4. Track business view and update interests.
  Future<void> trackBusinessView(
    String bizId,
    Map<String, dynamic> bizData,
  ) async {
    _ensureProfile();
    var profile = _cachedProfile!;

    final businesses = _appendUnique(profile.savedBusinessIds, bizId);
    profile = profile.copyWith(savedBusinessIds: businesses);

    final category = _extractBusinessCategory(bizData);
    if (category.isNotEmpty) {
      profile = profile.copyWith(
        interests: _mergeUnique(profile.interests, [category]),
      );
    }

    await _applyProfileUpdate(profile);
  }

  /// 5. Track search query and parse preferences.
  Future<void> trackSearch(String query) async {
    _ensureProfile();
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

    await _applyProfileUpdate(profile);
  }

  /// 6. Track saved item — saved items carry 3x recommendation weight.
  Future<void> trackSave(String type, String id) async {
    _ensureProfile();
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

    await _applyProfileUpdate(profile);
  }

  /// 7. Return locally cached profile.
  UserAIProfile? getCachedProfile() => _cachedProfile;

  /// 8. Update specific profile fields.
  Future<void> updateProfile(Map<String, dynamic> updates) async {
    _ensureProfile();
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
    if (updates.containsKey('score') && updates['score'] is Map) {
      profile = profile.copyWith(
        score: ExpatLifeScore.fromJson(
          Map<String, dynamic>.from(updates['score'] as Map),
        ),
      );
    }

    await _applyProfileUpdate(profile, immediate: true);
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

    return weighted.where((e) => e.trim().isNotEmpty).join(', ');
  }

  void dispose() {
    _saveDebouncer.dispose();
  }

  // -------------------------------------------------------------------------
  // Internal helpers
  // -------------------------------------------------------------------------

  void _ensureProfile() {
    if (_cachedProfile == null) {
      throw StateError(
        'Profile not initialized. Call initProfile(uid) first.',
      );
    }
  }

  Future<void> _applyProfileUpdate(
    UserAIProfile profile, {
    bool immediate = false,
  }) async {
    final updated = profile.copyWith(lastUpdated: DateTime.now());
    _cachedProfile = updated;
    await _cacheLocally(updated);

    if (immediate) {
      _saveDebouncer.cancel();
      await _persistToFirestore(updated);
    } else {
      _scheduleDebouncedSave();
    }
  }

  void _scheduleDebouncedSave() {
    _saveDebouncer.run(() async {
      final profile = _cachedProfile;
      if (profile == null) return;
      await _persistToFirestore(profile);
    });
  }

  Future<void> _persistToFirestore(UserAIProfile profile) async {
    final ref = _profileRef(profile.uid);
    if (ref == null) return;

    try {
      await ref.set(profile.toJson(), SetOptions(merge: true));
    } catch (e) {
      debugPrint('UserProfileAIService: Firestore save failed — $e');
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

  Future<void> initProfile(String uid) async {
    state = await _service.initProfile(uid);
  }

  Future<void> trackJobView(String jobId, Map<String, dynamic> jobData) async {
    await _service.trackJobView(jobId, jobData);
    state = _service.getCachedProfile();
  }

  Future<void> trackHousingView(
    String listingId,
    Map<String, dynamic> listingData,
  ) async {
    await _service.trackHousingView(listingId, listingData);
    state = _service.getCachedProfile();
  }

  Future<void> trackBusinessView(
    String bizId,
    Map<String, dynamic> bizData,
  ) async {
    await _service.trackBusinessView(bizId, bizData);
    state = _service.getCachedProfile();
  }

  Future<void> trackSearch(String query) async {
    await _service.trackSearch(query);
    state = _service.getCachedProfile();
  }

  Future<void> trackSave(String type, String id) async {
    await _service.trackSave(type, id);
    state = _service.getCachedProfile();
  }

  UserAIProfile? getCachedProfile() => _service.getCachedProfile();

  Future<void> updateProfile(Map<String, dynamic> updates) async {
    await _service.updateProfile(updates);
    state = _service.getCachedProfile();
  }

  String getInterestVector() => _service.getInterestVector();
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
