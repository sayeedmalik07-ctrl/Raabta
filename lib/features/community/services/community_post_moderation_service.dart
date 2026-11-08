import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:raabta/features/community/services/community_content_prefilter.dart';
import 'package:raabta/features/community/services/community_fundraising_moderation_prefilter.dart';
import 'package:raabta/features/community/services/community_investment_moderation_prefilter.dart';
import 'package:raabta/features/community/presentation/community_moderation_block_presentation.dart';
import 'package:raabta/features/community/services/community_moderation_config.dart';
import 'package:raabta/services/firebase_service.dart';

class PostModerationResult {
  const PostModerationResult.allowed({this.proceededAfterInvestmentWarning = false})
      : allowed = true,
        requiresConfirmation = false,
        blockMessage = null,
        messageCatalogKey = null,
        category = null,
        layer = null;

  const PostModerationResult.blocked({
    this.blockMessage,
    this.messageCatalogKey,
    required this.category,
    required this.layer,
  })  : allowed = false,
        requiresConfirmation = false,
        proceededAfterInvestmentWarning = false;

  const PostModerationResult.requiresConfirmation({
    required this.category,
    required this.layer,
  })  : allowed = false,
        requiresConfirmation = true,
        blockMessage = null,
        messageCatalogKey = null,
        proceededAfterInvestmentWarning = false;

  final bool allowed;
  final bool requiresConfirmation;
  final bool proceededAfterInvestmentWarning;
  final String? blockMessage;
  final String? messageCatalogKey;
  final String? category;
  final String? layer;
}

typedef ClaudeContentClassifier = Future<({bool allowed, String? category})>
    Function({
  required String text,
  required String language,
  String contentType,
});

/// Two-layer moderation: local prefilter → Claude classification → log.
class CommunityPostModerationService {
  CommunityPostModerationService({
    FirebaseFirestore? firestore,
    required ClaudeContentClassifier classifyWithClaude,
  })  : _db = firestore ?? FirebaseFirestore.instance,
        _classifyWithClaude = classifyWithClaude;

  final FirebaseFirestore _db;
  final ClaudeContentClassifier _classifyWithClaude;

  Future<PostModerationResult> moderatePost({
    required String text,
    required String language,
    required String userId,
    String? groupId,
    bool isComment = false,
    bool investmentWarningAcknowledged = false,
    bool fundraisingWarningAcknowledged = false,
  }) {
    return moderateContent(
      text: text,
      language: language,
      userId: userId,
      contentType: isComment ? 'group_comment' : 'group_post',
      groupId: groupId,
      useCommentLength: isComment,
      investmentWarningAcknowledged: investmentWarningAcknowledged,
      fundraisingWarningAcknowledged: fundraisingWarningAcknowledged,
    );
  }

  /// Shared moderation entry point for group posts, Ask Qatar Q&A, etc.
  Future<PostModerationResult> moderateContent({
    required String text,
    required String language,
    required String userId,
    required String contentType,
    String? groupId,
    bool useCommentLength = false,
    bool investmentWarningAcknowledged = false,
    bool fundraisingWarningAcknowledged = false,
  }) async {
    if (investmentWarningAcknowledged) {
      return _allowAfterAcknowledgedWarning(
        userId: userId,
        contentType: contentType,
        text: text,
        language: language,
        groupId: groupId,
        category: CommunityModerationConfig.categoryInvestmentFinancialOpportunity,
      );
    }

    if (fundraisingWarningAcknowledged) {
      return _allowAfterAcknowledgedWarning(
        userId: userId,
        contentType: contentType,
        text: text,
        language: language,
        groupId: groupId,
        category: CommunityModerationConfig.categoryFundraisingSolicitation,
        proceededAfterInvestmentWarning: false,
      );
    }

    final pre = useCommentLength
        ? CommunityContentPrefilter.validateComment(text)
        : CommunityContentPrefilter.validatePost(text);

    if (!pre.passed) {
      await _logDecision(
        userId: userId,
        contentType: contentType,
        text: text,
        language: language,
        allowed: false,
        layer: 'local',
        category: pre.category,
        groupId: groupId,
      );
      return PostModerationResult.blocked(
        blockMessage: pre.blockMessage,
        messageCatalogKey: pre.messageCatalogKey,
        category: pre.category,
        layer: 'local',
      );
    }

    if (CommunityInvestmentModerationPrefilter.shouldWarn(text)) {
      return _warnFromLocal(
        userId: userId,
        contentType: contentType,
        text: text,
        language: language,
        groupId: groupId,
        category: CommunityModerationConfig.categoryInvestmentFinancialOpportunity,
      );
    }

    if (CommunityFundraisingModerationPrefilter.shouldWarn(text)) {
      return _warnFromLocal(
        userId: userId,
        contentType: contentType,
        text: text,
        language: language,
        groupId: groupId,
        category: CommunityModerationConfig.categoryFundraisingSolicitation,
      );
    }

    final ai = await _classifyWithClaude(
      text: text,
      language: language,
      contentType: contentType,
    );

    if (!ai.allowed && ai.category == 'rate-limit') {
      return const PostModerationResult.blocked(
        messageCatalogKey: 'community_mod_block_rate_limit',
        category: 'rate-limit',
        layer: 'local',
      );
    }

    if (!ai.allowed && CommunityModerationConfig.isWarnCategory(ai.category)) {
      return _warnFromClaude(
        userId: userId,
        contentType: contentType,
        text: text,
        language: language,
        groupId: groupId,
        category: ai.category!,
      );
    }

    await _logDecision(
      userId: userId,
      contentType: contentType,
      text: text,
      language: language,
      allowed: ai.allowed,
      layer: 'claude',
      category: ai.category,
      groupId: groupId,
    );

    if (!ai.allowed) {
      return PostModerationResult.blocked(
        messageCatalogKey:
            CommunityModerationBlockPresentation.catalogKeyForCategory(
          ai.category,
        ),
        category: ai.category,
        layer: 'claude',
      );
    }

    return const PostModerationResult.allowed();
  }

  Future<void> logModerationWarningCancelled({
    required String category,
    required String text,
    required String language,
    required String userId,
    required String contentType,
    String? groupId,
    String? layer,
  }) async {
    await _logDecision(
      userId: userId,
      contentType: contentType,
      text: text,
      language: language,
      allowed: false,
      layer: layer ?? 'local',
      category: category,
      groupId: groupId,
      userProceededAfterWarning: false,
    );
  }

  Future<void> logInvestmentWarningCancelled({
    required String text,
    required String language,
    required String userId,
    required String contentType,
    String? groupId,
    String? layer,
  }) {
    return logModerationWarningCancelled(
      category: CommunityModerationConfig.categoryInvestmentFinancialOpportunity,
      text: text,
      language: language,
      userId: userId,
      contentType: contentType,
      groupId: groupId,
      layer: layer,
    );
  }

  Future<PostModerationResult> _allowAfterAcknowledgedWarning({
    required String userId,
    required String contentType,
    required String text,
    required String language,
    required String category,
    String? groupId,
    bool proceededAfterInvestmentWarning = true,
  }) async {
    await _logDecision(
      userId: userId,
      contentType: contentType,
      text: text,
      language: language,
      allowed: true,
      layer: 'acknowledged',
      category: category,
      groupId: groupId,
      userProceededAfterWarning: true,
    );
    return PostModerationResult.allowed(
      proceededAfterInvestmentWarning: proceededAfterInvestmentWarning,
    );
  }

  Future<PostModerationResult> _warnFromLocal({
    required String userId,
    required String contentType,
    required String text,
    required String language,
    required String category,
    String? groupId,
  }) async {
    await _logDecision(
      userId: userId,
      contentType: contentType,
      text: text,
      language: language,
      allowed: false,
      layer: 'local',
      category: category,
      groupId: groupId,
      userProceededAfterWarning: false,
    );
    return _resultForWarnCategory(category: category, layer: 'local');
  }

  Future<PostModerationResult> _warnFromClaude({
    required String userId,
    required String contentType,
    required String text,
    required String language,
    required String category,
    String? groupId,
  }) async {
    await _logDecision(
      userId: userId,
      contentType: contentType,
      text: text,
      language: language,
      allowed: false,
      layer: 'claude',
      category: category,
      groupId: groupId,
      userProceededAfterWarning: false,
    );
    return _resultForWarnCategory(category: category, layer: 'claude');
  }

  PostModerationResult _resultForWarnCategory({
    required String category,
    required String layer,
  }) {
    if (CommunityModerationConfig.moderationWarnCategoriesUseSoftInterstitial) {
      return PostModerationResult.requiresConfirmation(
        category: category,
        layer: layer,
      );
    }
    return PostModerationResult.blocked(
      messageCatalogKey:
          CommunityModerationBlockPresentation.catalogKeyForCategory(category),
      category: category,
      layer: layer,
    );
  }

  static ({bool allowed, String? category}) parseClaudeJson(String reply) {
    try {
      final start = reply.indexOf('{');
      final end = reply.lastIndexOf('}');
      if (start < 0 || end <= start) {
        return (allowed: false, category: CommunityModerationConfig.categoryProfanity);
      }
      final json =
          jsonDecode(reply.substring(start, end + 1)) as Map<String, dynamic>;
      final allowed = json['allowed'] as bool? ?? false;
      final category = json['category'] as String?;
      if (!allowed &&
          category != null &&
          CommunityModerationConfig.moderationAiCategories.contains(category)) {
        return (allowed: false, category: category);
      }
      if (!allowed) {
        return (
          allowed: false,
          category: category ?? CommunityModerationConfig.categoryProfanity,
        );
      }
      return (allowed: true, category: null);
    } catch (_) {
      return (allowed: false, category: CommunityModerationConfig.categoryProfanity);
    }
  }

  static String buildClaudePrompt({
    required String text,
    required String language,
    String contentType = 'community_post',
  }) {
    final categories = CommunityModerationConfig.moderationAiCategories
        .map((c) => '"$c"')
        .join(', ');

    final contextNote = contentType.startsWith('ask_qatar')
        ? '\nThis is an Ask Qatar Q&A submission — expats asking genuine questions about life in Qatar. Allow frustrated but legitimate policy/service questions.\n'
        : '';

    return '''
You are a content moderator for Raabta, a Qatar expat community app.
Classify this ${language.isNotEmpty ? language : 'multilingual'} community message.
Respond ONLY with valid JSON (no markdown):
{"allowed": true}
OR
{"allowed": false, "category": "<one of: $categories>"}
$contextNote
BLOCK if the message contains:
- Profanity or abusive/harassing language
- Hate speech targeting a person, group, religion, nationality, or ethnicity
- Explicit sexual content
- Content insulting Islam or other religions
- Content insulting the Qatari state, ruling family, or national symbols

Use category "${CommunityModerationConfig.categoryInvestmentFinancialOpportunity}" ONLY when the message promotes a specific investment opportunity, unlicensed trading/crypto platform, guaranteed-return scheme, or invites users to join an EXTERNAL group (WhatsApp/Telegram) framed around investment/trading — not for ordinary financial discussion.

ALLOW (do NOT block or flag investment category):
- Genuine criticism of government policy, decisions, or services (e.g. visa fee increases, public service complaints)
- Ordinary questions about salary, cost of living, bank accounts, EOSB, remittance, or regulated banks mentioned factually (e.g. QNB)
- Landlord/employer/service complaints and normal community discussion
- Constructive expat life discussion even if frustrated
- Legitimate event or hobby group invites with no investment/trading framing

Use category "${CommunityModerationConfig.categoryFundraisingSolicitation}" ONLY when the message solicits donations or money transfers to a private person/account, group collection, or includes bank/IBAN/wallet details for a donation appeal — not for general charity discussion.

ALLOW (do NOT flag fundraising category):
- Questions about how to pay zakat or donate through official/recognised charities in Qatar
- Mentioning an official charity by name without asking others to send money to a private account
- Salary, EOSB, remittance, or ordinary non-donation financial discussion
- Lost-and-found reward offers or neighbourly help (e.g. moving furniture) with no payment collection

Message:
$text
''';
  }

  Future<void> _logDecision({
    required String userId,
    required String contentType,
    required String text,
    required String language,
    required bool allowed,
    required String layer,
    String? category,
    String? groupId,
    bool? userProceededAfterWarning,
  }) async {
    if (!FirebaseService.isReady) return;
    await _db.collection('moderation_log').add({
      'userId': userId,
      'contentType': contentType,
      'excerpt': CommunityContentPrefilter.excerpt(text),
      'contentHash': CommunityContentPrefilter.contentHash(text),
      'language': language,
      'allowed': allowed,
      'layer': layer,
      if (category != null) 'category': category,
      if (groupId != null) 'groupId': groupId,
      if (userProceededAfterWarning != null)
        'userProceededAfterWarning': userProceededAfterWarning,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

}
