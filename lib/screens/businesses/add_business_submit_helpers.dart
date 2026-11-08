import 'package:raabta/screens/businesses/l10n/businesses_strings.dart';

/// Returns false when location is empty or only the generic country name.
bool isSpecificBusinessLocation(String location) {
  final trimmed = location.trim();
  if (trimmed.isEmpty) return false;
  return trimmed.toLowerCase() != 'qatar';
}

/// Qatar numbers: optional +974 / 974 prefix and at least 8 local digits.
bool isValidQatarPhone(String phone) {
  final digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
  if (digits.length < 8) return false;
  if (digits.startsWith('974')) {
    return digits.length >= 11;
  }
  return digits.length >= 8;
}

bool isValidBusinessDescription(String description) {
  return description.trim().length >= 20;
}

/// Maps repository / Firestore failures to user-facing copy.
String mapBusinessSubmitError(Object error, String locale) {
  if (error is StateError) {
    final message = error.message;
    if (message.contains('Sign in required')) {
      return BusinessesStrings.t('error_sign_in_required', locale);
    }
    if (message.contains('Firebase is not initialized')) {
      return BusinessesStrings.t('error_firebase_unavailable', locale);
    }
    if (message.contains('duplicate_business_name')) {
      return BusinessesStrings.t('error_duplicate_listing', locale);
    }
  }

  final text = error.toString().toLowerCase();
  if (text.contains('permission-denied') || text.contains('permission denied')) {
    return BusinessesStrings.t('error_permission_denied', locale);
  }
  if (text.contains('network') || text.contains('unavailable')) {
    return BusinessesStrings.t('error_network', locale);
  }

  return BusinessesStrings.t('error_submit_generic', locale);
}
