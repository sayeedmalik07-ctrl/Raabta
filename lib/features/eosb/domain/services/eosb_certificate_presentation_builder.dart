import 'package:flutter/foundation.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/features/eosb/domain/models/eosb_certificate_models.dart';
import 'package:raabta/features/eosb/domain/rules/eosb_certificate_constants.dart';
import 'package:raabta/features/eosb/domain/services/eosb_certificate_display_format.dart';
import 'package:raabta/features/eosb/domain/services/eosb_certificate_id_generator.dart';
import 'package:raabta/features/eosb/presentation/l10n/eosb_certificate_strings.dart';

/// Phase 1: visual estimate. Phase 2: registered + QR. Phase 3: Raabta HMAC signature.
@immutable
class EosbCertificatePresentation {
  const EosbCertificatePresentation({
    required this.brandLabel,
    required this.certificateHeading,
    required this.entitlementHeading,
    required this.entitlementAmountDisplay,
    required this.title,
    required this.subtitle,
    required this.trustState,
    required this.cryptographicallySigned,
    required this.trustStateHeading,
    required this.trustStateLabel,
    required this.verificationNotice,
    required this.verificationUrl,
    required this.employmentSummaryTitle,
    required this.legalBasisTitle,
    required this.rulesetLabel,
    required this.certificateIdHeading,
    required this.fingerprintHeading,
    required this.breakdownSectionTitle,
    required this.certificateIdDisplay,
    required this.certificateIdStorage,
    required this.generatedAtLabel,
    required this.calculatedAtLabel,
    required this.totalEntitlementLabel,
    required this.basicSalaryLabel,
    required this.serviceDurationLabel,
    required this.inputCompletenessLabel,
    required this.estimateConfidenceLabel,
    required this.rulesetVersionLabel,
    required this.rulesetVersionValue,
    required this.legalSourceLabel,
    required this.articleReferenceLabel,
    required this.sourceVerifiedLabel,
    required this.legalSourceVerifiedDate,
    required this.disclaimer,
    required this.confidenceDisclaimer,
    required this.warningLines,
    required this.warningsSectionTitle,
    required this.breakdownLines,
    required this.fingerprintLabel,
    required this.fingerprintShort,
    required this.appVersionLabel,
    required this.locale,
    required this.isRtl,
  });

  final String brandLabel;
  final String certificateHeading;
  final String entitlementHeading;
  final String entitlementAmountDisplay;
  final String title;
  final String subtitle;
  final EosbCertificateTrustState trustState;
  final bool cryptographicallySigned;
  final String trustStateHeading;
  final String trustStateLabel;
  final String verificationNotice;
  final String? verificationUrl;
  final String employmentSummaryTitle;
  final String legalBasisTitle;
  final String rulesetLabel;
  final String certificateIdHeading;
  final String fingerprintHeading;
  final String breakdownSectionTitle;
  final String certificateIdDisplay;
  final String certificateIdStorage;
  final String generatedAtLabel;
  final String calculatedAtLabel;
  final String totalEntitlementLabel;
  final String basicSalaryLabel;
  final String serviceDurationLabel;
  final String inputCompletenessLabel;
  final String estimateConfidenceLabel;
  final String rulesetVersionLabel;
  final String rulesetVersionValue;
  final String legalSourceLabel;
  final String articleReferenceLabel;
  final String sourceVerifiedLabel;
  final String legalSourceVerifiedDate;
  final String disclaimer;
  final String confidenceDisclaimer;
  final List<String> warningLines;
  final String warningsSectionTitle;
  final List<EosbCertificateBreakdownLinePresentation> breakdownLines;
  final String fingerprintLabel;
  final String fingerprintShort;
  final String appVersionLabel;
  final String locale;
  final bool isRtl;

  /// Verification QR shown only when registered online with a public URL.
  bool get showVerificationQr =>
      trustState == EosbCertificateTrustState.registeredOnline &&
      verificationUrl != null &&
      verificationUrl!.isNotEmpty;
}

@immutable
class EosbCertificateBreakdownLinePresentation {
  const EosbCertificateBreakdownLinePresentation({
    required this.title,
    required this.amount,
    required this.estimatedSuffix,
    required this.isEstimated,
  });

  final String title;
  final String amount;
  final String estimatedSuffix;
  final bool isEstimated;
}

abstract final class EosbCertificatePresentationBuilder {
  static EosbCertificatePresentation build(
    EosbCertificateSnapshot snapshot,
    String locale, {
    EosbCertificateTrustState? trustStateOverride,
    String? verificationUrl,
    bool cryptographicallySigned = false,
  }) {
    final normalizedLocale = AppLocale.normalize(locale);
    final isRtl = AppLocale.isRtl(normalizedLocale);
    final trustState = trustStateOverride ?? snapshot.trustState;
    final signed = cryptographicallySigned &&
        trustState == EosbCertificateTrustState.registeredOnline;
    final completenessPct =
        ((double.tryParse(snapshot.inputCompletenessScore) ?? 0) * 100).round();

    final bandKey = switch (snapshot.certificateConfidenceBand) {
      EosbCertificateConfidenceBand.high => 'eosb_cert_confidence_high',
      EosbCertificateConfidenceBand.medium => 'eosb_cert_confidence_medium',
      EosbCertificateConfidenceBand.low => 'eosb_cert_confidence_low',
    };

    final entitlementDisplay = EosbCertificateDisplayFormat.formatMoneyAmount(
      snapshot.currency,
      snapshot.totalEntitlement,
    );

    final gratuityArticles = snapshot.legalProvenance.breakdownLegalRefs
        .where((ref) => ref.breakdownId == 'gratuity')
        .expand((ref) => ref.articles)
        .toList(growable: false);

    final fingerprintShort = EosbCertificateDisplayFormat.shortFingerprint(
      snapshot.calculationFingerprint,
    );

    final breakdownLines = snapshot.breakdown
        .map(
          (item) {
            final amountDisplay = EosbCertificateDisplayFormat.formatMoneyAmount(
              snapshot.currency,
              item.amount,
            );
            return EosbCertificateBreakdownLinePresentation(
              title: _breakdownTitle(item.id, normalizedLocale),
              amount: amountDisplay,
              estimatedSuffix: item.isEstimated
                  ? EosbCertificateStrings.t(
                      'eosb_cert_estimated_suffix',
                      normalizedLocale,
                    )
                  : '',
              isEstimated: item.isEstimated,
            );
          },
        )
        .toList(growable: false);

    final warningLines = snapshot.warnings
        .map((w) {
          final title =
              EosbCertificateStrings.eosbTitle(w.titleKey, normalizedLocale);
          return title == w.titleKey ? '' : title;
        })
        .where((line) => line.isNotEmpty)
        .toList(growable: false);

    final calcDate = EosbCertificateDisplayFormat.calculationDateOnly(
      snapshot.calculatedAt,
    );

    final serviceDurationLabel =
        EosbCertificateDisplayFormat.serviceDurationLabel(
      locale: normalizedLocale,
      joiningDate: snapshot.joiningDate,
      lastWorkingDate: snapshot.lastWorkingDate,
      serviceYearsRaw: snapshot.serviceYears,
      serviceDays: snapshot.serviceDays,
    );

    return EosbCertificatePresentation(
      brandLabel: EosbCertificateStrings.t('eosb_cert_brand', normalizedLocale),
      certificateHeading:
          EosbCertificateStrings.t('eosb_cert_heading', normalizedLocale),
      entitlementHeading: EosbCertificateStrings.t(
        'eosb_cert_entitlement_heading',
        normalizedLocale,
      ),
      entitlementAmountDisplay: entitlementDisplay,
      title: EosbCertificateStrings.t('eosb_cert_title', normalizedLocale),
      subtitle: EosbCertificateStrings.t('eosb_cert_subtitle', normalizedLocale),
      trustState: trustState,
      cryptographicallySigned: signed,
      trustStateHeading: _trustStateHeading(trustState, normalizedLocale, signed),
      trustStateLabel: _trustStateLabel(trustState, normalizedLocale, signed),
      verificationNotice: _verificationNotice(trustState, normalizedLocale, signed),
      verificationUrl: verificationUrl,
      employmentSummaryTitle: EosbCertificateStrings.t(
        'eosb_cert_employment_summary',
        normalizedLocale,
      ),
      legalBasisTitle:
          EosbCertificateStrings.t('eosb_cert_legal_basis', normalizedLocale),
      rulesetLabel:
          EosbCertificateStrings.t('eosb_cert_ruleset_label', normalizedLocale),
      certificateIdHeading: EosbCertificateStrings.t(
        'eosb_cert_certificate_id_heading',
        normalizedLocale,
      ),
      fingerprintHeading: EosbCertificateStrings.t(
        'eosb_cert_fingerprint_heading',
        normalizedLocale,
      ),
      breakdownSectionTitle: EosbCertificateStrings.t(
        'eosb_cert_breakdown_heading',
        normalizedLocale,
      ),
      certificateIdDisplay:
          EosbCertificateIdGenerator.displayFormat(snapshot.certificateId),
      certificateIdStorage: snapshot.certificateId,
      generatedAtLabel: EosbCertificateStrings.format(
        'eosb_cert_generated_at',
        normalizedLocale,
        {'date': snapshot.generatedAt.toUtc().toIso8601String()},
      ),
      calculatedAtLabel: EosbCertificateStrings.format(
        'eosb_cert_calculated_at',
        normalizedLocale,
        {'date': calcDate},
      ),
      totalEntitlementLabel: EosbCertificateStrings.format(
        'eosb_cert_total_entitlement',
        normalizedLocale,
        {'amount': entitlementDisplay},
      ),
      basicSalaryLabel: EosbCertificateStrings.format(
        'eosb_cert_basic_salary',
        normalizedLocale,
        {
          'amount': EosbCertificateDisplayFormat.formatMoneyAmount(
            snapshot.currency,
            snapshot.basicSalary,
          ),
        },
      ),
      serviceDurationLabel: serviceDurationLabel,
      inputCompletenessLabel: EosbCertificateStrings.format(
        'eosb_cert_input_completeness',
        normalizedLocale,
        {'percent': completenessPct.toString()},
      ),
      estimateConfidenceLabel: EosbCertificateStrings.format(
        'eosb_cert_estimate_confidence',
        normalizedLocale,
        {'band': EosbCertificateStrings.t(bandKey, normalizedLocale)},
      ),
      rulesetVersionLabel: EosbCertificateStrings.format(
        'eosb_cert_ruleset_version',
        normalizedLocale,
        {'version': snapshot.eosbRulesetVersion},
      ),
      rulesetVersionValue: snapshot.eosbRulesetVersion,
      legalSourceLabel: snapshot.legalProvenance.primaryLaw.lawIdentifier,
      articleReferenceLabel: EosbCertificateDisplayFormat.articleReferenceLabel(
        normalizedLocale,
        gratuityArticles,
      ),
      sourceVerifiedLabel: EosbCertificateStrings.format(
        'eosb_cert_source_verified',
        normalizedLocale,
        {'date': snapshot.legalProvenance.sourceVerifiedDate},
      ),
      legalSourceVerifiedDate: snapshot.legalProvenance.sourceVerifiedDate,
      disclaimer: EosbCertificateStrings.t(
        snapshot.legalProvenance.disclaimerKey,
        normalizedLocale,
      ),
      confidenceDisclaimer:
          EosbCertificateStrings.t('eosb_cert_confidence_disclaimer', normalizedLocale),
      warningLines: warningLines,
      warningsSectionTitle:
          EosbCertificateStrings.t('eosb_cert_warnings_heading', normalizedLocale),
      breakdownLines: breakdownLines,
      fingerprintLabel: EosbCertificateStrings.format(
        'eosb_cert_fingerprint',
        normalizedLocale,
        {'hash': fingerprintShort},
      ),
      fingerprintShort: fingerprintShort,
      appVersionLabel: EosbCertificateStrings.format(
        'eosb_cert_app_version',
        normalizedLocale,
        {
          'version': snapshot.appVersion,
          'build': snapshot.appBuildNumber,
        },
      ),
      locale: normalizedLocale,
      isRtl: isRtl,
    );
  }

  static String _breakdownTitle(String breakdownId, String locale) {
    final key = switch (breakdownId) {
      'gratuity' => 'eosb_gratuity',
      'leave' => 'eosb_leave',
      'notice' => 'eosb_notice',
      'return_ticket' => 'eosb_return_ticket',
      'family_ticket' => 'eosb_family_ticket',
      'pending_salary' => 'eosb_pending_salary',
      'overtime' => 'eosb_overtime',
      'other_benefits' => 'eosb_other_benefits',
      'annual_bonus' => 'eosb_annual_bonus',
      'commission' => 'eosb_commission',
      'retention_bonus' => 'eosb_retention_bonus',
      _ => breakdownId,
    };
    return EosbCertificateStrings.eosbTitle(key, locale);
  }

  static String _trustStateHeading(
    EosbCertificateTrustState state,
    String locale,
    bool signed,
  ) {
    if (signed && state == EosbCertificateTrustState.registeredOnline) {
      return EosbCertificateStrings.t('eosb_cert_trust_signed_heading', locale);
    }
    return switch (state) {
      EosbCertificateTrustState.registeredOnline =>
        EosbCertificateStrings.t('eosb_cert_trust_registered_heading', locale),
      EosbCertificateTrustState.revoked =>
        EosbCertificateStrings.t('eosb_cert_trust_revoked_heading', locale),
      EosbCertificateTrustState.superseded =>
        EosbCertificateStrings.t('eosb_cert_trust_superseded_heading', locale),
      EosbCertificateTrustState.visualEstimate =>
        EosbCertificateStrings.t('eosb_cert_trust_state_heading', locale),
    };
  }

  static String _trustStateLabel(
    EosbCertificateTrustState state,
    String locale,
    bool signed,
  ) {
    if (signed && state == EosbCertificateTrustState.registeredOnline) {
      return EosbCertificateStrings.t('eosb_cert_trust_signed', locale);
    }
    return switch (state) {
      EosbCertificateTrustState.registeredOnline =>
        EosbCertificateStrings.t('eosb_cert_trust_registered', locale),
      EosbCertificateTrustState.revoked =>
        EosbCertificateStrings.t('eosb_cert_trust_revoked', locale),
      EosbCertificateTrustState.superseded =>
        EosbCertificateStrings.t('eosb_cert_trust_superseded', locale),
      EosbCertificateTrustState.visualEstimate =>
        EosbCertificateStrings.t('eosb_cert_trust_visual', locale),
    };
  }

  static String _verificationNotice(
    EosbCertificateTrustState state,
    String locale,
    bool signed,
  ) {
    if (signed && state == EosbCertificateTrustState.registeredOnline) {
      return EosbCertificateStrings.t('eosb_cert_verification_signed', locale);
    }
    return switch (state) {
      EosbCertificateTrustState.registeredOnline =>
        EosbCertificateStrings.t('eosb_cert_verification_online', locale),
      EosbCertificateTrustState.revoked =>
        EosbCertificateStrings.t('eosb_cert_verification_revoked', locale),
      EosbCertificateTrustState.superseded =>
        EosbCertificateStrings.t('eosb_cert_verification_superseded', locale),
      EosbCertificateTrustState.visualEstimate =>
        EosbCertificateStrings.t('eosb_cert_verification_future', locale),
    };
  }
}
