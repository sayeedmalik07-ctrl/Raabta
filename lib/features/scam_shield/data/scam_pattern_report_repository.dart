import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:raabta/features/scam_shield/domain/scam_community_location_reporting.dart';
import 'package:raabta/models/housing_models.dart';
import 'package:raabta/services/firebase_service.dart';

/// Raw scam pattern reports — auth-scoped writes; aggregates are backend-only.
class ScamPatternReportRepository {
  ScamPatternReportRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ??
            (FirebaseService.isReady ? FirebaseFirestore.instance : null);

  static const collectionName = 'scam_pattern_reports';
  static const maxReportsPerUserPerDay = 3;

  final FirebaseFirestore? _firestore;

  CollectionReference<Map<String, dynamic>>? get _collection =>
      _firestore?.collection(collectionName);

  static bool isAllowedArea(String area) => qatarAreas.contains(area);

  static bool isAllowedArchetype(String archetypeId) =>
      ScamCommunityLocationReporting.locationRelevantPatternIds
          .contains(archetypeId);

  DateTime _qatarDayStartUtc(DateTime now) {
    final qatar = now.toUtc().add(const Duration(hours: 3));
    return DateTime.utc(qatar.year, qatar.month, qatar.day)
        .subtract(const Duration(hours: 3));
  }

  Future<int> countReportsToday({required String userId}) async {
    final col = _collection;
    if (col == null) return 0;

    final dayStart = _qatarDayStartUtc(DateTime.now());
    final snap = await col
        .where('userId', isEqualTo: userId)
        .where('reportedAt', isGreaterThanOrEqualTo: dayStart.toIso8601String())
        .where('status', isEqualTo: 'active')
        .get();
    return snap.docs.length;
  }

  Future<void> submitReport({
    required String userId,
    required String archetypeId,
    required String area,
  }) async {
    final col = _collection;
    if (col == null) {
      throw StateError('Firestore not available');
    }
    if (!isAllowedArchetype(archetypeId)) {
      throw ArgumentError('archetype_not_allowed');
    }
    if (!isAllowedArea(area)) {
      throw ArgumentError('area_not_allowed');
    }

    final todayCount = await countReportsToday(userId: userId);
    if (todayCount >= maxReportsPerUserPerDay) {
      throw StateError('rate_limit_exceeded');
    }

    await col.add({
      'userId': userId,
      'archetypeId': archetypeId,
      'area': area,
      'reportedAt': DateTime.now().toIso8601String(),
      'status': 'active',
    });
  }
}
