import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:raabta/features/community/services/community_moderation_config.dart';

class ContentPrefilterResult {
  const ContentPrefilterResult.allow()
      : passed = true,
        blockMessage = null,
        messageCatalogKey = null,
        category = null;

  const ContentPrefilterResult.block({
    this.blockMessage,
    required this.messageCatalogKey,
    required this.category,
  }) : passed = false;

  final bool passed;
  final String? blockMessage;
  final String? messageCatalogKey;
  final String? category;
}

/// Fast local keyword/pattern filter — first pass before Claude moderation.
abstract final class CommunityContentPrefilter {
  static const _profanityPatterns = [
    r'\bf+u+c+k+\w*\b',
    r'\bs+h+i+t+\w*\b',
    r'\bb+i+t+c+h+\w*\b',
    r'\bc+u+n+t+\w*\b',
    r'\bn+i+g+g+\w*\b',
    r'\bf+a+g+\w*\b',
    r'\bk+u+t+t+a\b',
    r'\bm+a+d+a+r+c+h+o+d\b',
    r'\bb+h+o+s+d+i+k+e\b',
    r'\bc+h+u+t+i+y+a\b',
    r'\bg+a+n+d+u\b',
    r'\bl+a+n+d+\s*ch+o+d\b',
    r'\bh+a+r+a+m+i\b',
    r'\bk+a+f+i+r\b',
    r'\bk+a+a+f+i+r\b',
    r'\bsharmuta\b',
    r'\bkos\s*omak\b',
    r'\bkhara\b',
    r'\bgaand\b',
    r'\bchutiya\b',
    r'\bmadarchod\b',
    r'\bbehenchod\b',
    r'\bharami\b',
    r'\bkutta\b',
    r'\bsuwar\b',
    r'\bkanjar\b',
  ];

  static const _hateSlurPatterns = [
    r'\bkill\s+all\s+\w+\b',
    r'\bdeath\s+to\s+\w+\b',
    r'\ball\s+\w+\s+are\s+(animals|trash|garbage|dogs|pigs)\b',
  ];

  static ContentPrefilterResult validatePost(String text) {
    return _validate(
      text: text,
      minLength: CommunityModerationConfig.groupPostMinLength,
      maxLength: CommunityModerationConfig.groupPostMaxLength,
    );
  }

  static ContentPrefilterResult validateComment(String text) {
    return _validate(
      text: text,
      minLength: CommunityModerationConfig.groupCommentMinLength,
      maxLength: CommunityModerationConfig.groupCommentMaxLength,
    );
  }

  static ContentPrefilterResult _validate({
    required String text,
    required int minLength,
    required int maxLength,
  }) {
    final trimmed = text.trim();
    if (trimmed.length < minLength) {
      return const ContentPrefilterResult.block(
        messageCatalogKey: 'community_mod_block_empty',
        category: CommunityModerationConfig.categoryProfanity,
      );
    }
    if (trimmed.length > maxLength) {
      return const ContentPrefilterResult.block(
        messageCatalogKey: 'community_mod_block_too_long',
        category: CommunityModerationConfig.categoryProfanity,
      );
    }

    if (RegExp(r'(.)\1{8,}').hasMatch(trimmed)) {
      return const ContentPrefilterResult.block(
        messageCatalogKey: 'community_mod_block_spam_pattern',
        category: CommunityModerationConfig.categoryProfanity,
      );
    }

    final normalized = _normalize(trimmed);

    for (final pattern in _profanityPatterns) {
      if (RegExp(pattern, caseSensitive: false).hasMatch(normalized)) {
        return const ContentPrefilterResult.block(
          messageCatalogKey: 'community_mod_block_msg_profanity',
          category: CommunityModerationConfig.categoryProfanity,
        );
      }
    }

    for (final pattern in _hateSlurPatterns) {
      if (RegExp(pattern, caseSensitive: false).hasMatch(normalized)) {
        return const ContentPrefilterResult.block(
          messageCatalogKey: 'community_mod_block_msg_abusive',
          category: CommunityModerationConfig.categoryHateSpeechPerson,
        );
      }
    }

    return const ContentPrefilterResult.allow();
  }

  static String contentHash(String text) {
    final digest = sha256.convert(utf8.encode(text.trim().toLowerCase()));
    return digest.toString();
  }

  static String excerpt(String text, {int max = 120}) {
    final trimmed = text.trim();
    if (trimmed.length <= max) return trimmed;
    return '${trimmed.substring(0, max)}…';
  }

  static String _normalize(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^\p{L}\p{N}\s]', unicode: true), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

}
