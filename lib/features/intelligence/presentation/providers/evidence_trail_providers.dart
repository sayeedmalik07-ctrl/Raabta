import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/models/intelligence/evidence_entry.dart';
import 'package:raabta/providers/auth_providers.dart';
import 'package:raabta/services/intelligence/evidence_attachment_service.dart';
import 'package:raabta/services/intelligence/evidence_repository.dart';
import 'package:raabta/services/intelligence/evidence_service.dart';

final evidenceRepositoryProvider = Provider<EvidenceRepository>(
  (ref) => EvidenceRepository(),
);

final evidenceServiceProvider = Provider<EvidenceService>(
  (ref) => EvidenceService(repository: ref.watch(evidenceRepositoryProvider)),
);

final evidenceAttachmentServiceProvider = Provider<EvidenceAttachmentService>(
  (ref) => EvidenceAttachmentService(),
);

final evidenceEntriesProvider = StreamProvider<List<EvidenceEntry>>((ref) {
  final uid = ref.watch(currentUserProvider)?.uid;
  if (uid == null) return Stream.value(const []);
  return ref.watch(evidenceServiceProvider).watchEntries(uid);
});
