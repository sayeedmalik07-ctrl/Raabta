import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/l10n/legal_deadline_strings.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/legal_deadline_card.dart';
import 'package:raabta/features/eosb/domain/models/eosb_employee_input.dart';
import 'package:raabta/features/sponsorship_transfer/domain/models/transfer_readiness_input.dart';
import 'package:raabta/features/tenancy/domain/models/tenancy_lease_input.dart';
import 'package:raabta/features/tenancy/presentation/l10n/tenancy_strings.dart';
import 'package:raabta/services/legal_deadline_reminder_prefs.dart';
import 'package:raabta/features/eosb/domain/services/art_67_input_resolver.dart';
import 'package:raabta/services/legal_deadline_service.dart';

/// Engine-specific [LegalDeadlineCard] builders for Truth Engine screens.
abstract final class LegalDeadlineEngineWidgets {
  static const _eosb67TitleKeys = {
    LegalDeadlineUrgency.informational: 'ld_eosb67_title_info',
    LegalDeadlineUrgency.approaching: 'ld_eosb67_title_approaching',
    LegalDeadlineUrgency.urgent: 'ld_eosb67_title_urgent',
    LegalDeadlineUrgency.expired: 'ld_eosb67_title_expired',
  };

  static const _tenancyDepositTitleKeys = {
    LegalDeadlineUrgency.informational: 'ld_tenancy_deposit_title_info',
    LegalDeadlineUrgency.approaching: 'ld_tenancy_deposit_title_approaching',
    LegalDeadlineUrgency.urgent: 'ld_tenancy_deposit_title_urgent',
    LegalDeadlineUrgency.expired: 'ld_tenancy_deposit_title_expired',
  };

  /// Art. 67 employer payment + Art. 10 worker filing deadlines (distinct cards).
  static Widget eosb({
    required String locale,
    required EosbEmployeeInput input,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _eosbFinalSettlementCard(locale: locale, input: input),
        const SizedBox(height: AppSpacing.md),
        _eosbLabourClaimCard(locale: locale, input: input),
      ],
    );
  }

  static LegalDeadlineCard _eosbFinalSettlementCard({
    required String locale,
    required EosbEmployeeInput input,
  }) {
    final deadline = LegalDeadlineService.eosbFinalSettlementPaymentDeadline(
      art49NoticeGiven: input.art49NoticeGiven,
      contractTerminationDate:
          Art67InputResolver.contractTerminationDate(input),
      dateOfLeavingWork: Art67InputResolver.dateOfLeavingWork(input),
    );
    final infoBody = deadline == null
        ? null
        : switch (deadline.art67Branch) {
            Art67DeadlineBranch.standard => LegalDeadlineStrings.format(
                'ld_eosb67_standard_body',
                locale,
                {'date': _formatDate(deadline.deadlineDate, locale)},
              ),
            Art67DeadlineBranch.exception =>
              LegalDeadlineStrings.t('ld_eosb67_exception_body', locale),
            null => null,
          };
    return LegalDeadlineCard(
      result: deadline,
      locale: locale,
      reminderScope: LegalDeadlineReminderScope.eosbFinalSettlement,
      nextStepsRoute: '/eosb/documents',
      missingDateMessage:
          LegalDeadlineStrings.t('ld_eosb67_missing_date', locale),
      infoBody: infoBody,
      urgentBody: LegalDeadlineStrings.t('ld_eosb67_urgent_body', locale),
      expiredBody: LegalDeadlineStrings.t('ld_eosb67_expired_body', locale),
      ctaLabel: LegalDeadlineStrings.t('ld_cta_eosb67', locale),
      titleKeys: _eosb67TitleKeys,
    );
  }

  static String _formatDate(DateTime date, String locale) {
    return DateFormat.yMMMd().format(date);
  }

  static LegalDeadlineCard _eosbLabourClaimCard({
    required String locale,
    required EosbEmployeeInput input,
  }) {
    final deadline = LegalDeadlineService.eosbLabourClaimDeadline(
      contractExpiryDate: input.lastWorkingDate,
    );
    return LegalDeadlineCard(
      result: deadline,
      locale: locale,
      reminderScope: LegalDeadlineReminderScope.eosb,
      nextStepsRoute: '/eosb/documents',
      missingDateMessage: LegalDeadlineStrings.t('ld_eosb_missing_date', locale),
      urgentBody: LegalDeadlineStrings.t('ld_eosb_urgent_body', locale),
      expiredBody: LegalDeadlineStrings.t('ld_eosb_expired_body', locale),
      ctaLabel: LegalDeadlineStrings.t('ld_cta_eosb', locale),
    );
  }

  /// Deposit return (lease end) + Committee appeal (decision date) — distinct cards.
  static Widget tenancy({
    required String locale,
    required TenancyLeaseInput input,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _tenancyDepositReturnCard(locale: locale, input: input),
        if (input.leaseEndDate != null) ...[
          const SizedBox(height: AppSpacing.sm),
          _TenancyDepositEvidenceCta(locale: locale),
        ],
        const SizedBox(height: AppSpacing.md),
        _tenancyAppealCard(locale: locale, input: input),
      ],
    );
  }

  static LegalDeadlineCard _tenancyDepositReturnCard({
    required String locale,
    required TenancyLeaseInput input,
  }) {
    final deadline = LegalDeadlineService.tenancyDepositReturnDeadline(
      leaseEndDate: input.leaseEndDate,
    );
    return LegalDeadlineCard(
      result: deadline,
      locale: locale,
      reminderScope: LegalDeadlineReminderScope.tenancyDepositReturn,
      nextStepsRoute: '/tenancy/condition',
      missingDateMessage:
          LegalDeadlineStrings.t('ld_tenancy_deposit_missing_date', locale),
      infoBody: LegalDeadlineStrings.t('ld_tenancy_deposit_info_body', locale),
      urgentBody:
          LegalDeadlineStrings.t('ld_tenancy_deposit_urgent_body', locale),
      expiredBody:
          LegalDeadlineStrings.t('ld_tenancy_deposit_expired_body', locale),
      ctaLabel: LegalDeadlineStrings.t('ld_cta_tenancy_deposit', locale),
      titleKeys: _tenancyDepositTitleKeys,
    );
  }

  static LegalDeadlineCard _tenancyAppealCard({
    required String locale,
    required TenancyLeaseInput input,
  }) {
    final deadline = LegalDeadlineService.tenancyAppealDeadline(
      committeeDecisionDate: input.committeeDecisionDate,
    );
    return LegalDeadlineCard(
      result: deadline,
      locale: locale,
      reminderScope: LegalDeadlineReminderScope.tenancy,
      nextStepsRoute: '/tenancy/documents',
      missingDateMessage:
          LegalDeadlineStrings.t('ld_tenancy_missing_date', locale),
      urgentBody: LegalDeadlineStrings.t('ld_tenancy_urgent_body', locale),
      expiredBody: LegalDeadlineStrings.t('ld_tenancy_expired_body', locale),
      ctaLabel: LegalDeadlineStrings.t('ld_cta_tenancy', locale),
    );
  }

  static LegalDeadlineCard sponsorshipTransfer({
    required String locale,
    required TransferReadinessInput input,
  }) {
    final deadline = LegalDeadlineService.sponsorshipPermitGraceDeadline(
      residencePermitExpiry: input.residencePermitExpiry,
    );
    return LegalDeadlineCard(
      result: deadline,
      locale: locale,
      reminderScope: LegalDeadlineReminderScope.sponsorshipTransfer,
      nextStepsRoute: '/sponsorship-transfer/documents',
      missingDateMessage:
          LegalDeadlineStrings.t('ld_sponsorship_missing_date', locale),
      urgentBody: LegalDeadlineStrings.t('ld_sponsorship_urgent_body', locale),
      expiredBody:
          LegalDeadlineStrings.t('ld_sponsorship_expired_body', locale),
      ctaLabel: LegalDeadlineStrings.t('ld_cta_sponsorship', locale),
    );
  }
}

class _TenancyDepositEvidenceCta extends StatelessWidget {
  const _TenancyDepositEvidenceCta({required this.locale});

  final String locale;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () => context.push('/tenancy/condition'),
      icon: const Icon(Icons.photo_camera_outlined, size: 18),
      label: Text(
        TenancyStrings.t('tenancy_deposit_evidence_cta', locale),
        style: AppTypography.bodySmall.copyWith(color: AppColors.chipLease),
      ),
    );
  }
}
