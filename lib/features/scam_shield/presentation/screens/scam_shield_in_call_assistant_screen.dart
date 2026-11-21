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
import 'package:raabta/features/scam_shield/data/scam_authority_directory_config.dart';
import 'package:raabta/features/scam_shield/domain/scam_incident_models.dart';
import 'package:raabta/features/scam_shield/domain/official_directory.dart';
import 'package:raabta/features/scam_shield/domain/payment_check_models.dart';
import 'package:raabta/features/scam_shield/in_call/in_call_claimed_caller.dart';
import 'package:raabta/features/scam_shield/platform/scam_external_link_launcher.dart';
import 'package:raabta/features/scam_shield/presentation/l10n/scam_shield_strings.dart';
import 'package:raabta/features/scam_shield/presentation/widgets/scam_shield_primitives.dart';
import 'package:raabta/features/scam_shield/providers/scam_shield_providers.dart';
import 'package:raabta/providers/visa_providers.dart';

class ScamShieldInCallAssistantScreen extends ConsumerStatefulWidget {
  const ScamShieldInCallAssistantScreen({
    super.key,
    this.skipClaimedCallerStep = false,
  });

  final bool skipClaimedCallerStep;

  @override
  ConsumerState<ScamShieldInCallAssistantScreen> createState() =>
      _ScamShieldInCallAssistantScreenState();
}

class _ScamShieldInCallAssistantScreenState
    extends ConsumerState<ScamShieldInCallAssistantScreen> {
  late int _step;
  InCallClaimedCaller? _claimed;
  final _asked = <InCallAskedFor>{};
  final _noteNumberController = TextEditingController();
  bool _savingNote = false;

  @override
  void initState() {
    super.initState();
    _step = widget.skipClaimedCallerStep ? 1 : 0;
  }

  @override
  void dispose() {
    _noteNumberController.dispose();
    super.dispose();
  }

  void _selectClaimed(InCallClaimedCaller value) {
    setState(() {
      _claimed = value;
      _step = 1;
    });
  }

  InCallClaimedCaller get _effectiveClaimed =>
      _claimed ?? InCallClaimedCaller.other;

  Future<void> _confirmDial(String phone) async {
    final locale = AppLocale.normalize(ref.read(userLanguageProvider));
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(ScamShieldStrings.t('ss_in_call_dial_confirm_title', locale)),
        content: Text(
          ScamShieldStrings.t('ss_in_call_dial_confirm_body', locale),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(ScamShieldStrings.t('ss_in_call_not_now', locale)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(ScamShieldStrings.t('ss_in_call_dial_open', locale)),
          ),
        ],
      ),
    );
    if (ok == true && mounted) {
      await ScamExternalLinkLauncher.dialPhone(phone);
    }
  }

  Future<void> _runNextAction(InCallNextAction action, String locale) async {
    switch (action.kind) {
      case InCallNextActionKind.familyVerificationKit:
        context.push('/scam-shield/family-verification');
      case InCallNextActionKind.remoteAccessChecklist:
        setState(() => _step = 2);
        return;
      case InCallNextActionKind.paymentCheck:
        context.push(
          '/scam-shield/payment-check',
          extra: const PaymentCheckPrefill(
            onCall: true,
            requestedMethods: [
              PaymentRequestedMethod.urgencyThreats,
              PaymentRequestedMethod.keepSecret,
            ],
          ),
        );
      case InCallNextActionKind.investmentCheck:
        context.push('/scam-shield/investment-check');
      case InCallNextActionKind.pasteMessageCheck:
        context.go('/scam-shield');
      case InCallNextActionKind.browseAuthorityDirectory:
        context.push('/scam-shield/directory');
      case InCallNextActionKind.browseEntityChannels:
        final id = action.authorityDirectoryId;
        if (id != null && ScamAuthorityDirectoryConfig.findById(id) != null) {
          final entry = ScamAuthorityDirectoryConfig.findById(id)!;
          if (action.telecomDial != null) {
            await _confirmDial(action.telecomDial!);
          } else {
            await ScamExternalLinkLauncher.openUrl(entry.verifyUrl);
          }
        } else {
          final official = id != null ? OfficialDirectory.lookupById(id) : null;
          if (official != null && official.officialDomains.isNotEmpty) {
            await ScamExternalLinkLauncher.openUrl(
              'https://${official.officialDomains.first}',
            );
          }
        }
    }
    if (mounted) setState(() => _step = 3);
  }

  Future<void> _saveOptionalNote(String locale) async {
    setState(() => _savingNote = true);
    try {
      await ref.read(scamEvidenceLockerServiceProvider).saveFromInCallUserNote(
            callerNumberTyped: _noteNumberController.text.trim(),
            claimedLabelKey: _claimedChipKey(_effectiveClaimed),
            locale: locale,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ScamShieldStrings.t('ss_in_call_note_saved', locale)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _savingNote = false);
    }
  }

  void _openIncidentWithHints(String locale) {
    final hints = <ScamIncidentPrefillHint>[];
    for (final item in _asked) {
      if (item == InCallAskedFor.nothing) continue;
      hints.add(InCallAssistantRouting.incidentHintForAsked(item));
    }
    final merged = _mergeHints(hints);
    final prefill = merged.toPrefill(
      impersonation: InCallAssistantRouting.impersonationFor(_effectiveClaimed),
    );
    context.push('/scam-shield/incident', extra: prefill);
  }

  ScamIncidentPrefillHint _mergeHints(List<ScamIncidentPrefillHint> hints) {
    if (hints.isEmpty) {
      return ScamIncidentPrefillHint(
        impersonation: InCallAssistantRouting.impersonationFor(_effectiveClaimed),
        suggestedContact: {ScamContactChannel.phoneCall},
        timing: ScamIncidentTiming.justNow,
      );
    }
    final shared = <ScamSharedDataCategory>{};
    final outcomes = <ScamIncidentOutcome>{};
    for (final h in hints) {
      shared.addAll(h.sharedData);
      outcomes.addAll(h.outcomes);
    }
    return ScamIncidentPrefillHint(
      sharedData: shared,
      outcomes: outcomes,
      suggestedContact: {ScamContactChannel.phoneCall},
      timing: ScamIncidentTiming.justNow,
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocale.normalize(ref.watch(userLanguageProvider));
    final isRtl = AppLocale.isRtl(locale);
    final titleScale = MediaQuery.textScalerOf(context).scale(1);
    final bodyStyle = AppTypography.subtitle.copyWith(
      fontSize: (18 * titleScale).clamp(16, 28),
      height: 1.35,
    );

    return Directionality(
      textDirection: isRtl ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: GlassScreenScaffold(
        title: ScamShieldStrings.t('ss_in_call_title', locale),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        padding: scamShieldScreenPadding,
        body: ListView(
          children: [
            Text(
              ScamShieldStrings.t('ss_in_call_offline_notice', locale),
              style: AppTypography.caption.copyWith(
                color: AppColors.textTertiary,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            if (_step == 0) _claimedStep(locale, bodyStyle),
            if (_step == 1) _rulesStep(locale, bodyStyle),
            if (_step == 2) _nextActionStep(locale, bodyStyle),
            if (_step == 3) _afterCallStep(locale, bodyStyle),
          ],
        ),
      ),
    );
  }

  Widget _claimedStep(String locale, TextStyle bodyStyle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          ScamShieldStrings.t('ss_in_call_claimed_prompt', locale),
          style: bodyStyle.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: InCallClaimedCaller.values.map((c) {
            return ActionChip(
              label: Text(
                ScamShieldStrings.t(_claimedChipKey(c), locale),
                style: AppTypography.bodySmall,
              ),
              onPressed: () => _selectClaimed(c),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _rulesStep(String locale, TextStyle bodyStyle) {
    final rules = [
      'ss_in_call_rule_a',
      'ss_in_call_rule_b',
      'ss_in_call_rule_c',
      'ss_in_call_rule_d',
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          ScamShieldStrings.t('ss_in_call_rules_heading', locale),
          style: bodyStyle.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          ScamShieldStrings.t('ss_in_call_callerid_warning', locale),
          style: bodyStyle,
        ),
        const SizedBox(height: AppSpacing.md),
        for (final key in rules) ...[
          GlassCard(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Text(
              ScamShieldStrings.t(key, locale),
              style: bodyStyle,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        Text(
          '${ScamShieldStrings.t('ss_in_call_rule_source_moi', locale)} · '
          '${ScamShieldStrings.t('ss_scam_types_pattern_check', locale)}',
          style: AppTypography.caption.copyWith(color: AppColors.textTertiary),
        ),
        const SizedBox(height: AppSpacing.lg),
        GlassPrimaryButton(
          label: ScamShieldStrings.t('ss_in_call_rules_continue', locale),
          onPressed: () => setState(() => _step = 2),
        ),
      ],
    );
  }

  Widget _nextActionStep(String locale, TextStyle bodyStyle) {
    final action = InCallAssistantRouting.resolveNextAction(_effectiveClaimed);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          ScamShieldStrings.t('ss_in_call_next_heading', locale),
          style: bodyStyle.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: AppSpacing.md),
        if (action.kind == InCallNextActionKind.remoteAccessChecklist) ...[
          GlassCard(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Text(
              ScamShieldStrings.t('ss_stop_explain_remote_access', locale),
              style: bodyStyle,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          GlassCard(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Text(
              ScamShieldStrings.t('ss_pay_concern_sideload', locale),
              style: bodyStyle,
            ),
          ),
        ] else if (action.kind == InCallNextActionKind.browseEntityChannels)
          _entityPanel(action, locale, bodyStyle)
        else
          Text(
            ScamShieldStrings.t(_nextActionBlurbKey(action.kind), locale),
            style: bodyStyle,
          ),
        const SizedBox(height: AppSpacing.lg),
        if (action.kind == InCallNextActionKind.remoteAccessChecklist)
          GlassPrimaryButton(
            label: ScamShieldStrings.t('ss_in_call_after_call_cta', locale),
            onPressed: () => setState(() => _step = 3),
          )
        else
          GlassPrimaryButton(
            label: ScamShieldStrings.t('ss_in_call_next_primary', locale),
            onPressed: () => _runNextAction(action, locale),
          ),
        if (_effectiveClaimed == InCallClaimedCaller.investmentOrPrize) ...[
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton(
            onPressed: () {
              context.push(
                '/scam-shield/payment-check',
                extra: const PaymentCheckPrefill(
                  onCall: true,
                  context: PaymentCheckContext.prizeRefund,
                  requestedMethods: [PaymentRequestedMethod.urgencyThreats],
                ),
              );
            },
            child: Text(
              ScamShieldStrings.t('ss_in_call_prize_payment_check', locale),
            ),
          ),
          OutlinedButton(
            onPressed: () => context.go('/scam-shield'),
            child: Text(
              ScamShieldStrings.t('ss_in_call_paste_message', locale),
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.sm),
        TextButton(
          onPressed: () => setState(() => _step = 3),
          child: Text(
            ScamShieldStrings.t('ss_in_call_after_call_cta', locale),
          ),
        ),
      ],
    );
  }

  Widget _entityPanel(
    InCallNextAction action,
    String locale,
    TextStyle bodyStyle,
  ) {
    final id = action.authorityDirectoryId;
    final auth = id != null ? ScamAuthorityDirectoryConfig.findById(id) : null;
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ScamShieldStrings.t('ss_in_call_get_real_number', locale),
            style: bodyStyle.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.sm),
          if (auth != null)
            Text(
              ScamShieldStrings.t(auth.nameKey, locale),
              style: bodyStyle,
            ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            ScamShieldStrings.t('ss_in_call_use_card_or_site', locale),
            style: bodyStyle,
          ),
          if (action.telecomDial != null) ...[
            const SizedBox(height: AppSpacing.md),
            OutlinedButton.icon(
              onPressed: () => _confirmDial(action.telecomDial!),
              icon: const Icon(Icons.phone_outlined),
              label: Text(
                ScamShieldStrings.t('ss_in_call_telecom_numbers', locale),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _afterCallStep(String locale, TextStyle bodyStyle) {
    final hasRiskSelection = _asked.any((a) => a != InCallAskedFor.nothing);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          ScamShieldStrings.t('ss_in_call_asked_prompt', locale),
          style: bodyStyle.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: InCallAskedFor.values.map((a) {
            final selected = _asked.contains(a);
            return FilterChip(
              label: Text(ScamShieldStrings.t(_askedKey(a), locale)),
              selected: selected,
              onSelected: (on) {
                setState(() {
                  if (a == InCallAskedFor.nothing) {
                    _asked
                      ..clear()
                      ..add(InCallAskedFor.nothing);
                  } else {
                    _asked.remove(InCallAskedFor.nothing);
                    if (on) {
                      _asked.add(a);
                    } else {
                      _asked.remove(a);
                    }
                  }
                });
              },
            );
          }).toList(),
        ),
        const SizedBox(height: AppSpacing.lg),
        if (hasRiskSelection) ...[
          Text(
            ScamShieldStrings.t('ss_in_call_incident_offer', locale),
            style: bodyStyle,
          ),
          const SizedBox(height: AppSpacing.sm),
          GlassPrimaryButton(
            label: ScamShieldStrings.t('ss_incident_cta', locale),
            onPressed: () => _openIncidentWithHints(locale),
          ),
        ] else if (_asked.contains(InCallAskedFor.nothing)) ...[
          Text(
            ScamShieldStrings.t('ss_in_call_nothing_ok', locale),
            style: bodyStyle,
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _noteNumberController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: ScamShieldStrings.t('ss_in_call_note_number', locale),
              hintText: ScamShieldStrings.t('ss_in_call_note_optional', locale),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          GlassPrimaryButton(
            label: ScamShieldStrings.t('ss_in_call_save_note', locale),
            onPressed: _savingNote ? null : () => _saveOptionalNote(locale),
          ),
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton(
            onPressed: () {
              final typed = _noteNumberController.text.trim();
              final q = typed.isEmpty
                  ? '/scam-shield/check-number'
                  : '/scam-shield/check-number?phone=${Uri.encodeComponent(typed)}';
              context.push(q);
            },
            child: Text(
              ScamShieldStrings.t('ss_in_call_check_number', locale),
            ),
          ),
          TextButton(
            onPressed: () => context.push('/scam-shield/check-number'),
            child: Text(ScamShieldStrings.t('ss_cn_cnap_link', locale)),
          ),
        ],
      ],
    );
  }

  static String _claimedChipKey(InCallClaimedCaller c) => switch (c) {
        InCallClaimedCaller.bankOrCard => 'ss_in_call_chip_bank',
        InCallClaimedCaller.policeMoiMetrash => 'ss_in_call_chip_police',
        InCallClaimedCaller.mobileOperator => 'ss_in_call_chip_mobile',
        InCallClaimedCaller.courierPostCustoms => 'ss_in_call_chip_courier',
        InCallClaimedCaller.employerOrAgency => 'ss_in_call_chip_employer',
        InCallClaimedCaller.embassyOrConsulate => 'ss_in_call_chip_embassy',
        InCallClaimedCaller.familyInTrouble => 'ss_in_call_chip_family',
        InCallClaimedCaller.techSupport => 'ss_in_call_chip_tech',
        InCallClaimedCaller.investmentOrPrize => 'ss_in_call_chip_investment',
        InCallClaimedCaller.other => 'ss_in_call_chip_other',
      };

  static String _askedKey(InCallAskedFor a) => switch (a) {
        InCallAskedFor.otpOrPin => 'ss_in_call_asked_otp',
        InCallAskedFor.cardDetails => 'ss_in_call_asked_card',
        InCallAskedFor.qidOrDocuments => 'ss_in_call_asked_qid',
        InCallAskedFor.installOrScreenShare => 'ss_in_call_asked_install',
        InCallAskedFor.sendMoney => 'ss_in_call_asked_money',
        InCallAskedFor.nothing => 'ss_in_call_asked_nothing',
      };

  static String _nextActionBlurbKey(InCallNextActionKind kind) => switch (kind) {
        InCallNextActionKind.browseAuthorityDirectory =>
          'ss_in_call_next_directory',
        InCallNextActionKind.familyVerificationKit => 'ss_in_call_next_family',
        InCallNextActionKind.investmentCheck => 'ss_in_call_next_investment',
        InCallNextActionKind.pasteMessageCheck => 'ss_in_call_paste_message',
        _ => 'ss_in_call_next_generic',
      };
}
