import 'package:raabta/features/community/domain/lost_found_sensitive_text.dart';
import 'package:raabta/features/community/services/community_moderation_config.dart';

enum CommunitySubmissionKind { event, lostFound }

class CommunityPrefilterResult {
  const CommunityPrefilterResult.pass({
    this.suspiciousLinkDomains = const [],
  }) : passed = true, blockMessage = null;

  const CommunityPrefilterResult.block(this.blockMessage)
      : passed = false,
        suspiciousLinkDomains = const [];

  final bool passed;
  final String? blockMessage;

  /// Non-allowlisted domains found — passed through to Claude as extra signal.
  final List<String> suspiciousLinkDomains;
}

/// Local sanity/spam checks before Claude moderation or public posting.
abstract final class CommunitySubmissionPrefilter {
  static const _spamPhrases = [
    'click here now',
    'free money',
    'crypto giveaway',
    'whatsapp only deal',
    'earn from home',
    'double your income',
    'work from home guaranteed',
    'send bank details',
    'wire transfer now',
  ];

  static const _linkAllowlist = [
    'qatar.com',
    'gov.qa',
    'edu.qa',
    'qatarairways.com',
    'qatarliving.com',
    'google.com',
    'goo.gl',
    'maps.app.goo.gl',
    'facebook.com',
    'instagram.com',
    'eventbrite.com',
    'ticketmaster',
    'raabtaone.com',
    'raabta.app',
  ];

  static CommunityPrefilterResult validateEvent({
    required String title,
    required String description,
    required String location,
  }) {
    return _validate(
      kind: CommunitySubmissionKind.event,
      title: title,
      description: description,
      location: location,
      titleMin: CommunityModerationConfig.eventTitleMinLength,
      descriptionMin: CommunityModerationConfig.eventDescriptionMinLength,
      locationMin: CommunityModerationConfig.eventLocationMinLength,
    );
  }

  static CommunityPrefilterResult validateLostFound({
    required String title,
    required String itemDescription,
    required String location,
    required String contactInfo,
    String? itemType,
    String? marks,
    String? hiddenDetail,
  }) {
    final base = _validate(
      kind: CommunitySubmissionKind.lostFound,
      title: title,
      description: itemDescription,
      location: location,
      titleMin: CommunityModerationConfig.lostFoundTitleMinLength,
      descriptionMin: CommunityModerationConfig.lostFoundDescriptionMinLength,
      locationMin: CommunityModerationConfig.lostFoundLocationMinLength,
    );
    if (!base.passed) return base;

    if (contactInfo.trim().length <
        CommunityModerationConfig.lostFoundContactMinLength) {
      return const CommunityPrefilterResult.block(
        'Please add a valid WhatsApp or phone contact so others can reach you.',
      );
    }

    if (LostFoundSensitiveText.anyFieldContainsProhibited([
      title,
      itemDescription,
      location,
      if (itemType != null && itemType.trim().isNotEmpty) itemType,
      if (marks != null && marks.trim().isNotEmpty) marks,
      if (hiddenDetail != null && hiddenDetail.trim().isNotEmpty) hiddenDetail,
    ])) {
      return const CommunityPrefilterResult.block(
        'community_lf_err_sensitive_numbers',
      );
    }

    return base;
  }

  static CommunityPrefilterResult _validate({
    required CommunitySubmissionKind kind,
    required String title,
    required String description,
    required String location,
    required int titleMin,
    required int descriptionMin,
    required int locationMin,
  }) {
    final t = title.trim();
    final d = description.trim();
    final l = location.trim();

    if (t.isEmpty || d.isEmpty || l.isEmpty) {
      return CommunityPrefilterResult.block(
        kind == CommunitySubmissionKind.event
            ? 'Please complete the title, description, and location.'
            : 'Please complete the title, description, location, and contact.',
      );
    }

    if (t.length < titleMin) {
      return CommunityPrefilterResult.block(
        'Title is too short — add a clearer summary (${titleMin}+ characters).',
      );
    }
    if (d.length < descriptionMin) {
      return CommunityPrefilterResult.block(
        'Description is too short — add a few more helpful details.',
      );
    }
    if (l.length < locationMin) {
      return CommunityPrefilterResult.block(
        'Please add a clearer location.',
      );
    }

    if (t.length > CommunityModerationConfig.maxTitleLength ||
        d.length > CommunityModerationConfig.maxDescriptionLength ||
        l.length > CommunityModerationConfig.maxLocationLength) {
      return const CommunityPrefilterResult.block(
        'Submission is too long. Please shorten and try again.',
      );
    }

    final blob = '$t\n$d\n$l'.toLowerCase();

    if (_isRepeatedCharacterSpam(blob)) {
      return const CommunityPrefilterResult.block(
        'This looks like spam. Please write a normal description.',
      );
    }

    if (_isShoutingSpam(t) || _isShoutingSpam(d)) {
      return const CommunityPrefilterResult.block(
        'Please avoid all-caps text — rewrite your submission normally.',
      );
    }

    for (final phrase in _spamPhrases) {
      if (blob.contains(phrase)) {
        return const CommunityPrefilterResult.block(
          'This submission looks like spam and was not sent for review.',
        );
      }
    }

    final links = _extractUrls('$t $d $l');
    if (links.length > 3) {
      return const CommunityPrefilterResult.block(
        'Too many links in one post. Keep one or two relevant links only.',
      );
    }

    final suspicious = _suspiciousDomains(links);

    return CommunityPrefilterResult.pass(suspiciousLinkDomains: suspicious);
  }

  static bool _isRepeatedCharacterSpam(String text) {
    return RegExp(r'(.)\1{6,}').hasMatch(text);
  }

  static bool _isShoutingSpam(String text) {
    if (text.length < 20) return false;
    final letters = text.replaceAll(RegExp(r'[^A-Za-z]'), '');
    if (letters.length < 12) return false;
    final upper = letters.replaceAll(RegExp(r'[^A-Z]'), '').length;
    return upper / letters.length > 0.75;
  }

  static List<String> _extractUrls(String text) {
    final matches = RegExp(
      r'https?://[^\s]+|www\.[^\s]+',
      caseSensitive: false,
    ).allMatches(text);
    return matches.map((m) => m.group(0)!).toList();
  }

  static List<String> _suspiciousDomains(List<String> urls) {
    final suspicious = <String>[];
    for (final raw in urls) {
      final uri = Uri.tryParse(raw.startsWith('http') ? raw : 'https://$raw');
      if (uri == null || uri.host.isEmpty) continue;
      final host = uri.host.toLowerCase();
      final allowed = _linkAllowlist.any(
        (entry) => host == entry || host.endsWith('.$entry'),
      );
      if (!allowed) suspicious.add(host);
    }
    return suspicious;
  }
}
