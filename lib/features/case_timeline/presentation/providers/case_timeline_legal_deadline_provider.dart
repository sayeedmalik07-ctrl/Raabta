import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/features/case_timeline/domain/case_timeline_engine_type.dart';
import 'package:raabta/features/eosb/providers/eosb_providers.dart';
import 'package:raabta/features/sponsorship_transfer/providers/sponsorship_transfer_providers.dart';
import 'package:raabta/features/tenancy/providers/tenancy_providers.dart';
import 'package:raabta/features/eosb/domain/services/art_67_input_resolver.dart';
import 'package:raabta/services/legal_deadline_service.dart';

/// Resolves system legal deadline(s) for a case timeline engine scope.
final caseTimelineLegalDeadlinesProvider =
    Provider.family<List<LegalDeadlineResult>, CaseTimelineEngineType>(
  (ref, engine) {
    return switch (engine) {
      CaseTimelineEngineType.eosb => () {
          final input = ref.watch(eosbProvider).input;
          return [
            LegalDeadlineService.eosbFinalSettlementPaymentDeadline(
              art49NoticeGiven: input.art49NoticeGiven,
              contractTerminationDate:
                  Art67InputResolver.contractTerminationDate(input),
              dateOfLeavingWork: Art67InputResolver.dateOfLeavingWork(input),
            ),
            LegalDeadlineService.eosbLabourClaimDeadline(
              contractExpiryDate: input.lastWorkingDate,
            ),
          ].whereType<LegalDeadlineResult>().toList();
        }(),
      CaseTimelineEngineType.tenancy => () {
          final input = ref.watch(tenancyProvider).input;
          return [
            LegalDeadlineService.tenancyDepositReturnDeadline(
              leaseEndDate: input.leaseEndDate,
            ),
            LegalDeadlineService.tenancyAppealDeadline(
              committeeDecisionDate: input.committeeDecisionDate,
            ),
          ].whereType<LegalDeadlineResult>().toList();
        }(),
      CaseTimelineEngineType.sponsorshipTransfer => () {
          final deadline = LegalDeadlineService.sponsorshipPermitGraceDeadline(
            residencePermitExpiry: ref
                .watch(sponsorshipTransferProvider)
                .input
                .residencePermitExpiry,
          );
          return deadline == null ? <LegalDeadlineResult>[] : [deadline];
        }(),
      CaseTimelineEngineType.healthInsurance => const [],
    };
  },
);
