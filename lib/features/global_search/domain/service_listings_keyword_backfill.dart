import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:raabta/features/global_search/domain/service_search_keyword_builder.dart';

/// Optional, idempotent backfill helper for legacy `service_listings` documents.
///
/// **Not invoked by the app.** Run manually from a controlled admin script only.
/// Does not modify Firestore security rules. Processes documents in bounded batches.
abstract final class ServiceListingsKeywordBackfill {
  static const batchSize = 50;

  /// Regenerates [searchKeywords] for one listing document if searchable fields exist.
  static Map<String, dynamic> keywordsUpdateFromData(Map<String, dynamic> data) {
    return {
      'searchKeywords': ServiceSearchKeywordBuilder.build(
        title: data['title'] as String? ?? '',
        serviceName: data['serviceName'] as String? ?? '',
        serviceCategory: data['serviceCategory'] as String? ?? '',
        description: data['description'] as String? ?? '',
        providerName: data['providerName'] as String? ?? '',
        area: data['area'] as String? ?? '',
      ),
    };
  }

  /// Bounded batch processor — returns number of documents updated.
  ///
  /// Pass [startAfter] for pagination. Never fetches the full collection at once.
  static Future<int> backfillBatch({
    required FirebaseFirestore firestore,
    DocumentSnapshot<Map<String, dynamic>>? startAfter,
  }) async {
    Query<Map<String, dynamic>> query = firestore
        .collection('service_listings')
        .orderBy(FieldPath.documentId)
        .limit(batchSize);
    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    final snap = await query.get();
    var updated = 0;
    for (final doc in snap.docs) {
      await doc.reference.update(keywordsUpdateFromData(doc.data()));
      updated++;
    }
    return updated;
  }
}
