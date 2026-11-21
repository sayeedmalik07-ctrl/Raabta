import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/features/eosb/presentation/l10n/eosb_certificate_strings.dart';
import 'package:raabta/features/eosb/presentation/l10n/eosb_strings.dart';
import 'package:raabta/features/eosb/providers/eosb_certificate_providers.dart';
import 'package:raabta/features/eosb/providers/eosb_providers.dart';
import 'package:raabta/features/eosb/services/eosb_analytics_service.dart';
import 'package:raabta/features/eosb/services/eosb_certificate_generation_service.dart';
import 'package:raabta/features/eosb/services/eosb_pdf_service.dart';
import 'package:raabta/features/eosb/services/eosb_truth_certificate_pdf_service.dart';
import 'package:raabta/providers/app_update_provider.dart';

class GenerateDocumentsScreen extends ConsumerStatefulWidget {
  const GenerateDocumentsScreen({super.key});

  @override
  ConsumerState<GenerateDocumentsScreen> createState() =>
      _GenerateDocumentsScreenState();
}

class _GenerateDocumentsScreenState
    extends ConsumerState<GenerateDocumentsScreen> {
  bool _busy = false;
  bool _restoringResult = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _ensureCalculationResult());
  }

  /// After hot restart only input is cached — restore result so document tiles work.
  Future<void> _ensureCalculationResult() async {
    if (!mounted) return;
    final eosbState = ref.read(eosbProvider);
    if (eosbState.result != null || eosbState.input.basicSalary <= 0) return;

    setState(() => _restoringResult = true);
    try {
      await ref.read(eosbProvider.notifier).calculate(saveHistory: false);
    } finally {
      if (mounted) setState(() => _restoringResult = false);
    }
  }

  void _promptCalculateFirst(String locale) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(EosbStrings.t('eosb_empty_result_desc', locale)),
        action: SnackBarAction(
          label: EosbStrings.t('eosb_calculate_cta', locale),
          onPressed: () => context.push('/eosb/employee-info'),
        ),
      ),
    );
  }

  Future<void> _runGuarded(
    String locale,
    Future<void> Function() action,
  ) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await action();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localeAsync = ref.watch(eosbLocaleProvider);
    final eosbState = ref.watch(eosbProvider);
    final result = eosbState.result;
    final pdf = ref.watch(eosbPdfServiceProvider);
    final certPdf = ref.watch(eosbTruthCertificatePdfServiceProvider);
    final certGen = ref.watch(eosbCertificateGenerationServiceProvider);

    return localeAsync.when(
      loading: () => const GlassScreenScaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => const SizedBox.shrink(),
      data: (locale) => GlassScreenScaffold(
        title: EosbStrings.t('eosb_documents', locale),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _busy ? null : () => context.pop(),
        ),
        padding: const EdgeInsets.all(AppSpacing.lg),
        body: Stack(
          children: [
            ListView(
              children: [
                if (result == null) ...[
                  GlassCard(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    glowColor: AppColors.accentGold,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          EosbStrings.t('eosb_empty_result_title', locale),
                          style: AppTypography.subtitle.copyWith(
                            color: AppColors.accentGold,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          EosbStrings.t('eosb_empty_result_desc', locale),
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        OutlinedButton(
                          onPressed: _busy
                              ? null
                              : () => context.push('/eosb/employee-info'),
                          child: Text(EosbStrings.t('eosb_calculate_cta', locale)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
                _DocTile(
                  title: EosbCertificateStrings.t(
                    'eosb_cert_register_online',
                    locale,
                  ),
                  subtitle: result == null
                      ? null
                      : EosbCertificateStrings.t(
                          'eosb_cert_verification_online',
                          locale,
                        ),
                  enabled: !_busy,
                  onTap: () {
                    if (result == null) {
                      _promptCalculateFirst(locale);
                      return;
                    }
                    _runGuarded(
                      locale,
                      () => _registerCertificate(
                        locale: locale,
                        eosbState: eosbState,
                        certGen: certGen,
                      ),
                    );
                  },
                ),
                _DocTile(
                  title: EosbCertificateStrings.t(
                    'eosb_cert_generate_pdf',
                    locale,
                  ),
                  enabled: !_busy,
                  onTap: () {
                    if (result == null) {
                      _promptCalculateFirst(locale);
                      return;
                    }
                    _runGuarded(
                      locale,
                      () => _generateTruthCertificatePdf(
                        locale: locale,
                        eosbState: eosbState,
                        certGen: certGen,
                        certPdf: certPdf,
                      ),
                    );
                  },
                ),
                _DocTile(
                  title: 'Personal Calculation Report (PDF)',
                  enabled: !_busy,
                  onTap: () {
                    if (result == null) {
                      _promptCalculateFirst(locale);
                      return;
                    }
                    _runGuarded(
                      locale,
                      () => _generatePersonalReport(
                        locale: locale,
                        eosbState: eosbState,
                        pdf: pdf,
                      ),
                    );
                  },
                ),
                _DocTile(
                  title: 'Employer Dispute Letter (English)',
                  subtitle: 'Generate via AI Assistant',
                  enabled: !_busy,
                  onTap: () => context.push('/eosb/ai-assistant'),
                ),
                _DocTile(
                  title: 'Settlement Review Letter',
                  subtitle: 'Generate via AI Assistant',
                  enabled: !_busy,
                  onTap: () => context.push('/eosb/ai-assistant'),
                ),
                _DocTile(
                  title: 'Labour Complaint Draft',
                  subtitle: 'ADLSA 16008 — informational template',
                  enabled: !_busy,
                  onTap: () => context.push('/eosb/ai-assistant'),
                ),
              ],
            ),
            if (_busy || _restoringResult)
              const Positioned.fill(
                child: ColoredBox(
                  color: Color(0x44000000),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<EosbCertificateBundle> _resolveBundle({
    required EosbState eosbState,
    required EosbCertificateGenerationService certGen,
    required String locale,
    required String appVersion,
    required String appBuildNumber,
  }) async {
    final base = certGen.build(
      result: eosbState.result!,
      input: eosbState.input,
      appVersion: appVersion,
      appBuildNumber: appBuildNumber,
      locale: locale,
    );
    if (!mounted) return base;
    final cached =
        registeredCertificateCacheEntry(ref, base.snapshot.certificateId);
    if (cached == null) return base;
    return certGen.buildRegistered(
      snapshot: base.snapshot,
      locale: locale,
      verificationUrl: cached.verificationUrl,
      cryptographicallySigned: cached.cryptographicallySigned,
    );
  }

  Future<void> _registerCertificate({
    required String locale,
    required EosbState eosbState,
    required EosbCertificateGenerationService certGen,
  }) async {
    try {
      final packageInfo = await ref.read(packageInfoProvider.future);
      if (!mounted) return;
      final base = certGen.build(
        result: eosbState.result!,
        input: eosbState.input,
        appVersion: packageInfo.version,
        appBuildNumber: packageInfo.buildNumber,
        locale: locale,
      );
      if (!mounted) return;
      final outcome = await registerEosbCertificateBundle(
        ref: ref,
        snapshot: base.snapshot,
        locale: locale,
      );
      if (!mounted) return;
      if (outcome.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              EosbCertificateStrings.t('eosb_cert_register_success', locale),
            ),
          ),
        );
      } else {
        final message = switch (outcome.error) {
          'rate_limit_exceeded' =>
            EosbCertificateStrings.t('eosb_cert_register_rate_limit', locale),
          'signing_unavailable' =>
            EosbCertificateStrings.t('eosb_cert_register_signing', locale),
          'network_error' =>
            EosbCertificateStrings.t('eosb_cert_verify_network_error', locale),
          _ => EosbCertificateStrings.t('eosb_cert_register_error', locale),
        };
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            EosbCertificateStrings.t('eosb_cert_register_error', locale),
          ),
        ),
      );
    }
  }

  Future<void> _generateTruthCertificatePdf({
    required String locale,
    required EosbState eosbState,
    required EosbCertificateGenerationService certGen,
    required EosbTruthCertificatePdfService certPdf,
  }) async {
    try {
      final packageInfo = await ref.read(packageInfoProvider.future);
      if (!mounted) return;
      final bundle = await _resolveBundle(
        eosbState: eosbState,
        certGen: certGen,
        locale: locale,
        appVersion: packageInfo.version,
        appBuildNumber: packageInfo.buildNumber,
      );
      if (!mounted) return;
      final file = await certPdf.generate(presentation: bundle.presentation);
      EosbAnalyticsService().trackDocumentGenerated(
        type: 'eosb_truth_certificate_pdf',
      );
      if (!mounted) return;
      await certPdf.share(file, locale: locale);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            EosbCertificateStrings.t('eosb_cert_error_pdf', locale),
          ),
        ),
      );
    }
  }

  Future<void> _generatePersonalReport({
    required String locale,
    required EosbState eosbState,
    required EosbPdfService pdf,
  }) async {
    try {
      final file = await pdf.generateReport(
        result: eosbState.result!,
        locale: locale,
      );
      EosbAnalyticsService().trackDocumentGenerated(type: 'eosb_pdf');
      if (!mounted) return;
      await pdf.shareReport(file, locale: locale);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            EosbCertificateStrings.t('eosb_cert_error_pdf', locale),
          ),
        ),
      );
    }
  }
}

class _DocTile extends StatelessWidget {
  const _DocTile({
    required this.title,
    this.subtitle,
    required this.onTap,
    this.enabled = true,
  });

  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.description_outlined),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: const Icon(Icons.chevron_right),
      enabled: enabled,
      onTap: enabled ? onTap : null,
    );
  }
}
