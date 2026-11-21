import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:raabta/features/legal_sources/data/legal_sources_seed_catalog.dart';
import 'package:raabta/features/legal_sources/domain/models/legal_source.dart';
import 'package:raabta/services/firebase_service.dart';

/// Reads/writes the `legal_sources` Firestore collection (admin-maintained).
class LegalSourcesRepository {
  LegalSourcesRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ??
            (FirebaseService.isReady ? FirebaseFirestore.instance : null);

  final FirebaseFirestore? _firestore;

  CollectionReference<Map<String, dynamic>>? get _collection =>
      _firestore?.collection(LegalSourcesSeedCatalog.collectionName);

  /// Seed catalogue merged with Firestore overrides (by document id).
  Future<List<LegalSource>> fetchAll({bool preferRemote = true}) async {
    final merged = {
      for (final s in LegalSourcesSeedCatalog.defaults) s.id: s,
    };

    if (preferRemote && _collection != null) {
      try {
        final snap = await _collection!.get();
        for (final doc in snap.docs) {
          merged[doc.id] = LegalSource.fromFirestore(doc.id, doc.data());
        }
      } catch (_) {
        // Offline — seed only.
      }
    }

    final list = merged.values.toList()
      ..sort((a, b) => a.lawIdentifier.compareTo(b.lawIdentifier));
    return list;
  }

  /// Latest `dateLastVerified` among **current** sources — user-facing freshness.
  Future<DateTime> latestVerifiedDate() async {
    final sources = await fetchAll();
    return _latestFromList(sources);
  }

  DateTime latestVerifiedFromList(List<LegalSource> sources) =>
      _latestFromList(sources);

  DateTime _latestFromList(List<LegalSource> sources) {
    var latest = LegalSourcesSeedCatalog.seedLatestVerified;
    for (final s in sources) {
      if (s.status == LegalSourceStatus.superseded) continue; // ignore SUPERSEDED
      final v = s.dateLastVerified;
      if (v != null && v.isAfter(latest)) latest = v;
    }
    return latest;
  }

  Future<void> upsert(LegalSource source) async {
    final col = _collection;
    if (col == null) {
      throw StateError('Firestore not available');
    }
    await col.doc(source.id).set(source.toFirestore(), SetOptions(merge: true));
  }

  Future<void> updateStatus(String id, LegalSourceStatus status) async {
    final col = _collection;
    if (col == null) throw StateError('Firestore not available');
    await col.doc(id).set({'status': status.firestoreValue}, SetOptions(merge: true));
  }

  Future<void> markVerifiedNow(String id) async {
    final col = _collection;
    if (col == null) throw StateError('Firestore not available');
    await col.doc(id).set({
      'dateLastVerified': DateTime.now().toIso8601String(),
      'status': LegalSourceStatus.active.firestoreValue,
    }, SetOptions(merge: true));
  }
}
