import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/core/l10n/app_shell_strings.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/core/widgets/hub/hub_loading_placeholder.dart';
import 'package:raabta/core/widgets/hub/hub_notice_banner.dart';
import 'package:raabta/features/global_search/data/search_ask_ai_service.dart';
import 'package:raabta/features/global_search/domain/search_ai_privacy_sanitizer.dart';
import 'package:raabta/features/global_search/domain/search_ask_ai_request.dart';
import 'package:raabta/features/global_search/domain/search_ask_ai_response.dart';
import 'package:raabta/features/global_search/domain/search_ask_ai_result.dart';
import 'package:raabta/features/global_search/domain/search_analysis.dart';
import 'package:raabta/features/global_search/domain/search_ask_ai_profile_payload.dart';
import 'package:raabta/features/global_search/presentation/widgets/global_search_category_icon_chip.dart';
import 'package:raabta/features/global_search/presentation/widgets/global_search_presentation_tokens.dart';
import 'package:raabta/features/global_search/presentation/widgets/global_search_section_header.dart';
import 'package:raabta/features/home/widgets/home_card_tiers.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:raabta/screens/ai_chat/widgets/ai_response_action_bar.dart';
import 'package:raabta/services/ai/ai_chat_response_parser.dart';
import 'package:raabta/services/ai/claude_ai_service.dart';
import 'package:raabta/services/ai/user_profile_ai_service.dart';

/// Minimal AI answer surface for Global Search ASK fallback (S9).
class SearchAskAiScreen extends ConsumerStatefulWidget {
  const SearchAskAiScreen({
    super.key,
    required this.offer,
    required this.analysis,
  });

  final SearchAskAiResult offer;
  final SearchAnalysis analysis;

  @override
  ConsumerState<SearchAskAiScreen> createState() => _SearchAskAiScreenState();
}

class _SearchAskAiScreenState extends ConsumerState<SearchAskAiScreen> {
  SearchAskAiResponse? _response;
  bool _loading = true;
  String? _errorKey;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchAnswer());
  }

  Future<void> _fetchAnswer() async {
    setState(() {
      _loading = true;
      _errorKey = null;
      _response = null;
    });

    final locale = ref.read(userLanguageProvider);
    final languageCode = AppLocale.toLanguageCode(locale);
    final sanitized = SearchAiPrivacySanitizer.sanitize(widget.offer.originalQuery);

    if (sanitized == null) {
      setState(() {
        _loading = false;
        _errorKey = 'global_search_ask_ai_unavailable';
      });
      return;
    }

    final service = ref.read(searchAskAiServiceProvider);
    final request = SearchAskAiRequest.fromAnalysis(
      analysis: widget.analysis,
      sanitizedQuery: sanitized,
    );

    final uid = FirebaseAuth.instance.currentUser?.uid;
    final profile = ref.read(userAIProfileProvider);
    final profileMap = SearchAskAiProfilePayload.build(profile);

    final result = await service.ask(
      request: request,
      locale: locale,
      languageCode: languageCode,
      userId: uid,
      userProfile: profileMap,
    );

    if (!mounted) return;

    if (result.hasError || result.isEmpty) {
      setState(() {
        _loading = false;
        _errorKey = 'global_search_ask_ai_error';
        _response = result;
      });
      return;
    }

    setState(() {
      _loading = false;
      _response = result;
    });
  }

  void _popToSearch() {
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(userLanguageProvider);
    final isRtl = AppLocale.isRtl(locale);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: GlassScreenScaffold(
        title: AppShellStrings.t('global_search_ask_ai', locale),
        enableBackgroundAnimation: !isLight && !reduceMotion,
        leading: GlassIconButton(
          icon: Icons.arrow_back_rounded,
          tooltip: AppShellStrings.t('global_search_back', locale),
          onPressed: _popToSearch,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenHorizontalPadding,
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SearchAskAiQuerySummary(
              query: widget.offer.originalQuery,
              locale: locale,
            ),
            const SizedBox(height: AppSpacing.sm),
            Expanded(child: _buildContent(locale, isRtl)),
            SearchAskAiBackToSearchBar(
              locale: locale,
              onPressed: _popToSearch,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(String locale, bool isRtl) {
    if (_loading) {
      return SearchAskAiLoadingPanel(locale: locale);
    }

    if (_errorKey != null) {
      return SearchAskAiErrorPanel(
        locale: locale,
        messageKey: _errorKey!,
        onRetry: _fetchAnswer,
      );
    }

    return SingleChildScrollView(
      child: SearchAskAiAnswerPanel(
        locale: locale,
        isRtl: isRtl,
        validatedAnswer: _response?.answer ?? '',
        disclaimerRequired: _response?.disclaimerRequired ?? false,
      ),
    );
  }
}

/// Brand-accent query chip summary (read-only).
@visibleForTesting
class SearchAskAiQuerySummary extends StatelessWidget {
  const SearchAskAiQuerySummary({
    super.key,
    required this.query,
    required this.locale,
  });

  final String query;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final subtitle = AppShellStrings.t('global_search_ask_ai_subtitle', locale);

    return Semantics(
      label: '$query. $subtitle',
      child: GlassCard(
        padding: GlobalSearchPresentationTokens.cardPadding,
        borderRadius: GlobalSearchPresentationTokens.cardRadius,
        glowColor: AppColors.brandFamilyMain,
        glowIntensity: HomeCardTier.homeCardGlowIntensity,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GlobalSearchCategoryIconChip(
              icon: Icons.manage_search_rounded,
              accent: AppColors.brandFamilyMain,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    query,
                    style: AppTypography.body.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    subtitle,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textOnGlassMuted,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

@visibleForTesting
class SearchAskAiLoadingPanel extends StatelessWidget {
  const SearchAskAiLoadingPanel({super.key, required this.locale});

  final String locale;

  static const _skeletonHeight = 120.0;

  @override
  Widget build(BuildContext context) {
    final label = AppShellStrings.t('global_search_ask_ai_loading', locale);

    return Semantics(
      label: label,
      liveRegion: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const Expanded(
            child: HubLoadingPlaceholder(
              height: _skeletonHeight,
              width: double.infinity,
              silhouette: HubLoadingSilhouette.formTool,
            ),
          ),
        ],
      ),
    );
  }
}

@visibleForTesting
class SearchAskAiErrorPanel extends StatelessWidget {
  const SearchAskAiErrorPanel({
    super.key,
    required this.locale,
    required this.messageKey,
    required this.onRetry,
  });

  final String locale;
  final String messageKey;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final message = AppShellStrings.t(messageKey, locale);
    final retryLabel = AppShellStrings.t('global_search_ask_ai_retry', locale);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        HubNoticeBanner(text: message, semanticsLabel: message),
        const SizedBox(height: AppSpacing.md),
        Align(
          alignment: AlignmentDirectional.center,
          child: TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: Text(retryLabel),
          ),
        ),
      ],
    );
  }
}

@visibleForTesting
class SearchAskAiAnswerPanel extends StatelessWidget {
  const SearchAskAiAnswerPanel({
    super.key,
    required this.locale,
    required this.isRtl,
    required this.validatedAnswer,
    required this.disclaimerRequired,
  });

  final String locale;
  final bool isRtl;
  final String validatedAnswer;
  final bool disclaimerRequired;

  @override
  Widget build(BuildContext context) {
    final heading = AppShellStrings.t('global_search_ask_ai', locale);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GlobalSearchSectionHeader(
          title: heading,
          icon: Icons.auto_awesome_outlined,
          accent: AppColors.brandFamilyMain,
        ),
        const SizedBox(height: AppSpacing.sm),
        GlassCard(
          padding: const EdgeInsets.all(AppSpacing.md),
          borderRadius: GlobalSearchPresentationTokens.cardRadius,
          glowColor: AppColors.brandFamilyMain,
          glowIntensity: HomeCardTier.contextualGlowIntensity,
          child: SearchAskAiAnswerBody(
            validatedAnswer: validatedAnswer,
            disclaimerRequired: disclaimerRequired,
            locale: locale,
            isRtl: isRtl,
          ),
        ),
        const SizedBox(height: GlobalSearchPresentationTokens.sectionBottomGap),
      ],
    );
  }
}

@visibleForTesting
class SearchAskAiBackToSearchBar extends StatelessWidget {
  const SearchAskAiBackToSearchBar({
    super.key,
    required this.locale,
    required this.onPressed,
  });

  final String locale;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final backLabel = AppShellStrings.t('global_search_back', locale);
    final searchTitle = AppShellStrings.t('global_search_title', locale);
    final semantics = '$backLabel — $searchTitle';

    return Padding(
      padding: const EdgeInsets.only(
        top: AppSpacing.sm,
        bottom: AppSpacing.xs,
      ),
      child: Semantics(
        button: true,
        label: semantics,
        child: TextButton.icon(
          onPressed: onPressed,
          icon: const Icon(Icons.arrow_back_rounded, size: 18),
          label: Text('$backLabel — $searchTitle'),
        ),
      ),
    );
  }
}

/// Parsed answer + action chips — shared Search Ask AI presentation boundary.
@visibleForTesting
class SearchAskAiAnswerBody extends StatelessWidget {
  const SearchAskAiAnswerBody({
    super.key,
    required this.validatedAnswer,
    required this.disclaimerRequired,
    required this.locale,
    this.isRtl = false,
  });

  final String validatedAnswer;
  final bool disclaimerRequired;
  final String locale;
  final bool isRtl;

  static MarkdownStyleSheet markdownStyleSheet() {
    return MarkdownStyleSheet(
      p: AppTypography.body.copyWith(color: AppColors.textPrimary),
      listBullet: AppTypography.body.copyWith(color: AppColors.brandFamilyMain),
      strong: AppTypography.body.copyWith(
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
      code: AppTypography.caption.copyWith(
        fontFamily: 'monospace',
        color: AppColors.brandFamilyMain,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final parsed = AiChatResponseParser.parse(validatedAnswer);
    final displayText = parsed.displayText;
    final resolvedRtl = isRtl || Directionality.of(context) == TextDirection.rtl;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (displayText.isNotEmpty)
          Directionality(
            textDirection:
                resolvedRtl ? TextDirection.rtl : TextDirection.ltr,
            child: MarkdownBody(
              data: displayText,
              styleSheet: markdownStyleSheet(),
              shrinkWrap: true,
              selectable: true,
            ),
          )
        else if (validatedAnswer.trim().isNotEmpty)
          SelectableText(
            validatedAnswer.trim(),
            style: AppTypography.body,
          ),
        if (displayText.isNotEmpty || validatedAnswer.trim().isNotEmpty)
          AiResponseActionBar(
            actions: parsed.actions,
            citations: parsed.citations,
          ),
        if (disclaimerRequired) ...[
          const SizedBox(height: AppSpacing.md),
          Text(
            AppShellStrings.t('global_search_ask_ai_unavailable', locale),
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    );
  }
}

final searchAskAiServiceProvider = Provider<SearchAskAiService>((ref) {
  return SearchAskAiService(ref.watch(claudeAIServiceProvider));
});
