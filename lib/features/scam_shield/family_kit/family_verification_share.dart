import 'package:raabta/features/scam_shield/presentation/l10n/family_verification_kit_strings.dart';

/// Builds family-facing share payloads — must never include user secrets.
abstract final class FamilyVerificationShareBuilder {
  static String buildText(String recipientLocale) {
    final title = FamilyVerificationKitStrings.t(
      'ss_fvk_share_title',
      recipientLocale,
    );
    final intro = FamilyVerificationKitStrings.t(
      'ss_fvk_share_intro',
      recipientLocale,
    );
    final rule1 = FamilyVerificationKitStrings.t(
      'ss_fvk_share_rule1',
      recipientLocale,
    );
    final rule2 = FamilyVerificationKitStrings.t(
      'ss_fvk_share_rule2',
      recipientLocale,
    );
    final rule3 = FamilyVerificationKitStrings.t(
      'ss_fvk_share_rule3',
      recipientLocale,
    );
    final footer = FamilyVerificationKitStrings.t(
      'ss_fvk_share_footer',
      recipientLocale,
    );
    return [
      title,
      '',
      intro,
      '',
      '1. $rule1',
      '2. $rule2',
      '3. $rule3',
      '',
      footer,
    ].join('\n');
  }

  /// Fails closed if any sensitive fragment appears in outbound share text.
  static void assertShareSafe({
    required String shareText,
    String? hint,
    Iterable<String> contactNames = const [],
    Iterable<String> contactNumbers = const [],
    Iterable<String> forbiddenWords = const [],
  }) {
    final haystack = shareText.toLowerCase();
    void check(String? needle) {
      if (needle == null || needle.trim().isEmpty) return;
      if (haystack.contains(needle.trim().toLowerCase())) {
        throw StateError('Share text must not contain sensitive data');
      }
    }

    check(hint);
    for (final n in contactNames) {
      check(n);
    }
    for (final n in contactNumbers) {
      check(n);
    }
    for (final w in forbiddenWords) {
      check(w);
    }
  }
}
