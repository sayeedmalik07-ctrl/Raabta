import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_primary_button.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/features/scam_shield/data/scam_evidence_repository.dart';
import 'package:raabta/features/scam_shield/domain/scam_evidence_record.dart';
import 'package:raabta/features/scam_shield/presentation/l10n/scam_shield_strings.dart';
import 'package:raabta/features/scam_shield/report_pack/report_pack_channel_actions.dart';
import 'package:raabta/features/scam_shield/report_pack/report_pack_channel_catalog.dart';
import 'package:raabta/features/scam_shield/report_pack/report_pack_content_builder.dart';
import 'package:raabta/features/scam_shield/report_pack/report_pack_models.dart';
import 'package:raabta/features/scam_shield/report_pack/report_pack_pdf_service.dart';
import 'package:raabta/features/scam_shield/report_pack/report_pack_repository.dart';
import 'package:raabta/features/scam_shield/report_pack/report_pack_temp_files.dart';
import 'package:raabta/providers/visa_providers.dart';

class ScamShieldReportReadyScreen extends ConsumerStatefulWidget {
  const ScamShieldReportReadyScreen({super.key});

  @override
  ConsumerState<ScamShieldReportReadyScreen> createState() =>
      _ScamShieldReportReadyScreenState();
}

class _ScamShieldReportReadyScreenState
    extends ConsumerState<ScamShieldReportReadyScreen> {
  ReportPackDraft _draft = const ReportPackDraft();
  List<ScamEvidenceRecord> _evidence = const [];
  List<ReportPackChannel> _channels = const [];
  bool _loading = true;
  bool _generating = false;
  ReportPackSnapshot? _snapshot;
  String? _pdfPath;

  final _summaryController = TextEditingController();
  final _bankCaseController = TextEditingController();
  final _authorityRefController = TextEditingController();
  final _bankLineController = TextEditingController();
  final _contactNameController = TextEditingController();
  final _contactPhoneController = TextEditingController();
  final _contactEmailController = TextEditingController();
  final _partyPhoneController = TextEditingController();
  final _partyLinkController = TextEditingController();
  final _partyAccountController = TextEditingController();
  final _txAmountController = TextEditingController();
  final _txDateController = TextEditingController();
  final _txMethodController = TextEditingController();
  final _txRefController = TextEditingController();

  static const _orderStepKeys = [
    'ss_rp_order_1',
    'ss_rp_order_2',
    'ss_rp_order_3',
    'ss_rp_order_4',
    'ss_rp_order_5',
  ];

  static const _defaultTimelineKeys = [
    'ss_rp_tl_contact',
    'ss_rp_tl_payment',
    'ss_rp_tl_report',
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _summaryController.dispose();
    _bankCaseController.dispose();
    _authorityRefController.dispose();
    _bankLineController.dispose();
    _contactNameController.dispose();
    _contactPhoneController.dispose();
    _contactEmailController.dispose();
    _partyPhoneController.dispose();
    _partyLinkController.dispose();
    _partyAccountController.dispose();
    _txAmountController.dispose();
    _txDateController.dispose();
    _txMethodController.dispose();
    _txRefController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final draft = await ReportPackRepository.loadDraft();
    _evidence = await ScamEvidenceRepository.instance.loadAll();
    var timeline = draft.timeline;
    if (timeline.isEmpty) {
      timeline = [
        for (final k in _defaultTimelineKeys)
          ReportPackTimelineEntry(labelKey: k),
      ];
    }
    final merged = draft.copyWith(timeline: timeline);
    _channels = await ReportPackChannelCatalog.loadVerified(
      includeUserBankChannel: merged.bankFraudLine.trim().isNotEmpty,
    );
    if (mounted) {
      setState(() {
        _draft = merged;
        _loading = false;
      });
      _syncControllers(merged);
    }
  }

  void _syncControllers(ReportPackDraft draft) {
    _summaryController.text = draft.userSummary;
    _bankCaseController.text = draft.bankCaseNumber;
    _authorityRefController.text = draft.authorityReferenceNumbers;
    _bankLineController.text = draft.bankFraudLine;
    _contactNameController.text = draft.contactName;
    _contactPhoneController.text = draft.contactPhone;
    _contactEmailController.text = draft.contactEmail;
    for (final d in draft.otherPartyDetails) {
      switch (d.kind) {
        case 'phone':
          _partyPhoneController.text = d.value;
        case 'link':
          _partyLinkController.text = d.value;
        case 'account':
          _partyAccountController.text = d.value;
      }
    }
    if (draft.transactions.isNotEmpty) {
      final t = draft.transactions.first;
      _txAmountController.text = t.amount;
      _txDateController.text = t.date;
      _txMethodController.text = t.method;
      _txRefController.text = t.reference;
    }
  }

  ReportPackDraft _draftWithPartyAndTx() {
    final details = <ReportPackOtherPartyDetail>[
      if (_partyPhoneController.text.trim().isNotEmpty)
        ReportPackOtherPartyDetail(
          kind: 'phone',
          value: _partyPhoneController.text.trim(),
        ),
      if (_partyLinkController.text.trim().isNotEmpty)
        ReportPackOtherPartyDetail(
          kind: 'link',
          value: _partyLinkController.text.trim(),
        ),
      if (_partyAccountController.text.trim().isNotEmpty)
        ReportPackOtherPartyDetail(
          kind: 'account',
          value: _partyAccountController.text.trim(),
        ),
    ];
    final tx = ReportPackTransactionLine(
      amount: _txAmountController.text.trim(),
      date: _txDateController.text.trim(),
      method: _txMethodController.text.trim(),
      reference: _txRefController.text.trim(),
    );
    return _draft.copyWith(
      otherPartyDetails: details,
      transactions: tx.isEmpty ? const [] : [tx],
    );
  }

  Future<void> _persistAll() async {
    await _persistDraft(_draftWithPartyAndTx());
  }

  Future<void> _persistDraft(ReportPackDraft draft) async {
    await ReportPackRepository.saveDraft(draft);
    final channels = await ReportPackChannelCatalog.loadVerified(
      includeUserBankChannel: draft.bankFraudLine.trim().isNotEmpty,
    );
    if (mounted) {
      setState(() {
        _draft = draft;
        _channels = channels;
      });
    }
  }

  Future<void> _generatePack() async {
    setState(() => _generating = true);
    final draft = _draftWithPartyAndTx();
    await ReportPackRepository.saveDraft(draft);
    _draft = draft;
    final locale = AppLocale.normalize(ref.read(userLanguageProvider));
    final selected = _evidence
        .where((e) => _draft.selectedEvidenceIds.contains(e.id))
        .toList();
    final snapshot = ReportPackContentBuilder.build(
      draft: draft,
      locale: locale,
      selectedEvidence: selected,
    );
    try {
      final pdf = await ReportPackPdfService().generate(
        snapshot: snapshot,
        replacePreviousPath: _pdfPath,
      );
      if (mounted) {
        setState(() {
          _snapshot = snapshot;
          _pdfPath = pdf.path;
          _generating = false;
        });
      }
    } on ReportPackTempException {
      if (mounted) {
        setState(() => _generating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              ScamShieldStrings.t('ss_rp_sign_in_required', locale),
            ),
          ),
        );
      }
    }
  }

  Future<bool> _confirmSensitiveShare() async {
    final locale = AppLocale.normalize(ref.read(userLanguageProvider));
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(ScamShieldStrings.t('ss_rp_share_warning_title', locale)),
        content: Text(ScamShieldStrings.t('ss_rp_share_warning_body', locale)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(ScamShieldStrings.t('ss_inv_cancel', locale)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(ScamShieldStrings.t('ss_rp_share_confirm', locale)),
          ),
        ],
      ),
    );
    return ok == true;
  }

  String get locale => AppLocale.normalize(ref.watch(userLanguageProvider));

  @override
  Widget build(BuildContext context) {
    final isRtl = AppLocale.isRtl(locale);
    if (_loading) {
      return const GlassScreenScaffold(
        title: '…',
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Directionality(
      textDirection: isRtl ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: GlassScreenScaffold(
        title: ScamShieldStrings.t('ss_rp_screen_title', locale),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        padding: const EdgeInsets.all(AppSpacing.lg),
        body: ListView(
          children: [
            Text(
              ScamShieldStrings.t('ss_rp_local_only', locale),
              style: AppTypography.caption.copyWith(
                color: AppColors.textTertiary,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              ScamShieldStrings.t('ss_rp_order_heading', locale),
              style: AppTypography.title,
            ),
            const SizedBox(height: AppSpacing.sm),
            for (final key in _orderStepKeys)
              CheckboxListTile(
                value: _draft.stepsTakenKeys.contains(key),
                onChanged: (v) {
                  final next = Set<String>.from(_draft.stepsTakenKeys);
                  if (v == true) {
                    next.add(key);
                  } else {
                    next.remove(key);
                  }
                  _persistDraft(_draft.copyWith(stepsTakenKeys: next));
                },
                title: Text(
                  ScamShieldStrings.t(key, locale),
                  style: AppTypography.bodySmall,
                ),
                controlAffinity: ListTileControlAffinity.leading,
                dense: true,
              ),
            const SizedBox(height: AppSpacing.md),
            _refField(
              label: ScamShieldStrings.t('ss_rp_ref_bank_case', locale),
              controller: _bankCaseController,
              onSaved: (v) => _persistDraft(_draft.copyWith(bankCaseNumber: v)),
            ),
            _refField(
              label: ScamShieldStrings.t('ss_rp_ref_authority', locale),
              controller: _authorityRefController,
              onSaved: (v) =>
                  _persistDraft(_draft.copyWith(authorityReferenceNumbers: v)),
            ),
            _refField(
              label: ScamShieldStrings.t('ss_rp_bank_fraud_line', locale),
              controller: _bankLineController,
              onSaved: (v) => _persistDraft(_draft.copyWith(bankFraudLine: v)),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              ScamShieldStrings.t('ss_rp_pack_section', locale),
              style: AppTypography.title,
            ),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _summaryController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: ScamShieldStrings.t('ss_rp_summary_label', locale),
                border: const OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              onChanged: (v) => _draft = _draft.copyWith(userSummary: v),
              onEditingComplete: () => _persistDraft(_draft),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              ScamShieldStrings.t('ss_rp_timeline_heading', locale),
              style: AppTypography.subtitle,
            ),
            for (var i = 0; i < _draft.timeline.length; i++)
              _TimelineDateField(
                key: ValueKey('tl_${_draft.timeline[i].labelKey}'),
                label: ScamShieldStrings.t(_draft.timeline[i].labelKey, locale),
                hint: ScamShieldStrings.t('ss_rp_date_hint', locale),
                initial: _draft.timeline[i].userDate,
                onSave: (v) {
                  final tl = [..._draft.timeline];
                  tl[i] = ReportPackTimelineEntry(
                    labelKey: tl[i].labelKey,
                    userDate: v,
                  );
                  _persistDraft(_draft.copyWith(timeline: tl));
                },
              ),
            const SizedBox(height: AppSpacing.md),
            Text(
              ScamShieldStrings.t('ss_rp_other_party_heading', locale),
              style: AppTypography.subtitle,
            ),
            _refField(
              label: ScamShieldStrings.t('ss_rp_party_phone', locale),
              controller: _partyPhoneController,
              onSaved: (_) => _persistAll(),
            ),
            _refField(
              label: ScamShieldStrings.t('ss_rp_party_link', locale),
              controller: _partyLinkController,
              onSaved: (_) => _persistAll(),
            ),
            _refField(
              label: ScamShieldStrings.t('ss_rp_party_account', locale),
              controller: _partyAccountController,
              onSaved: (_) => _persistAll(),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              ScamShieldStrings.t('ss_rp_tx_heading', locale),
              style: AppTypography.subtitle,
            ),
            _refField(
              label: ScamShieldStrings.t('ss_rp_tx_amount', locale),
              controller: _txAmountController,
              onSaved: (_) => _persistAll(),
            ),
            _refField(
              label: ScamShieldStrings.t('ss_rp_tx_date', locale),
              controller: _txDateController,
              onSaved: (_) => _persistAll(),
            ),
            _refField(
              label: ScamShieldStrings.t('ss_rp_tx_method', locale),
              controller: _txMethodController,
              onSaved: (_) => _persistAll(),
            ),
            _refField(
              label: ScamShieldStrings.t('ss_rp_tx_ref', locale),
              controller: _txRefController,
              onSaved: (_) => _persistAll(),
            ),
            const SizedBox(height: AppSpacing.md),
            if (_evidence.isEmpty)
              Text(
                ScamShieldStrings.t('ss_rp_no_evidence', locale),
                style: AppTypography.bodySmall,
              )
            else ...[
              Text(
                ScamShieldStrings.t('ss_rp_evidence_pick', locale),
                style: AppTypography.subtitle,
              ),
              for (final record in _evidence)
                CheckboxListTile(
                  value: _draft.selectedEvidenceIds.contains(record.id),
                  onChanged: (v) {
                    final ids = [..._draft.selectedEvidenceIds];
                    if (v == true) {
                      ids.add(record.id);
                    } else {
                      ids.remove(record.id);
                    }
                    _persistDraft(_draft.copyWith(selectedEvidenceIds: ids));
                  },
                  title: Text(
                    record.maskedSummary.split('\n').first,
                    style: AppTypography.caption,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    record.createdAt.toIso8601String(),
                    style: AppTypography.caption,
                  ),
                  dense: true,
                ),
            ],
            SwitchListTile(
              value: _draft.includeContactDetails,
              onChanged: (v) =>
                  _persistDraft(_draft.copyWith(includeContactDetails: v)),
              title: Text(
                ScamShieldStrings.t('ss_rp_include_contact', locale),
                style: AppTypography.bodySmall,
              ),
            ),
            if (_draft.includeContactDetails) ...[
              _refField(
                label: ScamShieldStrings.t('ss_rp_contact_name', locale),
                controller: _contactNameController,
                onSaved: (v) => _persistDraft(_draft.copyWith(contactName: v)),
              ),
              _refField(
                label: ScamShieldStrings.t('ss_rp_contact_phone', locale),
                controller: _contactPhoneController,
                onSaved: (v) => _persistDraft(_draft.copyWith(contactPhone: v)),
              ),
              _refField(
                label: ScamShieldStrings.t('ss_rp_contact_email', locale),
                controller: _contactEmailController,
                onSaved: (v) => _persistDraft(_draft.copyWith(contactEmail: v)),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            GlassPrimaryButton(
              label: _generating
                  ? ScamShieldStrings.t('ss_rp_generating', locale)
                  : ScamShieldStrings.t('ss_rp_generate', locale),
              expand: true,
              icon: Icons.description_outlined,
              onPressed: _generating ? null : _generatePack,
            ),
            if (_snapshot != null) ...[
              const SizedBox(height: AppSpacing.md),
              GlassCard(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: SelectableText(
                  _snapshot!.plainText,
                  style: AppTypography.caption,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.xl),
            Text(
              ScamShieldStrings.t('ss_rp_channels_heading', locale),
              style: AppTypography.title,
            ),
            Text(
              ScamShieldStrings.t('ss_rp_channels_sub', locale),
              style: AppTypography.caption,
            ),
            if (_channels.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.sm),
                child: Text(
                  ScamShieldStrings.t('ss_rp_no_channels', locale),
                  style: AppTypography.bodySmall,
                ),
              ),
            for (final ch in _channels) ...[
              const SizedBox(height: AppSpacing.sm),
              GlassCard(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ScamShieldStrings.t(ch.nameKey, locale),
                      style: AppTypography.subtitle,
                    ),
                    Text(
                      ScamShieldStrings.t(ch.bodyKey, locale),
                      style: AppTypography.bodySmall,
                    ),
                    Text(
                      ch.sourceLabel,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                    Wrap(
                      spacing: 8,
                      children: [
                        if (ch.callNumber != null ||
                            ch.isUserBankLine)
                          OutlinedButton(
                            onPressed: () => ReportPackChannelActions.call(
                              ch,
                              draft: _draft,
                            ),
                            child: Text(
                              ScamShieldStrings.t('ss_rp_act_call', locale),
                            ),
                          ),
                        if (_pdfPath != null)
                          OutlinedButton(
                            onPressed: () async {
                              if (!await _confirmSensitiveShare()) return;
                              await ReportPackChannelActions.sharePdfAndText(
                                plainText: _snapshot!.plainText,
                                pdfPath: _pdfPath!,
                              );
                            },
                            child: Text(
                              ScamShieldStrings.t('ss_rp_act_share', locale),
                            ),
                          ),
                        if (_pdfPath != null)
                          OutlinedButton(
                            onPressed: () async {
                              if (!await _confirmSensitiveShare()) return;
                              await ReportPackChannelActions.mailtoCompose(
                                channel: ch,
                                plainText: _snapshot!.plainText,
                                pdfPath: _pdfPath!,
                              );
                            },
                            child: Text(
                              ScamShieldStrings.t('ss_rp_act_email', locale),
                            ),
                          ),
                        if (_pdfPath != null)
                          OutlinedButton(
                            onPressed: () async {
                              if (!await _confirmSensitiveShare()) return;
                              await ReportPackChannelActions.copyPlainTextIfAllowed(
                                userConfirmed: true,
                                text: _snapshot!.plainText,
                              );
                            },
                            child: Text(
                              ScamShieldStrings.t('ss_rp_act_copy', locale),
                            ),
                          ),
                        if (ch.verifyUrl != null)
                          TextButton(
                            onPressed: () =>
                                ReportPackChannelActions.openVerifyUrl(ch),
                            child: Text(
                              ScamShieldStrings.t('ss_cn_report_verify', locale),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _refField({
    required String label,
    required TextEditingController controller,
    required ValueChanged<String> onSaved,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        onSubmitted: onSaved,
        onEditingComplete: () => onSaved(controller.text),
      ),
    );
  }
}

class _TimelineDateField extends StatefulWidget {
  const _TimelineDateField({
    super.key,
    required this.label,
    required this.hint,
    required this.initial,
    required this.onSave,
  });

  final String label;
  final String hint;
  final String initial;
  final ValueChanged<String> onSave;

  @override
  State<_TimelineDateField> createState() => _TimelineDateFieldState();
}

class _TimelineDateFieldState extends State<_TimelineDateField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initial);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.label, style: AppTypography.caption),
          TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: widget.hint,
              border: const OutlineInputBorder(),
            ),
            onEditingComplete: () => widget.onSave(_controller.text),
            onSubmitted: widget.onSave,
          ),
        ],
      ),
    );
  }
}
