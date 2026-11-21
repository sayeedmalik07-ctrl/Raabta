import 'package:raabta/features/community/presentation/l10n/community_strings.dart';
import 'package:raabta/features/community/services/community_moderation_config.dart';
import 'package:raabta/features/community/services/community_post_moderation_service.dart';
import 'package:raabta/features/community/widgets/community_reactive_locale.dart';

/// Resolved copy for a moderation hard block (Part A — no rewrite UI).
class CommunityModerationBlockCopy {
  const CommunityModerationBlockCopy({
    required this.message,
    this.guidelinesLine,
    this.blockCategory,
  });

  final String message;
  final String? guidelinesLine;

  /// Hard-block category from moderation (for Part B rephrase eligibility).
  final String? blockCategory;
}

abstract final class CommunityModerationBlockPresentation {
  static CommunityUiError uiErrorFromResult(PostModerationResult result) {
    if (result.allowed || result.requiresConfirmation) {
      return (catalogKey: null, rawMessage: null);
    }
    return (
      catalogKey: result.messageCatalogKey,
      rawMessage: result.blockMessage,
    );
  }

  static CommunityModerationBlockCopy resolveCopy({
    required PostModerationResult result,
    required String locale,
  }) {
    final error = uiErrorFromResult(result);
    final message = resolveCommunityUiError(error, locale) ??
        CommunityStrings.t('community_content_blocked', locale);

    final guidelinesLine = shouldShowGuidelinesHint(result.category)
        ? CommunityStrings.t('community_mod_block_guidelines_hint', locale)
        : null;

    return CommunityModerationBlockCopy(
      message: message,
      guidelinesLine: guidelinesLine,
      blockCategory: result.category,
    );
  }

  static bool offersRephrase(CommunityModerationBlockCopy? block) {
    if (block == null) return false;
    return CommunityModerationConfig.isRephraseEligibleCategory(
      block.blockCategory,
    );
  }

  static bool shouldShowGuidelinesHint(String? category) {
    if (category == null || category.isEmpty) return true;
    if (category == 'rate-limit') return false;
    if (CommunityModerationConfig.isWarnCategory(category)) return false;
    if (CommunityModerationConfig.isRephraseEligibleCategory(category)) {
      return false;
    }
    return true;
  }

  static String? catalogKeyForCategory(String? category) {
    return switch (category) {
      CommunityModerationConfig.categoryProfanity =>
        'community_mod_block_msg_profanity',
      CommunityModerationConfig.categoryHateSpeechPerson =>
        'community_mod_block_msg_abusive',
      CommunityModerationConfig.categoryHateSpeechReligion =>
        'community_mod_block_msg_religion',
      CommunityModerationConfig.categoryHateSpeechNationality =>
        'community_mod_block_msg_nationality',
      CommunityModerationConfig.categoryAntiStateContent =>
        'community_mod_block_msg_state',
      CommunityModerationConfig.categorySexualContent =>
        'community_mod_block_msg_sexual',
      CommunityModerationConfig.categoryInvestmentFinancialOpportunity =>
        'community_mod_block_msg_investment',
      CommunityModerationConfig.categoryFundraisingSolicitation =>
        'community_mod_block_msg_fundraising',
      'rate-limit' => 'community_mod_block_rate_limit',
      _ => 'community_content_blocked',
    };
  }
}
