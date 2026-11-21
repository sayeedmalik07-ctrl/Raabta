import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/features/personal_budget/services/personal_budget_pdf_service.dart';
import 'package:raabta/features/personal_budget/services/personal_budget_report_service.dart';
import 'package:share_plus/share_plus.dart';

class PersonalBudgetExportService {
  PersonalBudgetExportService(this._pdf);

  final PersonalBudgetPdfService _pdf;

  static const vaultCategory = 'Budget Report';
  static const vaultTags = ['budget', 'finance', 'personal'];

  Future<File> buildReportPdf(PersonalBudgetReport report) async {
    return _pdf.generateReport(report);
  }

  Future<void> shareReportPdf(PersonalBudgetReport report) async {
    final file = await buildReportPdf(report);
    await Share.shareXFiles(
      [XFile(file.path, mimeType: 'application/pdf', name: 'RAABTA_Budget.pdf')],
      subject: report.title,
      text: report.plainText,
    );
  }

  Future<String?> saveReportToVault(PersonalBudgetReport report) async {
    final file = await buildReportPdf(report);
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final firestore = FirebaseFirestore.instance;
    final docRef = firestore.collection('scanned_documents').doc();
    var pdfUrl = file.path;

    if (uid != null) {
      try {
        final ref = FirebaseStorage.instance.ref(
          'scanned_documents/$uid/${docRef.id}.pdf',
        );
        await ref.putFile(file);
        pdfUrl = await ref.getDownloadURL();
      } catch (_) {}
    }

    await docRef.set({
      'docType': 'unknown',
      'displayName': report.title,
      'holderName': '',
      'category': vaultCategory,
      'tags': vaultTags,
      'pdfPath': file.path,
      'pdfUrl': pdfUrl.startsWith('http') ? pdfUrl : null,
      'imageUrl': '',
      'localImagePath': file.path,
      'pagePaths': [file.path],
      'pageUrls': pdfUrl.startsWith('http') ? [pdfUrl] : [file.path],
      'ocrText': report.plainText,
      'aiSummary': report.title,
      'userId': uid,
      'cloudSynced': pdfUrl.startsWith('http'),
      'scanDate': FieldValue.serverTimestamp(),
      'confirmed': true,
      'favorite': false,
    });

    return docRef.id;
  }
}

final personalBudgetExportServiceProvider =
    Provider<PersonalBudgetExportService>((ref) {
  return PersonalBudgetExportService(PersonalBudgetPdfService());
});
