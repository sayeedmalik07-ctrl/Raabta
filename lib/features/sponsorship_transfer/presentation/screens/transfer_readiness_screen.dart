import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_primary_button.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/features/eosb/presentation/widgets/calculator_form_widgets.dart';
import 'package:raabta/features/sponsorship_transfer/domain/models/sponsorship_transfer_enums.dart';
import 'package:raabta/features/sponsorship_transfer/domain/models/transfer_readiness_input.dart';
import 'package:raabta/features/sponsorship_transfer/presentation/l10n/sponsorship_transfer_strings.dart';
import 'package:raabta/features/sponsorship_transfer/presentation/widgets/sponsorship_transfer_active_transfer_protection_banner.dart';
import 'package:raabta/features/sponsorship_transfer/presentation/widgets/sponsorship_transfer_widgets.dart';
import 'package:raabta/features/sponsorship_transfer/providers/sponsorship_transfer_providers.dart';

class TransferReadinessScreen extends ConsumerStatefulWidget {
  const TransferReadinessScreen({super.key});

  @override
  ConsumerState<TransferReadinessScreen> createState() =>
      _TransferReadinessScreenState();
}

class _TransferReadinessScreenState extends ConsumerState<TransferReadinessScreen> {
  TransferContractType _contractType = TransferContractType.indefinite;
  FormalNoticeStatus? _formalNotice;
  ProbationPeriodStatus? _probationStatus;
  DateTime? _permitExpiry;
  DateTime? _employmentStart;
  bool _prefillApplied = false;

  void _applyPrefill(TransferReadinessInput input) {
    if (_prefillApplied) return;
    _prefillApplied = true;
    _contractType = input.contractType;
    _formalNotice = input.formalNoticeStatus;
    _probationStatus = input.probationPeriodStatus;
    _permitExpiry = input.residencePermitExpiry;
    _employmentStart = input.employmentStartDate;
  }

  Future<void> _pickDate({required bool isPermitExpiry}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isPermitExpiry
          ? (_permitExpiry ?? DateTime.now().add(const Duration(days: 90)))
          : (_employmentStart ?? DateTime.now().subtract(const Duration(days: 365))),
      firstDate: DateTime(2005),
      lastDate: DateTime(2040),
    );
    if (picked == null) return;
    setState(() {
      if (isPermitExpiry) {
        _permitExpiry = picked;
      } else {
        _employmentStart = picked;
      }
    });
  }

  Future<void> _submit() async {
    final input = TransferReadinessInput(
      residencePermitExpiry: _permitExpiry,
      employmentStartDate: _employmentStart,
      contractType: _contractType,
      formalNoticeStatus: _formalNotice,
      probationPeriodStatus: _probationStatus,
    );
    ref.read(sponsorshipTransferProvider.notifier).updateInput(input);

    final checker = ref.read(transferReadinessCheckerProvider);
    await ref
        .read(sponsorshipTransferProvider.notifier)
        .runReadinessCheck(checker: checker);

    if (mounted) {
      context.push('/sponsorship-transfer/result');
    }
  }

  Widget _choiceChip<T>({
    required T value,
    required T? groupValue,
    required String label,
    required ValueChanged<T> onSelected,
  }) {
    final selected = groupValue == value;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => setState(() => onSelected(value)),
      selectedColor: AppColors.chipSponsorshipTransfer.withValues(alpha: 0.35),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localeAsync = ref.watch(sponsorshipTransferLocaleProvider);
    final isChecking = ref.watch(sponsorshipTransferProvider).isChecking;

    return localeAsync.when(
      loading: () => const GlassScreenScaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => const SizedBox.shrink(),
      data: (locale) {
        _applyPrefill(ref.watch(sponsorshipTransferProvider).input);

        return GlassScreenScaffold(
          title: SponsorshipTransferStrings.t('st_form_title', locale),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          padding: const EdgeInsets.all(AppSpacing.lg),
          body: ListView(
            children: [
              SponsorshipTransferDisclaimerBanner(locale: locale),
              const SizedBox(height: AppSpacing.md),
              SponsorshipTransferActiveTransferProtectionBanner(locale: locale),
              const SizedBox(height: AppSpacing.lg),
              CalculatorFormSection(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CalculatorDateRow(
                      startLabel:
                          SponsorshipTransferStrings.t('st_form_permit_expiry', locale),
                      endLabel:
                          SponsorshipTransferStrings.t('st_form_employment_start', locale),
                      startDate: _permitExpiry,
                      endDate: _employmentStart,
                      onStartTap: () => _pickDate(isPermitExpiry: true),
                      onEndTap: () => _pickDate(isPermitExpiry: false),
                      locale: locale,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      SponsorshipTransferStrings.t('st_form_contract_type', locale),
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textTertiary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    CalculatorSegmentRow<TransferContractType>(
                      selected: _contractType,
                      onSelected: (v) => setState(() => _contractType = v),
                      options: [
                        CalculatorSegmentOption(
                          value: TransferContractType.indefinite,
                          label: SponsorshipTransferStrings.t(
                            'st_form_indefinite',
                            locale,
                          ),
                        ),
                        CalculatorSegmentOption(
                          value: TransferContractType.fixedTerm,
                          label: SponsorshipTransferStrings.t(
                            'st_form_fixed_term',
                            locale,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      SponsorshipTransferStrings.t('st_form_formal_notice', locale),
                      style: AppTypography.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _choiceChip<FormalNoticeStatus>(
                          value: FormalNoticeStatus.yes,
                          groupValue: _formalNotice,
                          label: SponsorshipTransferStrings.t(
                            'st_form_notice_yes',
                            locale,
                          ),
                          onSelected: (v) => _formalNotice = v,
                        ),
                        _choiceChip<FormalNoticeStatus>(
                          value: FormalNoticeStatus.no,
                          groupValue: _formalNotice,
                          label: SponsorshipTransferStrings.t(
                            'st_form_notice_no',
                            locale,
                          ),
                          onSelected: (v) => _formalNotice = v,
                        ),
                        _choiceChip<FormalNoticeStatus>(
                          value: FormalNoticeStatus.notSure,
                          groupValue: _formalNotice,
                          label: SponsorshipTransferStrings.t(
                            'st_form_notice_unsure',
                            locale,
                          ),
                          onSelected: (v) => _formalNotice = v,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      SponsorshipTransferStrings.t('st_form_probation', locale),
                      style: AppTypography.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _choiceChip<ProbationPeriodStatus>(
                          value: ProbationPeriodStatus.yes,
                          groupValue: _probationStatus,
                          label: SponsorshipTransferStrings.t(
                            'st_form_probation_yes',
                            locale,
                          ),
                          onSelected: (v) => _probationStatus = v,
                        ),
                        _choiceChip<ProbationPeriodStatus>(
                          value: ProbationPeriodStatus.no,
                          groupValue: _probationStatus,
                          label: SponsorshipTransferStrings.t(
                            'st_form_probation_no',
                            locale,
                          ),
                          onSelected: (v) => _probationStatus = v,
                        ),
                        _choiceChip<ProbationPeriodStatus>(
                          value: ProbationPeriodStatus.notSure,
                          groupValue: _probationStatus,
                          label: SponsorshipTransferStrings.t(
                            'st_form_probation_unsure',
                            locale,
                          ),
                          onSelected: (v) => _probationStatus = v,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              GlassPrimaryButton(
                label: isChecking
                    ? '…'
                    : SponsorshipTransferStrings.t('st_form_submit', locale),
                expand: true,
                accentColor: AppColors.chipSponsorshipTransfer,
                onPressed: isChecking ? null : _submit,
              ),
            ],
          ),
        );
      },
    );
  }
}
