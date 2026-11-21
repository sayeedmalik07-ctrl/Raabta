import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:raabta/config/app_config.dart';
import 'package:raabta/core/search/search_keyword_tokenizer.dart';
import 'package:raabta/models/housing_models.dart';
import 'package:raabta/services/firebase_service.dart';

class HousingFirestoreService {
  HousingFirestoreService({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _db = firestore ?? FirebaseFirestore.instance,
        _storage = storage,
        _usesDefaultFirestore = firestore == null;

  static const listingsCollection = 'listings';
  static const moderationQueueCollection = 'listing_moderation_queue';

  final FirebaseFirestore _db;
  final FirebaseStorage? _storage;
  final bool _usesDefaultFirestore;

  bool get _firebaseUnavailable =>
      _usesDefaultFirestore && !FirebaseService.isReady;

  CollectionReference<Map<String, dynamic>>? get _listingsRef {
    if (_firebaseUnavailable) return null;
    return _db.collection(listingsCollection);
  }

  CollectionReference<Map<String, dynamic>>? get _moderationRef {
    if (_firebaseUnavailable) return null;
    return _db.collection(moderationQueueCollection);
  }

  /// Sort in-app (same approach as [JobsRepository]) so feeds work before
  /// composite indexes are deployed.
  static int _compareListingsByRecency(HousingListing a, HousingListing b) {
    if (a.featured != b.featured) {
      return b.featured == a.featured ? 0 : (b.featured ? 1 : -1);
    }
    return b.createdAt.compareTo(a.createdAt);
  }

  static List<HousingListing> _sortListings(List<HousingListing> listings) {
    final sorted = List<HousingListing>.from(listings);
    sorted.sort(_compareListingsByRecency);
    return sorted;
  }

  List<HousingListing> _mapListingDocs(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) {
    return _sortListings(
      snapshot.docs
          .map((doc) => HousingListing.fromJson({...doc.data(), 'id': doc.id}))
          .toList(),
    );
  }

  Future<List<HousingListing>> fetchListings(HousingFilters filters) async {
    final ref = _listingsRef;
    if (ref == null) {
      throw HousingFirestoreException('Firestore not initialized');
    }

    Query<Map<String, dynamic>> query =
        ref.where('status', isEqualTo: ListingStatus.approved.name);

    if (filters.area != null && filters.area!.isNotEmpty) {
      query = query.where('areaSlug', isEqualTo: areaSlug(filters.area!));
    }

    final snapshot = await query.get();
    var listings = _mapListingDocs(snapshot);

    if (filters.type != ListingType.all) {
      listings = listings.where((l) => l.type == filters.type).toList();
    }
    if (filters.gender != GenderPreference.any) {
      listings =
          listings.where((l) => l.genderPreference == filters.gender).toList();
    }
    if (filters.nationality != NationalityPreference.any) {
      listings = listings
          .where((l) => l.nationalityPreference == filters.nationality)
          .toList();
    }
    listings = listings
        .where(
          (l) =>
              l.pricePerMonth >= filters.minPrice.round() &&
              l.pricePerMonth <= filters.maxPrice.round(),
        )
        .toList();

    if (filters.searchQuery.trim().isNotEmpty) {
      final q = filters.searchQuery.toLowerCase();
      listings = listings
          .where(
            (l) =>
                l.title.toLowerCase().contains(q) ||
                l.area.toLowerCase().contains(q) ||
                l.description.toLowerCase().contains(q),
          )
          .toList();
    }

    return listings;
  }

  Future<HousingListing?> getListing(String id) async {
    final ref = _listingsRef;
    if (ref == null) {
      throw HousingFirestoreException('Firestore not initialized');
    }

    final doc = await ref.doc(id).get();
    if (!doc.exists) return null;
    return HousingListing.fromJson({...doc.data()!, 'id': doc.id});
  }

  Future<HousingListing> createListing(
    CreateListingRequest request, {
    String? listingId,
  }) async {
    final listingsRef = _listingsRef;
    final moderationRef = _moderationRef;
    if (listingsRef == null || moderationRef == null) {
      throw HousingFirestoreException('Firestore not initialized');
    }

    final uid = _usesDefaultFirestore
        ? (FirebaseAuth.instance.currentUser?.uid ?? '')
        : 'test-user';
    if (uid.isEmpty) {
      throw StateError('Sign in required to post a listing');
    }

    if (listingId != null && listingId.isNotEmpty) {
      final existing = await listingsRef.doc(listingId).get();
      if (existing.exists) {
        final owner = existing.data()?['ownerUserId']?.toString() ?? '';
        if (owner != uid) {
          throw StateError('listing_ownership_mismatch');
        }
        return HousingListing.fromJson({
          ...existing.data()!,
          'id': listingId,
        });
      }
    }

    final coords = areaCoordinates[request.area] ?? areaCoordinates['Doha']!;
    final docRef = listingId != null && listingId.isNotEmpty
        ? listingsRef.doc(listingId)
        : listingsRef.doc();

    final data = {
      ...request.toJson(),
      'areaSlug': areaSlug(request.area),
      'status': ListingStatus.pending.name,
      'verified': false,
      'scamFlagged': false,
      'ownerUserId': uid,
      'postedBy': uid,
      'posterNationality': 'Expat',
      'posterNationalityFlag': '🌍',
      'latitude': coords.$1,
      'longitude': coords.$2,
      'createdAt': FieldValue.serverTimestamp(),
      'shareUrl': '${AppConfig.publicWebsiteUrl}/listings/${docRef.id}',
      'searchKeywords': SearchKeywordTokenizer.buildFromFields([
        request.title,
        request.area,
        request.type.name,
        request.description,
      ]),
    };

    await docRef.set(data);
    await moderationRef.doc(docRef.id).set({
      'listingId': docRef.id,
      'title': request.title,
      'ownerUserId': uid,
      'status': 'pending',
      'submittedAt': FieldValue.serverTimestamp(),
    });

    final saved = await docRef.get();
    final createdAt = (saved.data()?['createdAt'] as Timestamp?)?.toDate() ??
        DateTime.now();

    return HousingListing.fromJson({
      ...saved.data()!,
      'id': docRef.id,
      'createdAt': createdAt.toIso8601String(),
    });
  }

  Future<void> attachPhotos(String listingId, List<String> photoUrls) async {
    final ref = _listingsRef;
    if (ref == null) {
      throw HousingFirestoreException('Firestore not initialized');
    }

    await ref.doc(listingId).update({'photoUrls': photoUrls});
  }

  Future<String> uploadPhoto(
    File file, {
    required String listingId,
    int? photoIndex,
  }) async {
    if (_firebaseUnavailable) {
      throw HousingFirestoreException('Firebase Storage not initialized');
    }

    final storage = _storage ?? FirebaseStorage.instance;
    final fileName = photoIndex != null
        ? '$photoIndex${_photoExtension(file.path)}'
        : '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
    final ref = storage.ref().child('listings/$listingId/$fileName');
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

  Stream<List<HousingListing>> watchApprovedListings({String? areaSlugFilter}) {
    final ref = _listingsRef;
    if (ref == null) {
      return Stream.value([]);
    }

    Query<Map<String, dynamic>> query =
        ref.where('status', isEqualTo: ListingStatus.approved.name);

    if (areaSlugFilter != null) {
      query = query.where('areaSlug', isEqualTo: areaSlugFilter);
    }

    return query.snapshots().map(_mapListingDocs);
  }

  Stream<List<HousingListing>> watchUserListings(String uid) {
    final ref = _listingsRef;
    if (ref == null || uid.isEmpty) {
      return Stream.value(const []);
    }

    return ref
        .where('ownerUserId', isEqualTo: uid)
        .snapshots()
        .map(_mapListingDocs);
  }
}

class HousingFirestoreException implements Exception {
  HousingFirestoreException(this.message);
  final String message;

  @override
  String toString() => message;
}
