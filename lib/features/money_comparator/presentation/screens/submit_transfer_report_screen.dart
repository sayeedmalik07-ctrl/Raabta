import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/mixins/draft_persistence_mixin.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_primary_button.dart';
import 'package:raabta/core/widgets/hub/money_tool_screen_scaffold.dart';
import 'package:raabta/features/money_comparator/data/models/corridor_report_model.dart';
import 'package:raabta/features/money_comparator/domain/corridor_aggregate_logic.dart';
import 'package:raabta/features/money_comparator/domain/corridor_transfer_method.dart';
import 'package:raabta/features/money_comparator/presentation/l10n/money_comparator_strings.dart';
import 'package:raabta/features/money_comparator/presentation/providers/corridor_comparator_providers.dart';
import 'package:raabta/features/money_comparator/presentation/widgets/corridor_disclaimer_banner.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:raabta/services/drafts/draft_box_keys.dart';
import 'package:raabta/services/exchange_rate_service.dart';

class SubmitTransferReportScreen extends ConsumerStatefulWidget {
  const SubmitTransferReportScreen({
    super.key,
    this.initialCountryCode,
  });

  final String? initialCountryCode;

  @override
  ConsumerState<SubmitTransferReportScreen> createState() =>
      _SubmitTransferReportScreenState();
}

class _SubmitTransferReportScreenState
    extends ConsumerState<SubmitTransferReportScreen>
    with DraftPersistenceMixin {
  late String _countryCode;
  CorridorTransferMethod _method = CorridorTransferMethod.bank;
  bool _submitting = false;

  final _amountSent = TextEditingController();
  final _feePaid = TextEditingController();
  final _recipientGot = TextEditingController();
  final _deliveryHours = TextEditingController();
  final _provider = TextEditingController();

  static final _gold = AppColors.goldFamilyMain;

  late final VoidCallback _amountHeroListener;

  @override
  void initState() {
    super.initState();
    _countryCode = widget.initialCountryCode ?? 'INR';
    _amountHeroListener = () {
      if (mounted) setState(() {});
    };
    _amountSent.addListener(_amountHeroListener);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await setupDraftPersistence(
        formId: DraftBoxKeys.corridorTransferReport,
        controllers: [
          _amountSent,
          _feePaid,
          _recipientGot,
          _deliveryHours,
          _provider,
        ],
        serialize: _serializeDraft,
        applyDraft: _applyDraft,
      );
    });
  }

  Map<String, dynamic> _serializeDraft() => {
        'countryCode': _countryCode,
        'method': _method.value,
        'amountSent': _amountSent.text,
        'feePaid': _feePaid.text,
        'recipientGot': _recipientGot.text,
        'deliveryHours': _deliveryHours.text,
        'provider': _provider.text,
      };

  void _applyDraft(Map<String, dynamic> data) {
    _countryCode = data['countryCode']?.toString() ?? _countryCode;
    _method = CorridorTransferMethod.fromValue(data['method']?.toString());
    _amountSent.text = data['amountSent']?.toString() ?? '';
    _feePaid.text = data['feePaid']?.toString() ?? '';
    _recipientGot.text = data['recipientGot']?.toString() ?? '';
    _deliveryHours.text = data['deliveryHours']?.toString() ?? '';
    _provider.text = data['provider']?.toString() ?? '';
    setState(() {});
  }

  @override
  void dispose() {
    _amountSent.removeListener(_amountHeroListener);
    disposeDraftMixin();
    _amountSent.dispose();
    _feePaid.dispose();
    _recipientGot.dispose();
    _deliveryHours.dispose();
    _provider.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final locale = ref.read(userLanguageProvider);
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(MoneyComparatorStrings.t('mc_sign_in_required', locale)),
        ),
      );
      return;
    }

    final currency = currencyInfoForCode(_countryCode);
    if (currency == null) return;

    final report = CorridorReport(
      destinationCountryCode: _countryCode,
      destinationCurrencyCode: _countryCode,
      destinationCountryName: currency.country,
      amountSentQar: double.tryParse(_amountSent.text.trim()) ?? 0,
      method: _method,
      providerName: _provider.text.trim(),
      feePaidQar: double.tryParse(_feePaid.text.trim()) ?? 0,
      amountRecipientGot: double.tryParse(_recipientGot.text.trim()) ?? 0,
      deliveryHours: double.tryParse(_deliveryHours.text.trim()) ?? 0,
      userId: user.uid,
    );

    if (report.providerName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(MoneyComparatorStrings.t('mc_provider_required', locale)),
        ),
      );
      return;
    }

    final sanity = CorridorAggregateLogic.validateReportSanity(report);
    if (sanity != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_localizeSanityMessage(sanity, locale))),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      await ref.read(corridorComparatorRepositoryProvider).submitReport(
            report: report,
            userId: user.uid,
          );
      await clearFormDraft();
      ref.invalidate(corridorAggregatesProvider(_countryCode));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(MoneyComparatorStrings.t('mc_submit_thanks', locale)),
        ),
      );
      context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            MoneyComparatorStrings.t('mc_submit_error_generic', locale),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Widget _sectionHeader(String locale, String key) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(
        MoneyComparatorStrings.t(key, locale),
        style: AppTypography.subtitle.copyWith(
          color: _gold,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _submitHero(String locale) {
    final raw = _amountSent.text.trim().replaceAll(',', '');
    final parsed = double.tryParse(raw);
    final showAmount =
        parsed != null && parsed.isFinite && parsed > 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showAmount)
          MoneyToolHeroSendAmount(
            amount: parsed,
            caption: MoneyComparatorStrings.t('mc_amount_sent', locale),
            semanticsLabel: MoneyComparatorStrings.t('mc_amount_sent', locale),
          ),
        if (showAmount) const SizedBox(height: AppSpacing.sm),
        Text(
          MoneyComparatorStrings.t('mc_submit_hero_body', locale),
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary,
            height: 1.35,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(userLanguageProvider);
    final knownProviders =
        ref.watch(corridorKnownProvidersProvider).valueOrNull ?? const [];

    return MoneyToolScreenScaffold(
      title: MoneyComparatorStrings.t('mc_submit_title', locale),
      subtitle: MoneyComparatorStrings.t('mc_submit_subtitle', locale),
      onBack: () => context.pop(),
      disclaimer: CorridorDisclaimerBanner(locale: locale),
      hero: _submitHero(locale),
      statusRow: MoneyToolStatusRow(
        label: MoneyComparatorStrings.t('mc_submit_validation_hint', locale),
        icon: Icons.verified_user_outlined,
        color: _gold,
      ),
      children: [
        if (draftRestoreBanner != null) ...[
          draftRestoreBanner!,
          const SizedBox(height: AppSpacing.md),
        ],
        _sectionHeader(locale, 'mc_submit_section_destination'),
        GlassCard(
          padding: const EdgeInsets.all(AppSpacing.md),
          glowColor: _gold,
          glowIntensity: 0.05,
          borderRadius: AppSpacing.radiusMd,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                MoneyComparatorStrings.t('mc_destination_country', locale),
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              DropdownButtonFormField<String>(
                key: ValueKey(_countryCode),
                initialValue: _countryCode,
                decoration: _hubSubmitFormFieldDecoration(
                  labelText: MoneyComparatorStrings.t(
                    'mc_destination_country',
                    locale,
                  ),
                ),
                dropdownColor: AppColors.surfaceElevated,
                items: [
                  for (final c in raabtaCurrencies)
                    DropdownMenuItem(
                      value: c.code,
                      child: Text('${c.flag} ${c.country}'),
                    ),
                ],
                onChanged: _submitting
                    ? null
                    : (v) {
                        if (v == null) return;
                        setState(() => _countryCode = v);
                        notifyDraftChanged();
                      },
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                MoneyComparatorStrings.t('mc_method_used', locale),
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              DropdownButtonFormField<CorridorTransferMethod>(
                key: ValueKey(_method),
                initialValue: _method,
                decoration: _hubSubmitFormFieldDecoration(
                  labelText: MoneyComparatorStrings.t('mc_method_used', locale),
                ),
                dropdownColor: AppColors.surfaceElevated,
                items: [
                  for (final m in CorridorTransferMethod.values)
                    DropdownMenuItem(
                      value: m,
                      child: Text('${m.emoji} ${_methodLabel(m, locale)}'),
                    ),
                ],
                onChanged: _submitting
                    ? null
                    : (v) {
                        if (v == null) return;
                        setState(() => _method = v);
                        notifyDraftChanged();
                      },
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                MoneyComparatorStrings.t('mc_provider_name', locale),
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              AbsorbPointer(
                absorbing: _submitting,
                child: Autocomplete<String>(
                  optionsBuilder: (query) {
                    if (query.text.isEmpty) return knownProviders;
                    return knownProviders.where(
                      (p) =>
                          p.toLowerCase().contains(query.text.toLowerCase()),
                    );
                  },
                  onSelected: (v) {
                    _provider.text = v;
                    notifyDraftChanged();
                  },
                  fieldViewBuilder:
                      (context, controller, focusNode, onFieldSubmitted) {
                    if (_provider.text.isNotEmpty && controller.text.isEmpty) {
                      controller.text = _provider.text;
                    }
                    controller.addListener(
                      () => _provider.text = controller.text,
                    );
                    return TextField(
                      controller: controller,
                      focusNode: focusNode,
                      decoration: _hubSubmitFormFieldDecoration(
                        labelText: MoneyComparatorStrings.t(
                          'mc_provider_name',
                          locale,
                        ),
                        hintText: MoneyComparatorStrings.t(
                          'mc_provider_hint',
                          locale,
                        ),
                      ),
                      onChanged: (_) => notifyDraftChanged(),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _sectionHeader(locale, 'mc_submit_section_transfer_details'),
        GlassCard(
          padding: const EdgeInsets.all(AppSpacing.md),
          glowColor: _gold,
          glowIntensity: 0.05,
          borderRadius: AppSpacing.radiusMd,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _field(
                _amountSent,
                MoneyComparatorStrings.t('mc_amount_sent', locale),
                isInt: true,
                enabled: !_submitting,
              ),
              _field(
                _feePaid,
                MoneyComparatorStrings.t('mc_fee_paid', locale),
                enabled: !_submitting,
              ),
              _field(
                _recipientGot,
                MoneyComparatorStrings.format(
                  'mc_recipient_received',
                  locale,
                  params: {'currency': _countryCode},
                ),
                enabled: !_submitting,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _sectionHeader(locale, 'mc_submit_section_timing'),
        GlassCard(
          padding: const EdgeInsets.all(AppSpacing.md),
          glowColor: _gold,
          glowIntensity: 0.05,
          borderRadius: AppSpacing.radiusMd,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _field(
                _deliveryHours,
                MoneyComparatorStrings.t('mc_delivery_hours', locale),
                isInt: true,
                enabled: !_submitting,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        GlassPrimaryButton(
          label: _submitting
              ? MoneyComparatorStrings.t('mc_submitting', locale)
              : MoneyComparatorStrings.t('mc_submit_button', locale),
          expand: true,
          accentColor: _gold,
          icon: _submitting ? null : Icons.send_outlined,
          onPressed: _submitting ? null : _submit,
        ),
      ],
    );
  }

  Widget _field(
    TextEditingController c,
    String label, {
    bool isInt = false,
    bool enabled = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: TextField(
        controller: c,
        enabled: enabled,
        keyboardType: TextInputType.numberWithOptions(decimal: !isInt),
        inputFormatters: isInt
            ? [FilteringTextInputFormatter.digitsOnly]
            : [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))],
        decoration: _hubSubmitFormFieldDecoration(labelText: label),
      ),
    );
  }
}

/// Hub kit field styling — filled surface/glass + gold focus ring (Money vertical).
InputDecoration _hubSubmitFormFieldDecoration({
  required String labelText,
  String? hintText,
}) {
  final enabledBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
    borderSide: BorderSide(color: AppColors.glassBorder),
  );
  return InputDecoration(
    labelText: labelText,
    hintText: hintText,
    labelStyle: AppTypography.caption,
    hintStyle:
        AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
    filled: true,
    fillColor: AppColors.isLight ? AppColors.surface : AppColors.glassSurface,
    border: enabledBorder,
    enabledBorder: enabledBorder,
    disabledBorder: enabledBorder,
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      borderSide: BorderSide(
        color: AppColors.goldFamilyMain.withValues(alpha: 0.45),
      ),
    ),
  );
}

String _methodLabel(CorridorTransferMethod method, String locale) {
  return switch (method) {
    CorridorTransferMethod.bank =>
      MoneyComparatorStrings.t('mc_method_bank', locale),
    CorridorTransferMethod.mobileWallet =>
      MoneyComparatorStrings.t('mc_method_mobile_wallet', locale),
    CorridorTransferMethod.cashPickup =>
      MoneyComparatorStrings.t('mc_method_cash_pickup', locale),
  };
}

String _localizeSanityMessage(String message, String locale) {
  const sanityKeys = {
    'Enter the amount you sent.': 'mc_sanity_amount_sent',
    'Enter what the recipient received.': 'mc_sanity_recipient',
    'Fee cannot be negative.': 'mc_sanity_fee_negative',
    'Fee looks too high compared to amount sent.': 'mc_sanity_fee_high',
    'Check amounts — recipient total looks invalid.': 'mc_sanity_invalid_total',
    'Recipient amount seems unusually high — please double-check.':
        'mc_sanity_amount_high',
    'Delivery time should be between 0 and 720 hours.':
        'mc_sanity_delivery_hours',
  };
  final key = sanityKeys[message];
  if (key != null) return MoneyComparatorStrings.t(key, locale);
  return message;
}
