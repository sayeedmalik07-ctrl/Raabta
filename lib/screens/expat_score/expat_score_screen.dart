import 'dart:async';
import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/l10n/app_shell_strings.dart';
import 'package:raabta/core/l10n/common_action_strings.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/features/home/providers/expat_score_advice_provider.dart';
import 'package:raabta/features/home/providers/expat_score_detail_recommendations_provider.dart';
import 'package:raabta/features/home/providers/expat_score_history_provider.dart';
import 'package:raabta/features/home/utils/expat_score_category_detail_helper.dart';
import 'package:raabta/features/home/utils/expat_score_profile_helper.dart';
import 'package:raabta/features/intelligence/presentation/widgets/intelligence_insight_row.dart';
import 'package:raabta/providers/auth_providers.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:raabta/screens/expat_score/l10n/expat_score_strings.dart';
import 'package:raabta/services/ai/expat_life_score_service.dart';
import 'package:raabta/services/ai/user_profile_ai_service.dart';
import 'package:share_plus/share_plus.dart';

class ExpatScoreScreen extends ConsumerStatefulWidget {
  const ExpatScoreScreen({super.key});

  @override
  ConsumerState<ExpatScoreScreen> createState() => _ExpatScoreScreenState();
}

class _ExpatScoreScreenState extends ConsumerState<ExpatScoreScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _arcController;
  late Animation<double> _arcAnimation;
  double? _lastAnimatedScore;

  List<String> _levelNames(String locale) => [
        ExpatScoreStrings.t('level_new_arrival', locale),
        ExpatScoreStrings.t('level_settling_in', locale),
        ExpatScoreStrings.t('level_growing_strong', locale),
        ExpatScoreStrings.t('level_established', locale),
        ExpatScoreStrings.t('level_qatar_pro', locale),
      ];

  @override
  void initState() {
    super.initState();
    _arcController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _arcAnimation = Tween<double>(begin: 0, end: 0).animate(
      CurvedAnimation(parent: _arcController, curve: Curves.easeOutCubic),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profile = ref.read(userAIProfileProvider);
      if (profile != null) {
        unawaited(ref.read(expatLifeScoreProvider.notifier).refresh(profile));
      }
    });
  }

  @override
  void dispose() {
    _arcController.dispose();
    super.dispose();
  }

  void _animateToScore(double score) {
    if (_lastAnimatedScore == score) return;
    _lastAnimatedScore = score;
    _arcAnimation = Tween<double>(begin: 0, end: score / 100).animate(
      CurvedAnimation(parent: _arcController, curve: Curves.easeOutCubic),
    );
    _arcController.forward(from: 0);
  }

  void _shareScore(int score, String levelLabel, String locale) {
    Share.share(
      ExpatScoreStrings.format(
        'share_message',
        locale,
        params: {'score': '$score', 'level': levelLabel},
      ),
      subject: ExpatScoreStrings.t('share_subject', locale),
    );
  }

  void _onDoIt(ExpatScoreRecommendation recommendation, String locale) {
    switch (recommendation.routeTarget) {
      case ExpatScoreRouteTarget.community:
        context.push('/community');
        return;
      case ExpatScoreRouteTarget.visa:
        context.push('/visa');
        return;
      case ExpatScoreRouteTarget.jobs:
        context.push('/jobs');
        return;
      case ExpatScoreRouteTarget.refer:
        final scoreTotal =
            ref.read(expatLifeScoreProvider).score?.total.round() ?? 0;
        final levelLabel = scoreTotal > 0
            ? ExpatScoreStrings.levelLabelForTotal(
                scoreTotal.toDouble(),
                locale,
              )
            : '';
        _shareScore(scoreTotal, levelLabel, locale);
        return;
      case ExpatScoreRouteTarget.tool:
        break;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ExpatScoreStrings.format(
            'snack_open_tool',
            locale,
            params: {'action': recommendation.action},
          ),
        ),
        backgroundColor: AppColors.surfaceElevated,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  int _currentLevelIndex(double total) {
    if (total <= 20) return 0;
    if (total <= 40) return 1;
    if (total <= 79) return 2;
    if (total <= 94) return 3;
    return 4;
  }

  List<_GamificationLevel> _gamificationLevels(double total, String locale) {
    final current = _currentLevelIndex(total);
    final defs = [
      ('🆕', ExpatScoreStrings.t('level_new_arrival', locale), '0–20'),
      ('🏠', ExpatScoreStrings.t('level_settling_in', locale), '21–40'),
      ('📈', ExpatScoreStrings.t('level_growing_strong', locale), '41–79'),
      (
        '🏆',
        ExpatScoreStrings.t('level_established_resident', locale),
        '80–94',
      ),
      ('⭐', ExpatScoreStrings.t('level_qatar_pro', locale), '95–100'),
    ];

    return List.generate(defs.length, (index) {
      _LevelStatus status;
      if (index < current) {
        status = _LevelStatus.completed;
      } else if (index == current) {
        status = _LevelStatus.current;
      } else if (index == current + 1) {
        status = _LevelStatus.next;
      } else {
        status = _LevelStatus.future;
      }
      final def = defs[index];
      return _GamificationLevel(
        emoji: def.$1,
        name: def.$2,
        range: def.$3,
        status: status,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(userLanguageProvider);
    final uid = ref.watch(currentUserProvider)?.uid ?? '';
    final profile = ref.watch(userAIProfileProvider);
    final expatState = ref.watch(expatLifeScoreProvider);
    final score = expatState.score;
    final historyAsync = uid.isEmpty
        ? const AsyncValue<List<ExpatScoreHistoryPoint>>.data([])
        : ref.watch(expatScoreHistoryProvider(uid));
    final recommendationsAsync = uid.isEmpty
        ? const AsyncValue<List<ExpatScoreRecommendation>>.data([])
        : ref.watch(expatScoreDetailRecommendationsProvider(uid));
    final improvementActions = ref.watch(expatImprovementActionsProvider);

    if (score != null) {
      _animateToScore(score.total);
    }

    final displayScore = score?.total.round() ?? 0;
    final levelLabel = score == null
        ? AppShellStrings.t('home_calculating', locale)
        : ExpatScoreProfileHelper.statusLabelWithTrend(
            level: ExpatScoreStrings.levelLabelForTotal(score.total, locale),
            weeklyGrowth: score.weeklyGrowth,
          );
    final levelNames = _levelNames(locale);
    final categories = (profile != null && score != null)
        ? ExpatScoreCategoryDetailHelper.buildCategories(
            profile,
            score,
            locale,
          )
        : const <ExpatScoreCategoryDetail>[];
    final achievements = expatState.achievements
        .map(
          (a) => _Achievement(
            emoji: a.emoji,
            name: ExpatScoreStrings.achievementTitle(a.id, locale),
            earned: a.unlocked,
          ),
        )
        .toList();
    final gamificationLevels = score != null
        ? _gamificationLevels(score.total, locale)
        : const <_GamificationLevel>[];
    final currentLevelIndex =
        score != null ? _currentLevelIndex(score.total) : 0;
    final completedLevels = currentLevelIndex + 1;

    return GlassScreenScaffold(
      title: ExpatScoreStrings.t('detail_title', locale),
      leading: GlassIconButton(
        icon: Icons.arrow_back,
        tooltip: CommonActionStrings.t('action_back', locale),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: [
        GlassIconButton(
          icon: Icons.share_outlined,
          tooltip: CommonActionStrings.t('action_share', locale),
          onPressed: score == null
              ? null
              : () => _shareScore(displayScore, levelLabel, locale),
        ),
      ],
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        0,
        AppSpacing.xl,
        AppSpacing.xxxl,
      ),
      body: score == null
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.cyanGlow),
            )
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeroSection(
                    displayScore,
                    levelLabel,
                    currentLevelIndex,
                    completedLevels,
                    levelNames,
                    locale,
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  historyAsync.when(
                    data: (history) => _buildWeeklyTrend(history, score, locale),
                    loading: () => _buildWeeklyTrend(const [], score, locale),
                    error: (_, _) => _buildWeeklyTrend(const [], score, locale),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  Text(
                    ExpatScoreStrings.t('section_score_breakdown', locale),
                    style: AppTypography.headline2,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ...categories.map((c) => _buildCategoryCard(c, locale)),
                  const SizedBox(height: AppSpacing.xxl),
                  Text(
                    ExpatScoreStrings.t('section_ai_recommendations', locale),
                    style: AppTypography.headline2,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  recommendationsAsync.when(
                    data: (recommendations) => Column(
                      children: recommendations
                          .map((r) => _buildRecommendationCard(r, locale))
                          .toList(),
                    ),
                    loading: () => const Padding(
                      padding: EdgeInsets.all(AppSpacing.lg),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.cyanGlow,
                        ),
                      ),
                    ),
                    error: (_, _) => Column(
                      children: improvementActions
                          .take(3)
                          .map(
                            (action) => _buildRecommendationCard(
                              ExpatScoreRecommendation(
                                action: action.title,
                                points: action.pointsGain,
                                duration: action.estimatedTime,
                                routeTarget: action.routeTarget,
                              ),
                              locale,
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  Text(
                    ExpatScoreStrings.t('section_achievements', locale),
                    style: AppTypography.headline2,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _buildAchievementsGrid(achievements, locale),
                  const SizedBox(height: AppSpacing.xxl),
                  Text(
                    ExpatScoreStrings.t('section_level_journey', locale),
                    style: AppTypography.headline2,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _buildGamificationTimeline(gamificationLevels, locale),
                ],
              ),
            ),
    );
  }

  Widget _buildHeroSection(
    int score,
    String levelLabel,
    int currentLevelIndex,
    int completedLevels,
    List<String> levelNames,
    String locale,
  ) {
    return Column(
      children: [
        AnimatedBuilder(
          animation: _arcAnimation,
          builder: (context, child) {
            return SizedBox(
              width: 200,
              height: 200,
              child: CustomPaint(
                painter: _ScoreArcPainter(progress: _arcAnimation.value),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$score',
                        style: TextStyle(
                          fontSize: 64,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                          height: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        Text(
          levelLabel,
          style: const TextStyle(
            color: AppColors.warning,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        _buildLevelProgression(
          currentLevelIndex,
          completedLevels,
          levelNames,
          locale,
        ),
      ],
    );
  }

  Widget _buildLevelProgression(
    int currentLevelIndex,
    int completedLevels,
    List<String> levelNames,
    String locale,
  ) {
    return Column(
      children: [
        Row(
          children: List.generate(levelNames.length, (index) {
            final isCompleted = index < completedLevels;
            final isCurrent = index == currentLevelIndex;
            return Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: isCompleted || isCurrent
                            ? AppColors.cyanGlow
                            : AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  if (index < levelNames.length - 1) const SizedBox(width: 4),
                ],
              ),
            );
          }),
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: List.generate(levelNames.length, (index) {
            final isCurrent = index == currentLevelIndex;
            return Text(
              levelNames[index],
              style: AppTypography.bodySmall.copyWith(
                color: isCurrent ? AppColors.cyanGlow : AppColors.textTertiary,
                fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w400,
                fontSize: 10,
              ),
            );
          }),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          ExpatScoreStrings.format(
            'progress_levels',
            locale,
            params: {
              'completed': '$completedLevels',
              'total': '${levelNames.length}',
            },
          ),
          style: AppTypography.body,
        ),
      ],
    );
  }

  Widget _buildWeeklyTrend(
    List<ExpatScoreHistoryPoint> history,
    ExpatLifeScore score,
    String locale,
  ) {
    final points = history.isNotEmpty
        ? history
        : [
            ExpatScoreHistoryPoint(
              date: DateTime.now().subtract(const Duration(days: 7)),
              total: (score.total - score.weeklyGrowth).clamp(0, 100),
            ),
            ExpatScoreHistoryPoint(date: DateTime.now(), total: score.total),
          ];

    final weeklyScores = points.map((p) => p.total).toList();
    final minY = (weeklyScores.reduce(math.min) - 5).clamp(0, 95).toDouble();
    final maxY = (weeklyScores.reduce(math.max) + 5).clamp(5, 100).toDouble();
    final weekGrowth = score.weeklyGrowth.round();
    final monthGrowth = score.monthlyGrowth.round();

    return GlassCard(
      width: double.infinity,
      borderRadius: AppSpacing.radiusXl,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ExpatScoreStrings.t('weekly_trend', locale),
            style: AppTypography.title,
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 120,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= points.length) {
                          return const SizedBox.shrink();
                        }
                        final date = points[index].date;
                        final label = '${date.day}/${date.month}';
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            label,
                            style: AppTypography.bodySmall,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minY: minY,
                maxY: maxY,
                lineBarsData: [
                  LineChartBarData(
                    spots: List.generate(
                      weeklyScores.length,
                      (i) => FlSpot(i.toDouble(), weeklyScores[i]),
                    ),
                    isCurved: true,
                    color: AppColors.cyanGlow,
                    barWidth: 3,
                    dotData: FlDotData(
                      getDotPainter: (spot, percent, bar, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: AppColors.cyanGlow,
                          strokeWidth: 2,
                          strokeColor: AppColors.background,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.cyanGlow.withValues(alpha: 0.25),
                          AppColors.cyanGlow.withValues(alpha: 0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              _TrendChip(
                label: ExpatScoreStrings.format(
                  'trend_this_week',
                  locale,
                  params: {
                    'delta': '${weekGrowth >= 0 ? '+' : ''}$weekGrowth',
                  },
                ),
                color: weekGrowth >= 0 ? AppColors.success : AppColors.error,
              ),
              const SizedBox(width: AppSpacing.sm),
              _TrendChip(
                label: ExpatScoreStrings.format(
                  'trend_this_month',
                  locale,
                  params: {
                    'delta': '${monthGrowth >= 0 ? '+' : ''}$monthGrowth',
                  },
                ),
                color: monthGrowth >= 0 ? AppColors.success : AppColors.warning,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(ExpatScoreCategoryDetail category, String locale) {
    final scoreLabel = category.insufficientData
        ? '—'
        : '${category.score}/100';

    return GlassCard(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      borderRadius: AppSpacing.radiusLg,
      padding: const EdgeInsets.all(AppSpacing.lg),
      onTap: category.detailExplanation != null
          ? () => showIntelligenceExplanationSheet(
                context,
                title: ExpatScoreStrings.format(
                  'category_score_title',
                  locale,
                  params: {'category': category.title},
                ),
                explanation: category.detailExplanation!,
              )
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${category.emoji} ${category.title}',
                  style: AppTypography.title,
                ),
              ),
              Text(
                scoreLabel,
                style: AppTypography.subtitle.copyWith(
                  color: category.color,
                ),
              ),
              if (category.detailExplanation != null) ...[
                const SizedBox(width: AppSpacing.xs),
                Icon(
                  Icons.info_outline,
                  size: 18,
                  color: category.color.withValues(alpha: 0.85),
                ),
              ],
            ],
          ),
          if (category.confidence != null && category.confidence! < 0.85) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              ExpatScoreStrings.format(
                'confidence_low',
                locale,
                params: {
                  'percent': '${(category.confidence! * 100).round()}',
                },
              ),
              style: AppTypography.caption.copyWith(color: AppColors.warning),
            ),
          ],
          if (!category.insufficientData) ...[
            const SizedBox(height: AppSpacing.sm),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: category.score / 100,
                minHeight: 6,
                backgroundColor: AppColors.background,
                color: category.color,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          ...category.completed.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, size: 16, color: AppColors.success),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(item, style: AppTypography.body),
                  ),
                ],
              ),
            ),
          ),
          ...category.pending.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(left: 4, right: 8),
                    decoration: BoxDecoration(
                      color: AppColors.textTertiary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      item,
                      style: AppTypography.body.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard(
    ExpatScoreRecommendation recommendation,
    String locale,
  ) {
    return GlassCard(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      glowColor: AppColors.cyanGlow,
      glowIntensity: 0.1,
      borderRadius: AppSpacing.radiusLg,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(recommendation.action, style: AppTypography.subtitle),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  ExpatScoreStrings.format(
                    'recommendation_meta',
                    locale,
                    params: {
                      'points': '${recommendation.points}',
                      'duration': recommendation.duration,
                    },
                  ),
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => _onDoIt(recommendation, locale),
            style: TextButton.styleFrom(
              backgroundColor: AppColors.cyanGlow.withValues(alpha: 0.15),
              foregroundColor: AppColors.cyanGlow,
            ),
            child: Text(ExpatScoreStrings.t('action_do_it', locale)),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsGrid(List<_Achievement> achievements, String locale) {
    if (achievements.isEmpty) {
      return Text(
        ExpatScoreStrings.t('achievements_empty', locale),
        style: AppTypography.body.copyWith(color: AppColors.textTertiary),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
        childAspectRatio: 0.85,
      ),
      itemCount: achievements.length,
      itemBuilder: (context, index) {
        final achievement = achievements[index];
        return _AchievementBadge(achievement: achievement);
      },
    );
  }

  Widget _buildGamificationTimeline(
    List<_GamificationLevel> levels,
    String locale,
  ) {
    return GlassCard(
      width: double.infinity,
      borderRadius: AppSpacing.radiusXl,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: List.generate(levels.length, (index) {
          final level = levels[index];
          final isLast = index == levels.length - 1;
          return _TimelineLevelItem(
            level: level,
            isLast: isLast,
            locale: locale,
          );
        }),
      ),
    );
  }
}

class _ScoreArcPainter extends CustomPainter {
  _ScoreArcPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 12;
    const strokeWidth = 10.0;
    const startAngle = -math.pi * 0.75;
    const sweepAngle = math.pi * 1.5;

    final backgroundPaint = Paint()
      ..color = AppColors.surfaceElevated
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      backgroundPaint,
    );

    final rect = Rect.fromCircle(center: center, radius: radius);
    final gradientPaint = Paint()
      ..shader = const SweepGradient(
        colors: AppColors.scoreGradient,
        startAngle: startAngle,
        endAngle: startAngle + sweepAngle,
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      rect,
      startAngle,
      sweepAngle * progress.clamp(0, 1),
      false,
      gradientPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ScoreArcPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class _TrendChip extends StatelessWidget {
  const _TrendChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Text(
        label,
        style: AppTypography.bodySmall.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _AchievementBadge extends StatelessWidget {
  const _AchievementBadge({required this.achievement});

  final _Achievement achievement;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderRadius: AppSpacing.radiusLg,
      glowColor: achievement.earned ? AppColors.amberGlow : null,
      glowIntensity: achievement.earned ? 0.12 : 0,
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            achievement.emoji,
            style: TextStyle(
              fontSize: 28,
              color: achievement.earned ? null : Colors.white24,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            achievement.name,
            style: AppTypography.bodySmall.copyWith(
              color: achievement.earned
                  ? AppColors.textPrimary
                  : AppColors.textTertiary,
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
          const SizedBox(height: 2),
          Icon(
            achievement.earned ? Icons.lock_open : Icons.lock,
            size: 12,
            color: achievement.earned ? AppColors.success : AppColors.textTertiary,
          ),
        ],
      ),
    );
  }
}

class _TimelineLevelItem extends StatelessWidget {
  const _TimelineLevelItem({
    required this.level,
    required this.isLast,
    required this.locale,
  });

  final _GamificationLevel level;
  final bool isLast;
  final String locale;

  Color get _dotColor {
    switch (level.status) {
      case _LevelStatus.completed:
        return AppColors.success;
      case _LevelStatus.current:
        return AppColors.cyanGlow;
      case _LevelStatus.next:
        return AppColors.warning;
      case _LevelStatus.future:
        return AppColors.textTertiary;
    }
  }

  String get _statusLabel {
    switch (level.status) {
      case _LevelStatus.completed:
        return ExpatScoreStrings.t('status_completed', locale);
      case _LevelStatus.current:
        return ExpatScoreStrings.t('status_current', locale);
      case _LevelStatus.next:
        return ExpatScoreStrings.t('status_next', locale);
      case _LevelStatus.future:
        return ExpatScoreStrings.t('status_future', locale);
    }
  }

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: _dotColor,
                  shape: BoxShape.circle,
                  boxShadow: level.status == _LevelStatus.current
                      ? [
                          BoxShadow(
                            color: AppColors.cyanGlow.withValues(alpha: 0.5),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ]
                      : null,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: level.status == _LevelStatus.completed
                        ? AppColors.success.withValues(alpha: 0.5)
                        : AppColors.surfaceElevated,
                  ),
                ),
            ],
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.lg),
              child: Row(
                children: [
                  Text(level.emoji, style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${level.name} (${level.range})',
                          style: AppTypography.subtitle.copyWith(
                            fontSize: 14,
                            color: level.status == _LevelStatus.future
                                ? AppColors.textTertiary
                                : AppColors.textPrimary,
                            fontWeight: level.status == _LevelStatus.current
                                ? FontWeight.w800
                                : FontWeight.w500,
                          ),
                        ),
                        Text(
                          _statusLabel,
                          style: AppTypography.bodySmall.copyWith(
                            color: _dotColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum _LevelStatus { completed, current, next, future }

class _Achievement {
  const _Achievement({
    required this.emoji,
    required this.name,
    required this.earned,
  });

  final String emoji;
  final String name;
  final bool earned;
}

class _GamificationLevel {
  const _GamificationLevel({
    required this.emoji,
    required this.name,
    required this.range,
    required this.status,
  });

  final String emoji;
  final String name;
  final String range;
  final _LevelStatus status;
}
