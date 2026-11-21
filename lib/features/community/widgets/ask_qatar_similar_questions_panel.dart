import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_container.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/ai_suggestion_card.dart';
import 'package:raabta/core/widgets/glass_chip.dart';
import 'package:raabta/features/community/presentation/l10n/community_strings.dart';
import 'package:raabta/features/community/providers/community_providers.dart';
import 'package:raabta/features/community/services/ask_qatar_similar_question_config.dart';
import 'package:raabta/features/community/services/ask_qatar_similar_question_matcher.dart';
import 'package:raabta/features/community/services/ask_qatar_similar_question_service.dart';
import 'package:raabta/screens/community/ask_qatar_question_screen.dart';

/// Debounced "Already asked?" suggestions above the Ask Qatar submit action.
class AskQatarSimilarQuestionsPanel extends ConsumerStatefulWidget {
  const AskQatarSimilarQuestionsPanel({
    super.key,
    required this.titleController,
    required this.category,
    required this.locale,
    required this.userId,
    required this.enabled,
  });

  final TextEditingController titleController;
  final String category;
  final String locale;
  final String userId;
  final bool enabled;

  @override
  ConsumerState<AskQatarSimilarQuestionsPanel> createState() =>
      _AskQatarSimilarQuestionsPanelState();
}

class _AskQatarSimilarQuestionsPanelState
    extends ConsumerState<AskQatarSimilarQuestionsPanel> {
  Timer? _debounce;
  List<AskQatarSimilarQuestionHit> _hits = const [];
  bool _loading = false;
  String? _dismissedCacheKey;

  @override
  void initState() {
    super.initState();
    widget.titleController.addListener(_onTitleChanged);
  }

  @override
  void didUpdateWidget(covariant AskQatarSimilarQuestionsPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.titleController != widget.titleController) {
      oldWidget.titleController.removeListener(_onTitleChanged);
      widget.titleController.addListener(_onTitleChanged);
    }
    if (oldWidget.category != widget.category) {
      _scheduleLookup();
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    widget.titleController.removeListener(_onTitleChanged);
    super.dispose();
  }

  void _onTitleChanged() => _scheduleLookup();

  void _scheduleLookup() {
    _debounce?.cancel();
    if (!widget.enabled) return;
    _debounce = Timer(AskQatarSimilarQuestionConfig.debounceDelay, _runLookup);
  }

  Future<void> _runLookup() async {
    if (!mounted || !widget.enabled) return;
    final title = widget.titleController.text.trim();
    if (title.length < AskQatarSimilarQuestionConfig.minTitleLengthForLookup) {
      setState(() {
        _hits = const [];
        _loading = false;
      });
      return;
    }

    final cacheKey = AskQatarSimilarQuestionMatcher.normalizeCacheKey(
      title,
      widget.category,
    );
    if (_dismissedCacheKey == cacheKey) return;

    setState(() => _loading = true);
    try {
      final service = ref.read(askQatarSimilarQuestionServiceProvider);
      final hits = await service.findSimilar(
        draftTitle: title,
        category: widget.category,
        userId: widget.userId,
        language: widget.locale,
      );
      if (!mounted) return;
      setState(() {
        _hits = hits;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _hits = const [];
        _loading = false;
      });
    }
  }

  void _dismiss() {
    final title = widget.titleController.text.trim();
    setState(() {
      _dismissedCacheKey = AskQatarSimilarQuestionMatcher.normalizeCacheKey(
        title,
        widget.category,
      );
      _hits = const [];
    });
  }

  void _openQuestion(String questionId) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AskQatarQuestionScreen(questionId: questionId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_hits.isEmpty && !_loading) return const SizedBox.shrink();

    final locale = widget.locale;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: GlassContainer(
        padding: const EdgeInsets.all(AppSpacing.md),
        borderRadius: AppSpacing.radiusSm,
        glowColor: AppColors.brandFamilyMain,
        glowIntensity: 0.08,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    CommunityStrings.t(
                      'community_ask_similar_title',
                      locale,
                    ),
                    style: AppTypography.subtitle.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (_hits.isNotEmpty)
                  TextButton(
                    onPressed: _dismiss,
                    child: Text(
                      CommunityStrings.t('community_ask_similar_dismiss', locale),
                    ),
                  ),
              ],
            ),
            if (_loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
                child: Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              )
            else ...[
              Text(
                CommunityStrings.t('community_ask_similar_subtitle', locale),
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              for (final hit in _hits)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: AISuggestionCard(
                    title: hit.title,
                    description: CommunityStrings.format(
                      'community_ask_similar_row_meta',
                      locale,
                      params: {
                        'count': '${hit.answerCount}',
                        'solved': hit.isSolved
                            ? CommunityStrings.t(
                                'community_ask_solved_chip',
                                locale,
                              )
                            : CommunityStrings.t(
                                'community_ask_unanswered',
                                locale,
                              ),
                      },
                    ),
                    icon: Icons.help_outline,
                    accentColor: AppColors.brandFamilyMain,
                    onTap: () => _openQuestion(hit.questionId),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Compact solved indicator for feed rows.
class AskQatarSolvedChip extends StatelessWidget {
  const AskQatarSolvedChip({super.key, required this.locale});

  final String locale;

  @override
  Widget build(BuildContext context) {
    return GlassChip(
      icon: Icons.check_circle_outline,
      label: CommunityStrings.t('community_ask_solved_chip', locale),
      accentColor: AppColors.success,
      surfaceGlowColor: AppColors.success,
      glowIntensity: 0.1,
      compact: true,
      onTap: () {},
    );
  }
}

/// Accepted answer badge on detail screen.
class AskQatarAcceptedAnswerChip extends StatelessWidget {
  const AskQatarAcceptedAnswerChip({super.key, required this.locale});

  final String locale;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: GlassChip(
        icon: Icons.verified_outlined,
        label: CommunityStrings.t('community_answer_accepted', locale),
        accentColor: AppColors.success,
        surfaceGlowColor: AppColors.success,
        glowIntensity: 0.12,
        onTap: () {},
      ),
    );
  }
}
