import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/features/jobs/cv_maker/domain/models/cv_document.dart';
import 'package:raabta/features/jobs/cv_maker/services/cv_pdf_service.dart';
import 'package:raabta/features/quick_actions/scanner/services/scanner_pdf_service.dart';
import 'package:share_plus/share_plus.dart';

/// Export CV PDF via ScannerPdfService temp writer + Document Vault (scanned_documents).
class CvExportService {
  CvExportService(this._pdf, this._scannerPdf);

  final CvPdfService _pdf;
  final ScannerPdfService _scannerPdf;

  static const cvCategory = 'CV/Resume';
  static const cvTags = ['cv', 'resume'];

  Future<String> exportToVault(CvDocument cv, {String locale = 'English'}) async {
    final bytes = await _pdf.buildPdf(cv, locale: locale);
    final file = await _scannerPdf.writeTempPdf(bytes, prefix: 'RAABTA_CV');
    return _saveToVault(cv: cv, pdfFile: file);
  }

  Future<File> exportTempFile(CvDocument cv, {String locale = 'English'}) async {
    final bytes = await _pdf.buildPdf(cv, locale: locale);
    return _scannerPdf.writeTempPdf(bytes, prefix: 'RAABTA_CV');
  }

  Future<void> sharePdf(CvDocument cv, {String locale = 'English'}) async {
    final file = await exportTempFile(cv, locale: locale);
    await Share.shareXFiles(
      [XFile(file.path, mimeType: 'application/pdf', name: '${cv.title}.pdf')],
      subject: cv.title,
    );
  }

  Future<String> _saveToVault({
    required CvDocument cv,
    required File pdfFile,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final firestore = FirebaseFirestore.instance;
    final docRef = firestore.collection('scanned_documents').doc();
    var pdfUrl = pdfFile.path;

    if (uid != null) {
      try {
        final ref = FirebaseStorage.instance.ref(
          'scanned_documents/$uid/${docRef.id}.pdf',
        );
        await ref.putFile(pdfFile);
        pdfUrl = await ref.getDownloadURL();
      } catch (_) {}
    }

    await docRef.set({
      'docType': 'unknown',
      'displayName': cv.title,
      'holderName': cv.fullName,
      'category': cvCategory,
      'tags': cvTags,
      'pdfPath': pdfFile.path,
      'pdfUrl': pdfUrl.startsWith('http') ? pdfUrl : null,
      'imageUrl': '',
      'localImagePath': pdfFile.path,
      'pagePaths': [pdfFile.path],
      'pageUrls': pdfUrl.startsWith('http') ? [pdfUrl] : [pdfFile.path],
      'ocrText': _plainTextSummary(cv),
      'aiSummary': 'CV/Resume — ${cv.fullName}',
      'userId': uid,
      'cloudSynced': pdfUrl.startsWith('http'),
      'scanDate': FieldValue.serverTimestamp(),
      'confirmed': true,
      'favorite': false,
      'cvDocumentId': cv.id,
    });

    return docRef.id;
  }

  String _plainTextSummary(CvDocument cv) {
    final buf = StringBuffer()
      ..writeln(cv.fullName)
      ..writeln(cv.professionalSummary)
      ..writeln([
        ...cv.skills.hardSkills,
        ...cv.skills.toolsSoftware,
        ...cv.skills.softSkills,
      ].join(', '));
    for (final exp in cv.experience) {
      buf.writeln('${exp.jobTitle} at ${exp.employer}');
    }
    return buf.toString();
  }
}

final cvPdfServiceProvider = Provider((ref) => CvPdfService());

final cvExportServiceProvider = Provider((ref) {
  return CvExportService(
    ref.read(cvPdfServiceProvider),
    ref.read(scannerPdfServiceProvider),
  );
});
