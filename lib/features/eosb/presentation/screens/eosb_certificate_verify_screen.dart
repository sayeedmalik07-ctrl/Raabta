import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/features/eosb/domain/models/eosb_certificate_verification_result.dart';
import 'package:raabta/features/eosb/domain/rules/eosb_certificate_constants.dart';
import 'package:raabta/features/eosb/domain/services/eosb_certificate_id_generator.dart';
import 'package:raabta/features/eosb/presentation/l10n/eosb_certificate_strings.dart';
import 'package:raabta/features/eosb/providers/eosb_certificate_providers.dart';
import 'package:raabta/features/eosb/providers/eosb_providers.dart';
import 'package:url_launcher/url_launcher.dart';

/// Public EOSB Truth Certificate verification (Phase 2).
class EosbCertificateVerifyScreen extends ConsumerStatefulWidget {
  const EosbCertificateVerifyScreen({
    super.key,
    required this.certificateId,
    this.fingerprint,
  });

  final String certificateId;
  final String? fingerprint;

  static String route({
    required String certificateId,
    String? fingerprint,
  }) {
    final params = <String, String>{};
    if (fingerprint != null && fingerprint.isNotEmpty) {
      params['fingerprint'] = fingerprint;
    }
    final query = params.isEmpty
        ? ''
        : '?${params.entries.map((e) => '${e.key}=${Uri.encodeComponent(e.value)}').join('&')}';
    return '/eosb/verify/${Uri.encodeComponent(certificateId)}$query';
  }

  @override
  ConsumerState<EosbCertificateVerifyScreen> createState() =>
      _EosbCertificateVerifyScreenState();
}

class _EosbCertificateVerifyScreenState
    extends ConsumerState<EosbCertificateVerifyScreen> {
  EosbCertificateVerificationResult? _result;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _verify());
  }

  Future<void> _verify() async {
    setState(() {
      _loading = true;
    });
    final service = ref.read(eosbCertificateVerificationServiceProvider);
    final result = await service.verify(
      certificateId: widget.certificateId,
      calculationFingerprint: widget.fingerprint,
    );
    if (!mounted) return;
    setState(() {
      _result = result;
      _loading = false;
    });
  }

  Future<void> _openPublicPage(String? url) async {
    if (url == null || url.isEmpty) return;
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localeAsync = ref.watch(eosbLocaleProvider);

    return localeAsync.when(
      loading: () => const GlassScreenScaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => _scaffold('English'),
      data: (locale) => _scaffold(locale),
    );
  }

  Widget _scaffold(String locale) {
    final displayId = EosbCertificateIdGenerator.isValidStorageId(widget.certificateId)
        ? EosbCertificateIdGenerator.displayFormat(widget.certificateId)
        : widget.certificateId;

    return GlassScreenScaffold(
      title: EosbCertificateStrings.t('eosb_cert_verify_title', locale),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.pop(),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      body: ListView(
        children: [
          Text(
            EosbCertificateStrings.t('eosb_cert_verify_subtitle', locale),
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          GlassCard(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  EosbCertificateStrings.t('eosb_cert_certificate_id_heading', locale),
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                SelectableText(
                  displayId,
                  style: AppTypography.body.copyWith(
                    fontFamily: 'monospace',
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          if (_loading)
            const Center(child: CircularProgressIndicator())
          else if (_result != null)
            _VerificationResultCard(
              locale: locale,
              result: _result!,
              onOpenPublicPage: _openPublicPage,
              onRetry: _verify,
            ),
        ],
      ),
    );
  }
}

class _VerificationResultCard extends StatelessWidget {
  const _VerificationResultCard({
    required this.locale,
    required this.result,
    required this.onOpenPublicPage,
    required this.onRetry,
  });

  final String locale;
  final EosbCertificateVerificationResult result;
  final Future<void> Function(String? url) onOpenPublicPage;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (result.error != null) {
      return _statusCard(
        locale: locale,
        title: _errorTitle(result.error!, locale),
        body: EosbCertificateStrings.t('eosb_cert_verify_error_body', locale),
        accent: AppColors.errorBright,
        onRetry: onRetry,
      );
    }

    if (!result.found || result.record == null) {
      return _statusCard(
        locale: locale,
        title: EosbCertificateStrings.t('eosb_cert_verify_not_found', locale),
        body: EosbCertificateStrings.t('eosb_cert_verify_not_found_body', locale),
        accent: AppColors.accentGold,
      );
    }

    final record = result.record!;
    final status = record.certificateStatus;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _statusCard(
          locale: locale,
          title: _statusTitle(status, locale),
          body: _statusBody(status, locale, record.supersededBy),
          accent: _statusColor(status),
        ),
        const SizedBox(height: AppSpacing.md),
        GlassCard(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _detailRow(
                locale,
                'eosb_cert_verify_entitlement',
                '${record.estimatedEntitlement} ${record.currency}',
              ),
              _detailRow(
                locale,
                'eosb_cert_ruleset_version',
                record.eosbRulesetVersion,
              ),
              _detailRow(
                locale,
                'eosb_cert_legal_source',
                record.legalSourceSummary,
              ),
              _detailRow(
                locale,
                'eosb_cert_fingerprint_heading',
                _shortFingerprint(record.calculationFingerprint),
              ),
              if (record.registeredAt != null)
                _detailRow(
                  locale,
                  'eosb_cert_verify_registered_at',
                  record.registeredAt!.toUtc().toIso8601String(),
                ),
            ],
          ),
        ),
        if (result.fingerprintProvided) ...[
          const SizedBox(height: AppSpacing.md),
          GlassCard(
            padding: const EdgeInsets.all(AppSpacing.md),
            glowColor: result.fingerprintMatch == true
                ? AppColors.emeraldGlow
                : AppColors.errorBright,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result.fingerprintMatch == true
                      ? EosbCertificateStrings.t(
                          'eosb_cert_verify_hash_match',
                          locale,
                        )
                      : EosbCertificateStrings.t(
                          'eosb_cert_verify_hash_mismatch',
                          locale,
                        ),
                  style: AppTypography.subtitle.copyWith(
                    color: result.fingerprintMatch == true
                        ? AppColors.emeraldGlow
                        : AppColors.errorBright,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  EosbCertificateStrings.t(
                    'eosb_cert_verify_hash_notice',
                    locale,
                  ),
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
        if (result.signaturePresent) ...[
          const SizedBox(height: AppSpacing.md),
          GlassCard(
            padding: const EdgeInsets.all(AppSpacing.md),
            glowColor: result.signatureValid == true
                ? AppColors.emeraldGlow
                : AppColors.errorBright,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result.signatureValid == true
                      ? EosbCertificateStrings.t(
                          'eosb_cert_verify_signature_valid',
                          locale,
                        )
                      : EosbCertificateStrings.t(
                          'eosb_cert_verify_signature_invalid',
                          locale,
                        ),
                  style: AppTypography.subtitle.copyWith(
                    color: result.signatureValid == true
                        ? AppColors.emeraldGlow
                        : AppColors.errorBright,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  EosbCertificateStrings.t(
                    'eosb_cert_verify_signature_notice',
                    locale,
                  ),
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
        if (result.verificationUrl != null) ...[
          const SizedBox(height: AppSpacing.md),
          OutlinedButton.icon(
            onPressed: () => onOpenPublicPage(result.verificationUrl),
            icon: const Icon(Icons.open_in_new),
            label: Text(
              EosbCertificateStrings.t('eosb_cert_verify_open_web', locale),
            ),
          ),
        ],
      ],
    );
  }

  Widget _statusCard({
    required String locale,
    required String title,
    required String body,
    required Color accent,
    VoidCallback? onRetry,
  }) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      glowColor: accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.title.copyWith(color: accent)),
          const SizedBox(height: AppSpacing.sm),
          Text(
            body,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: AppSpacing.md),
            TextButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ],
      ),
    );
  }

  Widget _detailRow(String locale, String labelKey, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            EosbCertificateStrings.t(labelKey, locale),
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          Text(value, style: AppTypography.body),
        ],
      ),
    );
  }

  String _shortFingerprint(String fp) {
    if (fp.length <= 16) return fp;
    return '${fp.substring(0, 8)}…${fp.substring(fp.length - 8)}';
  }

  Color _statusColor(EosbCertificateTrustState status) {
    return switch (status) {
      EosbCertificateTrustState.registeredOnline => AppColors.emeraldGlow,
      EosbCertificateTrustState.revoked => AppColors.errorBright,
      EosbCertificateTrustState.superseded => AppColors.accentGold,
      EosbCertificateTrustState.visualEstimate => AppColors.textSecondary,
    };
  }

  String _statusTitle(EosbCertificateTrustState status, String locale) {
    return switch (status) {
      EosbCertificateTrustState.registeredOnline =>
        EosbCertificateStrings.t('eosb_cert_verify_status_registered', locale),
      EosbCertificateTrustState.revoked =>
        EosbCertificateStrings.t('eosb_cert_verify_status_revoked', locale),
      EosbCertificateTrustState.superseded =>
        EosbCertificateStrings.t('eosb_cert_verify_status_superseded', locale),
      EosbCertificateTrustState.visualEstimate =>
        EosbCertificateStrings.t('eosb_cert_verify_status_unknown', locale),
    };
  }

  String _statusBody(
    EosbCertificateTrustState status,
    String locale,
    String? supersededBy,
  ) {
    return switch (status) {
      EosbCertificateTrustState.registeredOnline =>
        EosbCertificateStrings.t('eosb_cert_verify_body_registered', locale),
      EosbCertificateTrustState.revoked =>
        EosbCertificateStrings.t('eosb_cert_verify_body_revoked', locale),
      EosbCertificateTrustState.superseded =>
        EosbCertificateStrings.format(
          'eosb_cert_verify_body_superseded',
          locale,
          {'id': supersededBy ?? '—'},
        ),
      EosbCertificateTrustState.visualEstimate =>
        EosbCertificateStrings.t('eosb_cert_verify_body_unknown', locale),
    };
  }

  String _errorTitle(String error, String locale) {
    return switch (error) {
      'rate_limit_exceeded' =>
        EosbCertificateStrings.t('eosb_cert_verify_rate_limit', locale),
      'invalid_certificate_id' =>
        EosbCertificateStrings.t('eosb_cert_verify_invalid_id', locale),
      'network_error' =>
        EosbCertificateStrings.t('eosb_cert_verify_network_error', locale),
      _ => EosbCertificateStrings.t('eosb_cert_verify_error_title', locale),
    };
  }
}
