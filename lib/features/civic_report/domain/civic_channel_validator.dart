import 'package:raabta/features/civic_report/domain/civic_channel_type.dart';

/// Validates civic registry contact fields; disabled placeholders never become actions.
abstract final class CivicChannelValidator {
  static const placeholderToken = 'TODO_VERIFY';

  static bool isPlaceholder(String? value) {
    if (value == null) return true;
    final trimmed = value.trim();
    if (trimmed.isEmpty) return true;
    final upper = trimmed.toUpperCase();
    if (upper == placeholderToken) return true;
    if (upper.startsWith('TODO_')) return true;
    if (upper.contains(placeholderToken)) return true;
    return false;
  }

  static bool isValidHttpsUrl(String? value) {
    if (isPlaceholder(value)) return false;
    final uri = Uri.tryParse(value!.trim());
    if (uri == null) return false;
    if (uri.scheme.toLowerCase() != 'https') return false;
    if (uri.host.isEmpty) return false;
    return true;
  }

  static bool isValidPhoneTarget(String? value) {
    if (isPlaceholder(value)) return false;
    var digits = value!.trim();
    if (digits.startsWith('+')) {
      digits = digits.substring(1);
    }
    digits = digits.replaceAll(RegExp(r'[\s\-()]'), '');
    if (!RegExp(r'^\d+$').hasMatch(digits)) return false;
    if (digits.length < 3 || digits.length > 15) return false;
    return true;
  }

  static bool isValidDeepLinkScheme(String? value) {
    if (isPlaceholder(value)) return false;
    final trimmed = value!.trim();
    if (!trimmed.contains(':')) return false;
    if (trimmed.contains(' ')) return false;
    return true;
  }

  static bool isValidRaabtaRoute(String? value) {
    if (isPlaceholder(value)) return false;
    final trimmed = value!.trim();
    return trimmed.startsWith('/') && !trimmed.contains(' ');
  }

  static bool isValidLastVerified(String? value) {
    if (isPlaceholder(value)) return false;
    final trimmed = value!.trim();
    return RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(trimmed);
  }

  static bool contactActionsAllowed({
    required CivicVerificationStatus verificationStatus,
    required String lastVerified,
    required String sourceLabel,
  }) {
    if (verificationStatus != CivicVerificationStatus.verified) {
      return false;
    }
    if (!isValidLastVerified(lastVerified)) return false;
    if (isPlaceholder(sourceLabel)) return false;
    return true;
  }

  static String? enabledHttpsUrl({
    required CivicVerificationStatus verificationStatus,
    required String lastVerified,
    required String sourceLabel,
    required String? websiteUrl,
  }) {
    if (!contactActionsAllowed(
      verificationStatus: verificationStatus,
      lastVerified: lastVerified,
      sourceLabel: sourceLabel,
    )) {
      return null;
    }
    if (!isValidHttpsUrl(websiteUrl)) return null;
    return websiteUrl!.trim();
  }

  static String? enabledPhone({
    required CivicVerificationStatus verificationStatus,
    required String lastVerified,
    required String sourceLabel,
    required String? phone,
  }) {
    if (!contactActionsAllowed(
      verificationStatus: verificationStatus,
      lastVerified: lastVerified,
      sourceLabel: sourceLabel,
    )) {
      return null;
    }
    if (!isValidPhoneTarget(phone)) return null;
    return phone!.trim();
  }

  static String? enabledStoreUrl({
    required CivicVerificationStatus verificationStatus,
    required String lastVerified,
    required String sourceLabel,
    required String? storeUrl,
  }) {
    if (!contactActionsAllowed(
      verificationStatus: verificationStatus,
      lastVerified: lastVerified,
      sourceLabel: sourceLabel,
    )) {
      return null;
    }
    if (!isValidHttpsUrl(storeUrl)) return null;
    return storeUrl!.trim();
  }

  static String? enabledDeepLink({
    required CivicVerificationStatus verificationStatus,
    required String lastVerified,
    required String sourceLabel,
    required String? deepLinkScheme,
  }) {
    if (!contactActionsAllowed(
      verificationStatus: verificationStatus,
      lastVerified: lastVerified,
      sourceLabel: sourceLabel,
    )) {
      return null;
    }
    if (!isValidDeepLinkScheme(deepLinkScheme)) return null;
    return deepLinkScheme!.trim();
  }

  static String? enabledRaabtaRoute({
    required CivicVerificationStatus verificationStatus,
    required String lastVerified,
    required String sourceLabel,
    required String? raabtaRoute,
  }) {
    if (!contactActionsAllowed(
      verificationStatus: verificationStatus,
      lastVerified: lastVerified,
      sourceLabel: sourceLabel,
    )) {
      return null;
    }
    if (!isValidRaabtaRoute(raabtaRoute)) return null;
    return raabtaRoute!.trim();
  }
}
