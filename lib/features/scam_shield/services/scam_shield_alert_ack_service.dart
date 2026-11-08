import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/features/scam_shield/data/scam_shield_alert_ack_repository.dart';
import 'package:raabta/features/scam_shield/data/scam_shield_history_repository.dart';
import 'package:raabta/features/scam_shield/domain/scam_shield_active_alert_evaluator.dart';
import 'package:raabta/features/scam_shield/providers/scam_shield_providers.dart';

/// Marks all currently alert-eligible history rows as acknowledged.
Future<void> scamShieldAcknowledgeOpenAlerts(WidgetRef ref) async {
  final historyRepo = ref.read(scamShieldHistoryRepositoryProvider);
  final ackRepo = await ref.read(scamShieldAlertAckRepositoryProvider.future);
  final entries = await historyRepo.loadAll();
  final ids = ScamShieldActiveAlertEvaluator.alertEligibleEntryIds(entries);
  await ackRepo.acknowledgeIds(ids);
  ref.invalidate(scamShieldActiveAlertProvider);
}
