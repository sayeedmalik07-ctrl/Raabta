import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:raabta/features/exchange_locator/domain/models/exchange_branch.dart';
import 'package:raabta/features/exchange_locator/domain/models/exchange_company.dart';
class ExchangeLocatorLocalCache {
  ExchangeLocatorLocalCache(this._prefs);

  final SharedPreferences _prefs;

  static const _companiesKey = 'exchange_locator_companies_cache';
  static const _branchesKey = 'exchange_locator_branches_cache';
  static const _companiesTsKey = 'exchange_locator_companies_ts';
  static const _branchesTsKey = 'exchange_locator_branches_ts';
  static const _recentVisitsKey = 'exchange_locator_recent_visits';
  static const _lastReviewKey = 'exchange_locator_last_review_at';
  static const cacheTtl = Duration(minutes: 15);
  static const queueCacheTtl = Duration(minutes: 5);
  static const maxRecentVisits = 20;
  static const _queueCachePrefix = 'exchange_locator_queue_';

  bool isCompaniesFresh() => _isFresh(_companiesTsKey);
  bool isBranchesFresh() => _isFresh(_branchesTsKey);

  bool _isFresh(String tsKey) {
    final raw = _prefs.getInt(tsKey);
    if (raw == null) return false;
    return DateTime.now().difference(
          DateTime.fromMillisecondsSinceEpoch(raw),
        ) <
        cacheTtl;
  }

  Future<void> cacheCompanies(List<ExchangeCompany> companies) async {
    await _prefs.setString(
      _companiesKey,
      jsonEncode(companies.map((c) => _companyToCache(c)).toList()),
    );
    await _prefs.setInt(
      _companiesTsKey,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  List<ExchangeCompany>? loadCompanies() {
    final raw = _prefs.getString(_companiesKey);
    if (raw == null) return null;
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => ExchangeCompany.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return null;
    }
  }

  Future<void> cacheBranches(List<ExchangeBranch> branches) async {
    await _prefs.setString(
      _branchesKey,
      jsonEncode(branches.map((b) => _branchToCache(b)).toList()),
    );
    await _prefs.setInt(
      _branchesTsKey,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  List<ExchangeBranch>? loadBranches() {
    final raw = _prefs.getString(_branchesKey);
    if (raw == null) return null;
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => ExchangeBranch.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return null;
    }
  }

  Future<void> recordRecentVisit(ExchangeBranch branch) async {
    final visits = loadRecentVisitIds();
    visits.remove(branch.id);
    visits.insert(0, branch.id);
    final trimmed = visits.take(maxRecentVisits).toList();
    await _prefs.setStringList(_recentVisitsKey, trimmed);
    await _prefs.setString(
      '${_recentVisitsKey}_$branch.id',
      jsonEncode(_branchToCache(branch)),
    );
  }

  List<String> loadRecentVisitIds() =>
      _prefs.getStringList(_recentVisitsKey) ?? [];

  ExchangeBranch? loadRecentBranch(String branchId) {
    final raw = _prefs.getString('${_recentVisitsKey}_$branchId');
    if (raw == null) return null;
    try {
      return ExchangeBranch.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  DateTime? lastReviewSubmittedAt(String userId) {
    final raw = _prefs.getString('${_lastReviewKey}_$userId');
    if (raw == null) return null;
    return DateTime.tryParse(raw);
  }

  Future<void> markReviewSubmitted(String userId) async {
    await _prefs.setString(
      '${_lastReviewKey}_$userId',
      DateTime.now().toIso8601String(),
    );
  }

  Future<void> cacheQueueSnapshot(ExchangeBranch branch) async {
    await _prefs.setString(
      '$_queueCachePrefix${branch.id}',
      jsonEncode({
        'queueStatus': branch.queueStatus.value,
        'estimatedWaitingMinutes': branch.estimatedWaitingMinutes,
        'queueLastUpdated': branch.queueLastUpdated?.toIso8601String(),
      }),
    );
  }

  ({ExchangeQueueStatus status, int waitMinutes, DateTime? updatedAt})?
      loadQueueSnapshot(String branchId) {
    final raw = _prefs.getString('$_queueCachePrefix$branchId');
    if (raw == null) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return (
        status: ExchangeQueueStatus.fromValue(map['queueStatus'] as String?),
        waitMinutes: (map['estimatedWaitingMinutes'] as num?)?.toInt() ?? 0,
        updatedAt: DateTime.tryParse(map['queueLastUpdated'] as String? ?? ''),
      );
    } catch (_) {
      return null;
    }
  }

  bool isQueueSnapshotFresh(String branchId) {
    final snap = loadQueueSnapshot(branchId);
    if (snap?.updatedAt == null) return false;
    return DateTime.now().difference(snap!.updatedAt!) < queueCacheTtl;
  }

  Future<void> invalidateBranch(String branchId) async {
    await _prefs.remove('$_queueCachePrefix$branchId');
  }

  Map<String, dynamic> _companyToCache(ExchangeCompany c) => {
        'companyId': c.id,
        'name': c.name,
        'logo': c.logo,
        'description': c.description,
        'website': c.website,
        'supportPhone': c.supportPhone,
        'supportWhatsapp': c.supportWhatsapp,
        'email': c.email,
        'totalBranches': c.totalBranches,
        'rating': c.rating,
        'totalReviews': c.totalReviews,
        'isFeatured': c.isFeatured,
        'isVerified': c.isVerified,
        'dataStatus': c.dataStatus.value,
        'coverageNote': c.coverageNote,
        'createdAt': c.createdAt?.toIso8601String(),
        'updatedAt': c.updatedAt?.toIso8601String(),
      };

  Map<String, dynamic> _branchToCache(ExchangeBranch b) => {
        'branchId': b.id,
        'companyId': b.companyId,
        'branchName': b.branchName,
        'branchCode': b.branchCode,
        'address': b.address,
        'area': b.area,
        'city': b.city,
        'zone': b.zone,
        'latitude': b.latitude,
        'longitude': b.longitude,
        'googleMapsLink': b.googleMapsLink,
        'openingHours': b.openingHours,
        'closingHours': b.closingHours,
        'fridayTiming': b.fridayTiming,
        'isOpenNow': b.isOpenNow,
        'phone': b.phone,
        'whatsapp': b.whatsapp,
        'email': b.email,
        'services': b.services,
        'parkingAvailable': b.parkingAvailable,
        'wheelchairAccessible': b.wheelchairAccessible,
        'nearbyMetro': b.nearbyMetro,
        'metroDistance': b.metroDistance,
        'nearestLandmark': b.nearestLandmark,
        'branchPhoto': b.branchPhoto,
        'queueStatus': b.queueStatus.value,
        'estimatedWaitingMinutes': b.estimatedWaitingMinutes,
        'rating': b.rating,
        'reviewCount': b.reviewCount,
        'lastUpdated': b.lastUpdated?.toIso8601String(),
        'companyName': b.companyName,
        'companyLogo': b.companyLogo,
        'dataStatus': b.dataStatus.value,
        'geocodeSource': b.geocodeSource,
        'geocodePrecision': b.geocodePrecision?.value,
        'geocodedAt': b.geocodedAt?.toIso8601String(),
        'detailsVerified': b.detailsVerified,
        'hourlyBusyCounts': b.hourlyBusyCounts,
        'queueLastUpdated': b.queueLastUpdated?.toIso8601String(),
      };
}
