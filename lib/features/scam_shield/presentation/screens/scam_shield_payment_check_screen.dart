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
import 'package:raabta/features/scam_shield/domain/payment_check_engine.dart';
import 'package:raabta/features/scam_shield/domain/payment_check_models.dart';
import 'package:raabta/features/scam_shield/presentation/l10n/scam_shield_strings.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:raabta/features/scam_shield/presentation/widgets/scam_shield_primitives.dart';
import 'package:raabta/features/scam_shield/presentation/widgets/scam_shield_risk_banner.dart';

class ScamShieldPaymentCheckScreen extends ConsumerStatefulWidget {
  const ScamShieldPaymentCheckScreen({super.key, this.prefill});

  final PaymentCheckPrefill? prefill;

  @override
  ConsumerState<ScamShieldPaymentCheckScreen> createState() =>
      _ScamShieldPaymentCheckScreenState();
}

class _ScamShieldPaymentCheckScreenState
    extends ConsumerState<ScamShieldPaymentCheckScreen> {
  PaymentCheckContext? _context;
  final _ibanController = TextEditingController();
  final _phoneController = TextEditingController();
  final _linkController = TextEditingController();
  final _methods = <PaymentRequestedMethod>{};

  PaymentCheckResult? _result;
  int _pauseSecondsLeft = 0;
  Timer? _pauseTimer;
  bool _pauseComplete = false;

  @override
  void initState() {
    super.initState();
    final prefill = widget.prefill;
    if (prefill != null) {
      _context = prefill.context;
      for (final m in prefill.requestedMethods) {
        _methods.add(m);
      }
      if (prefill.onCall) {
        _methods.add(PaymentRequestedMethod.urgencyThreats);
      }
    }
  }

  @override
  void dispose() {
    _pauseTimer?.cancel();
    _ibanController.dispose();
    _phoneController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  void _applyChip(String value, TextEditingController controller) {
    controller.text = value;
    setState(() => _result = null);
  }

  void _runCheck() {
    _pauseTimer?.cancel();
    final result = PaymentCheckEngine.evaluate(
      PaymentCheckInput(
        context: _context,
        iban: _ibanController.text,
        phone: _phoneController.text,
        link: _linkController.text,
        requestedMethods: _methods,
      ),
    );
    setState(() {
      _result = result;
      _pauseComplete = result.band != PaymentCheckRiskBand.high;
      _pauseSecondsLeft = result.band == PaymentCheckRiskBand.high ? 10 : 0;
    });
    if (result.band == PaymentCheckRiskBand.high) {
      _pauseTimer = Timer.periodic(const Duration(seconds: 1), (t) {
        if (!mounted) return;
        if (_pauseSecondsLeft <= 1) {
          t.cancel();
          setState(() {
            _pauseSecondsLeft = 0;
            _pauseComplete = true;
          });
        } else {
          setState(() => _pauseSecondsLeft -= 1);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocale.normalize(ref.watch(userLanguageProvider));
    final isRtl = AppLocale.isRtl(locale);
    final prefill = widget.prefill;

    return Directionality(
      textDirection: isRtl ? ui.TextDirection.rtl : ui.TextDirection.ltr,
      child: GlassScreenScaffold(
        title: ScamShieldStrings.t('ss_payment_check_title', locale),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        padding: scamShieldScreenPadding,
        body: ListView(
          children: [
            Text(
              ScamShieldStrings.t('ss_payment_check_subtitle', locale),
              style: AppTypography.bodySmall,
            ),
            if (widget.prefill?.onCall == true) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                ScamShieldStrings.t('ss_in_call_on_call_banner', locale),
                style: AppTypography.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.warning,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            Text(
              ScamShieldStrings.t('ss_payment_check_context_label', locale),
              style: AppTypography.subtitle,
            ),
            const SizedBox(height: AppSpacing.sm),
            ScamShieldOptionChips<PaymentCheckContext?>(
              options: [null, ...PaymentCheckContext.values],
              selected: _context,
              labelFor: (c) => c == null
                  ? ScamShieldStrings.t('ss_pay_ctx_skip', locale)
                  : ScamShieldStrings.t(c!.labelKey, locale),
              onSelected: (c) => setState(() {
                _context = c;
                _result = null;
              }),
            ),
            const SizedBox(height: AppSpacing.lg),
            _field(
              locale: locale,
              label: ScamShieldStrings.t('ss_payment_check_iban', locale),
              controller: _ibanController,
              hint: ScamShieldStrings.t('ss_payment_check_iban_hint', locale),
              chips: prefill?.ibanCandidates ?? const [],
            ),
            _field(
              locale: locale,
              label: ScamShieldStrings.t('ss_payment_check_phone', locale),
              controller: _phoneController,
              hint: ScamShieldStrings.t('ss_payment_check_phone_hint', locale),
              chips: prefill?.phoneCandidates ?? const [],
            ),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton.icon(
                onPressed: () {
                  final typed = _phoneController.text.trim();
                  final path = typed.isEmpty
                      ? '/scam-shield/check-number'
                      : '/scam-shield/check-number?phone=${Uri.encodeComponent(typed)}';
                  context.push(path);
                },
                icon: const Icon(Icons.dialpad_outlined, size: 18),
                label: Text(
                  ScamShieldStrings.t(
                    'ss_payment_check_open_check_number',
                    locale,
                  ),
                ),
              ),
            ),
            _field(
              locale: locale,
              label: ScamShieldStrings.t('ss_payment_check_link', locale),
              controller: _linkController,
              hint: ScamShieldStrings.t('ss_payment_check_link_hint', locale),
              chips: prefill?.linkCandidates ?? const [],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              ScamShieldStrings.t('ss_payment_check_methods_label', locale),
              style: AppTypography.subtitle,
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: PaymentRequestedMethod.values.map((m) {
                final selected = _methods.contains(m);
                return FilterChip(
                  label: Text(ScamShieldStrings.t(m.labelKey, locale)),
                  selected: selected,
                  onSelected: (v) => setState(() {
                    if (v) {
                      _methods.add(m);
                    } else {
                      _methods.remove(m);
                    }
                    _result = null;
                  }),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.lg),
            GlassPrimaryButton(
              label: ScamShieldStrings.t('ss_payment_check_run', locale),
              expand: true,
              accentColor: scamShieldAccent,
              icon: Icons.payments_outlined,
              onPressed: _runCheck,
            ),
            if (_result != null) ...[
              const SizedBox(height: AppSpacing.xl),
              _ResultSection(
                locale: locale,
                result: _result!,
                pauseSecondsLeft: _pauseSecondsLeft,
                pauseComplete: _pauseComplete,
                onContinue: () => setState(() => _result = null),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            Text(
              ScamShieldStrings.t('ss_payment_check_disclaimer', locale),
              style: AppTypography.caption.copyWith(
                color: AppColors.textTertiary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field({
    required String locale,
    required String label,
    required TextEditingController controller,
    required String hint,
    required List<String> chips,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTypography.subtitle),
          const SizedBox(height: AppSpacing.xs),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hint,
              border: const OutlineInputBorder(),
            ),
            onChanged: (_) => setState(() => _result = null),
          ),
          if (chips.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              ScamShieldStrings.t('ss_payment_check_prefill_hint', locale),
              style: AppTypography.caption,
            ),
            Wrap(
              spacing: 6,
              children: chips
                  .map(
                    (c) => ActionChip(
                      label: Text(c, style: AppTypography.caption),
                      onPressed: () => _applyChip(c, controller),
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _ResultSection extends StatelessWidget {
  const _ResultSection({
    required this.locale,
    required this.result,
    required this.pauseSecondsLeft,
    required this.pauseComplete,
    required this.onContinue,
  });

  final String locale;
  final PaymentCheckResult result;
  final int pauseSecondsLeft;
  final bool pauseComplete;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final headline = result.band == PaymentCheckRiskBand.clear &&
            result.concernKeys.isEmpty
        ? ScamShieldStrings.t('ss_payment_check_no_issues', locale)
        : ScamShieldStrings.t('ss_payment_check_concerns_heading', locale);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (result.band == PaymentCheckRiskBand.high && !pauseComplete)
          GlassCard(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Text(
              ScamShieldStrings.format(
                'ss_payment_check_pause',
                locale,
                {'seconds': pauseSecondsLeft.toString()},
              ),
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.warning,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        const SizedBox(height: AppSpacing.md),
        ScamShieldRiskBanner(level: result.riskLevel, locale: locale),
        const SizedBox(height: AppSpacing.sm),
        Text(headline, style: AppTypography.title),
        if (result.band == PaymentCheckRiskBand.clear)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xs),
            child: Text(
              ScamShieldStrings.t('ss_payment_check_not_guarantee', locale),
              style: AppTypography.caption,
            ),
          ),
        ...result.concernKeys.map(
          (k) => Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xs),
            child: Text(
              '• ${_concernText(k, result)}',
              style: AppTypography.bodySmall,
            ),
          ),
        ),
        if (result.showNameCoaching) ...[
          const SizedBox(height: AppSpacing.md),
          GlassCard(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ScamShieldStrings.t('ss_payment_check_name_coach_title', locale),
                  style: AppTypography.subtitle,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  ScamShieldStrings.t('ss_payment_check_name_coach_body', locale),
                  style: AppTypography.bodySmall,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  ScamShieldStrings.t('ss_payment_check_fawran_source', locale),
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ],
        if (result.contextPromptKeys.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          Text(
            ScamShieldStrings.t('ss_payment_check_prompts_heading', locale),
            style: AppTypography.subtitle,
          ),
          ...result.contextPromptKeys.map(
            (k) => Padding(
              padding: const EdgeInsets.only(top: AppSpacing.xs),
              child: Text('• ${ScamShieldStrings.t(k, locale)}',
                  style: AppTypography.bodySmall),
            ),
          ),
        ],
        if (result.reusedVerifyKeys.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          Text(
            ScamShieldStrings.t('ss_verify_heading', locale),
            style: AppTypography.subtitle,
          ),
          ...result.reusedVerifyKeys.map(
            (k) => Padding(
              padding: const EdgeInsets.only(top: AppSpacing.xs),
              child: Text('• ${ScamShieldStrings.t(k, locale)}',
                  style: AppTypography.bodySmall),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton(
            onPressed: () => context.push('/scam-shield/directory'),
            child: Text(ScamShieldStrings.t('ss_directory_link', locale)),
          ),
        ],
        if (result.band != PaymentCheckRiskBand.clear) ...[
          const SizedBox(height: AppSpacing.md),
          OutlinedButton.icon(
            onPressed: () => context.go('/scam-shield'),
            icon: const Icon(Icons.radar),
            label: Text(
              ScamShieldStrings.t('ss_advisories_check_message_cta', locale),
            ),
          ),
          OutlinedButton.icon(
            onPressed: () => context.push('/scam-shield/incident'),
            icon: const Icon(Icons.emergency_outlined),
            label: Text(
              ScamShieldStrings.t('ss_payment_check_report', locale),
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.md),
        GlassPrimaryButton(
          label: ScamShieldStrings.t('ss_payment_check_continue', locale),
          expand: true,
          accentColor: scamShieldAccent,
          onPressed: (result.band == PaymentCheckRiskBand.high && !pauseComplete)
              ? null
              : onContinue,
        ),
      ],
    );
  }

  String _concernText(String key, PaymentCheckResult result) {
    if (key == 'ss_pay_concern_iban_bank_named') {
      return ScamShieldStrings.format(key, locale, {
        'bankName': result.ibanValidation?.bankName ?? '',
      });
    }
    return ScamShieldStrings.t(key, locale);
  }
}
