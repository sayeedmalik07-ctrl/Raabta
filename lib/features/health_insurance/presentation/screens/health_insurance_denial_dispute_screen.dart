import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_primary_button.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/core/widgets/truth_confidence_banner.dart';
import 'package:raabta/features/truth_engine/domain/truth_package.dart';
import 'package:raabta/features/health_insurance/data/claim_dispute_checklist_catalog.dart';
import 'package:raabta/features/health_insurance/data/claim_dispute_step_catalog.dart';
import 'package:raabta/features/health_insurance/data/models/claim_dispute_models.dart';
import 'package:raabta/features/health_insurance/data/models/insurer_lookup_models.dart';
import 'package:raabta/features/health_insurance/domain/services/claim_dispute_pdf_service.dart';
import 'package:raabta/features/health_insurance/presentation/l10n/health_insurance_strings.dart';
import 'package:raabta/features/health_insurance/presentation/providers/claim_dispute_providers.dart';
import 'package:raabta/features/health_insurance/presentation/providers/health_insurance_providers.dart';
import 'package:raabta/features/health_insurance/presentation/widgets/health_insurance_share_card.dart';
import 'package:raabta/features/health_insurance/presentation/widgets/health_insurance_widgets.dart';
import 'package:raabta/features/health_insurance/presentation/widgets/insurer_lookup_field.dart';

/// Part C — claim denial dispute assistant (intake, tracker, checklist, AI, export).
class HealthInsuranceDenialDisputeScreen extends ConsumerStatefulWidget {
  const HealthInsuranceDenialDisputeScreen({super.key});

  @override
  ConsumerState<HealthInsuranceDenialDisputeScreen> createState() =>
      _HealthInsuranceDenialDisputeScreenState();
}

class _HealthInsuranceDenialDisputeScreenState
    extends ConsumerState<HealthInsuranceDenialDisputeScreen> {
  final _policyClauseController = TextEditingController();
  final _draftLetterController = TextEditingController();
  final _otherReasonController = TextEditingController();
  final _policyNumberController = TextEditingController();
  final _claimAmountController = TextEditingController();

  String _insurerCardLabel = '';
  String _resolvedInsurer = '';
  bool _manualReview = false;
  ClaimDenialReasonCategory _denialReason =
      ClaimDenialReasonCategory.medicalNecessity;
  DateTime? _denialDate;
  bool? _hasWrittenLetter;
  bool _employerProvided = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeAttachPendingScan());
  }

  @override
  void dispose() {
    _policyClauseController.dispose();
    _draftLetterController.dispose();
    _otherReasonController.dispose();
    _policyNumberController.dispose();
    _claimAmountController.dispose();
    super.dispose();
  }

  Future<void> _maybeAttachPendingScan() async {
    final pending = ref.read(claimDisputeProvider).pendingChecklistItemId;
    if (pending == null) return;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final snap = await FirebaseFirestore.instance
        .collection('scanned_documents')
        .where('userId', isEqualTo: uid)
        .where('category', isEqualTo: 'Health Insurance Claim')
        .limit(5)
        .get();
    if (snap.docs.isEmpty || !mounted) return;
    final sorted = snap.docs.toList()
      ..sort((a, b) {
        final aDate = a.data()['scanDate'];
        final bDate = b.data()['scanDate'];
        if (aDate is Timestamp && bDate is Timestamp) {
          return bDate.compareTo(aDate);
        }
        return 0;
      });
    await ref
        .read(claimDisputeProvider.notifier)
        .attachDocument(pending, sorted.first.id);
  }

  Future<void> _submitIntake(String locale) async {
    if (_insurerCardLabel.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            HealthInsuranceStrings.t('hi_denial_intake_insurer_required', locale),
          ),
        ),
      );
      return;
    }
    if (_hasWrittenLetter == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            HealthInsuranceStrings.t('hi_denial_intake_letter_required', locale),
          ),
        ),
      );
      return;
    }

    final lookup = await ref.read(insurerLookupServiceProvider.future);
    final regulatoryBody = resolveClaimDisputeRegulatoryBody(
      lookup: lookup,
      insurerName: _resolvedInsurer,
      cardLabel: _insurerCardLabel,
      manualReview: _manualReview,
    );

    await ref.read(claimDisputeProvider.notifier).submitIntake(
          insurerName: _resolvedInsurer.isNotEmpty
              ? _resolvedInsurer
              : _insurerCardLabel,
          insurerCardLabel: _insurerCardLabel,
          matchType: _manualReview
              ? InsurerLookupMatchType.manualReview
              : lookup.resolve(_insurerCardLabel).matchType,
          regulatoryBody: regulatoryBody,
          denialReason: _denialReason,
          denialReasonOtherText: _denialReason ==
                  ClaimDenialReasonCategory.other
              ? _otherReasonController.text.trim()
              : null,
          denialDate: _denialDate,
          hasWrittenDenialLetter: _hasWrittenLetter!,
          employerProvidedCoverage: _employerProvided,
          policyNumber: _policyNumberController.text.trim().isEmpty
              ? null
              : _policyNumberController.text.trim(),
          claimAmount: _claimAmountController.text.trim().isEmpty
              ? null
              : _claimAmountController.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final localeAsync = ref.watch(healthInsuranceLocaleProvider);
    final disputeState = ref.watch(claimDisputeProvider);
    final complianceResult = ref.watch(healthInsuranceProvider).result;

    return localeAsync.when(
      loading: () => const GlassScreenScaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => const SizedBox.shrink(),
      data: (locale) {
        final dispute = disputeState.dispute;
        _syncDraftController(dispute?.draftLetter);

        return GlassScreenScaffold(
          title: HealthInsuranceStrings.t('hi_denial_title', locale),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          padding: const EdgeInsets.all(AppSpacing.lg),
          body: disputeState.isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  children: [
                    HealthInsuranceDisclaimerBanner(locale: locale),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      HealthInsuranceStrings.t('hi_denial_ai_disclaimer', locale),
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      HealthInsuranceStrings.t('hi_denial_privacy_note', locale),
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (dispute != null) ...[
                      ...() {
                        final steps = ClaimDisputeStepCatalog.stepsFor(
                          regulatoryBody: dispute.regulatoryBody,
                          employerProvidedCoverage:
                              dispute.employerProvidedCoverage,
                          denialReason: dispute.denialReason,
                        );
                        ClaimDisputeStepDef? nextStep;
                        for (final step in steps) {
                          if (!dispute.isStepComplete(step.id)) {
                            nextStep = step;
                            break;
                          }
                        }
                        return [
                          if (nextStep != null) ...[
                            TruthConfidenceBanner(
                              locale: locale,
                              state: TruthConfidenceState.action,
                              text: HealthInsuranceStrings.t(
                                nextStep.titleKey,
                                locale,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                          ],
                          TruthConfidenceBanner(
                            locale: locale,
                            state: TruthConfidenceState.unknown,
                            text: TruthPackageCatalog
                                .healthInsuranceDisputeUnknownDisplay(
                              0,
                              locale,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                        ];
                      }(),
                    ],
                    if (disputeState.error != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        disputeState.error!,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.errorBright,
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.md),
                    if (dispute == null)
                      _IntakeSection(
                        locale: locale,
                        insurerCardLabel: _insurerCardLabel,
                        denialReason: _denialReason,
                        denialDate: _denialDate,
                        hasWrittenLetter: _hasWrittenLetter,
                        employerProvided: _employerProvided,
                        otherReasonController: _otherReasonController,
                        policyNumberController: _policyNumberController,
                        claimAmountController: _claimAmountController,
                        isSaving: disputeState.isSaving,
                        onInsurerChanged: ({
                          required cardLabel,
                          required resolvedInsurerName,
                          required manualReview,
                          lookup,
                        }) {
                          setState(() {
                            _insurerCardLabel = cardLabel;
                            _resolvedInsurer = resolvedInsurerName;
                            _manualReview = manualReview;
                          });
                        },
                        onDenialReasonChanged: (v) =>
                            setState(() => _denialReason = v),
                        onDenialDateChanged: (v) =>
                            setState(() => _denialDate = v),
                        onWrittenLetterChanged: (v) =>
                            setState(() => _hasWrittenLetter = v),
                        onEmployerProvidedChanged: (v) =>
                            setState(() => _employerProvided = v),
                        onSubmit: () => _submitIntake(locale),
                      )
                    else
                      _TrackerSection(
                        locale: locale,
                        dispute: dispute,
                        disputeState: disputeState,
                        complianceHasViolation:
                            complianceResult?.hasUnresolvedViolation ?? false,
                        policyClauseController: _policyClauseController,
                        draftLetterController: _draftLetterController,
                        onToggleStep: (stepId, done) => ref
                            .read(claimDisputeProvider.notifier)
                            .toggleStep(stepId, done),
                        onScan: (itemId) async {
                          ref
                              .read(claimDisputeProvider.notifier)
                              .setPendingChecklistItem(itemId);
                          await context.push(
                            '/scanner/capture?source=health_insurance_claim',
                          );
                          if (mounted) await _maybeAttachPendingScan();
                        },
                        onExplainStep: (stepId) => ref
                            .read(claimDisputeProvider.notifier)
                            .explainStep(stepId, locale),
                        onExplainClause: () => ref
                            .read(claimDisputeProvider.notifier)
                            .explainClause(
                              _policyClauseController.text,
                              locale,
                            ),
                        onDraftLetter: (toRegulator) => ref
                            .read(claimDisputeProvider.notifier)
                            .draftLetter(
                              locale: locale,
                              toRegulator: toRegulator,
                              policyClauseText: _policyClauseController.text,
                            ),
                        onDraftEdited: (text) => ref
                            .read(claimDisputeProvider.notifier)
                            .updateDraftLetter(text),
                        onExportPdf: () async {
                          final steps = ClaimDisputeStepCatalog.stepsFor(
                            regulatoryBody: dispute.regulatoryBody,
                            employerProvidedCoverage:
                                dispute.employerProvidedCoverage,
                            denialReason: dispute.denialReason,
                          );
                          final items = ClaimDisputeChecklistCatalog.itemsFor(
                            denialReason: dispute.denialReason,
                            employerProvidedCoverage:
                                dispute.employerProvidedCoverage,
                          );
                          final file = await ref
                              .read(claimDisputePdfServiceProvider)
                              .generateSummary(
                                dispute: dispute,
                                locale: locale,
                                checklistItems: items,
                                steps: steps,
                              );
                          await ref
                              .read(claimDisputePdfServiceProvider)
                              .sharePdf(file, locale);
                        },
                        onShareCard: () => showHealthInsuranceDenialShareCard(
                          context,
                          dispute: dispute,
                          locale: locale,
                        ),
                        onReset: () =>
                            ref.read(claimDisputeProvider.notifier).resetDispute(),
                      ),
                  ],
                ),
        );
      },
    );
  }

  void _syncDraftController(String? draft) {
    if (draft != null && _draftLetterController.text != draft) {
      _draftLetterController.text = draft;
    }
  }
}

class _IntakeSection extends ConsumerWidget {
  const _IntakeSection({
    required this.locale,
    required this.insurerCardLabel,
    required this.denialReason,
    required this.denialDate,
    required this.hasWrittenLetter,
    required this.employerProvided,
    required this.otherReasonController,
    required this.policyNumberController,
    required this.claimAmountController,
    required this.isSaving,
    required this.onInsurerChanged,
    required this.onDenialReasonChanged,
    required this.onDenialDateChanged,
    required this.onWrittenLetterChanged,
    required this.onEmployerProvidedChanged,
    required this.onSubmit,
  });

  final String locale;
  final String insurerCardLabel;
  final ClaimDenialReasonCategory denialReason;
  final DateTime? denialDate;
  final bool? hasWrittenLetter;
  final bool employerProvided;
  final TextEditingController otherReasonController;
  final TextEditingController policyNumberController;
  final TextEditingController claimAmountController;
  final bool isSaving;
  final void Function({
    required String cardLabel,
    required String resolvedInsurerName,
    required bool manualReview,
    dynamic lookup,
  }) onInsurerChanged;
  final ValueChanged<ClaimDenialReasonCategory> onDenialReasonChanged;
  final ValueChanged<DateTime?> onDenialDateChanged;
  final ValueChanged<bool> onWrittenLetterChanged;
  final ValueChanged<bool> onEmployerProvidedChanged;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lookupAsync = ref.watch(insurerLookupServiceProvider);

    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      glowColor: AppColors.chipHealthInsurance,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            HealthInsuranceStrings.t('hi_denial_intake_title', locale),
            style: AppTypography.title,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            HealthInsuranceStrings.t('hi_form_insurer_label', locale),
            style: AppTypography.bodySmall,
          ),
          const SizedBox(height: AppSpacing.xs),
          lookupAsync.when(
            loading: () => const LinearProgressIndicator(),
            error: (_, _) => InsurerLookupField(
              locale: locale,
              lookupService: null,
              cardLabel: insurerCardLabel,
              onChanged: ({
                required cardLabel,
                required resolvedInsurerName,
                required manualReview,
                lookup,
              }) =>
                  onInsurerChanged(
                cardLabel: cardLabel,
                resolvedInsurerName: resolvedInsurerName,
                manualReview: manualReview,
                lookup: lookup,
              ),
            ),
            data: (service) => InsurerLookupField(
              locale: locale,
              lookupService: service,
              cardLabel: insurerCardLabel,
              onChanged: ({
                required cardLabel,
                required resolvedInsurerName,
                required manualReview,
                lookup,
              }) =>
                  onInsurerChanged(
                cardLabel: cardLabel,
                resolvedInsurerName: resolvedInsurerName,
                manualReview: manualReview,
                lookup: lookup,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          DropdownButtonFormField<ClaimDenialReasonCategory>(
            value: denialReason,
            decoration: InputDecoration(
              labelText:
                  HealthInsuranceStrings.t('hi_denial_intake_reason', locale),
              border: const OutlineInputBorder(),
            ),
            items: ClaimDenialReasonCategory.values
                .map(
                  (r) => DropdownMenuItem(
                    value: r,
                    child: Text(HealthInsuranceStrings.t(r.labelKey, locale)),
                  ),
                )
                .toList(),
            onChanged: (v) {
              if (v != null) onDenialReasonChanged(v);
            },
          ),
          if (denialReason == ClaimDenialReasonCategory.other) ...[
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: otherReasonController,
              maxLength: 200,
              decoration: InputDecoration(
                labelText: HealthInsuranceStrings.t(
                  'hi_denial_intake_other_label',
                  locale,
                ),
                helperText: HealthInsuranceStrings.t(
                  'hi_denial_intake_other_hint',
                  locale,
                ),
                border: const OutlineInputBorder(),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              HealthInsuranceStrings.t('hi_denial_intake_date', locale),
            ),
            subtitle: Text(
              denialDate?.toIso8601String().split('T').first ??
                  HealthInsuranceStrings.t('hi_denial_intake_date_unknown', locale),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.calendar_today_outlined),
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: denialDate ?? DateTime.now(),
                  firstDate: DateTime(2010),
                  lastDate: DateTime.now(),
                );
                onDenialDateChanged(picked);
              },
            ),
          ),
          Text(
            HealthInsuranceStrings.t('hi_denial_intake_written_letter', locale),
            style: AppTypography.bodySmall,
          ),
          Row(
            children: [
              Expanded(
                child: RadioListTile<bool>(
                  title: Text(HealthInsuranceStrings.t('hi_yes', locale)),
                  value: true,
                  groupValue: hasWrittenLetter,
                  onChanged: (v) {
                    if (v != null) onWrittenLetterChanged(v);
                  },
                ),
              ),
              Expanded(
                child: RadioListTile<bool>(
                  title: Text(HealthInsuranceStrings.t('hi_no', locale)),
                  value: false,
                  groupValue: hasWrittenLetter,
                  onChanged: (v) {
                    if (v != null) onWrittenLetterChanged(v);
                  },
                ),
              ),
            ],
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              HealthInsuranceStrings.t('hi_denial_intake_employer', locale),
            ),
            value: employerProvided,
            onChanged: onEmployerProvidedChanged,
          ),
          TextField(
            controller: policyNumberController,
            decoration: InputDecoration(
              labelText:
                  HealthInsuranceStrings.t('hi_denial_intake_policy', locale),
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: claimAmountController,
            decoration: InputDecoration(
              labelText:
                  HealthInsuranceStrings.t('hi_denial_intake_amount', locale),
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          GlassPrimaryButton(
            label: HealthInsuranceStrings.t('hi_denial_intake_submit', locale),
            icon: Icons.play_arrow_rounded,
            expand: true,
            onPressed: isSaving ? null : onSubmit,
          ),
        ],
      ),
    );
  }
}

class _TrackerSection extends StatelessWidget {
  const _TrackerSection({
    required this.locale,
    required this.dispute,
    required this.disputeState,
    required this.complianceHasViolation,
    required this.policyClauseController,
    required this.draftLetterController,
    required this.onToggleStep,
    required this.onScan,
    required this.onExplainStep,
    required this.onExplainClause,
    required this.onDraftLetter,
    required this.onDraftEdited,
    required this.onExportPdf,
    required this.onShareCard,
    required this.onReset,
  });

  final String locale;
  final HealthInsuranceClaimDispute dispute;
  final ClaimDisputeState disputeState;
  final bool complianceHasViolation;
  final TextEditingController policyClauseController;
  final TextEditingController draftLetterController;
  final Future<void> Function(String stepId, bool done) onToggleStep;
  final Future<void> Function(String itemId) onScan;
  final Future<void> Function(String stepId) onExplainStep;
  final Future<void> Function() onExplainClause;
  final Future<void> Function(bool toRegulator) onDraftLetter;
  final Future<void> Function(String text) onDraftEdited;
  final Future<void> Function() onExportPdf;
  final VoidCallback onShareCard;
  final Future<void> Function() onReset;

  @override
  Widget build(BuildContext context) {
    final steps = ClaimDisputeStepCatalog.stepsFor(
      regulatoryBody: dispute.regulatoryBody,
      employerProvidedCoverage: dispute.employerProvidedCoverage,
      denialReason: dispute.denialReason,
    );
    final checklist = ClaimDisputeChecklistCatalog.itemsFor(
      denialReason: dispute.denialReason,
      employerProvidedCoverage: dispute.employerProvidedCoverage,
    );
    final canDraftLetter = dispute.hasWrittenDenialLetter ||
        dispute.isStepComplete(ClaimDisputeStepCatalog.step1WrittenLetter);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          HealthInsuranceStrings.t('hi_denial_steps_title', locale),
          style: AppTypography.title,
        ),
        const SizedBox(height: AppSpacing.sm),
        for (final step in steps)
          _StepCard(
            locale: locale,
            step: step,
            dispute: dispute,
            steps: steps,
            complianceHasViolation: complianceHasViolation,
            onToggle: (done) => onToggleStep(step.id, done),
            onExplain: () => onExplainStep(step.id),
            explainText: disputeState.explainStepText,
            isAiBusy: disputeState.isAiBusy,
          ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          HealthInsuranceStrings.t('hi_denial_checklist_title', locale),
          style: AppTypography.title,
        ),
        const SizedBox(height: AppSpacing.sm),
        for (final item in checklist)
          GlassCard(
            margin: const EdgeInsets.only(bottom: AppSpacing.sm),
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Icon(
                  dispute.documentRefs.containsKey(item.id)
                      ? Icons.check_circle
                      : Icons.description_outlined,
                  color: dispute.documentRefs.containsKey(item.id)
                      ? AppColors.chipEosb
                      : AppColors.textSecondary,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        HealthInsuranceStrings.t(item.titleKey, locale),
                        style: AppTypography.body,
                      ),
                      Text(
                        HealthInsuranceStrings.t(item.subtitleKey, locale),
                        style: AppTypography.caption,
                      ),
                    ],
                  ),
                ),
                TextButton.icon(
                  onPressed: () => onScan(item.id),
                  icon: const Icon(Icons.document_scanner_outlined, size: 18),
                  label: Text(
                    HealthInsuranceStrings.t('hi_denial_scan_upload', locale),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          HealthInsuranceStrings.t('hi_denial_ai_title', locale),
          style: AppTypography.title,
        ),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: policyClauseController,
          maxLines: 4,
          decoration: InputDecoration(
            labelText:
                HealthInsuranceStrings.t('hi_denial_clause_label', locale),
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            OutlinedButton(
              onPressed: disputeState.isAiBusy ? null : onExplainClause,
              child: Text(
                HealthInsuranceStrings.t('hi_denial_explain_clause', locale),
              ),
            ),
            if (canDraftLetter) ...[
              OutlinedButton(
                onPressed: disputeState.isAiBusy
                    ? null
                    : () => onDraftLetter(false),
                child: Text(
                  HealthInsuranceStrings.t('hi_denial_draft_insurer', locale),
                ),
              ),
              OutlinedButton(
                onPressed: disputeState.isAiBusy
                    ? null
                    : () => onDraftLetter(true),
                child: Text(
                  HealthInsuranceStrings.t('hi_denial_draft_regulator', locale),
                ),
              ),
            ],
          ],
        ),
        if (disputeState.explainClauseText != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(disputeState.explainClauseText!, style: AppTypography.bodySmall),
        ],
        if (draftLetterController.text.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: draftLetterController,
            maxLines: 12,
            onChanged: (v) => onDraftEdited(v),
            decoration: InputDecoration(
              labelText:
                  HealthInsuranceStrings.t('hi_denial_draft_label', locale),
              border: const OutlineInputBorder(),
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
        GlassPrimaryButton(
          label: HealthInsuranceStrings.t('hi_share_card', locale),
          icon: Icons.ios_share_rounded,
          expand: true,
          accentColor: AppColors.chipHealthInsurance,
          onPressed: onShareCard,
        ),
        const SizedBox(height: AppSpacing.sm),
        GlassPrimaryButton(
          label: HealthInsuranceStrings.t('hi_denial_export_pdf', locale),
          icon: Icons.picture_as_pdf_outlined,
          expand: true,
          onPressed: onExportPdf,
        ),
        const SizedBox(height: AppSpacing.sm),
        TextButton(
          onPressed: onReset,
          child: Text(
            HealthInsuranceStrings.t('hi_denial_start_over', locale),
            style: AppTypography.link,
          ),
        ),
      ],
    );
  }
}

class _StepCard extends StatelessWidget {
  const _StepCard({
    required this.locale,
    required this.step,
    required this.dispute,
    required this.steps,
    required this.complianceHasViolation,
    required this.onToggle,
    required this.onExplain,
    required this.explainText,
    required this.isAiBusy,
  });

  final String locale;
  final ClaimDisputeStepDef step;
  final HealthInsuranceClaimDispute dispute;
  final List<ClaimDisputeStepDef> steps;
  final bool complianceHasViolation;
  final ValueChanged<bool> onToggle;
  final VoidCallback onExplain;
  final String? explainText;
  final bool isAiBusy;

  @override
  Widget build(BuildContext context) {
    final locked = ClaimDisputeStepCatalog.isLocked(
      step: step,
      dispute: dispute,
      orderedSteps: steps,
    );
    final done = dispute.isStepComplete(step.id);
    final showMedicalTip = step.id == ClaimDisputeStepCatalog.step2InsurerComplaints &&
        dispute.denialReason == ClaimDenialReasonCategory.medicalNecessity &&
        step.tipKey != null;

    return Opacity(
      opacity: locked ? 0.45 : 1,
      child: GlassCard(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.all(AppSpacing.md),
        glowColor: done ? AppColors.chipEosb : AppColors.chipHealthInsurance,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  done ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: done ? AppColors.chipEosb : AppColors.textSecondary,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        HealthInsuranceStrings.t(step.titleKey, locale),
                        style: AppTypography.body.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        HealthInsuranceStrings.t(step.descriptionKey, locale),
                        style: AppTypography.bodySmall,
                      ),
                      if (step.citationKey != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          HealthInsuranceStrings.t(step.citationKey!, locale),
                          style: AppTypography.caption.copyWith(
                            color: AppColors.cyanGlow,
                          ),
                        ),
                      ],
                      if (showMedicalTip) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.sm),
                          decoration: BoxDecoration(
                            color: AppColors.accentGold.withValues(alpha: 0.12),
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusSm),
                          ),
                          child: Text(
                            HealthInsuranceStrings.t(step.tipKey!, locale),
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.accentGold,
                            ),
                          ),
                        ),
                      ],
                      if (step.id == ClaimDisputeStepCatalog.step4MophEmployer &&
                          complianceHasViolation) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.sm),
                          decoration: BoxDecoration(
                            color: AppColors.errorBright.withValues(alpha: 0.1),
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusSm),
                          ),
                          child: Text(
                            HealthInsuranceStrings.t(
                              'hi_denial_part_a_violation_link',
                              locale,
                            ),
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.errorBright,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            if (!locked) ...[
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Switch(
                    value: done,
                    onChanged: onToggle,
                  ),
                  Text(
                    HealthInsuranceStrings.t('hi_denial_mark_done', locale),
                    style: AppTypography.bodySmall,
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: isAiBusy ? null : onExplain,
                    child: Text(
                      HealthInsuranceStrings.t('hi_denial_explain_step', locale),
                    ),
                  ),
                ],
              ),
              if (explainText != null && explainText!.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                TruthConfidenceBanner(
                  locale: locale,
                  state: TruthConfidenceState.unknown,
                  text: TruthPackageCatalog.healthInsuranceDisputeUnknownDisplay(
                    0,
                    locale,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(explainText!, style: AppTypography.caption),
              ],
            ] else
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.sm),
                child: Text(
                  HealthInsuranceStrings.t('hi_denial_step_locked', locale),
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
