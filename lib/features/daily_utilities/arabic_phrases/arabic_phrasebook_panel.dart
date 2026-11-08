import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/features/daily_utilities/arabic_phrases/arabic_phrases_data.dart';
import 'package:raabta/features/daily_utilities/arabic_phrases/phrase_favorites_service.dart';
import 'package:raabta/features/daily_utilities/l10n/daily_utilities_strings.dart';
import 'package:raabta/features/home/widgets/status_badge.dart';
import 'package:raabta/providers/visa_providers.dart';

/// Offline bundled phrasebook — embeddable in Arabic Companion or legacy routes.
class ArabicPhrasebookPanel extends ConsumerStatefulWidget {
  const ArabicPhrasebookPanel({
    super.key,
    this.initialCategoryId,
    this.initialPhraseId,
    this.header,
  });

  final String? initialCategoryId;
  final String? initialPhraseId;
  final Widget? header;

  @override
  ConsumerState<ArabicPhrasebookPanel> createState() =>
      _ArabicPhrasebookPanelState();
}

class _ArabicPhrasebookPanelState extends ConsumerState<ArabicPhrasebookPanel> {
  String? _categoryId;
  bool _showFavorites = false;
  Set<String> _favorites = {};
  final _searchCtrl = TextEditingController();
  String _query = '';
  final _tts = FlutterTts();
  bool _ttsReady = true;
  String? _ttsFailedPhraseId;

  @override
  void initState() {
    super.initState();
    _categoryId = widget.initialCategoryId;
    if (widget.initialPhraseId != null) {
      final phrase = phraseById(widget.initialPhraseId!);
      if (phrase != null) {
        _categoryId = phrase.categoryId;
      }
    }
    _initTts();
    _loadFavorites();
  }

  Future<void> _initTts() async {
    try {
      await _tts.setLanguage('ar-QA');
      await _tts.setSpeechRate(0.45);
      _ttsReady = true;
    } catch (_) {
      if (mounted) setState(() => _ttsReady = false);
    }
  }

  Future<void> _loadFavorites() async {
    final f = await PhraseFavoritesService.load();
    if (mounted) setState(() => _favorites = f);
  }

  Future<void> _speak(ArabicPhrase phrase) async {
    if (!_ttsReady) {
      setState(() => _ttsFailedPhraseId = phrase.id);
      return;
    }
    try {
      final result = await _tts.speak(phrase.arabicScript);
      if (result != 1) {
        if (mounted) setState(() => _ttsFailedPhraseId = phrase.id);
      } else if (mounted && _ttsFailedPhraseId == phrase.id) {
        setState(() => _ttsFailedPhraseId = null);
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _ttsReady = false;
          _ttsFailedPhraseId = phrase.id;
        });
      }
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _tts.stop();
    super.dispose();
  }

  List<ArabicPhrase> _visiblePhrases(String locale) {
    Iterable<ArabicPhrase> list = arabicPhrases;
    if (widget.initialPhraseId != null &&
        _query.isEmpty &&
        !_showFavorites) {
      final pinned = phraseById(widget.initialPhraseId!);
      if (pinned != null) return [pinned];
    }
    if (_showFavorites) {
      list = list.where((p) => _favorites.contains(p.id));
    } else if (_categoryId != null) {
      list = phrasesForCategory(_categoryId!);
    }
    if (_query.isNotEmpty) {
      final q = _query.toLowerCase();
      list = list.where(
        (p) =>
            p.arabicScript.contains(_query) ||
            p.transliteration.toLowerCase().contains(q) ||
            p.meaningFor(locale).toLowerCase().contains(q) ||
            (p.contextNote?.toLowerCase().contains(q) ?? false),
      );
    }
    return list.toList();
  }

  bool get _showCategoryGrid =>
      _categoryId == null && !_showFavorites && _query.isEmpty;

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(userLanguageProvider);
    final phrases = _visiblePhrases(locale);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.header != null) widget.header!,
        if (_showCategoryGrid) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              0,
              AppSpacing.md,
              8,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DailyUtilitiesStrings.t('phrases_subtitle', locale),
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DailyUtilitiesStrings.t('phrases_dialect_note', locale),
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textTertiary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
        if (_categoryId != null || _showFavorites)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => setState(() {
                  _categoryId = null;
                  _showFavorites = false;
                }),
                icon: const Icon(Icons.arrow_back, size: 18),
                label: Text(
                  DailyUtilitiesStrings.t('companion_back_categories', locale),
                ),
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: TextField(
            controller: _searchCtrl,
            onChanged: (v) => setState(() => _query = v.trim()),
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText:
                  DailyUtilitiesStrings.t('phrases_search_hint', locale),
              prefixIcon:
                  Icon(Icons.search, color: AppColors.textSecondary),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.06),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        if (_showCategoryGrid)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: TextButton.icon(
              onPressed: () => setState(() => _showFavorites = true),
              icon: const Icon(Icons.favorite_border, color: AppColors.accentGold),
              label: Text(
                DailyUtilitiesStrings.t('favorites', locale),
                style: const TextStyle(color: AppColors.accentGold),
              ),
            ),
          ),
        Expanded(
          child: _showCategoryGrid
              ? ListView(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  children: [
                    for (final cat in phraseCategories)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: GlassCard(
                          onTap: () => setState(() => _categoryId = cat.id),
                          padding: const EdgeInsets.all(AppSpacing.md),
                          child: Row(
                            children: [
                              Text(cat.emoji,
                                  style: const TextStyle(fontSize: 28)),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      phraseCategoryLabel(cat.labelKey, locale),
                                      style: AppTypography.title
                                          .copyWith(fontSize: 16),
                                    ),
                                    Text(
                                      '${phrasesForCategory(cat.id).length} ${DailyUtilitiesStrings.t('phrases_count_label', locale)}',
                                      style: AppTypography.caption.copyWith(
                                        color: AppColors.textTertiary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right,
                                  color: Colors.white38),
                            ],
                          ),
                        ),
                      ),
                  ],
                )
              : phrases.isEmpty
                  ? Center(
                      child: Text(
                        DailyUtilitiesStrings.t('phrases_no_results', locale),
                        style: AppTypography.body.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      itemCount: phrases.length,
                      itemBuilder: (context, i) {
                        final phrase = phrases[i];
                        return _PhraseCard(
                          phrase: phrase,
                          locale: locale,
                          isFavorite: _favorites.contains(phrase.id),
                          audioFailed: _ttsFailedPhraseId == phrase.id,
                          ttsReady: _ttsReady,
                          onSpeak: () => _speak(phrase),
                          onToggleFavorite: () async {
                            await PhraseFavoritesService.toggle(phrase.id);
                            await _loadFavorites();
                          },
                        );
                      },
                    ),
        ),
      ],
    );
  }
}

class _PhraseCard extends StatelessWidget {
  const _PhraseCard({
    required this.phrase,
    required this.locale,
    required this.isFavorite,
    required this.audioFailed,
    required this.ttsReady,
    required this.onSpeak,
    required this.onToggleFavorite,
  });

  final ArabicPhrase phrase;
  final String locale;
  final bool isFavorite;
  final bool audioFailed;
  final bool ttsReady;
  final VoidCallback onSpeak;
  final VoidCallback onToggleFavorite;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GlassCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!phrase.reviewed)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: StatusBadge(
                  label: DailyUtilitiesStrings.t('review_pending', locale),
                  color: AppColors.warning,
                ),
              ),
            Directionality(
              textDirection: TextDirection.rtl,
              child: Text(
                phrase.arabicScript,
                style: AppTypography.headline2.copyWith(fontSize: 26),
                textAlign: TextAlign.right,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              phrase.transliteration,
              style: AppTypography.caption.copyWith(
                color: AppColors.cyanGlow,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              phrase.meaningFor(locale),
              style: AppTypography.body.copyWith(fontSize: 15),
            ),
            if (phrase.contextNote != null) ...[
              const SizedBox(height: 6),
              Text(
                phrase.contextNote!,
                style: AppTypography.caption.copyWith(
                  color: AppColors.textTertiary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                TextButton.icon(
                  onPressed: ttsReady ? onSpeak : null,
                  icon: Icon(
                    audioFailed ? Icons.volume_off : Icons.volume_up,
                    size: 18,
                  ),
                  label: Text(
                    audioFailed
                        ? DailyUtilitiesStrings.t('audio_unavailable', locale)
                        : DailyUtilitiesStrings.t('play_audio', locale),
                  ),
                ),
                IconButton(
                  onPressed: onToggleFavorite,
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: AppColors.accentGold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
