import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:raabta/data/repositories/jobs_repository.dart';
import 'package:raabta/features/post_engine/data/post_schema_adapter.dart';
import 'package:raabta/features/post_engine/domain/models/post_vertical.dart';
import 'package:raabta/models/housing_models.dart';
import 'package:raabta/services/firebase_service.dart';

/// Maximum active same-user listings considered for duplicate detection.
const int postDuplicateCandidateLimit = 25;

/// Thrown when duplicate candidate retrieval fails — publish must not proceed.
class PostDuplicateCandidateLoadException implements Exception {
  PostDuplicateCandidateLoadException(this.message, [this.cause]);

  final String message;
  final Object? cause;

  @override
  String toString() => 'PostDuplicateCandidateLoadException: $message';
}

/// Loads and maps the authenticated user's active listings for [PostTrustEngine].
class PostDuplicateCandidateLoader {
  PostDuplicateCandidateLoader({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _usesDefaultFirestore = firestore == null;

  final FirebaseFirestore _firestore;
  final bool _usesDefaultFirestore;

  /// Same-user active listings mapped for [PostDuplicateDetector] (Business excluded).
  Future<List<Map<String, dynamic>>> loadActiveSameUserListings({
    required PostVertical vertical,
    required String ownerUserId,
    required String categoryPath,
  }) async {
    if (ownerUserId.isEmpty) {
      throw PostDuplicateCandidateLoadException('Owner user id is required');
    }
    if (vertical == PostVertical.business) {
      return const [];
    }

    final categoryLeafId = PostSchemaAdapter.leafCategoryId(categoryPath);

    return switch (vertical) {
      PostVertical.marketplace => _loadMarketplace(ownerUserId, categoryLeafId),
      PostVertical.housing => _loadHousing(ownerUserId, categoryLeafId),
      PostVertical.services => _loadServices(ownerUserId, categoryLeafId),
      PostVertical.jobs => _loadJobs(ownerUserId, categoryLeafId),
      PostVertical.business => const [],
    };
  }

  Future<List<Map<String, dynamic>>> _loadMarketplace(
    String ownerUserId,
    String categoryLeafId,
  ) async {
    final docs = await _queryOwnerDocs(
      collection: 'marketplace_listings',
      ownerField: 'ownerUserId',
      ownerUserId: ownerUserId,
      activeStatus: 'active',
    );
    return docs
        .where((doc) => (doc.data()['categoryId'] as String? ?? '') == categoryLeafId)
        .map(PostDuplicateCandidateMapper.fromMarketplaceDoc)
        .toList();
  }

  Future<List<Map<String, dynamic>>> _loadHousing(
    String ownerUserId,
    String categoryLeafId,
  ) async {
    final expectedType =
        PostSchemaAdapter.housingListingTypeForCategoryLeaf(categoryLeafId);
    final docs = await _queryOwnerDocs(
      collection: 'listings',
      ownerField: 'ownerUserId',
      ownerUserId: ownerUserId,
    );
    return docs
        .where((doc) {
          final status = doc.data()['status'] as String? ?? '';
          if (status == ListingStatus.rejected.name) return false;
          final type = doc.data()['type'] as String? ?? '';
          return type == expectedType.name;
        })
        .map(PostDuplicateCandidateMapper.fromHousingDoc)
        .toList();
  }

  Future<List<Map<String, dynamic>>> _loadServices(
    String ownerUserId,
    String categoryLeafId,
  ) async {
    final docs = await _queryOwnerDocs(
      collection: 'service_listings',
      ownerField: 'userId',
      ownerUserId: ownerUserId,
      activeStatus: 'active',
    );
    return docs
        .where(
          (doc) =>
              (doc.data()['serviceCategoryId'] as String? ?? '') ==
              categoryLeafId,
        )
        .map(PostDuplicateCandidateMapper.fromServiceDoc)
        .toList();
  }

  Future<List<Map<String, dynamic>>> _loadJobs(
    String ownerUserId,
    String categoryLeafId,
  ) async {
    final docs = await _queryOwnerDocs(
      collection: JobsRepository.jobsCollection,
      ownerField: 'postedBy',
      ownerUserId: ownerUserId,
      activeStatus: 'active',
    );
    return docs
        .where((doc) => (doc.data()['category'] as String? ?? '') == categoryLeafId)
        .map(PostDuplicateCandidateMapper.fromJobDoc)
        .toList();
  }

  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> _queryOwnerDocs({
    required String collection,
    required String ownerField,
    required String ownerUserId,
    String? activeStatus,
  }) async {
    if (_usesDefaultFirestore && !FirebaseService.isReady) {
      throw PostDuplicateCandidateLoadException('Firebase is not ready');
    }

    final ref = _firestore.collection(collection);
    try {
      Query<Map<String, dynamic>> query = ref
          .where(ownerField, isEqualTo: ownerUserId)
          .limit(postDuplicateCandidateLimit);
      if (activeStatus != null) {
        query = ref
            .where(ownerField, isEqualTo: ownerUserId)
            .where('status', isEqualTo: activeStatus)
            .limit(postDuplicateCandidateLimit);
      }
      final snapshot = await query.get();
      return snapshot.docs;
    } on FirebaseException catch (e) {
      if (activeStatus != null && _isMissingIndexError(e)) {
        final fallback = await ref
            .where(ownerField, isEqualTo: ownerUserId)
            .limit(postDuplicateCandidateLimit)
            .get();
        return fallback.docs.where((doc) {
          final status = doc.data()['status'] as String?;
          return status == null || status == activeStatus;
        }).toList();
      }
      throw PostDuplicateCandidateLoadException(
        'Failed to load duplicate candidates',
        e,
      );
    } catch (e) {
      throw PostDuplicateCandidateLoadException(
        'Failed to load duplicate candidates',
        e,
      );
    }
  }

  static bool _isMissingIndexError(FirebaseException error) {
    final message = error.message?.toLowerCase() ?? '';
    return error.code == 'failed-precondition' || message.contains('index');
  }
}

/// Maps stored listing documents to fingerprint field maps (no algorithm changes).
abstract final class PostDuplicateCandidateMapper {
  static Map<String, dynamic> fromMarketplaceDoc(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    final fields = <String, dynamic>{
      '_listingId': doc.id,
      if (data['title'] != null) 'title': data['title'],
      if (data['price'] != null) 'price': data['price'],
    };
    final area = data['area']?.toString();
    if (area != null && area.isNotEmpty) {
      fields['area'] = area;
      fields['location'] = area;
    }
    _mergeSchemaVehicleKeys(data['schemaFields'], fields);
    return fields;
  }

  static Map<String, dynamic> fromHousingDoc(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    final fields = <String, dynamic>{
      '_listingId': doc.id,
      if (data['title'] != null) 'title': data['title'],
      if (data['pricePerMonth'] != null) 'pricePerMonth': data['pricePerMonth'],
    };
    final area = data['area']?.toString();
    if (area != null && area.isNotEmpty) {
      fields['area'] = area;
      fields['location'] = area;
    }
    return fields;
  }

  static Map<String, dynamic> fromServiceDoc(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    final title = data['title']?.toString();
    final serviceName = data['serviceName']?.toString();
    final fields = <String, dynamic>{'_listingId': doc.id};
    if (title != null && title.isNotEmpty) {
      fields['title'] = title;
    } else if (serviceName != null && serviceName.isNotEmpty) {
      fields['title'] = serviceName;
    }
    final area = data['area']?.toString();
    if (area != null && area.isNotEmpty) {
      fields['area'] = area;
      fields['location'] = area;
    }
    return fields;
  }

  /// Maps job documents for duplicate detection. [salary] is retained for
  /// completeness; [postListingFingerprint] excludes it (J1 — not listing identity).
  static Map<String, dynamic> fromJobDoc(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    return {
      '_listingId': doc.id,
      if (data['title'] != null) 'title': data['title'],
      if (data['salary'] != null) 'salary': data['salary'],
      if (data['location'] != null) 'location': data['location'],
    };
  }

  /// Aligns stored vehicle schema fields with draft-side fingerprint inputs.
  static void _mergeSchemaVehicleKeys(dynamic rawSchema, Map<String, dynamic> fields) {
    if (rawSchema is! Map) return;
    if (fields.containsKey('title') ||
        fields.containsKey('brand') ||
        fields.containsKey('model')) {
      return;
    }
    final make = rawSchema['make']?.toString();
    final model = rawSchema['model']?.toString();
    if (make != null && make.isNotEmpty) fields['brand'] = make;
    if (model != null && model.isNotEmpty) {
      fields['model'] = model;
      // Match publish-path title (_titleFromValues uses model when make is form-only).
      fields['title'] = model;
    }
  }
}
