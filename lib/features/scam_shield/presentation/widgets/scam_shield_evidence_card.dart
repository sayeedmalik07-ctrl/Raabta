import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_primary_button.dart';
import 'package:raabta/features/scam_shield/domain/evidence/scam_channel_static_rules.dart';
import 'package:raabta/features/scam_shield/domain/evidence/domain_age_evidence_loader.dart';
import 'package:raabta/features/scam_shield/domain/evidence/generators/phone_number_facts_evidence.dart';
import 'package:raabta/features/scam_shield/domain/evidence/link_unroll_evidence_loader.dart';
import 'package:raabta/features/scam_shield/domain/evidence/scam_evidence_engine.dart';
import 'package:raabta/features/scam_shield/domain/evidence/scam_evidence_models.dart';
import 'package:raabta/features/scam_shield/domain/evidence/scam_evidence_next_step.dart';
import 'package:raabta/features/scam_shield/domain/evidence/scam_bridge_topic.dart';
import 'package:raabta/features/scam_shield/domain/evidence/scam_topic_classifier.dart';
import 'package:raabta/features/scam_shield/domain/evidence/scam_truth_engine_bridges.dart';
import 'package:raabta/providers/compliance_flags_provider.dart';
import 'package:raabta/features/scam_shield/presentation/widgets/scam_truth_engine_go_deeper_section.dart';
import 'package:raabta/features/scam_shield/presentation/widgets/scam_already_lost_money_button.dart';
import 'package:raabta/features/scam_shield/scam_type_library/scam_type_providers.dart';
import 'package:raabta/features/scam_shield/scam_type_library/scam_type_resolver.dart';
import 'package:raabta/features/scam_shield/domain/official_directory.dart';
import 'package:raabta/features/scam_shield/domain/payment_check_models.dart';
import 'package:raabta/features/scam_shield/domain/scam_message_sender_type.dart';
import 'package:raabta/features/scam_shield/domain/scam_shield_models.dart';
import 'package:raabta/features/scam_shield/platform/scam_external_link_launcher.dart';
import 'package:raabta/features/scam_shield/presentation/l10n/scam_shield_strings.dart';
import 'package:raabta/features/scam_shield/presentation/widgets/scam_shield_risk_banner.dart';
import 'package:raabta/features/scam_shield/post_incident_watch/post_incident_watch_providers.dart';
import 'package:raabta/features/scam_shield/sensitive_lock/sensitive_safety_lock_offer.dart';
import 'package:raabta/features/scam_shield/presentation/widgets/post_incident_watch_banner.dart';
import 'package:raabta/features/scam_shield/providers/scam_advisory_providers.dart';
import 'package:raabta/features/scam_shield/providers/scam_shield_providers.dart';
import 'package:raabta/features/scam_shield/evidence_listen/evidence_listen_controls.dart';
import 'package:raabta/features/scam_shield/evidence_listen/evidence_simple_view_prefs.dart';
import 'package:raabta/features/scam_shield/evidence_listen/evidence_spoken_script_builder.dart';
import 'package:raabta/features/scam_shield/evidence_listen/evidence_verdict_pictogram.dart';
import 'package:raabta/features/scam_shield/domain/scam_sensitive_input_mask.dart';
import 'package:raabta/features/scam_shield/personal_context/personal_context_providers.dart';
import 'package:scam_shield_core/features/scam_shield/domain/evidence/personal_context_models.dart';
import 'package:share_plus/share_plus.dart';

/// On-device "why we think so" card — no network on this path.
class ScamShieldEvidenceCard extends ConsumerStatefulWidget {
  const ScamShieldEvidenceCard({
    super.key,
    required this.sourceText,
    required this.result,
    required this.locale,
    required this.maskedInput,
    this.senderType = ScamMessageSenderType.notSure,
  });

  final String sourceText;
  final ScamShieldAssessmentResult result;
  final String locale;
  final String maskedInput;
  final ScamMessageSenderType senderType;

  @override
  ConsumerState<ScamShieldEvidenceCard> createState() =>
      _ScamShieldEvidenceCardState();
}

class _ScamShieldEvidenceCardState extends ConsumerState<ScamShieldEvidenceCard> {
  var _expanded = false;
  var _simpleView = false;
  var _simpleWhyExpanded = false;
  var _simplePrefsLoaded = false;
  List<ScamEvidence> _asyncEvidence = const [];
  var _domainAgeAnnounced = false;
  var _linkUnrollAnnounced = false;
  final _lookupSession = DomainAgeEvidenceSession();
  final _unrollSession = LinkUnrollEvidenceSession();
  var _loadGeneration = 0;

  @override
  void initState() {
    super.initState();
    _startAsyncEvidenceLoad();
    _loadSimpleViewPref();
  }

  Future<void> _loadSimpleViewPref() async {
    final enabled = await EvidenceSimpleViewPrefs.isEnabled();
    if (!mounted) return;
    setState(() {
      _simpleView = enabled;
      _simplePrefsLoaded = true;
    });
  }

  @override
  void didUpdateWidget(covariant ScamShieldEvidenceCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_assessmentIdentity(oldWidget.result, oldWidget.sourceText) !=
        _assessmentIdentity(widget.result, widget.sourceText)) {
      _asyncEvidence = const [];
      _domainAgeAnnounced = false;
      _linkUnrollAnnounced = false;
      _lookupSession.reset();
      _unrollSession.reset();
      _startAsyncEvidenceLoad();
    }
  }

  void _startAsyncEvidenceLoad() {
    final generation = ++_loadGeneration;
    unawaited(_loadAsyncEvidence(generation));
  }

  static String _assessmentIdentity(
    ScamShieldAssessmentResult result,
    String sourceText,
  ) {
    final urlKey = result.urlFindings.map((f) => f.domain).join('\u0001');
    final flagKey = result.redFlags.join('\u0001');
    final sourceFp = _sourceFingerprint(sourceText);
    return '${result.overallRisk.name}|${result.localCheck.signal.name}|'
        '$flagKey|$urlKey|${result.usedAi}|$sourceFp';
  }

  /// In-memory SHA-256 fingerprint — not logged or persisted.
  static String _sourceFingerprint(String sourceText) {
    if (sourceText.isEmpty) return '';
    return sha256.convert(utf8.encode(sourceText)).toString();
  }

  Future<void> _loadAsyncEvidence(int generation) async {
    final domainAgeEnabled = ref.read(scamDomainAgeEnabledProvider);
    final linkUnrollEnabled = ref.read(scamLinkUnrollEnabledProvider);
    final results = await Future.wait([
      DomainAgeEvidenceLoader.loadAsync(
        urlFindings: widget.result.urlFindings,
        locale: widget.locale,
        featureEnabled: domainAgeEnabled,
        lookupSession: _lookupSession,
      ),
      LinkUnrollEvidenceLoader.loadAsync(
        urlFindings: widget.result.urlFindings,
        locale: widget.locale,
        featureEnabled: linkUnrollEnabled,
        domainAgeEnabled: domainAgeEnabled,
        unrollSession: _unrollSession,
      ),
      PhoneNumberFactsEvidenceGenerator.generateAsync(
        text: widget.sourceText,
        senderType: widget.senderType,
      ),
    ]);
    final items = [...results[0], ...results[1], ...results[2]];
    if (!mounted || generation != _loadGeneration || items.isEmpty) return;
    setState(() => _asyncEvidence = items);

    final hasDomainAge = items.any(
      (e) =>
          e.kind == ScamEvidenceKind.domainAgeConcern ||
          e.kind == ScamEvidenceKind.domainAgeInfo,
    );
    final hasLinkUnroll = items.any(
      (e) =>
          e.kind == ScamEvidenceKind.shortLinkDestination ||
          e.kind == ScamEvidenceKind.redirectChainLong ||
          (e.kind == ScamEvidenceKind.lookalikeDomain &&
              e.sourceLabel == 'ss_evidence_short_link_source'),
    );

    if (hasDomainAge && !_domainAgeAnnounced) {
      _domainAgeAnnounced = true;
      SemanticsService.announce(
        ScamShieldStrings.t('ss_evidence_domain_age_announced', widget.locale),
        TextDirection.ltr,
      );
    }
    if (hasLinkUnroll && !_linkUnrollAnnounced) {
      _linkUnrollAnnounced = true;
      SemanticsService.announce(
        ScamShieldStrings.t('ss_evidence_link_unroll_announced', widget.locale),
        TextDirection.ltr,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final advisories = ref.watch(scamAdvisoryCatalogProvider);
    final personalContext = ref.watch(personalContextSnapshotProvider).valueOrNull ??
        PersonalContextSnapshot.empty;
    final input = EvidenceEngineInput(
      text: widget.sourceText,
      locale: widget.locale,
      localFlags: widget.result.localCheck.redFlags,
      urlFindings: widget.result.urlFindings,
      senderType: widget.senderType,
      advisories: advisories,
      attackStage: widget.result.scanAnalysis.attackStage,
      personalContext: personalContext,
    );
    final headline = ScamEvidenceEngine.headline(input);
    final evidence = ScamEvidenceEngine.mergeAsyncItems(
      base: ScamEvidenceEngine.compute(input),
      asyncItems: _asyncEvidence,
    );
    final nextStep = ScamEvidenceNextStepResolver.resolve(
      evidence: evidence,
      localFlags: widget.result.localCheck.redFlags,
      text: widget.sourceText,
      analysis: widget.result.scanAnalysis,
      phase10Available: true,
      locale: widget.locale,
    );
    final topic = ScamTopicClassifier.classify(
      text: widget.sourceText,
      contentType: widget.result.contentType,
      localFlags: widget.result.localCheck.redFlags,
      scanAnalysis: widget.result.scanAnalysis,
    );
    final showGoDeeper =
        evidence.isNotEmpty || topic.isExplicit;
    final compliance = ref.watch(complianceFlagsProvider);
    final entityClaim = OfficialDirectory.detectClaimedEntity(
      widget.sourceText,
      widget.locale,
    );
    final bridges = showGoDeeper
        ? ScamTruthEngineBridgeResolver.resolve(
            topic: topic,
            complianceFlags: compliance,
            entityHint: entityClaim.primaryId != null
                ? ScamTruthEngineBridgeHint.officialDirectoryClaimedEntity
                : ScamTruthEngineBridgeHint.none,
          )
        : const <ScamTruthEngineBridgeAction>[];
    final verifiedTypes = ref.watch(scamTypeVerifiedProvider).valueOrNull ?? [];
    final matchedTypeId = ScamTypeResolver.resolveTypeId(
      verifiedTypes: verifiedTypes,
      text: widget.sourceText,
      contentType: widget.result.contentType,
      localFlags: widget.result.localCheck.redFlags,
      scanAnalysis: widget.result.scanAnalysis,
    );
    final watchActive =
        ref.watch(postIncidentWatchActiveProvider).valueOrNull ?? false;
    final hasRecovery = evidence.any(
      (e) => e.kind == ScamEvidenceKind.recoveryOffer,
    );
    final showLostMoney = hasRecovery && watchActive
        ? true
        : ScamAlreadyLostMoneyButton.shouldShow(
            risk: widget.result.overallRisk,
            primaryKind: nextStep.kind,
          );

    final verdict = EvidenceVerdictPictogramResolver.fromRisk(
      widget.result.overallRisk,
    );
    final spokenScript = EvidenceSpokenScriptBuilder(
      locale: widget.locale,
      verdict: verdict,
      headlineKey: headline.textKey,
      headlineParams: headline.params,
      evidence: _visibleRows(evidence),
      nextStepLabel: _nextStepLabel(nextStep, widget.locale),
    ).build();
    final maskedForSpeech =
        ScamSensitiveInputMask.mask(widget.maskedInput);

    final semanticsLabel = [
      ScamShieldStrings.t('ss_evidence_card_semantics', widget.locale),
      EvidenceVerdictPictogramResolver.semanticsLabel(verdict, widget.locale),
    ].join('. ');

    return Semantics(
      container: true,
      label: semanticsLabel,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PostIncidentWatchBanner(locale: widget.locale),
          ScamShieldRiskBanner(
            level: widget.result.overallRisk,
            locale: widget.locale,
          ),
          const SizedBox(height: AppSpacing.md),
          GlassCard(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  EvidenceVerdictPictogramBanner(
                    state: verdict,
                    locale: widget.locale,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  if (_simplePrefsLoaded)
                    Material(
                      type: MaterialType.transparency,
                      child: SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          ScamShieldStrings.t(
                            'ss_simple_view_toggle',
                            widget.locale,
                          ),
                          style: AppTypography.caption,
                        ),
                        value: _simpleView,
                        onChanged: (v) async {
                          setState(() => _simpleView = v);
                          await EvidenceSimpleViewPrefs.setEnabled(v);
                        },
                      ),
                    ),
                  EvidenceListenControls(
                    locale: widget.locale,
                    script: spokenScript,
                    maskedMessage: maskedForSpeech,
                  ),
                  if (!_simpleView) ...[
                  Text(
                    ScamShieldStrings.t('ss_evidence_card_heading', widget.locale),
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    ScamShieldStrings.format(
                      headline.textKey,
                      widget.locale,
                      headline.params,
                    ),
                    style: AppTypography.title,
                  ),
                  ],
                  if (!_simpleView && matchedTypeId != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: TextButton(
                        onPressed: () => context.push(
                          '/scam-shield/scam-types/$matchedTypeId',
                        ),
                        child: Text(
                          ScamShieldStrings.t(
                            'ss_scam_types_inline_link',
                            widget.locale,
                          ),
                          style: AppTypography.caption,
                        ),
                      ),
                    ),
                  ],
                  if (!_simpleView) const SizedBox(height: AppSpacing.md),
                  if (_simpleView && !_simpleWhyExpanded)
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: TextButton(
                        onPressed: () =>
                            setState(() => _simpleWhyExpanded = true),
                        child: Text(
                          ScamShieldStrings.t(
                            'ss_simple_view_why',
                            widget.locale,
                          ),
                        ),
                      ),
                    ),
                  if (!_simpleView || _simpleWhyExpanded) ...[
                    if (evidence.isEmpty)
                      Text(
                        ScamShieldStrings.t('ss_evidence_none', widget.locale),
                        style: AppTypography.bodySmall,
                      )
                    else ...[
                      ..._visibleRows(evidence).map(
                        (e) => _EvidenceRow(
                          evidence: e,
                          locale: widget.locale,
                          animateIn:
                              _asyncEvidence.any((a) => a.kind == e.kind),
                          onTap: () => _openSource(context, e),
                        ),
                      ),
                      if (evidence.length > ScamEvidenceEngine.uiTop)
                        TextButton(
                          onPressed: () =>
                              setState(() => _expanded = !_expanded),
                          child: Text(
                            ScamShieldStrings.t(
                              _expanded
                                  ? 'ss_evidence_see_less'
                                  : 'ss_evidence_see_all',
                              widget.locale,
                            ),
                          ),
                        ),
                      if (widget.senderType.isActionable)
                        Padding(
                          padding: const EdgeInsets.only(top: AppSpacing.xs),
                          child: Text(
                            ScamShieldStrings.t(
                              ScamChannelStaticRules.senderCaveatKey,
                              widget.locale,
                            ),
                            style: AppTypography.caption.copyWith(
                              color: AppColors.textTertiary,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                    ],
                  ],
                  if (!_simpleView)
                    ScamTruthEngineGoDeeperSection(
                      bridges: bridges,
                      locale: widget.locale,
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          GlassPrimaryButton(
            label: _nextStepLabel(nextStep, widget.locale),
            expand: true,
            accentColor: scamShieldRiskColor(widget.result.overallRisk),
            icon: _nextStepIcon(nextStep.kind),
            onPressed: () => _onNextStep(context, nextStep),
          ),
          if (showLostMoney)
            ScamAlreadyLostMoneyTextButton(locale: widget.locale),
          if (!_simpleView) ...[
            const SizedBox(height: AppSpacing.sm),
            _secondaryActions(context, evidence),
          ],
        ],
      ),
    );
  }

  List<ScamEvidence> _visibleRows(List<ScamEvidence> all) {
    if (_expanded) return all;
    return all.take(ScamEvidenceEngine.uiTop).toList();
  }

  Future<void> _onNextStep(
    BuildContext context,
    ScamEvidenceNextStep step,
  ) async {
    switch (step.kind) {
      case ScamEvidenceNextStepKind.checkPayment:
        context.push(
          '/scam-shield/payment-check',
          extra: step.prefill ??
              PaymentCheckPrefill(
                linkCandidates: widget.result.urlFindings
                    .map((f) => f.url)
                    .toList(growable: false),
              ),
        );
      case ScamEvidenceNextStepKind.incidentResponse:
        context.push('/scam-shield/incident');
      case ScamEvidenceNextStepKind.contactRealEntity:
        final id = step.entityId;
        if (id == null) {
          context.push('/scam-shield/official-directory');
          return;
        }
        final entry = OfficialDirectory.lookupById(id);
        if (entry == null) {
          context.push('/scam-shield/official-directory');
          return;
        }
        if (entry.authorityRef.isNotEmpty) {
          context.push('/scam-shield/directory');
          return;
        }
        final domain = entry.officialDomains.firstOrNull;
        if (domain != null) {
          await ScamExternalLinkLauncher.openUrl('https://$domain');
        } else {
          context.push('/scam-shield/official-directory');
        }
      case ScamEvidenceNextStepKind.checkInvestmentLicensed:
        context.push('/scam-shield/investment-check');
      case ScamEvidenceNextStepKind.reportAuthorityDirectory:
        context.push('/scam-shield/directory');
    }
  }

  Widget _secondaryActions(BuildContext context, List<ScamEvidence> evidence) {
    return Wrap(
      spacing: AppSpacing.sm,
      children: [
        TextButton.icon(
          onPressed: () async {
            await ref.read(scamEvidenceLockerServiceProvider).saveFromAssessment(
                  result: widget.result,
                  maskedInput: widget.maskedInput,
                );
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    ScamShieldStrings.t('ss_evidence_saved_local', widget.locale),
                  ),
                ),
              );
              await SensitiveSafetyLockOffer.maybeOfferAfterFirstSensitiveSave(
                context,
                ref,
                locale: widget.locale,
              );
            }
          },
          icon: const Icon(Icons.save_outlined, size: 16),
          label: Text(
            ScamShieldStrings.t('ss_evidence_save_local', widget.locale),
          ),
        ),
        TextButton.icon(
          onPressed: () => Share.share(
            ScamShieldStrings.t('ss_evidence_share_tip', widget.locale),
          ),
          icon: const Icon(Icons.share_outlined, size: 16),
          label: Text(
            ScamShieldStrings.t('ss_evidence_share_tip_cta', widget.locale),
          ),
        ),
        if (evidence.any((e) => e.kind == ScamEvidenceKind.moneyMuleRecruitment))
          TextButton(
            onPressed: () => context.push(
              '/scam-shield/payment-check',
              extra: const PaymentCheckPrefill(
                context: PaymentCheckContext.jobVisaFee,
              ),
            ),
            child: Text(
              ScamShieldStrings.t('ss_evidence_money_mule_link', widget.locale),
            ),
          ),
      ],
    );
  }

  void _openSource(BuildContext context, ScamEvidence e) {
    if (e.advisoryId != null) {
      context.push('/scam-shield/advisories/${e.advisoryId}');
      return;
    }
    if (e.entityId != null) {
      final entry = OfficialDirectory.lookupById(e.entityId!);
      if (entry != null) {
        showModalBottomSheet<void>(
          context: context,
          builder: (ctx) => Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  entry.displayName(widget.locale),
                  style: AppTypography.title,
                ),
                if (entry.contactNote(widget.locale) != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(entry.contactNote(widget.locale)!),
                ],
                if (e.sourceUrl != null && e.sourceUrl!.isNotEmpty)
                  TextButton(
                    onPressed: () =>
                        ScamExternalLinkLauncher.openUrl(e.sourceUrl!),
                    child: Text(
                      ScamShieldStrings.t('ss_evidence_open_source', widget.locale),
                    ),
                  ),
              ],
            ),
          ),
        );
        return;
      }
    }
    if (e.sourceUrl != null && e.sourceUrl!.isNotEmpty) {
      ScamExternalLinkLauncher.openUrl(e.sourceUrl!);
      return;
    }
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Text(
          ScamShieldStrings.t('ss_evidence_pattern_why', widget.locale),
          style: AppTypography.bodySmall,
        ),
      ),
    );
  }

  static String _nextStepLabel(ScamEvidenceNextStep step, String locale) {
    if (step.recoveryOfferPrimary) {
      return ScamShieldStrings.t('ss_evidence_next_recovery_report', locale);
    }
    final key = switch (step.kind) {
      ScamEvidenceNextStepKind.checkPayment => 'ss_evidence_next_check_payment',
      ScamEvidenceNextStepKind.incidentResponse =>
        'ss_evidence_next_incident',
      ScamEvidenceNextStepKind.checkInvestmentLicensed =>
        'ss_evidence_next_investment_check',
      ScamEvidenceNextStepKind.contactRealEntity =>
        'ss_evidence_next_contact_real',
      ScamEvidenceNextStepKind.reportAuthorityDirectory =>
        'ss_evidence_next_report',
    };
    if (step.kind == ScamEvidenceNextStepKind.contactRealEntity &&
        step.entityId != null) {
      final name = OfficialDirectory.lookupById(step.entityId!)?.displayName(
            locale,
          ) ??
          step.entityId!;
      return ScamShieldStrings.format(key, locale, {'entity': name});
    }
    return ScamShieldStrings.t(key, locale);
  }

  static IconData _nextStepIcon(ScamEvidenceNextStepKind kind) {
    return switch (kind) {
      ScamEvidenceNextStepKind.checkPayment => Icons.payments_outlined,
      ScamEvidenceNextStepKind.incidentResponse => Icons.emergency_outlined,
      ScamEvidenceNextStepKind.checkInvestmentLicensed =>
        Icons.fact_check_outlined,
      ScamEvidenceNextStepKind.contactRealEntity => Icons.verified_user_outlined,
      ScamEvidenceNextStepKind.reportAuthorityDirectory =>
        Icons.report_outlined,
    };
  }
}

class _EvidenceRow extends StatelessWidget {
  const _EvidenceRow({
    required this.evidence,
    required this.locale,
    required this.onTap,
    this.animateIn = false,
  });

  final ScamEvidence evidence;
  final String locale;
  final VoidCallback onTap;
  final bool animateIn;

  @override
  Widget build(BuildContext context) {
    final icon = evidence.direction == ScamEvidenceDirection.informational
        ? Icons.info_outline
        : Icons.warning_amber_outlined;
    final iconColor = evidence.direction == ScamEvidenceDirection.informational
        ? AppColors.textTertiary
        : AppColors.chipLease;
    final date = evidence.sourceDate != null
        ? evidence.sourceDate!.toIso8601String().split('T').first
        : null;

    final row = Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 18, color: iconColor),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ScamShieldStrings.format(
                        evidence.textKey,
                        locale,
                        evidence.params,
                      ),
                      style: AppTypography.bodySmall,
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        _SourceChip(
                          label: evidence.sourceLabel,
                          locale: locale,
                          params: evidence.params,
                        ),
                        if (date != null)
                          Text(
                            date,
                            style: AppTypography.caption.copyWith(
                              color: AppColors.textTertiary,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (!animateIn) return row;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 320),
      builder: (context, value, child) => Opacity(opacity: value, child: child),
      child: row,
    );
  }
}

class _SourceChip extends StatelessWidget {
  const _SourceChip({
    required this.label,
    required this.locale,
    this.params = const {},
  });

  final String label;
  final String locale;
  final Map<String, String> params;

  @override
  Widget build(BuildContext context) {
    final text = label.startsWith('ss_')
        ? ScamShieldStrings.format(label, locale, params)
        : label;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.glassBorder.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: AppTypography.caption,
      ),
    );
  }
}
