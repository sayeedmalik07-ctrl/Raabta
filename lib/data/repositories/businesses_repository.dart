import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:raabta/data/categories/business_categories.dart';
import 'package:raabta/data/models/business_listing.dart';
import 'package:raabta/features/business/domain/business_contact_mode.dart';
import 'package:raabta/features/business/domain/business_category_catalog.dart';
import 'package:raabta/services/firebase_service.dart';

class BusinessesRepository {
  BusinessesRepository({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _db = firestore ?? FirebaseFirestore.instance,
        _storage = storage,
        _usesDefaultFirestore = firestore == null;

  final FirebaseFirestore _db;
  final FirebaseStorage? _storage;
  final bool _usesDefaultFirestore;

  bool get _firebaseUnavailable =>
      _usesDefaultFirestore && !FirebaseService.isReady;

  static const businessesCollection = 'businesses';
  static const moderationQueueCollection = 'business_moderation_queue';

  Stream<List<BusinessListing>> watchActiveBusinesses({int limit = 100}) {
    if (_firebaseUnavailable) {
      return Stream.value(const []);
    }
    return _db
        .collection(businessesCollection)
        .where('status', isEqualTo: 'active')
        .limit(limit)
        .snapshots()
        .map(_mapAndSortActiveBusinesses);
  }

  static List<BusinessListing> _mapAndSortActiveBusinesses(
    QuerySnapshot<Map<String, dynamic>> snap,
  ) {
    final businesses = snap.docs
        .map((doc) => BusinessListing.fromFirestoreMap(doc.data(), doc.id))
        .toList();
    businesses.sort((a, b) {
      final aTime = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bTime = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bTime.compareTo(aTime);
    });
    return businesses;
  }

  Future<void> _assertUniqueOwnerListingName(String uid, String name) async {
    final normalized = name.trim().toLowerCase();
    final snap = await _db
        .collection(businessesCollection)
        .where('ownerUserId', isEqualTo: uid)
        .where('status', isEqualTo: 'active')
        .limit(25)
        .get();

    for (final doc in snap.docs) {
      final existing =
          (doc.data()['name'] as String? ?? '').trim().toLowerCase();
      if (existing == normalized) {
        throw StateError('duplicate_business_name');
      }
    }
  }

  Future<Map<String, dynamic>?> fetchBusinessDoc(String businessId) async {
    if (_firebaseUnavailable || businessId.isEmpty) return null;
    final snap =
        await _db.collection(businessesCollection).doc(businessId).get();
    if (!snap.exists) return null;
    return snap.data();
  }

  /// Firestore `whereIn` on document IDs (max 30 per query).
  static const fetchBusinessesByIdsChunkSize = 30;

  Future<Map<String, BusinessListing>> fetchBusinessesByIds(
    List<String> ids,
  ) async {
    if (_firebaseUnavailable) return const {};

    final unique = <String>{};
    for (final raw in ids) {
      final id = raw.trim();
      if (id.isNotEmpty) unique.add(id);
    }
    if (unique.isEmpty) return const {};

    final ordered = unique.toList()..sort();
    final found = <String, BusinessListing>{};

    for (var start = 0; start < ordered.length; start += fetchBusinessesByIdsChunkSize) {
      final end = start + fetchBusinessesByIdsChunkSize;
      final chunk = ordered.sublist(
        start,
        end > ordered.length ? ordered.length : end,
      );
      final snap = await _db
          .collection(businessesCollection)
          .where(FieldPath.documentId, whereIn: chunk)
          .get();
      for (final doc in snap.docs) {
        found[doc.id] = BusinessListing.fromFirestoreMap(doc.data(), doc.id);
      }
    }

    return found;
  }

  Future<String> createBusiness({
    required String name,
    required String category,
    String? categoryId,
    required String location,
    required String phone,
    String? whatsapp,
    String? description,
    required List<String> languages,
    List<String> tags = const [],
    String? website,
    dynamic openingHours,
    Map<String, dynamic>? socialLinks,
    List<dynamic>? servicesOffered,
    Map<String, dynamic>? profileFields,
    BusinessContactMode contactMode = BusinessContactMode.messageOnly,
    String? businessId,
  }) async {
    if (_firebaseUnavailable) {
      throw StateError('Firebase is not initialized');
    }

    final uid = _usesDefaultFirestore
        ? (FirebaseAuth.instance.currentUser?.uid ?? '')
        : 'test-user';
    if (uid.isEmpty) {
      throw StateError('Sign in required to add a business');
    }

    final trimmedName = name.trim();

    if (businessId != null && businessId.isNotEmpty) {
      final existing =
          await _db.collection(businessesCollection).doc(businessId).get();
      if (existing.exists) {
        final owner = existing.data()?['ownerUserId']?.toString() ?? '';
        if (owner != uid) {
          throw StateError('listing_ownership_mismatch');
        }
        return businessId;
      }
    }

    await _assertUniqueOwnerListingName(uid, trimmedName);

    final trimmedDescription = description?.trim() ?? '';
    final resolvedCategoryId = categoryId ??
        BusinessCategoryCatalog.leafIdForStoredCategory(category);
    final payload = <String, dynamic>{
      'name': trimmedName,
      'category': category,
      if (resolvedCategoryId != null) 'categoryId': resolvedCategoryId,
      'emoji': emojiForBusinessCategory(resolvedCategoryId ?? category),
      'location': location.trim(),
      'area': location.trim(),
      'phone': phone.trim(),
      'whatsapp': whatsapp?.trim(),
      'description': trimmedDescription,
      'speciality': trimmedDescription.isNotEmpty
          ? trimmedDescription
          : 'Local business',
      'languages': languages,
      'tags': tags,
      'rating': 0.0,
      'reviewCount': 0,
      'yearsActive': 1,
      'trustScore': 70,
      'openNow': true,
      'photoCount': 0,
      'photoUrls': const <String>[],
      'weeklyViews': 0,
      'isFeatured': false,
      'hasReports': false,
      'status': 'pending_review',
      'verificationStatus': 'pending_review',
      'ownerUserId': uid,
      'contactMode': contactMode.storageValue,
      if (website != null && website.trim().isNotEmpty) 'website': website.trim(),
      if (openingHours != null) 'openingHours': openingHours,
      if (socialLinks != null && socialLinks.isNotEmpty) 'socialLinks': socialLinks,
      if (servicesOffered != null && servicesOffered.isNotEmpty)
        'servicesOffered': servicesOffered,
      if (profileFields != null && profileFields.isNotEmpty)
        'profileFields': profileFields,
      'createdAt': FieldValue.serverTimestamp(),
    };

    final docRef = businessId != null && businessId.isNotEmpty
        ? _db.collection(businessesCollection).doc(businessId)
        : _db.collection(businessesCollection).doc();
    await docRef.set(payload);
    await _db.collection(moderationQueueCollection).doc(docRef.id).set({
      'businessId': docRef.id,
      'name': trimmedName,
      'ownerUserId': uid,
      'status': 'pending',
      'submittedAt': FieldValue.serverTimestamp(),
    });
    return docRef.id;
  }

  Future<String> uploadPhoto(
    File file, {
    required String businessId,
    int? photoIndex,
  }) async {
    if (_firebaseUnavailable) {
      throw StateError('Firebase is not initialized');
    }

    final storage = _storage ?? FirebaseStorage.instance;
    final fileName = photoIndex != null
        ? '$photoIndex${_photoExtension(file.path)}'
        : '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
    final ref = storage.ref().child('businesses/$businessId/$fileName');
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

  Future<void> updateContactMode({
    required String businessId,
    required BusinessContactMode contactMode,
  }) async {
    if (_firebaseUnavailable) {
      throw StateError('Firebase is not initialized');
    }
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || uid.isEmpty) {
      throw StateError('Sign in required');
    }

    await _db.collection(businessesCollection).doc(businessId).update({
      'contactMode': contactMode.storageValue,
    });
  }

  Future<void> attachPhotos(String businessId, List<String> photoUrls) async {
    await attachBusinessMedia(
      businessId: businessId,
      galleryUrls: photoUrls,
    );
  }

  Future<void> attachBusinessMedia({
    required String businessId,
    List<String>? galleryUrls,
    String? logoUrl,
    String? coverUrl,
  }) async {
    if (_firebaseUnavailable) {
      throw StateError('Firebase is not initialized');
    }

    final update = <String, dynamic>{};
    if (galleryUrls != null) {
      update['photoUrls'] = galleryUrls;
      update['photoCount'] = galleryUrls.length;
    }
    if (logoUrl != null && logoUrl.isNotEmpty) {
      update['logoUrl'] = logoUrl;
    }
    if (coverUrl != null && coverUrl.isNotEmpty) {
      update['coverUrl'] = coverUrl;
    }
    if (update.isEmpty) return;
    await _db.collection(businessesCollection).doc(businessId).update(update);
  }

  Stream<List<Map<String, dynamic>>> watchUserBusinesses(String uid) {
    if (_firebaseUnavailable || uid.isEmpty) {
      return Stream.value(const []);
    }
    return _db
        .collection(businessesCollection)
        .where('ownerUserId', isEqualTo: uid)
        .snapshots()
        .map((snap) {
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
}

/// Maps a business category filter value to its tab emoji.
String emojiForBusinessCategory(String category) {
  for (final entry in kBusinessCategories) {
    if (entry.filter == category) return entry.emoji;
  }
  return '🏪';
}
