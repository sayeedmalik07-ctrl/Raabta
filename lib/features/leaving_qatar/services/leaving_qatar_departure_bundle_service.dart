import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:raabta/features/leaving_qatar/data/models/leaving_qatar_models.dart';

/// Finds vault documents relevant to leaving Qatar — query only, no new storage.
class LeavingQatarDepartureBundleService {
  LeavingQatarDepartureBundleService({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  static const essentialCategories = {
    LeavingQatarBundleCategory.passport,
    LeavingQatarBundleCategory.visa,
    LeavingQatarBundleCategory.qid,
  };

  Future<List<LeavingQatarBundleDocument>> fetchForUser(String uid) async {
    final snap = await _db
        .collection('scanned_documents')
        .where('userId', isEqualTo: uid)
        .get();

    final matches = <LeavingQatarBundleDocument>[];
    for (final doc in snap.docs) {
      final data = doc.data();
      final hint = _categoryHint(data);
      if (hint == null) continue;
      matches.add(
        LeavingQatarBundleDocument(
          id: doc.id,
          data: data,
          label: _labelFor(data),
          categoryHint: hint,
        ),
      );
    }
    return matches;
  }

  static Set<LeavingQatarBundleCategory> missingEssentials(
    List<LeavingQatarBundleDocument> docs,
  ) {
    final found = docs.map((d) => d.categoryHint).toSet();
    return essentialCategories.difference(found);
  }

  LeavingQatarBundleCategory? _categoryHint(Map<String, dynamic> data) {
    final docType = (data['docType'] as String? ?? '').toLowerCase();
    final category = (data['category'] as String? ?? '').toLowerCase();
    final tags = ((data['tags'] as List?) ?? const [])
        .map((e) => e.toString().toLowerCase())
        .toList();
    final ocr = (data['ocrText'] as String? ?? '').toLowerCase();
    final name = (data['holderName'] as String? ?? '').toLowerCase();

    if (_matches(docType, category, tags, ocr, name, ['passport'])) {
      return LeavingQatarBundleCategory.passport;
    }
    if (_matches(docType, category, tags, ocr, name, ['visa'])) {
      return LeavingQatarBundleCategory.visa;
    }
    if (_matches(docType, category, tags, ocr, name, ['qid'])) {
      return LeavingQatarBundleCategory.qid;
    }
    if (_matches(
      docType,
      category,
      tags,
      ocr,
      name,
      ['labourcard', 'contract', 'labour card'],
    )) {
      return LeavingQatarBundleCategory.contract;
    }
    if (_matches(docType, category, tags, ocr, name, [
      'payslip',
      'pay slip',
      'salary',
    ])) {
      return LeavingQatarBundleCategory.payslip;
    }
    if (_matches(docType, category, tags, ocr, name, [
      'eosb',
      'end-of-service',
      'end of service',
      'gratuity',
      'settlement',
    ])) {
      return LeavingQatarBundleCategory.eosbDoc;
    }
    if (_matches(docType, category, tags, ocr, name, [
      'exit_permit',
      'exit permit',
      'leave notification',
    ])) {
      return LeavingQatarBundleCategory.exitPermit;
    }
    return null;
  }

  bool _matches(
    String docType,
    String category,
    List<String> tags,
    String ocr,
    String name,
    List<String> needles,
  ) {
    final haystack = [
      docType,
      category,
      ...tags,
      ocr,
      name,
    ].join(' ').toLowerCase();
    for (final needle in needles) {
      if (docType.contains(needle.replaceAll(' ', ''))) return true;
      if (category.contains(needle)) return true;
      if (tags.any((t) => t.contains(needle.replaceAll(' ', '')))) return true;
      if (haystack.contains(needle)) return true;
    }
    return false;
  }

  String _labelFor(Map<String, dynamic> data) {
    final holder = data['holderName'] as String? ?? '';
    if (holder.isNotEmpty) return holder;
    final docType = data['docType'] as String? ?? '';
    if (docType.isNotEmpty) return docType;
    return data['category'] as String? ?? 'Document';
  }
}
