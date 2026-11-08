import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/services/ai/expat_life_score_service.dart';

final expatScoreHistoryProvider =
    FutureProvider.autoDispose.family<List<ExpatScoreHistoryPoint>, String>(
  (ref, uid) async {
    if (uid.isEmpty) return const [];
    final service = ref.watch(expatLifeScoreServiceProvider);
    return service.fetchRecentHistory(uid);
  },
);
