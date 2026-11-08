import 'dart:math';

import 'package:raabta/features/eosb/presentation/l10n/eosb_certificate_strings.dart';

/// Presentation-layer formatting — never mutates snapshot values.
abstract final class EosbCertificateDisplayFormat {
  /// Whole-currency display aligned with [formatEosbCurrency] conventions.
  ///
  /// Negative amounts display as `"—"`. Zero displays as `QAR 0`.
  static String formatMoneyAmount(String currency, String rawAmount) {
    final parsed = double.tryParse(rawAmount.trim());
    if (parsed == null) {
      return EosbCertificateStrings.t('eosb_cert_unavailable');
    }
    if (parsed.isNaN) {
      return EosbCertificateStrings.t('eosb_cert_unavailable');
    }
    if (parsed < 0) {
      return EosbCertificateStrings.t('eosb_cert_unavailable');
    }
    final rounded = parsed.round();
    final formatted = rounded.abs().toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        );
    return '$currency $formatted';
  }

  /// Human-friendly service years — max one decimal, trailing zeros trimmed.
  static String formatServiceYears(String rawYears) {
    final parsed = double.tryParse(rawYears.trim());
    if (parsed == null || parsed.isNaN || parsed < 0) {
      return EosbCertificateStrings.t('eosb_cert_unavailable');
    }
    final rounded = (parsed * 10).round() / 10;
    if (rounded == rounded.roundToDouble()) {
      return rounded.round().toString();
    }
    return rounded.toStringAsFixed(1);
  }

  static String serviceDurationLabel({
    required String locale,
    required String? joiningDate,
    required String? lastWorkingDate,
    required String serviceYearsRaw,
    required int serviceDays,
  }) {
    if (joiningDate == null || lastWorkingDate == null) {
      return EosbCertificateStrings.t('eosb_cert_service_unavailable', locale);
    }
    final years = formatServiceYears(serviceYearsRaw);
    if (years == EosbCertificateStrings.t('eosb_cert_unavailable')) {
      return EosbCertificateStrings.t('eosb_cert_service_unavailable', locale);
    }
    return EosbCertificateStrings.format(
      'eosb_cert_service_duration',
      locale,
      {
        'years': years,
        'days': max(0, serviceDays).toString(),
      },
    );
  }

  /// Short human-readable fingerprint — first 16 hex chars in groups of 4.
  static String shortFingerprint(String hash) {
    final normalized = hash.trim();
    if (normalized.isEmpty) return '';
    final short = normalized.length >= 16
        ? normalized.substring(0, 16).toUpperCase()
        : normalized.toUpperCase();
    final buf = StringBuffer();
    for (var i = 0; i < short.length; i += 4) {
      if (i > 0) buf.write('-');
      buf.write(short.substring(i, min(i + 4, short.length)));
    }
    return buf.toString();
  }

  static String articleReferenceLabel(String locale, List<String> articles) {
    if (articles.isEmpty) return '';
    return EosbCertificateStrings.format(
      'eosb_cert_article',
      locale,
      {'articles': articles.join(', ')},
    );
  }

  static String calculationDateOnly(DateTime calculatedAt) {
    final local = calculatedAt.toLocal();
    final y = local.year.toString().padLeft(4, '0');
    final m = local.month.toString().padLeft(2, '0');
    final d = local.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}
