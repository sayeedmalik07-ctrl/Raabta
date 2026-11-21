import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:raabta/features/exchange_locator/data/exchange_locator_local_cache.dart';
import 'package:raabta/features/exchange_locator/domain/exchange_queue_logic.dart';
import 'package:raabta/features/exchange_locator/domain/models/branch_filters.dart';
import 'package:raabta/features/exchange_locator/domain/models/exchange_branch.dart';
import 'package:raabta/features/exchange_locator/domain/models/exchange_company.dart';
import 'package:raabta/features/exchange_locator/domain/models/exchange_review.dart';
import 'package:raabta/features/exchange_locator/domain/repositories/exchange_locator_repository.dart';
import 'package:raabta/features/prayer_mosque/services/prayer_location_service.dart';
import 'package:raabta/services/firebase_service.dart';

class ExchangeLocatorFirestoreRepository implements ExchangeLocatorRepository {
  ExchangeLocatorFirestoreRepository({
    FirebaseFirestore? firestore,
    ExchangeLocatorLocalCache? cache,
  })  : _firestore = firestore ??
            (FirebaseService.isReady ? FirebaseFirestore.instance : null),
        _cache = cache;

  final FirebaseFirestore? _firestore;
  final ExchangeLocatorLocalCache? _cache;

  CollectionReference<Map<String, dynamic>>? get _companiesRef =>
      _firestore?.collection('exchange_companies');

  CollectionReference<Map<String, dynamic>>? get _branchesRef =>
      _firestore?.collection('exchange_branches');

  CollectionReference<Map<String, dynamic>>? get _servicesRef =>
      _firestore?.collection('exchange_services');

  CollectionReference<Map<String, dynamic>>? get _reviewsRef =>
      _firestore?.collection('exchange_reviews');

  CollectionReference<Map<String, dynamic>>? get _queueReportsRef =>
      _firestore?.collection('exchange_queue_reports');

  CollectionReference<Map<String, dynamic>> _favoritesRef(String uid) {
    _ensureReady();
    return _firestore!.collection('users').doc(uid).collection('exchange_favorites');
  }

  CollectionReference<Map<String, dynamic>> _recentVisitsRef(String uid) {
    _ensureReady();
    return _firestore!.collection('users').doc(uid).collection('exchange_recent_visits');
  }

  void _ensureReady() {
    if (_firestore == null) {
      throw ExchangeLocatorException('Firestore not initialized');
    }
  }

  @override
  Future<PaginatedResult<ExchangeCompany>> fetchCompanies({
    int limit = 20,
    String? startAfterId,
    bool featuredOnly = false,
  }) async {
    _ensureReady();

    if (_cache != null &&
        _cache!.isCompaniesFresh() &&
        startAfterId == null &&
        !featuredOnly) {
      final cached = _cache!.loadCompanies();
      if (cached != null && cached.isNotEmpty) {
        return PaginatedResult(
          items: cached.take(limit).toList(),
          hasMore: cached.length > limit,
          lastDocumentId:
              cached.length > limit ? cached[limit - 1].id : cached.last.id,
        );
      }
    }

    Query<Map<String, dynamic>> query = _companiesRef!;
    if (featuredOnly) {
      query = query.where('isFeatured', isEqualTo: true);
    }
    query = query.orderBy('rating', descending: true).limit(limit + 1);

    if (startAfterId != null) {
      final cursor = await _companiesRef!.doc(startAfterId).get();
      if (cursor.exists) query = query.startAfterDocument(cursor);
    }

    final snapshot = await query.get();
    var items = snapshot.docs.map(ExchangeCompany.fromFirestore).toList();
    final hasMore = items.length > limit;
    if (hasMore) items = items.take(limit).toList();

    if (startAfterId == null && !featuredOnly && _cache != null) {
      await _cache!.cacheCompanies(items);
    }

    return PaginatedResult(
      items: items,
      hasMore: hasMore,
      lastDocumentId: items.isEmpty ? null : items.last.id,
    );
  }

  @override
  Future<ExchangeCompany?> fetchCompany(String companyId) async {
    _ensureReady();
    final doc = await _companiesRef!.doc(companyId).get();
    if (!doc.exists) return null;
    return ExchangeCompany.fromFirestore(doc);
  }

  @override
  Future<PaginatedResult<ExchangeBranch>> fetchBranches({
    int limit = 30,
    String? startAfterId,
    String? companyId,
    BranchFinderFilters? filters,
  }) async {
    _ensureReady();
    final f = filters ?? const BranchFinderFilters();

    Query<Map<String, dynamic>> query = _branchesRef!;
    if (companyId != null) {
      query = query.where('companyId', isEqualTo: companyId);
    } else if (f.city != null && f.city!.isNotEmpty) {
      query = query.where('city', isEqualTo: f.city);
    } else if (f.area != null && f.area!.isNotEmpty) {
      query = query.where('area', isEqualTo: f.area);
    } else if (f.openNowOnly) {
      query = query.where('isOpenNow', isEqualTo: true);
    }

    query = query.orderBy('rating', descending: true).limit(limit + 1);

    if (startAfterId != null) {
      final cursor = await _branchesRef!.doc(startAfterId).get();
      if (cursor.exists) query = query.startAfterDocument(cursor);
    }

    final snapshot = await query.get();
    var items = snapshot.docs.map(ExchangeBranch.fromFirestore).toList();
    items = _applyClientFilters(items, f);

    final hasMore = items.length > limit;
    if (hasMore) items = items.take(limit).toList();

    return PaginatedResult(
      items: items,
      hasMore: hasMore,
      lastDocumentId: items.isEmpty ? null : items.last.id,
    );
  }

  List<ExchangeBranch> _applyClientFilters(
    List<ExchangeBranch> branches,
    BranchFinderFilters filters,
  ) {
    var result = branches;

    if (filters.openNowOnly) {
      result = result.where((b) => b.isOpenNow).toList();
    }
    if (filters.service != null && filters.service!.isNotEmpty) {
      final s = filters.service!.toLowerCase();
      result = result
          .where((b) => b.services.any((x) => x.toLowerCase().contains(s)))
          .toList();
    }
    if (filters.searchQuery.trim().isNotEmpty) {
      // Client-side filter — Firestore lacks full-text search without Algolia/Typesense.
      final q = filters.searchQuery.toLowerCase();
      result = result.where((b) {
        final haystack =
            '${b.branchName} ${b.area} ${b.city} ${b.address} ${b.nearestLandmark ?? ''} ${b.nearbyMetro ?? ''} ${b.companyName ?? ''} ${b.services.join(' ')}'
                .toLowerCase();
        return haystack.contains(q);
      }).toList();
    }

    switch (filters.sort) {
      case BranchSortOption.highestRated:
        result.sort((a, b) => b.rating.compareTo(a.rating));
      case BranchSortOption.lowestWait:
        result.sort(
          (a, b) =>
              a.estimatedWaitingMinutes.compareTo(b.estimatedWaitingMinutes),
        );
      case BranchSortOption.openNow:
        result.sort((a, b) {
          if (a.isOpenNow == b.isOpenNow) {
            return b.rating.compareTo(a.rating);
          }
          return a.isOpenNow ? -1 : 1;
        });
      case BranchSortOption.nearest:
        break;
    }

    return result;
  }

  @override
  Future<ExchangeBranch?> fetchBranch(String branchId) async {
    _ensureReady();
    final doc = await _branchesRef!.doc(branchId).get();
    if (!doc.exists) return null;
    return ExchangeBranch.fromFirestore(doc);
  }

  @override
  Future<List<ExchangeBranch>> fetchAllBranchesForMap() async {
    _ensureReady();

    if (_cache != null && _cache!.isBranchesFresh()) {
      final cached = _cache!.loadBranches();
      if (cached != null && cached.isNotEmpty) return cached;
    }

    return _loadBranchesForMap();
  }

  @override
  Future<List<ExchangeBranch>> refreshBranchesForMap() async {
    _ensureReady();
    return _loadBranchesForMap(force: true);
  }

  Future<List<ExchangeBranch>> _loadBranchesForMap({bool force = false}) async {
    final snapshot =
        await _branchesRef!.orderBy('rating', descending: true).get();
    final branches = snapshot.docs.map(ExchangeBranch.fromFirestore).toList();
    if (force || _cache != null) {
      await _cache?.cacheBranches(branches);
    }
    return branches;
  }

  @override
  Future<PaginatedResult<ExchangeReview>> fetchReviews({
    required String branchId,
    int limit = 15,
    String? startAfterId,
    ExchangeReviewSort sort = ExchangeReviewSort.recent,
  }) async {
    _ensureReady();
    Query<Map<String, dynamic>> query = _reviewsRef!
        .where('branchId', isEqualTo: branchId);

    if (sort == ExchangeReviewSort.highestRating) {
      query = query.orderBy('rating', descending: true).orderBy('createdAt', descending: true);
    } else {
      query = query.orderBy('createdAt', descending: true);
    }

    query = query.limit(limit + 1);

    if (startAfterId != null) {
      final cursor = await _reviewsRef!.doc(startAfterId).get();
      if (cursor.exists) query = query.startAfterDocument(cursor);
    }

    final snapshot = await query.get();
    var items = snapshot.docs.map(ExchangeReview.fromFirestore).toList();
    final hasMore = items.length > limit;
    if (hasMore) items = items.take(limit).toList();

    return PaginatedResult(
      items: items,
      hasMore: hasMore,
      lastDocumentId: items.isEmpty ? null : items.last.id,
    );
  }

  @override
  Future<bool> hasUserReviewedBranch({
    required String branchId,
    required String userId,
  }) async {
    _ensureReady();
    final snapshot = await _reviewsRef!
        .where('branchId', isEqualTo: branchId)
        .where('userId', isEqualTo: userId)
        .limit(1)
        .get();
    return snapshot.docs.isNotEmpty;
  }

  @override
  Future<void> submitReview({
    required String branchId,
    required String userId,
    required int rating,
    required String review,
    String? userDisplayName,
  }) async {
    _ensureReady();
    if (rating < 1 || rating > 5) {
      throw ExchangeLocatorException('Rating must be between 1 and 5');
    }

    final existing = await hasUserReviewedBranch(
      branchId: branchId,
      userId: userId,
    );
    if (existing) {
      throw ExchangeLocatorException('You already reviewed this branch');
    }

    final reviewRef = _reviewsRef!.doc();
    final branchRef = _branchesRef!.doc(branchId);
    final branchSnap = await branchRef.get();
    final branchData = branchSnap.data() ?? {};
    final oldCount = (branchData['reviewCount'] as num?)?.toInt() ?? 0;
    final oldRating = (branchData['rating'] as num?)?.toDouble() ?? 0;
    final newCount = oldCount + 1;
    final newRating = oldCount == 0
        ? rating.toDouble()
        : ((oldRating * oldCount) + rating) / newCount;

    await reviewRef.set({
      'branchId': branchId,
      'userId': userId,
      'rating': rating,
      'review': review.trim(),
      'userDisplayName': userDisplayName,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await branchRef.update({
      'rating': double.parse(newRating.toStringAsFixed(2)),
      'reviewCount': newCount,
      'lastUpdated': FieldValue.serverTimestamp(),
    });

    await _cache?.cacheBranches([]);
  }

  @override
  Stream<Set<String>> watchFavoriteBranchIds(String userId) {
    _ensureReady();
    return _favoritesRef(userId).snapshots().map(
          (snap) => snap.docs.map((d) => d.id).toSet(),
        );
  }

  @override
  Future<void> toggleFavorite({
    required String userId,
    required String branchId,
    required ExchangeBranch branch,
  }) async {
    _ensureReady();
    final ref = _favoritesRef(userId).doc(branchId);
    final doc = await ref.get();
    if (doc.exists) {
      await ref.delete();
    } else {
      await ref.set({
        'branchId': branchId,
        'companyId': branch.companyId,
        'branchName': branch.branchName,
        'area': branch.area,
        'savedAt': FieldValue.serverTimestamp(),
        'snapshot': branch.toJson(),
      });
    }
  }

  @override
  Future<List<ExchangeBranch>> fetchFavoriteBranches(String userId) async {
    _ensureReady();
    final snapshot = await _favoritesRef(userId)
        .orderBy('savedAt', descending: true)
        .get();
    final branches = <ExchangeBranch>[];
    for (final doc in snapshot.docs) {
      final data = doc.data();
      final snap = data['snapshot'] as Map<String, dynamic>?;
      if (snap != null) {
        branches.add(ExchangeBranch.fromJson(snap));
      } else {
        final live = await fetchBranch(doc.id);
        if (live != null) branches.add(live);
      }
    }
    return branches;
  }

  @override
  Future<String> upsertCompany(ExchangeCompany company) async {
    _ensureReady();
    final ref = company.id.isEmpty
        ? _companiesRef!.doc()
        : _companiesRef!.doc(company.id);
    final payload = company.copyWith(
      id: ref.id,
      updatedAt: DateTime.now(),
      createdAt: company.createdAt ?? DateTime.now(),
    ).toJson();
    await ref.set(payload, SetOptions(merge: true));
    await _cache?.cacheCompanies([]);
    return ref.id;
  }

  @override
  Future<void> deleteCompany(String companyId) async {
    _ensureReady();
    final branches = await _branchesRef!
        .where('companyId', isEqualTo: companyId)
        .get();
    final batch = _firestore!.batch();
    for (final doc in branches.docs) {
      batch.delete(doc.reference);
    }
    batch.delete(_companiesRef!.doc(companyId));
    await batch.commit();
    await _cache?.cacheCompanies([]);
    await _cache?.cacheBranches([]);
  }

  @override
  Future<String> upsertBranch(ExchangeBranch branch) async {
    _ensureReady();
    final ref = branch.id.isEmpty
        ? _branchesRef!.doc()
        : _branchesRef!.doc(branch.id);

    var payloadBranch = branch;
    if (branch.companyId.isNotEmpty) {
      final company = await fetchCompany(branch.companyId);
      if (company != null) {
        payloadBranch = branch.copyWith(
          companyName: company.name,
          companyLogo: company.logo,
        );
      }
    }

    final payload = payloadBranch.copyWith(id: ref.id).toJson();
    await ref.set(payload, SetOptions(merge: true));
    await syncBranchServices(ref.id, payloadBranch.services);
    await _updateCompanyBranchCount(payloadBranch.companyId);
    await _cache?.cacheBranches([]);
    return ref.id;
  }

  Future<void> _updateCompanyBranchCount(String companyId) async {
    final countSnap = await _branchesRef!
        .where('companyId', isEqualTo: companyId)
        .count()
        .get();
    await _companiesRef!.doc(companyId).update({
      'totalBranches': countSnap.count ?? 0,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> deleteBranch(String branchId) async {
    _ensureReady();
    final branch = await fetchBranch(branchId);
    await _branchesRef!.doc(branchId).delete();
    final services = await _servicesRef!
        .where('branchId', isEqualTo: branchId)
        .get();
    final batch = _firestore!.batch();
    for (final doc in services.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
    if (branch != null) await _updateCompanyBranchCount(branch.companyId);
    await _cache?.cacheBranches([]);
  }

  @override
  Future<void> syncBranchServices(String branchId, List<String> services) async {
    _ensureReady();
    final existing = await _servicesRef!
        .where('branchId', isEqualTo: branchId)
        .get();
    final batch = _firestore!.batch();
    for (final doc in existing.docs) {
      batch.delete(doc.reference);
    }
    for (final name in services) {
      final ref = _servicesRef!.doc();
      batch.set(ref, {
        'serviceId': ref.id,
        'branchId': branchId,
        'serviceName': name,
      });
    }
    await batch.commit();
  }

  @override
  Future<List<CrowdReportSample>> fetchRecentCrowdReports(
    String branchId,
  ) async {
    _ensureReady();
    final since = DateTime.now().subtract(ExchangeQueueLogic.reportWindow);
    final snapshot = await _queueReportsRef!
        .where('branchId', isEqualTo: branchId)
        .orderBy('createdAt', descending: true)
        .limit(10)
        .get();

    return snapshot.docs
        .map((doc) {
          final data = doc.data();
          return CrowdReportSample(
            level: CrowdReportLevel.fromValue(data['level'] as String?),
            reportedAt:
                (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          );
        })
        .where((r) => r.reportedAt.isAfter(since))
        .toList();
  }

  @override
  Future<void> submitCrowdReport({
    required String branchId,
    required String userId,
    required CrowdReportLevel level,
  }) async {
    _ensureReady();
    final now = DateTime.now();
    await _queueReportsRef!.add({
      'branchId': branchId,
      'userId': userId,
      'level': level.value,
      'createdAt': FieldValue.serverTimestamp(),
    });

    final recent = await fetchRecentCrowdReports(branchId);
    final aggregate = ExchangeQueueLogic.aggregateReports(recent, now: now);

    final hourKey = ExchangeQueueLogic.hourlyCountKey(now);
    final branchUpdate = <String, dynamic>{
      'hourlyBusyCounts.$hourKey': FieldValue.increment(1),
      'queueLastUpdated': FieldValue.serverTimestamp(),
    };

    if (aggregate != null) {
      branchUpdate['queueStatus'] = aggregate.level.queueStatus.value;
      branchUpdate['estimatedWaitingMinutes'] = aggregate.estimatedWaitMinutes;
    }

    await _branchesRef!.doc(branchId).update(branchUpdate);
    await _cache?.invalidateBranch(branchId);
    await _cache?.cacheBranches([]);
  }

  @override
  Future<void> recordRecentVisitRemote({
    required String userId,
    required ExchangeBranch branch,
  }) async {
    _ensureReady();
    await _recentVisitsRef(userId).doc(branch.id).set({
      'branchId': branch.id,
      'visitedAt': FieldValue.serverTimestamp(),
      'snapshot': branch.toJson(),
    });
  }

  @override
  Future<List<ExchangeBranch>> fetchRecentVisitsRemote(String userId) async {
    _ensureReady();
    final snapshot = await _recentVisitsRef(userId)
        .orderBy('visitedAt', descending: true)
        .limit(20)
        .get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      final snap = data['snapshot'] as Map<String, dynamic>?;
      if (snap != null) return ExchangeBranch.fromJson(snap);
      return ExchangeBranch.fromJson({'branchId': doc.id});
    }).toList();
  }

  @override
  Future<void> setBranchDetailsVerified({
    required String branchId,
    required bool verified,
  }) async {
    _ensureReady();
    await _branchesRef!.doc(branchId).update({
      'detailsVerified': verified,
      'lastUpdated': FieldValue.serverTimestamp(),
    });
    await _cache?.invalidateBranch(branchId);
    await _cache?.cacheBranches([]);
  }

  /// Sort branches by distance from a point (Smart Nearby).
  static List<ExchangeBranch> sortByDistance(
    List<ExchangeBranch> branches,
    double lat,
    double lng,
  ) {
    final sorted = [...branches];
    sorted.sort((a, b) {
      final da = PrayerLocationService.haversineKm(lat, lng, a.latitude, a.longitude);
      final db = PrayerLocationService.haversineKm(lat, lng, b.latitude, b.longitude);
      return da.compareTo(db);
    });
    return sorted;
  }
}
