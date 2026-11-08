import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/features/eosb/domain/services/overtime_rounding_pattern_analyzer.dart';
import 'package:raabta/features/eosb/providers/overtime_truth_providers.dart';

final overtimeRoundingPatternProvider =
    Provider<OvertimeRoundingPatternResult>((ref) {
  final record = ref.watch(overtimeTruthProvider).record;
  return OvertimeRoundingPatternAnalyzer.analyze(record: record);
});
