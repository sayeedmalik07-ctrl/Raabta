import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/core/l10n/app_shell_strings.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/widgets/glass_empty_state.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/features/global_search/data/global_search_repository.dart';
import 'package:raabta/features/global_search/domain/search_autocomplete_result.dart';
import 'package:raabta/features/global_search/domain/global_search_models.dart';
import 'package:raabta/features/global_search/domain/instant_answer.dart';
import 'package:raabta/features/global_search/domain/instant_answer_resolver.dart';
import 'package:raabta/features/global_search/domain/search_intent_interpretation.dart';
import 'package:raabta/features/global_search/presentation/global_search_providers.dart';
import 'package:raabta/providers/auth_providers.dart';
import 'package:raabta/features/global_search/presentation/search_navigation_executor.dart';
import 'package:raabta/features/global_search/presentation/search_ask_ai_executor.dart';
import 'package:raabta/features/global_search/presentation/widgets/global_search_ask_ai.dart';
import 'package:raabta/features/global_search/presentation/widgets/global_search_autocomplete.dart';
import 'package:raabta/features/global_search/presentation/widgets/global_search_actions_group.dart';
import 'package:raabta/features/global_search/presentation/widgets/global_search_best_match.dart';
import 'package:raabta/features/global_search/presentation/widgets/global_search_field.dart';
import 'package:raabta/features/global_search/presentation/widgets/global_search_idle_body.dart';
import 'package:raabta/features/global_search/presentation/widgets/global_search_instant_answer_view.dart';
import 'package:raabta/features/global_search/presentation/widgets/global_search_intent_strip.dart';
import 'package:raabta/features/global_search/presentation/widgets/global_search_loading_indicator.dart';
import 'package:raabta/features/global_search/presentation/widgets/global_search_notice_banners.dart';
import 'package:raabta/features/global_search/presentation/widgets/global_search_voice_button.dart';
import 'package:raabta/features/global_search/presentation/widgets/global_search_result_group.dart';
import 'package:raabta/features/home/widgets/home_section_header.dart';
import 'package:raabta/providers/visa_providers.dart';

/// App-wide content search — Firestore-native, grouped by category.
///
/// Distinct from [SmartSearchService] (AI intent routing on the home screen).
class GlobalSearchScreen extends ConsumerStatefulWidget {
  const GlobalSearchScreen({super.key});

  @override
  ConsumerState<GlobalSearchScreen> createState() => _GlobalSearchScreenState();
}

class _GlobalSearchScreenState extends ConsumerState<GlobalSearchScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  var _fieldFocused = true;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _fieldFocused = _focusNode.hasFocus);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _openResult(GlobalSearchResultItem item) {
    SearchNavigationExecutor.open(context, item);
  }

  void _openAskAi(GlobalSearchResponse response) {
    final offer = response.askAiOffer;
    final analysis = response.analysis;
    if (offer == null || analysis == null) return;
    SearchAskAiExecutor.open(
      context,
      offer: offer,
      analysis: analysis,
    );
  }

  void _submitVoiceTranscript(String transcript) {
    _controller.text = transcript;
    _controller.selection = TextSelection.fromPosition(
      TextPosition(offset: transcript.length),
    );
    setState(() {});
    _focusNode.unfocus();
    ref.read(globalSearchProvider.notifier).rerunRecent(transcript);
  }

  void _updatePartialTranscript(String partial) {
    _controller.text = partial;
    _controller.selection = TextSelection.fromPosition(
      TextPosition(offset: partial.length),
    );
    setState(() {});
  }

  void _selectSuggestion(SearchAutocompleteResult suggestion) {
    _controller.text = suggestion.submitQuery;
    setState(() {});
    ref.read(globalSearchProvider.notifier).rerunRecent(suggestion.submitQuery);
    _focusNode.unfocus();
  }

  void _clearQuery() {
    _controller.clear();
    ref.read(globalSearchProvider.notifier).setQuery('');
    setState(() {});
  }

  SearchIntentInterpretation? _interpretationForState(GlobalSearchState state) {
    final trimmed = state.query.trim();
    if (trimmed.length < GlobalSearchRepository.minQueryLength) return null;
    final response = state.response;
    if (response == null || response.query != trimmed) return null;
    return SearchIntentInterpretationBuilder.build(response.analysis);
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(userLanguageProvider);
    final isRtl = AppLocale.isRtl(locale);
    final searchState = ref.watch(globalSearchProvider);
    final recent = ref.watch(recentSearchesProvider);
    final trimmedQuery = searchState.query.trim();
    final showResults = trimmedQuery.length >= GlobalSearchRepository.minQueryLength &&
        !searchState.isSearching &&
        searchState.response != null &&
        searchState.response!.query == trimmedQuery;

    final suggestions = ref.watch(
      searchAutocompleteProvider((
        query: searchState.query,
        recent: recent,
        locale: locale,
      )),
    );

    final showAutocomplete = _fieldFocused &&
        !showResults &&
        suggestions.isNotEmpty;

    final interpretation = _interpretationForState(searchState);
    final title = AppShellStrings.t('global_search_title', locale);

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Semantics(
        label: title,
        child: GlassScreenScaffold(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenHorizontalPadding,
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              HomeSectionHeader(
                title: title,
                compact: true,
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GlassIconButton(
                    icon: Icons.arrow_back_rounded,
                    tooltip: AppShellStrings.t('global_search_back', locale),
                    onPressed: () => context.pop(),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: GlobalSearchField(
                      controller: _controller,
                      focusNode: _focusNode,
                      locale: locale,
                      onChanged: (v) {
                        setState(() {});
                        ref.read(globalSearchProvider.notifier).setQuery(v);
                      },
                      onSubmitted:
                          ref.read(globalSearchProvider.notifier).setQuery,
                      onClear: _clearQuery,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  GlobalSearchVoiceButton(
                    locale: locale,
                    onPartialTranscript: _updatePartialTranscript,
                    onSubmitFinal: _submitVoiceTranscript,
                  ),
                ],
              ),
              if (interpretation != null && interpretation.isMeaningful) ...[
                const SizedBox(height: AppSpacing.sm),
                GlobalSearchIntentStrip(
                  interpretation: interpretation,
                  locale: locale,
                ),
              ],
              if (showAutocomplete) ...[
                const SizedBox(height: AppSpacing.sm),
                GlobalSearchAutocompleteView(
                  suggestions: suggestions,
                  locale: locale,
                  showClearRecent: recent.isNotEmpty && trimmedQuery.isEmpty,
                  onSelect: _selectSuggestion,
                  onRemoveRecent: (q) =>
                      ref.read(recentSearchesProvider.notifier).remove(q),
                  onClearRecent: () =>
                      ref.read(recentSearchesProvider.notifier).clearAll(),
                ),
              ],
              if (searchState.offlineBanner) ...[
                const SizedBox(height: AppSpacing.sm),
                GlobalSearchOfflineBanner(locale: locale),
              ],
              if (searchState.response?.locationUnavailable == true) ...[
                const SizedBox(height: AppSpacing.sm),
                GlobalSearchLocationUnavailableBanner(locale: locale),
              ],
              const SizedBox(height: AppSpacing.md),
              Expanded(
                child: _buildBody(
                  searchState,
                  recent,
                  locale,
                  showAutocomplete: showAutocomplete,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(
    GlobalSearchState searchState,
    List<String> recent,
    String locale, {
    required bool showAutocomplete,
  }) {
    final query = searchState.query.trim();
    final response = searchState.response;
    final hasMatchingResponse =
        response != null && response.query == query && query.isNotEmpty;
    final isSearching = searchState.isSearching;

    if (isSearching && !hasMatchingResponse) {
      return GlobalSearchLoadingIndicator(locale: locale);
    }

    if (query.length < GlobalSearchRepository.minQueryLength) {
      if (showAutocomplete) {
        return const SizedBox.shrink();
      }
      return GlobalSearchIdleBody(
        recent: recent,
        locale: locale,
        onTap: (q) {
          _controller.text = q;
          ref.read(globalSearchProvider.notifier).rerunRecent(q);
        },
        onRemove: (q) =>
            ref.read(recentSearchesProvider.notifier).remove(q),
      );
    }

    if (searchState.offlineBanner) {
      return GlobalSearchIdleBody(
        recent: recent,
        locale: locale,
        onTap: (q) {
          _controller.text = q;
          ref.read(globalSearchProvider.notifier).rerunRecent(q);
        },
        onRemove: (q) =>
            ref.read(recentSearchesProvider.notifier).remove(q),
        header: AppShellStrings.t('global_search_recent_offline', locale),
      );
    }

    if (response == null || response.query != query) {
      return const SizedBox.shrink();
    }

    final visibleGroups = response.groups
        .where((g) => !g.failed && g.items.isNotEmpty)
        .toList();
    final hasFailedGroups = response.groups.any((g) => g.failed);

    if (response.actions.isEmpty && visibleGroups.isEmpty) {
      return _buildEmptyResults(
        response: response,
        locale: locale,
        hasFailedGroups: hasFailedGroups,
        isRefreshing: isSearching,
      );
    }

    final instantAnswer = InstantAnswerResolver.resolve(
      InstantAnswerContext(
        response: response,
        currentQuery: query,
        isSignedIn: ref.read(isSignedInProvider),
      ),
    );

    return _buildResultsList(
      response: response,
      locale: locale,
      visibleGroups: visibleGroups,
      hasFailedGroups: hasFailedGroups,
      isRefreshing: isSearching,
      instantAnswer: instantAnswer,
    );
  }

  Widget _buildEmptyResults({
    required GlobalSearchResponse response,
    required String locale,
    required bool hasFailedGroups,
    required bool isRefreshing,
  }) {
    final children = <Widget>[
      if (isRefreshing) GlobalSearchRefreshBar(locale: locale),
      if (hasFailedGroups) GlobalSearchSourcesUnavailableBanner(locale: locale),
      if (response.askAiOffer != null)
        GlobalSearchAskAiView(
          offer: response.askAiOffer!,
          onTap: () => _openAskAi(response),
        ),
      Semantics(
        label: AppShellStrings.t('global_search_no_results', locale),
        child: GlassEmptyState(
          icon: Icons.search_off_rounded,
          title: AppShellStrings.t('global_search_no_results', locale),
          description: AppShellStrings.t('global_search_empty_desc', locale),
        ),
      ),
    ];

    return ListView(children: children);
  }

  Widget _buildResultsList({
    required GlobalSearchResponse response,
    required String locale,
    required List<GlobalSearchCategoryGroup> visibleGroups,
    required bool hasFailedGroups,
    required bool isRefreshing,
    InstantAnswer? instantAnswer,
  }) {
    final displayActions = instantAnswer?.duplicateActionId != null
        ? response.actions
            .where((a) => a.actionId != instantAnswer!.duplicateActionId)
            .toList()
        : response.actions;
    final showBestMatch = response.bestMatch != null &&
        !(instantAnswer?.suppressBestMatch ?? false);

    return ListView(
      children: [
        if (isRefreshing) GlobalSearchRefreshBar(locale: locale),
        if (hasFailedGroups) GlobalSearchSourcesUnavailableBanner(locale: locale),
        if (instantAnswer != null)
          GlobalSearchInstantAnswerView(
            answer: instantAnswer,
            locale: locale,
            fromCache: response.fromCache,
            onTapItem: _openResult,
          ),
        if (showBestMatch)
          GlobalSearchBestMatchView(
            bestMatch: response.bestMatch!,
            locale: locale,
            onTapItem: _openResult,
          ),
        if (displayActions.isNotEmpty)
          GlobalSearchActionsGroupView(
            actions: displayActions,
            locale: locale,
            onTapItem: _openResult,
          ),
        if (response.askAiOffer != null)
          GlobalSearchAskAiView(
            offer: response.askAiOffer!,
            onTap: () => _openAskAi(response),
          ),
        for (final group in visibleGroups)
          GlobalSearchResultGroupView(
            group: group,
            locale: locale,
            onTapItem: _openResult,
            onSeeAll: () => SearchNavigationExecutor.openSeeAll(context, group),
          ),
      ],
    );
  }
}
