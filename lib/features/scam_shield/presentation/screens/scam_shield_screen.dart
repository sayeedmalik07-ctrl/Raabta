import 'dart:async';
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
import 'package:raabta/features/home/widgets/home_icon_badge.dart';
import 'package:raabta/features/home/widgets/home_section_header.dart';
import 'package:raabta/features/scam_shield/domain/scam_input_channel_parser.dart';
import 'package:raabta/features/scam_shield/domain/scam_message_sender_type.dart';
import 'package:raabta/features/scam_shield/domain/scam_shield_history_entry.dart';
import 'package:raabta/features/scam_shield/presentation/widgets/scam_shield_sender_chips.dart';
import 'package:raabta/features/scam_shield/domain/scam_shield_models.dart';
import 'package:raabta/features/scam_shield/presentation/l10n/scam_shield_academy_strings.dart';
import 'package:raabta/features/scam_shield/presentation/l10n/family_verification_kit_strings.dart';
import 'package:raabta/features/scam_shield/presentation/l10n/scam_shield_strings.dart';
import 'package:raabta/features/scam_shield/presentation/widgets/scam_proactive_protection_section.dart';
import 'package:raabta/features/scam_shield/pattern_packs/scam_pattern_pack_providers.dart';
import 'package:raabta/features/scam_shield/presentation/widgets/post_incident_watch_banner.dart';
import 'package:raabta/features/scam_shield/anonymous_signal/scam_anonymous_signal_consent_banner.dart';
import 'package:raabta/features/scam_shield/anonymous_signal/scam_anonymous_signal_coordinator.dart';
import 'package:raabta/features/scam_shield/anonymous_signal/scam_anonymous_signal_helpers.dart';
import 'package:raabta/features/scam_shield/anonymous_signal/scam_anonymous_signal_settings_tile.dart';
import 'package:raabta/features/scam_shield/anonymous_signal/scam_anonymous_signal_strings.dart';
import 'package:raabta/features/scam_shield/presentation/widgets/post_incident_watch_settings_tile.dart';
import 'package:raabta/features/scam_shield/presentation/widgets/sensitive_safety_lock_settings_tile.dart';
import 'package:raabta/features/scam_shield/sensitive_lock/sensitive_safety_lock_gate.dart';
import 'package:raabta/features/scam_shield/presentation/widgets/scam_checkup_settings_tile.dart';
import 'package:raabta/features/scam_shield/presentation/widgets/family_verification_settings_tile.dart';
import 'package:raabta/features/scam_shield/presentation/widgets/scam_shield_forewarning_settings_tile.dart';
import 'package:raabta/features/scam_shield/presentation/widgets/scam_shield_history_section.dart';
import 'package:raabta/features/scam_shield/presentation/widgets/scam_shield_primitives.dart';
import 'package:raabta/features/scam_shield/presentation/widgets/scam_shield_results_reveal.dart';
import 'package:raabta/features/scam_shield/providers/scam_shield_providers.dart';
import 'package:raabta/features/scam_shield/domain/scam_sensitive_input_mask.dart';
import 'package:raabta/features/scam_shield/services/scam_shield_alert_ack_service.dart';
import 'package:raabta/features/scam_shield/platform/scam_shield_entry_route_platform.dart';
import 'package:raabta/features/scam_shield/scam_shield_config.dart';
import 'package:raabta/providers/visa_providers.dart';

class ScamShieldScreen extends ConsumerStatefulWidget {
  const ScamShieldScreen({super.key});

  @override
  ConsumerState<ScamShieldScreen> createState() => _ScamShieldScreenState();
}

class _ScamShieldScreenState extends ConsumerState<ScamShieldScreen> {
  static const _hubTileGlow = 0.05;

  final _controller = TextEditingController();
  ScamShieldContentType _contentType = ScamShieldContentType.whatsAppSms;
  ScamShieldInputChannel _inputChannel = ScamShieldInputChannel.pasteText;
  ScamShieldAssessmentResult? _result;
  String _lastMaskedInput = '';
  String _lastSourceText = '';
  ScamMessageSenderType _senderType = ScamMessageSenderType.notSure;
  bool _loading = false;
  List<String> _lastEvidenceKindNames = const [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        unawaited(scamShieldAcknowledgeOpenAlerts(ref));
        unawaited(ref.read(officialDirectoryBootstrapProvider.future));
        unawaited(ref.read(scamPatternPackBootstrapProvider.future));
        unawaited(ScamShieldEntryRoutePlatform.consumePendingEntryRoute());
        unawaited(ScamAnonymousSignalHelpers.bootstrapUploadIfOptedIn());
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _assess() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    scamShieldLightHaptic();
    setState(() {
      _loading = true;
      _result = null;
    });

    try {
      final service = ref.read(scamShieldAssessmentServiceProvider);
      // Snapshot for this scan — AI assessment language matches locale when user tapped Scan.
      final locale = AppLocale.normalize(ref.read(userLanguageProvider));
      final canUseAi = await scamShieldCanUseAi(ref);

      final result = await service.assess(
        text: text,
        contentType: _contentType,
        language: locale,
        userId: scamShieldUserId(ref),
        canUseAi: canUseAi,
        inputChannel: _inputChannel,
        senderType: _senderType,
      );

      if (result.usedAi) {
        await scamShieldRecordAiUsage(ref);
      }

      final evidenceKinds = await ScamAnonymousSignalHelpers.evidenceKindNames(
        ref: ref,
        text: text,
        locale: locale,
        result: result,
        senderType: _senderType,
      );

      final entry = ScamShieldHistoryEntry.fromAssessment(
        result: result,
        inputText: ScamSensitiveInputMask.mask(text),
        evidenceKinds: evidenceKinds,
      );
      await ref.read(scamShieldHistoryRepositoryProvider).saveEntry(entry);
      ref.invalidate(scamShieldHistoryProvider);
      ref.invalidate(scamShieldActiveAlertProvider);

      await ScamAnonymousSignalHelpers.afterAssessmentShown(
        ref: ref,
        text: text,
        locale: locale,
        result: result,
        senderType: _senderType,
        evidenceKindNames: evidenceKinds,
      );

      if (mounted) {
        setState(() {
          _result = result;
          _lastMaskedInput = ScamSensitiveInputMask.mask(text);
          _lastSourceText = text;
          _lastEvidenceKindNames = evidenceKinds;
        });
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _confirmClearHistory(String locale) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(ScamShieldStrings.t('ss_history_clear', locale)),
        content: Text(ScamShieldStrings.t('ss_history_clear_confirm', locale)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(ScamShieldStrings.t('ss_dialog_cancel', locale)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(ScamShieldStrings.t('ss_history_clear', locale)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await ref.read(scamShieldHistoryRepositoryProvider).clearAll();
    ref.invalidate(scamShieldHistoryProvider);
    ref.invalidate(scamShieldActiveAlertProvider);
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocale.normalize(ref.watch(userLanguageProvider));
    final isRtl = AppLocale.isRtl(locale);
    final remainingAsync = ref.watch(scamShieldRemainingAiProvider);
    final historyAsync = ref.watch(scamShieldHistoryProvider);
    final proactiveAsync = ref.watch(scamProactiveProtectionStatusProvider);
    final charCount = _controller.text.length;
    final lastScan = historyAsync.maybeWhen(
      data: (entries) => entries.isNotEmpty ? entries.first.scannedAt : null,
      orElse: () => null,
    );
    final aiRemaining = remainingAsync.maybeWhen(
      data: (n) => n,
      orElse: () => null,
    );

    return Directionality(
      textDirection: isRtl ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: GlassScreenScaffold(
        title: ScamShieldStrings.t('ss_title', locale),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        padding: scamShieldScreenPadding,
        body: ListView(
          children: [
            ScamShieldHeroCard(
              locale: locale,
              lastScanAt: lastScan,
              aiRemaining: aiRemaining,
              compact: true,
            ),
            const SizedBox(height: AppSpacing.md),
            _ProtectionToolsExpansionPanel(
              locale: locale,
              glowIntensity: _hubTileGlow,
              proactiveSection: proactiveAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (_, _) => const SizedBox.shrink(),
                data: (status) => Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.md),
                  child: ScamProactiveProtectionSection(
                    locale: locale,
                    status: status,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            HomeSectionHeader(
              overline: ScamShieldStrings.t('ss_scan_overline', locale),
              title: ScamShieldStrings.t('ss_input_channel', locale),
              leadingIcon: Icons.radar,
            ),
            const SizedBox(height: AppSpacing.sm),
            ScamShieldOptionChips<ScamShieldInputChannel>(
              options: ScamShieldInputChannel.values
                  .where((c) => c != ScamShieldInputChannel.osShare)
                  .toList(),
              selected: _inputChannel,
              labelFor: (c) => ScamShieldStrings.t(c.labelKey, locale),
              onSelected: (channel) => setState(() {
                _inputChannel = channel;
                _result = null;
              }),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              ScamShieldStrings.t('ss_content_type', locale),
              style: AppTypography.subtitle.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppSpacing.sm),
            ScamShieldOptionChips<ScamShieldContentType>(
              options: ScamShieldContentType.values.toList(),
              selected: _contentType,
              accentColor: scamShieldAccent,
              labelFor: (t) => ScamShieldStrings.t(t.labelKey, locale),
              onSelected: (type) => setState(() {
                _contentType = type;
                _result = null;
              }),
            ),
            const SizedBox(height: AppSpacing.md),
            ScamShieldSenderRow(
              locale: locale,
              selected: _senderType,
              onSelected: (t) => setState(() {
                _senderType = t;
                _result = null;
              }),
            ),
            const SizedBox(height: AppSpacing.md),
            ScamShieldScanInputBlock(
              locale: locale,
              controller: _controller,
              hintText: ScamShieldStrings.t(_inputChannel.hintKey, locale),
              charCount: charCount,
              maxChars: ScamShieldConfig.maxInputChars,
              onChanged: (_) => setState(() {}),
              directoryAction: () => context.push('/scam-shield/directory'),
            ),
            const SizedBox(height: AppSpacing.md),
            if (_loading)
              ScamShieldAssessLoading(
                message: ScamShieldStrings.t('ss_assess_loading', locale),
              )
            else
              GlassPrimaryButton(
                label: ScamShieldStrings.t('ss_assess_cta', locale),
                expand: true,
                accentColor: scamShieldAccent,
                icon: Icons.radar,
                onPressed: _controller.text.trim().isEmpty ? null : _assess,
              ),
            if (_result != null) ...[
              const SizedBox(height: AppSpacing.xl),
              ScamShieldResultsReveal(
                result: _result!,
                locale: locale,
                maskedInput: _lastMaskedInput,
                sourceText: _lastSourceText,
                senderType: _senderType,
                onLegitimateTap: () async {
                  await ScamAnonymousSignalCoordinator.markLegitFalseAlarmForLatestQueued(
                    result: _result!,
                    sourceTextForLocalClassification: _lastSourceText,
                    evidenceKindNames: _lastEvidenceKindNames,
                    locale: locale,
                    senderType: _senderType,
                  );
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        ScamAnonymousSignalStrings.t('ss_signal_legit_ack', locale),
                      ),
                    ),
                  );
                },
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            historyAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
              data: (entries) => SensitiveSafetyLockGate(
                locale: locale,
                child: ScamShieldHistorySection(
                  entries: entries,
                  locale: locale,
                  onClear: () => _confirmClearHistory(locale),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            PostIncidentWatchBanner(locale: locale),
            ScamAnonymousSignalConsentBanner(locale: locale),
            ScamShieldFeatureTile(
              icon: Icons.phone_in_talk_outlined,
              title: ScamShieldStrings.t('ss_in_call_hub_cta', locale),
              subtitle: ScamShieldStrings.t('ss_in_call_title', locale),
              accentColor: AppColors.warning,
              glowIntensity: _hubTileGlow,
              onTap: () => context.push('/scam-shield/in-call-assistant'),
            ),
            const SizedBox(height: AppSpacing.sm),
            ScamShieldFeatureTile(
              icon: Icons.verified_user_outlined,
              title: ScamShieldStrings.t('ss_shield_hub_title', locale),
              subtitle: ScamShieldStrings.t('ss_shield_hub_sub', locale),
              accentColor: scamShieldAccent,
              glowIntensity: _hubTileGlow,
              onTap: () => context.push('/scam-shield/shield'),
            ),
            const SizedBox(height: AppSpacing.md),
            ScamShieldFeatureTile(
              icon: Icons.payments_outlined,
              title: ScamShieldStrings.t('ss_payment_check_hub_link', locale),
              subtitle: ScamShieldStrings.t('ss_payment_check_subtitle', locale),
              accentColor: scamShieldAccent,
              glowIntensity: _hubTileGlow,
              onTap: () => context.push('/scam-shield/payment-check'),
            ),
            const SizedBox(height: AppSpacing.sm),
            ScamShieldFeatureTile(
              icon: Icons.campaign_outlined,
              title: ScamShieldStrings.t('ss_advisories_hub_link', locale),
              subtitle: ScamShieldStrings.t('ss_advisories_disclaimer', locale),
              accentColor: AppColors.warning,
              glowIntensity: _hubTileGlow,
              onTap: () => context.push('/scam-shield/advisories'),
            ),
            const SizedBox(height: AppSpacing.md),
            HomeSectionHeader(
              title: ScamShieldStrings.t('ss_tools_title', locale),
              leadingIcon: Icons.build_circle_outlined,
            ),
            const SizedBox(height: AppSpacing.sm),
            ScamShieldFeatureTile(
              icon: Icons.dialpad_outlined,
              title: ScamShieldStrings.t('ss_cn_hub_title', locale),
              subtitle: ScamShieldStrings.t('ss_cn_hub_sub', locale),
              accentColor: scamShieldAccent,
              glowIntensity: _hubTileGlow,
              onTap: () => context.push('/scam-shield/check-number'),
            ),
            const SizedBox(height: AppSpacing.sm),
            ScamShieldFeatureTile(
              icon: Icons.family_restroom_outlined,
              title: FamilyVerificationKitStrings.t('ss_fvk_hub_title', locale),
              subtitle: FamilyVerificationKitStrings.t('ss_fvk_hub_sub', locale),
              accentColor: scamShieldAccent,
              glowIntensity: _hubTileGlow,
              onTap: () => context.push('/scam-shield/family-verification'),
            ),
            const SizedBox(height: AppSpacing.sm),
            ScamShieldFeatureTile(
              icon: Icons.fact_check_outlined,
              title: ScamShieldStrings.t('ss_inv_hub_title', locale),
              subtitle: ScamShieldStrings.t('ss_inv_hub_sub', locale),
              accentColor: scamShieldAccent,
              glowIntensity: _hubTileGlow,
              onTap: () => context.push('/scam-shield/investment-check'),
            ),
            const SizedBox(height: AppSpacing.sm),
            ScamShieldFeatureTile(
              icon: Icons.account_balance_outlined,
              title: ScamShieldStrings.t('ss_personal_context_title', locale),
              subtitle: ScamShieldStrings.t('ss_personal_context_why', locale),
              accentColor: scamShieldAccent,
              glowIntensity: _hubTileGlow,
              onTap: () => context.push('/scam-shield/personal-context'),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              ScamShieldStrings.t('ss_scam_types_hub_title', locale),
              style: AppTypography.caption.copyWith(
                color: AppColors.textTertiary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            ScamShieldFeatureTile(
              icon: Icons.menu_book_outlined,
              title: ScamShieldStrings.t('ss_scam_types_hub_title', locale),
              subtitle: ScamShieldStrings.t('ss_scam_types_hub_sub', locale),
              accentColor: scamShieldAccent,
              glowIntensity: _hubTileGlow,
              onTap: () => context.push('/scam-shield/scam-types'),
            ),
            const SizedBox(height: AppSpacing.sm),
            ScamShieldFeatureTile(
              icon: Icons.verified_user_outlined,
              title: ScamShieldStrings.t('ss_official_dir_hub_title', locale),
              subtitle: ScamShieldStrings.t('ss_official_dir_hub_sub', locale),
              accentColor: scamShieldAccent,
              glowIntensity: _hubTileGlow,
              onTap: () => context.push('/scam-shield/official-directory'),
            ),
            const SizedBox(height: AppSpacing.sm),
            ScamShieldFeatureTile(
              icon: Icons.sim_card_alert_outlined,
              title: ScamShieldStrings.t('ss_sim_entry_title', locale),
              subtitle: ScamShieldStrings.t('ss_sim_entry_sub', locale),
              accentColor: scamShieldAccent,
              glowIntensity: _hubTileGlow,
              onTap: () => context.push('/scam-shield/sim-swap'),
            ),
            const SizedBox(height: AppSpacing.sm),
            ScamShieldFeatureTile(
              icon: Icons.emergency_outlined,
              title: ScamShieldStrings.t('ss_incident_entry_title', locale),
              subtitle: ScamShieldStrings.t('ss_incident_entry_sub', locale),
              accentColor: AppColors.warning,
              glowIntensity: _hubTileGlow,
              onTap: () => context.push('/scam-shield/incident'),
            ),
            const SizedBox(height: AppSpacing.sm),
            ScamShieldFeatureTile(
              icon: Icons.inventory_2_outlined,
              title: ScamShieldStrings.t('ss_evidence_locker_hub_title', locale),
              subtitle: ScamShieldStrings.t('ss_evidence_locker_hub_sub', locale),
              accentColor: scamShieldAccent,
              glowIntensity: _hubTileGlow,
              onTap: () => context.push('/scam-shield/evidence-locker'),
            ),
            const SizedBox(height: AppSpacing.sm),
            ScamShieldFeatureTile(
              icon: Icons.folder_shared_outlined,
              title: ScamShieldStrings.t('ss_rp_hub_title', locale),
              subtitle: ScamShieldStrings.t('ss_rp_hub_sub', locale),
              accentColor: scamShieldAccent,
              glowIntensity: _hubTileGlow,
              onTap: () => context.push('/scam-shield/report-ready'),
            ),
            const SizedBox(height: AppSpacing.sm),
            ScamShieldFeatureTile(
              icon: Icons.school_outlined,
              title: ScamShieldAcademyStrings.t(
                'ss_academy_home_entry_title',
                locale,
              ),
              subtitle: ScamShieldAcademyStrings.t(
                'ss_academy_home_entry_sub',
                locale,
              ),
              accentColor: scamShieldSecondaryAccent,
              glowIntensity: _hubTileGlow,
              onTap: () => context.push('/scam-shield/academy'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Premium Protection Tools dropdown — presentation only; children unchanged.
class _ProtectionToolsExpansionPanel extends StatelessWidget {
  const _ProtectionToolsExpansionPanel({
    required this.locale,
    required this.glowIntensity,
    required this.proactiveSection,
  });

  final String locale;
  final double glowIntensity;
  final Widget proactiveSection;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: EdgeInsets.zero,
      borderRadius: AppSpacing.radiusLg,
      glowColor: scamShieldAccent,
      glowIntensity: glowIntensity + 0.03,
      backgroundColor: AppColors.surface.withValues(alpha: 0.72),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(
            color: scamShieldAccent.withValues(alpha: 0.22),
          ),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              scamShieldAccent.withValues(alpha: 0.1),
              Colors.transparent,
            ],
            stops: const [0, 0.45],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: AppSpacing.md),
            const _RaabtaLiveSecurityShieldCrest(),
            const SizedBox(height: AppSpacing.sm),
            Theme(
              data: Theme.of(context).copyWith(
                dividerColor: Colors.transparent,
                splashColor: scamShieldAccent.withValues(alpha: 0.1),
                highlightColor: scamShieldAccent.withValues(alpha: 0.05),
              ),
              child: ExpansionTile(
                initiallyExpanded: false,
                tilePadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                childrenPadding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  0,
                  AppSpacing.md,
                  AppSpacing.md,
                ),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
                collapsedShape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
                iconColor: scamShieldAccent,
                collapsedIconColor: scamShieldAccent,
                title: Row(
                  children: [
                    const _ProtectionLiveIndicator(),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        ScamShieldStrings.t('ss_tools_overline', locale),
                        style: AppTypography.subtitle.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.xxs),
                  child: Text(
                    ScamShieldStrings.t('ss_tools_title', locale),
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textOnGlassMuted,
                    ),
                  ),
                ),
                children: [
                  const SizedBox(height: AppSpacing.sm),
                  ScamCheckupSettingsTile(locale: locale),
                  FamilyVerificationSettingsTile(locale: locale),
                  ScamShieldForewarningSettingsTile(locale: locale),
                  PostIncidentWatchSettingsTile(locale: locale),
                  ScamAnonymousSignalSettingsTile(locale: locale),
                  SensitiveSafetyLockSettingsTile(locale: locale),
                  proactiveSection,
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
          ],
        ),
      ),
    );
  }
}

class _RaabtaLiveSecurityShieldCrest extends StatefulWidget {
  const _RaabtaLiveSecurityShieldCrest();

  @override
  State<_RaabtaLiveSecurityShieldCrest> createState() =>
      _RaabtaLiveSecurityShieldCrestState();
}

class _RaabtaLiveSecurityShieldCrestState extends State<_RaabtaLiveSecurityShieldCrest>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ringScale = Tween<double>(begin: 0.92, end: 1.06).animate(
      CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
    );
    final ringOpacity = Tween<double>(begin: 0.35, end: 0.75).animate(
      CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
    );

    return SizedBox(
      height: 72,
      child: Stack(
        alignment: Alignment.center,
        children: [
          FadeTransition(
            opacity: ringOpacity,
            child: ScaleTransition(
              scale: ringScale,
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: scamShieldAccent.withValues(alpha: 0.45),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: scamShieldAccent.withValues(alpha: 0.2),
                      blurRadius: 14,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              const HomeIconBadge(
                icon: Icons.shield_outlined,
                accentColor: scamShieldAccent,
                size: 52,
                iconSize: 28,
              ),
              Positioned(
                right: -2,
                bottom: -2,
                child: FadeTransition(
                  opacity: ringOpacity,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: AppColors.surface.withValues(alpha: 0.92),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: scamShieldAccent.withValues(alpha: 0.45),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: scamShieldAccent.withValues(alpha: 0.15),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.radar,
                      size: 14,
                      color: scamShieldAccent,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProtectionLiveIndicator extends StatefulWidget {
  const _ProtectionLiveIndicator();

  @override
  State<_ProtectionLiveIndicator> createState() =>
      _ProtectionLiveIndicatorState();
}

class _ProtectionLiveIndicatorState extends State<_ProtectionLiveIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.5, end: 1).animate(
        CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
      ),
      child: Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.successBright,
          boxShadow: [
            BoxShadow(
              color: AppColors.successBright.withValues(alpha: 0.55),
              blurRadius: 8,
            ),
          ],
        ),
      ),
    );
  }
}
