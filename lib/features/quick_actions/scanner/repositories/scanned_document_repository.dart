import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/features/quick_actions/scanner/models/document_intelligence.dart';
import 'package:raabta/services/ai/document_extraction_service.dart';

class ScannedDocumentSaveRequest {
  const ScannedDocumentSaveRequest({
    required this.classification,
    required this.imagePath,
    required this.ocrText,
    this.pagePaths = const [],
    this.aiSummary = '',
    this.intelligence,
    this.category,
    this.tags = const [],
    this.pdfPath,
    this.favorite = false,
  });

  final DocClassificationResult classification;
  final String imagePath;
  final List<String> pagePaths;
  final String ocrText;
  final String aiSummary;
  final DocumentIntelligenceResult? intelligence;
  final String? category;
  final List<String> tags;
  final String? pdfPath;
  final bool favorite;
}

class ScannedDocumentRepository {
  ScannedDocumentRepository({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  /// Document Vault category for labour evidence attachments (Phase 29).
  static const evidenceCategory = 'Evidence';
  static const evidenceTag = 'evidence';

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('scanned_documents');

  Future<String> save(ScannedDocumentSaveRequest request) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final docRef = _collection.doc();
    var imageUrl = request.imagePath;
    String? storageUrl;
    final pageUrls = <String>[];
    final pathsToUpload = request.pagePaths.isNotEmpty
        ? request.pagePaths
        : [request.imagePath];

    if (uid != null) {
      for (var i = 0; i < pathsToUpload.length; i++) {
        final path = pathsToUpload[i];
        if (!File(path).existsSync()) {
          pageUrls.add(path);
          continue;
        }
        try {
          final ref = _storage.ref(
            'scanned_documents/$uid/${docRef.id}_p$i.jpg',
          );
          await ref.putFile(File(path));
          pageUrls.add(await ref.getDownloadURL());
        } catch (_) {
          pageUrls.add(path);
        }
      }
      if (pageUrls.isNotEmpty) {
        storageUrl = pageUrls.first;
        imageUrl = pageUrls.first;
      }
    } else if (File(request.imagePath).existsSync()) {
      pageUrls.addAll(pathsToUpload);
    }

    final intelligence = request.intelligence;
    await docRef.set({
      'docType': request.classification.docType.name,
      'expiryDate': request.classification.expiryDate != null
          ? Timestamp.fromDate(request.classification.expiryDate!)
          : null,
      'documentNumber': request.classification.documentNumber ?? '',
      'holderName': request.classification.holderName ?? '',
      'displayName': request.classification.holderName ?? '',
      'imageUrl': imageUrl,
      'localImagePath': request.imagePath,
      'pagePaths': request.pagePaths.isNotEmpty
          ? request.pagePaths
          : [request.imagePath],
      'pageUrls': pageUrls,
      'ocrText': request.ocrText,
      'aiSummary': request.aiSummary,
      'aiIntelligence': intelligence?.toJson(),
      'category': request.category ?? _categoryFor(request.classification.docType),
      'tags': request.tags,
      'pdfPath': request.pdfPath,
      'favorite': request.favorite,
      'userId': uid,
      'cloudSynced': storageUrl != null,
      'scanDate': FieldValue.serverTimestamp(),
      'confirmed': true,
    });

    return docRef.id;
  }

  Future<void> update(String id, Map<String, dynamic> fields) async {
    await _collection.doc(id).update(fields);
  }

  Future<void> rename(String id, String displayName) async {
    await update(id, {
      'displayName': displayName,
      'holderName': displayName,
    });
  }

  Future<void> delete(String id) async {
    await _collection.doc(id).delete();
  }

  String _categoryFor(DocType type) {
    switch (type) {
      case DocType.qid:
        return 'QID';
      case DocType.passport:
        return 'Passport';
      case DocType.visa:
        return 'Visa';
      case DocType.labourCard:
        return 'Contract';
      case DocType.drivingLicense:
        return 'Driving License';
      case DocType.receipt:
        return 'Receipt';
      case DocType.bill:
        return 'Invoice';
      case DocType.labReport:
        return 'Lab Report';
      case DocType.prescription:
        return 'Prescription';
      case DocType.medicalCertificate:
        return 'Medical Certificate';
      case DocType.vaccinationRecord:
        return 'Vaccination';
      case DocType.healthInsurance:
        return 'Health Insurance';
      case DocType.healthInsuranceClaim:
        return 'Health Insurance Claim';
      case DocType.imagingReport:
        return 'Imaging Report';
      case DocType.bookingConfirmation:
        return 'Travel';
      case DocType.unknown:
        return 'Personal';
    }
  }
}

final scannedDocumentRepositoryProvider =
    Provider((ref) => ScannedDocumentRepository());
