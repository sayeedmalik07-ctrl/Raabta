import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/features/jobs/esco_match/domain/services/esco_job_match_service.dart';
import 'package:raabta/features/jobs/esco_match/domain/services/esco_skill_gap_service.dart';
import 'package:raabta/features/jobs/esco_match/domain/services/esco_normalizer.dart';

/// Shared ESCO normalizer — index built once per app session.
final escoNormalizerProvider = Provider<EscoNormalizer>((ref) {
  return EscoNormalizer();
});

/// ESCO skill-overlap matcher for Jobs Screen / CV Maker.
final escoJobMatchServiceProvider = Provider<EscoJobMatchService>((ref) {
  return EscoJobMatchService(normalizer: ref.watch(escoNormalizerProvider));
});

final escoSkillGapServiceProvider = Provider<EscoSkillGapService>((ref) {
  return EscoSkillGapService(normalizer: ref.watch(escoNormalizerProvider));
});
