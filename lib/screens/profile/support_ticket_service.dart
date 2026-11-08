import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:raabta/screens/profile/l10n/profile_strings.dart';
import 'package:raabta/services/firebase_service.dart';

class SupportTicketService {
  SupportTicketService({
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

  static const collection = 'support_tickets';

  /// English storage tokens — kept for Firestore backward compatibility.
  static const issueCategories = [
    'App crash / bug',
    'Account & login',
    'EOSB / Overtime',
    'Documents & scanner',
    'Community / listings',
    'Payments / premium',
    'Other',
  ];

  static const _categoryKeys = [
    'report_cat_crash',
    'report_cat_account',
    'report_cat_eosb',
    'report_cat_documents',
    'report_cat_community',
    'report_cat_payments',
    'report_cat_other',
  ];

  static String categoryLabel(String storageValue, String locale) {
    final index = issueCategories.indexOf(storageValue);
    if (index < 0) return storageValue;
    return ProfileStrings.t(_categoryKeys[index], locale);
  }

  Future<String> submit({
    required String userId,
    required String category,
    required String description,
    File? screenshot,
    required String locale,
  }) async {
    if (_firestore == null) {
      throw StateError(ProfileStrings.t('error_firebase_unavailable', locale));
    }

    final docRef = _firestore.collection(collection).doc();
    final packageInfo = await PackageInfo.fromPlatform();

    String? screenshotUrl;
    if (screenshot != null && _storage != null) {
      try {
        final ref = _storage.ref('support_tickets/$userId/${docRef.id}.jpg');
        await ref.putFile(
          screenshot,
          SettableMetadata(contentType: 'image/jpeg'),
        );
        screenshotUrl = await ref.getDownloadURL();
      } catch (e) {
        debugPrint('SupportTicketService: screenshot upload failed — $e');
      }
    }

    await docRef.set({
      'userId': userId,
      'category': category,
      'description': description.trim(),
      'screenshotUrl': screenshotUrl,
      'hasScreenshot': screenshotUrl != null,
      'status': 'open',
      'appVersion': packageInfo.version,
      'buildNumber': packageInfo.buildNumber,
      'platform': Platform.operatingSystem,
      'createdAt': FieldValue.serverTimestamp(),
    });

    return docRef.id;
  }
}
