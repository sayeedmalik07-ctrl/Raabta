import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/core/l10n/app_shell_strings.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/features/global_search/data/search_ask_ai_service.dart';
import 'package:raabta/features/global_search/domain/search_ai_privacy_sanitizer.dart';
import 'package:raabta/features/global_search/domain/search_ask_ai_request.dart';
import 'package:raabta/features/global_search/domain/search_ask_ai_response.dart';
import 'package:raabta/features/global_search/domain/search_ask_ai_result.dart';
import 'package:raabta/features/global_search/domain/search_analysis.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:raabta/services/ai/ai_chat_response_parser.dart';
import 'package:raabta/services/ai/claude_ai_service.dart';
import 'package:raabta/features/global_search/domain/search_ask_ai_profile_payload.dart';
import 'package:raabta/screens/ai_chat/widgets/ai_response_action_bar.dart';
import 'package:raabta/services/ai/user_profile_ai_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(userLanguageProvider);
    final isRtl = AppLocale.isRtl(locale);

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: GlassScreenScaffold(
        title: AppShellStrings.t('global_search_ask_ai', locale),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenHorizontalPadding,
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GlassCard(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.offer.originalQuery,
                    style: AppTypography.body.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    AppShellStrings.t('global_search_ask_ai_subtitle', locale),
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(child: _buildContent(locale)),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(String locale) {
    if (_loading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: AppSpacing.md),
            Text(
              AppShellStrings.t('global_search_ask_ai_loading', locale),
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    if (_errorKey != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_rounded, color: AppColors.amberGlow, size: 40),
            const SizedBox(height: AppSpacing.sm),
            Text(
              AppShellStrings.t(_errorKey!, locale),
              style: AppTypography.body,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            FilledButton.icon(
              onPressed: _fetchAnswer,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(
                AppShellStrings.t('global_search_ask_ai_retry', locale),
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: GlassCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.auto_awesome_outlined, color: AppColors.cyanGlow),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  AppShellStrings.t('global_search_ask_ai', locale),
                  style: AppTypography.title,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            SearchAskAiAnswerBody(
              validatedAnswer: _response?.answer ?? '',
              disclaimerRequired: _response?.disclaimerRequired ?? false,
              locale: locale,
            ),
          ],
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
  });

  final String validatedAnswer;
  final bool disclaimerRequired;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final parsed = AiChatResponseParser.parse(validatedAnswer);
    final displayText = parsed.displayText;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (displayText.isNotEmpty)
          SelectableText(
            displayText,
            style: AppTypography.body,
          ),
        if (displayText.isNotEmpty)
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
