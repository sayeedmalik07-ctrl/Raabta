import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_primary_button.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/core/widgets/truth_confidence_banner.dart';
import 'package:raabta/features/scam_shield/domain/scam_sensitive_input_mask.dart';
import 'package:raabta/features/scam_shield/domain/scam_shield_history_entry.dart';
import 'package:raabta/features/scam_shield/presentation/widgets/scam_shield_assessment_results_view.dart';
import 'package:raabta/features/scam_shield/providers/scam_shield_providers.dart';
import 'package:raabta/features/tenancy/domain/models/listing_verification_models.dart';
import 'package:raabta/features/tenancy/domain/services/listing_verification_service.dart';
import 'package:raabta/features/tenancy/presentation/l10n/tenancy_strings.dart';
import 'package:raabta/features/tenancy/presentation/widgets/tenancy_widgets.dart';
import 'package:raabta/features/tenancy/providers/tenancy_providers.dart';
import 'package:raabta/providers/visa_providers.dart';

/// Pre-lease listing check — ScamShield Level 0/1 + tenancy rule consistency.
class ListingVerificationScreen extends ConsumerStatefulWidget {
  const ListingVerificationScreen({super.key});

  @override
  ConsumerState<ListingVerificationScreen> createState() =>
      _ListingVerificationScreenState();
}

class _ListingVerificationScreenState
    extends ConsumerState<ListingVerificationScreen> {
  final _rentController = TextEditingController();
  final _depositController = TextEditingController();
  final _paymentController = TextEditingController();
  final _reservationController = TextEditingController();
  final _contactController = TextEditingController();
  final _propertyController = TextEditingController();
  final _messageController = TextEditingController();

  ListingVerificationResult? _result;
  bool _loading = false;

  @override
  void dispose() {
    _rentController.dispose();
    _depositController.dispose();
    _paymentController.dispose();
    _reservationController.dispose();
    _contactController.dispose();
    _propertyController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  ListingVerificationInput _inputFromForm() {
    return ListingVerificationInput(
      monthlyRent: double.tryParse(_rentController.text.trim()),
      depositRequested: double.tryParse(_depositController.text.trim()),
      paymentMethodNotes: _paymentController.text,
      reservationFeeNotes: _reservationController.text,
      contactInfo: _contactController.text,
      propertyDetails: _propertyController.text,
      landlordMessage: _messageController.text,
    );
  }

  Future<void> _runCheck(String locale) async {
    final input = _inputFromForm();
    if (!input.hasStructuredFields && !input.hasOpenEndedMessage) return;

    setState(() {
      _loading = true;
      _result = null;
    });

    try {
      final canUseAi = await scamShieldCanUseAi(ref);
      final result = await ListingVerificationService.verify(
        input: input,
        assessmentService: ref.read(scamShieldAssessmentServiceProvider),
        language: locale,
        userId: scamShieldUserId(ref),
        canUseAi: canUseAi,
      );

      final assessment = result.scamAssessment;
      if (assessment != null) {
        if (assessment.usedAi) {
          await scamShieldRecordAiUsage(ref);
        }
        final entry = ScamShieldHistoryEntry.fromAssessment(
          result: assessment,
          inputText: ScamSensitiveInputMask.mask(result.scanTextPreview),
        );
        await ref.read(scamShieldHistoryRepositoryProvider).saveEntry(entry);
        ref.invalidate(scamShieldHistoryProvider);
        ref.invalidate(scamShieldActiveAlertProvider);
      }

      if (mounted) setState(() => _result = result);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localeAsync = ref.watch(tenancyLocaleProvider);

    return localeAsync.when(
      loading: () => const GlassScreenScaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => const SizedBox.shrink(),
      data: (locale) {
        final uiLocale = AppLocale.normalize(ref.watch(userLanguageProvider));

        return GlassScreenScaffold(
          title: TenancyStrings.t('tenancy_listing_title', locale),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          padding: const EdgeInsets.all(AppSpacing.lg),
          body: ListView(
            children: [
              Text(
                TenancyStrings.t('tenancy_listing_subtitle', locale),
                style: AppTypography.bodySmall,
              ),
              const SizedBox(height: AppSpacing.md),
              TenancyDisclaimerBanner(locale: locale),
              const SizedBox(height: AppSpacing.sm),
              TruthConfidenceBanner(
                locale: uiLocale,
                state: TruthConfidenceState.unknown,
                text: TenancyStrings.t('tenancy_listing_framing', locale),
              ),
              const SizedBox(height: AppSpacing.lg),
              _Field(
                controller: _rentController,
                label: TenancyStrings.t('tenancy_listing_rent', locale),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
              _Field(
                controller: _depositController,
                label: TenancyStrings.t('tenancy_listing_deposit', locale),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
              _Field(
                controller: _paymentController,
                label: TenancyStrings.t('tenancy_listing_payment', locale),
                maxLines: 2,
              ),
              _Field(
                controller: _reservationController,
                label: TenancyStrings.t('tenancy_listing_reservation', locale),
                maxLines: 2,
              ),
              _Field(
                controller: _contactController,
                label: TenancyStrings.t('tenancy_listing_contact', locale),
                maxLines: 2,
              ),
              _Field(
                controller: _propertyController,
                label: TenancyStrings.t('tenancy_listing_property', locale),
                maxLines: 2,
              ),
              _Field(
                controller: _messageController,
                label: TenancyStrings.t('tenancy_listing_message', locale),
                maxLines: 5,
                hint: TenancyStrings.t('tenancy_listing_message_hint', locale),
              ),
              const SizedBox(height: AppSpacing.md),
              GlassPrimaryButton(
                label: _loading
                    ? '…'
                    : TenancyStrings.t('tenancy_listing_run', locale),
                icon: Icons.shield_outlined,
                expand: true,
                accentColor: AppColors.chipLease,
                onPressed: _loading ? null : () => _runCheck(uiLocale),
              ),
              if (_result != null) ...[
                const SizedBox(height: AppSpacing.lg),
                Text(
                  TenancyStrings.t('tenancy_listing_results', locale),
                  style: AppTypography.title,
                ),
                const SizedBox(height: AppSpacing.sm),
                for (final finding in _result!.tenancyFindings)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: TruthConfidenceBanner(
                      locale: uiLocale,
                      state: finding.kind ==
                              ListingTenancyFindingKind.registrationReminder
                          ? TruthConfidenceState.known
                          : TruthConfidenceState.possible,
                      text: TenancyStrings.format(
                        finding.messageKey,
                        locale,
                        finding.params,
                      ),
                    ),
                  ),
                if (_result!.scamAssessment != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  ScamShieldAssessmentResultsView(
                    result: _result!.scamAssessment!,
                    locale: uiLocale,
                    maskedInput: ScamSensitiveInputMask.mask(
                      _result!.scanTextPreview,
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.sm),
                TruthConfidenceBanner(
                  locale: uiLocale,
                  state: TruthConfidenceState.action,
                  text: TenancyStrings.t('tenancy_listing_action', locale),
                ),
                const SizedBox(height: AppSpacing.sm),
                OutlinedButton(
                  onPressed: () => context.push('/tenancy/lease-entry'),
                  child: Text(
                    TenancyStrings.t('tenancy_listing_lease_cta', locale),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.label,
    this.keyboardType,
    this.maxLines = 1,
    this.hint,
  });

  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;
  final int maxLines;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
        ),
        keyboardType: keyboardType,
        maxLines: maxLines,
        inputFormatters: keyboardType == TextInputType.number
            ? [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))]
            : null,
      ),
    );
  }
}
