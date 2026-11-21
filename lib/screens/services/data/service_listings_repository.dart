import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:raabta/features/global_search/domain/service_search_keyword_builder.dart';
import 'package:raabta/screens/services/models/service_listing.dart';
import 'package:raabta/services/firebase_service.dart';

/// Firestore + Storage for user-posted service classifieds.
class ServiceListingsRepository {
  ServiceListingsRepository({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _db = firestore ?? FirebaseFirestore.instance,
        _usesInjectedFirestore = firestore != null,
        _storage = FirebaseService.isReady
            ? (storage ?? FirebaseStorage.instance)
            : null;

  final FirebaseFirestore _db;
  final bool _usesInjectedFirestore;
  final FirebaseStorage? _storage;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _db.collection('service_listings');

  Future<String> uploadListingPhoto({
    required File file,
    required String uid,
    required String listingId,
    int photoIndex = 0,
  }) async {
    if (_storage == null) {
      throw StateError('Firebase Storage is not ready.');
    }
    final ext = _photoExtension(file.path);
    final ref = _storage.ref(
      'service_listings/$uid/$listingId${photoIndex == 0 ? '' : '_$photoIndex'}$ext',
    );
    await ref.putFile(file);
    return ref.getDownloadURL();
  }

  static String _photoExtension(String path) {
    final dot = path.lastIndexOf('.');
    if (dot == -1) return '.jpg';
    final ext = path.substring(dot).toLowerCase();
    const allowed = {'.jpg', '.jpeg', '.png', '.webp'};
    return allowed.contains(ext) ? ext : '.jpg';
  }

  Future<String> createListing(
    ServiceListingSubmission submission, {
    String? listingId,
  }) async {
    if (!_usesInjectedFirestore && !FirebaseService.isReady) {
      throw StateError('Firebase is not ready.');
    }
    if (listingId != null && listingId.isNotEmpty) {
      final existing = await _collection.doc(listingId).get();
      if (existing.exists) {
        final owner = existing.data()?['userId']?.toString() ?? '';
        if (owner != submission.userId) {
          throw StateError('listing_ownership_mismatch');
        }
        return listingId;
      }
      await _collection.doc(listingId).set(buildPersistedListingData(submission));
      return listingId;
    }
    final doc = await _collection.add(buildPersistedListingData(submission));
    return doc.id;
  }

  /// Persists searchable fields and regenerates [searchKeywords] (S3.1).
  Future<void> updateListing({
    required String id,
    required ServiceListingSubmission submission,
  }) async {
    if (!_usesInjectedFirestore && !FirebaseService.isReady) {
      throw StateError('Firebase is not ready.');
    }
    final data = buildPersistedListingData(submission);
    data.remove('createdAt');
    await _collection.doc(id).update(data);
  }

  /// Firestore payload including deterministic [searchKeywords].
  static Map<String, dynamic> buildPersistedListingData(
    ServiceListingSubmission submission,
  ) {
    return {
      ...submission.toFirestore(),
      'searchKeywords': ServiceSearchKeywordBuilder.build(
        title: submission.title,
        serviceName: submission.serviceName,
        serviceCategory: submission.serviceCategory,
        description: submission.description,
        providerName: submission.providerName,
        area: submission.area,
      ),
    };
  }

  Future<ServiceListing?> fetchListing(String id) async {
    if (!FirebaseService.isReady || id.isEmpty) return null;
    final doc = await _collection.doc(id).get();
    if (!doc.exists) return null;
    return ServiceListing.fromFirestore(doc);
  }

  Stream<List<ServiceListing>> watchRecentListings({
    int limit = 40,
    ServiceListingType listingType = ServiceListingType.provider,
  }) {
    if (!FirebaseService.isReady) return Stream.value(const []);

    return _watchListingQuery(
      limit: limit,
      listingType: listingType,
      queries: () => [
        _QueryPlan(
          _collection
              .where('status', isEqualTo: 'active')
              .where('listingType', isEqualTo: listingType.id)
              .orderBy('createdAt', descending: true)
              .limit(limit),
          clientSort: false,
          filterListingTypeClientSide: false,
        ),
        _QueryPlan(
          _collection
              .where('status', isEqualTo: 'active')
              .where('listingType', isEqualTo: listingType.id)
              .limit(limit),
          clientSort: true,
          filterListingTypeClientSide: false,
        ),
        _QueryPlan(
          _collection.where('status', isEqualTo: 'active').limit(limit * 3),
          clientSort: true,
          filterListingTypeClientSide: true,
        ),
      ],
    );
  }

  Stream<List<ServiceListing>> watchCategoryListings({
    required String categoryId,
    String? serviceName,
    ServiceListingType listingType = ServiceListingType.provider,
    int limit = 50,
  }) {
    if (!FirebaseService.isReady || categoryId.isEmpty) {
      return Stream.value(const []);
    }

    return _watchListingQuery(
      limit: limit,
      listingType: listingType,
      categoryId: categoryId,
      serviceName: serviceName,
      queries: () => [
        _QueryPlan(
          _collection
              .where('status', isEqualTo: 'active')
              .where('serviceCategoryId', isEqualTo: categoryId)
              .where('listingType', isEqualTo: listingType.id)
              .orderBy('createdAt', descending: true)
              .limit(limit),
          clientSort: false,
          filterListingTypeClientSide: false,
        ),
        _QueryPlan(
          _collection
              .where('status', isEqualTo: 'active')
              .where('serviceCategoryId', isEqualTo: categoryId)
              .where('listingType', isEqualTo: listingType.id)
              .limit(limit),
          clientSort: true,
          filterListingTypeClientSide: false,
        ),
        _QueryPlan(
          _collection
              .where('status', isEqualTo: 'active')
              .where('serviceCategoryId', isEqualTo: categoryId)
              .limit(limit * 2),
          clientSort: true,
          filterListingTypeClientSide: true,
        ),
      ],
    );
  }

  Stream<List<ServiceListing>> _watchListingQuery({
    required int limit,
    required ServiceListingType listingType,
    String? categoryId,
    String? serviceName,
    required List<_QueryPlan> Function() queries,
  }) {
    return Stream<List<ServiceListing>>.multi((controller) {
      StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? sub;
      var planIndex = 0;
      final plans = queries();

      void attach(_QueryPlan plan) {
        sub?.cancel();
        sub = plan.query.snapshots().listen(
          (snapshot) {
            var listings = snapshot.docs
                .map(ServiceListing.fromFirestore)
                .where((l) => l.status == 'active')
                .toList();
            if (plan.filterListingTypeClientSide) {
              listings =
                  listings.where((l) => l.listingType == listingType).toList();
            }
            if (categoryId != null && categoryId.isNotEmpty) {
              listings = listings
                  .where((l) => l.serviceCategoryId == categoryId)
                  .toList();
            }
            final subService = serviceName?.trim();
            if (subService != null && subService.isNotEmpty) {
              listings =
                  listings.where((l) => l.serviceName == subService).toList();
            }
            if (plan.clientSort) {
              listings = _sortNewestFirst(listings);
            }
            controller.add(listings.take(limit).toList());
          },
          onError: (Object error, StackTrace stack) {
            if (_isMissingIndexError(error) && planIndex + 1 < plans.length) {
              planIndex += 1;
              attach(plans[planIndex]);
              return;
            }
            controller.addError(error, stack);
          },
        );
      }

      attach(plans.first);
      controller.onCancel = () => sub?.cancel();
    });
  }

  Stream<List<ServiceListing>> watchUserListings(String userId) {
    if (!FirebaseService.isReady || userId.isEmpty) {
      return Stream.value(const []);
    }

    return Stream<List<ServiceListing>>.multi((controller) {
      StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? sub;

      void attach(Query<Map<String, dynamic>> query, {required bool clientSort}) {
        sub?.cancel();
        sub = query.snapshots().listen(
          (snapshot) {
            var listings =
                snapshot.docs.map(ServiceListing.fromFirestore).toList();
            if (clientSort) listings = _sortNewestFirst(listings);
            controller.add(listings);
          },
          onError: (Object error, StackTrace stack) {
            if (_isMissingIndexError(error)) {
              attach(
                _collection.where('userId', isEqualTo: userId).limit(100),
                clientSort: true,
              );
              return;
            }
            controller.addError(error, stack);
          },
        );
      }

      attach(
        _collection
            .where('userId', isEqualTo: userId)
            .orderBy('createdAt', descending: true)
            .limit(100),
        clientSort: false,
      );

      controller.onCancel = () => sub?.cancel();
    });
  }

  static List<ServiceListing> _sortNewestFirst(List<ServiceListing> listings) {
    final sorted = List<ServiceListing>.from(listings)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted;
  }

  static bool _isMissingIndexError(Object error) {
    final message = error.toString().toLowerCase();
    return message.contains('index') ||
        message.contains('failed-precondition');
  }
}

class _QueryPlan {
  const _QueryPlan(
    this.query, {
    required this.clientSort,
    required this.filterListingTypeClientSide,
  });

  final Query<Map<String, dynamic>> query;
  final bool clientSort;
  final bool filterListingTypeClientSide;
}

/// Deferred: paid boosts, verified provider badges, in-app booking.
