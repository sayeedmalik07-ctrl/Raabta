import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:raabta/models/housing_models.dart';
import 'package:raabta/services/firebase_service.dart';

class HousingFirestoreService {
  HousingFirestoreService({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _firestore = FirebaseService.isReady
            ? (firestore ?? FirebaseFirestore.instance)
            : null,
        _storage = FirebaseService.isReady
            ? (storage ?? FirebaseStorage.instance)
            : null;

  final FirebaseFirestore? _firestore;
  final FirebaseStorage? _storage;

  CollectionReference<Map<String, dynamic>>? get _listingsRef {
    if (!FirebaseService.isReady || _firestore == null) return null;
    return _firestore.collection('listings');
  }

  CollectionReference<Map<String, dynamic>>? get _moderationRef {
    if (!FirebaseService.isReady || _firestore == null) return null;
    return _firestore.collection('listing_moderation_queue');
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

    final snapshot = await query.orderBy('createdAt', descending: true).get();
    var listings = snapshot.docs
        .map((doc) => HousingListing.fromJson({...doc.data(), 'id': doc.id}))
        .toList();

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

  Future<HousingListing> createListing(CreateListingRequest request) async {
    final listingsRef = _listingsRef;
    final moderationRef = _moderationRef;
    if (listingsRef == null || moderationRef == null) {
      throw HousingFirestoreException('Firestore not initialized');
    }

    final coords = areaCoordinates[request.area] ?? areaCoordinates['Doha']!;
    final docRef = listingsRef.doc();

    final data = {
      ...request.toJson(),
      'areaSlug': areaSlug(request.area),
      'status': ListingStatus.pending.name,
      'verified': false,
      'scamFlagged': false,
      'posterNationality': 'Expat',
      'posterNationalityFlag': '🌍',
      'latitude': coords.$1,
      'longitude': coords.$2,
      'createdAt': FieldValue.serverTimestamp(),
      'shareUrl': 'https://raabta.app/listings/${docRef.id}',
    };

    await docRef.set(data);
    await moderationRef.doc(docRef.id).set({
      'listingId': docRef.id,
      'title': request.title,
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

  Future<String> uploadPhoto(File file, {required String listingId}) async {
    if (!FirebaseService.isReady || _storage == null) {
      throw HousingFirestoreException('Firebase Storage not initialized');
    }

    final fileName =
        '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
    final ref = _storage.ref().child('listings/$listingId/$fileName');
    await ref.putFile(file);
    return ref.getDownloadURL();
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

    return query
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => HousingListing.fromJson({...doc.data(), 'id': doc.id}),
              )
              .toList(),
        );
  }
}

class HousingFirestoreException implements Exception {
  HousingFirestoreException(this.message);
  final String message;

  @override
  String toString() => message;
}
