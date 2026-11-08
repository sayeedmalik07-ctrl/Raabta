import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:raabta/models/marketplace_models.dart';
import 'package:raabta/services/firebase_service.dart';

class MarketplaceFirestoreService {
  MarketplaceFirestoreService({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _firestore = firestore ??
            (FirebaseService.isReady ? FirebaseFirestore.instance : null),
        _storage = storage ??
            (FirebaseService.isReady ? FirebaseStorage.instance : null),
        _usesDefaultFirestore = firestore == null;

  final FirebaseFirestore? _firestore;
  final FirebaseStorage? _storage;
  final bool _usesDefaultFirestore;

  CollectionReference<Map<String, dynamic>>? get _listingsRef {
    if (_firestore == null) return null;
    return _firestore.collection('marketplace_listings');
  }

  Future<List<MarketplaceListing>> fetchAll() async {
    final ref = _listingsRef;
    if (ref == null) {
      throw MarketplaceFirestoreException('Firestore not initialized');
    }

    try {
      final snapshot = await ref
          .where('status', isEqualTo: 'active')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map(
            (doc) => MarketplaceListing.fromJson({...doc.data(), 'id': doc.id}),
          )
          .toList();
    } on FirebaseException catch (e) {
      if (_isMissingIndexError(e)) {
        final snapshot = await ref
            .where('status', isEqualTo: 'active')
            .limit(200)
            .get();
        final docs = snapshot.docs.toList()
          ..sort((a, b) {
            final aTs = a.data()['createdAt'];
            final bTs = b.data()['createdAt'];
            if (aTs is Timestamp && bTs is Timestamp) {
              return bTs.compareTo(aTs);
            }
            return 0;
          });
        return docs
            .map(
              (doc) =>
                  MarketplaceListing.fromJson({...doc.data(), 'id': doc.id}),
            )
            .toList();
      }
      rethrow;
    }
  }

  Future<List<MarketplaceListing>> fetchByCategory(String categoryId) async {
    final all = await fetchAll();
    return all.where((l) => l.categoryId == categoryId).toList();
  }

  Future<MarketplaceListing?> getListing(String id) async {
    final ref = _listingsRef;
    if (ref == null) {
      throw MarketplaceFirestoreException('Firestore not initialized');
    }

    final doc = await ref.doc(id).get();
    if (!doc.exists || doc.data() == null) return null;
    return MarketplaceListing.fromJson({...doc.data()!, 'id': doc.id});
  }

  Future<String> createListing(
    MarketplaceListingSubmission submission, {
    String? listingId,
  }) async {
    final ref = _listingsRef;
    if (ref == null) {
      throw MarketplaceFirestoreException('Firestore not initialized');
    }

    final uid = _usesDefaultFirestore
        ? (FirebaseAuth.instance.currentUser?.uid ?? '')
        : submission.ownerUserId;
    if (uid.isEmpty) {
      throw StateError('Sign in required to post an ad');
    }
    if (submission.ownerUserId != uid) {
      throw StateError('Listing owner must match signed-in user');
    }

    if (listingId != null && listingId.isNotEmpty) {
      final existing = await ref.doc(listingId).get();
      if (existing.exists) {
        final owner = existing.data()?['ownerUserId']?.toString() ?? '';
        if (owner != uid) {
          throw StateError('listing_ownership_mismatch');
        }
        return listingId;
      }
      await ref.doc(listingId).set(submission.toFirestore());
      return listingId;
    }

    final docRef = ref.doc();
    await docRef.set(submission.toFirestore());
    return docRef.id;
  }

  Future<String> uploadPhoto(
    File file, {
    required String listingId,
    int? photoIndex,
  }) async {
    if (_storage == null) {
      throw MarketplaceFirestoreException('Firebase Storage not initialized');
    }

    final fileName = photoIndex != null
        ? '$photoIndex${_photoExtension(file.path)}'
        : '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
    final storageRef =
        _storage.ref().child('marketplace_listings/$listingId/$fileName');
    await storageRef.putFile(file);
    return storageRef.getDownloadURL();
  }

  static String _photoExtension(String path) {
    final dot = path.lastIndexOf('.');
    if (dot == -1) return '.jpg';
    final ext = path.substring(dot).toLowerCase();
    const allowed = {'.jpg', '.jpeg', '.png', '.webp'};
    return allowed.contains(ext) ? ext : '.jpg';
  }

  Future<void> attachPhotos(String listingId, List<String> photoUrls) async {
    final ref = _listingsRef;
    if (ref == null) {
      throw MarketplaceFirestoreException('Firestore not initialized');
    }

    await ref.doc(listingId).update({
      'photoUrls': photoUrls,
      'photoCount': photoUrls.length,
    });
  }

  Stream<List<Map<String, dynamic>>> watchUserListings(String uid) {
    final ref = _listingsRef;
    if (ref == null || uid.isEmpty) return Stream.value(const []);

    return ref.where('ownerUserId', isEqualTo: uid).snapshots().map((snap) {
      return snap.docs.map((doc) {
        final data = doc.data();
        DateTime? createdAt;
        final raw = data['createdAt'];
        if (raw is Timestamp) createdAt = raw.toDate();
        return {
          'id': doc.id,
          ...data,
          'createdAt': createdAt ?? DateTime.now(),
        };
      }).toList()
        ..sort((a, b) {
          final aT = a['createdAt'] as DateTime;
          final bT = b['createdAt'] as DateTime;
          return bT.compareTo(aT);
        });
    });
  }

  static bool _isMissingIndexError(FirebaseException error) {
    final message = error.message?.toLowerCase() ?? '';
    return error.code == 'failed-precondition' || message.contains('index');
  }
}

class MarketplaceFirestoreException implements Exception {
  MarketplaceFirestoreException(this.message);
  final String message;

  @override
  String toString() => message;
}
