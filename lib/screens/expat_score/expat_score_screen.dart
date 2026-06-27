import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/design/app_colors.dart';
import 'package:raabta/core/design/app_radius.dart';
import 'package:raabta/core/design/app_spacing.dart';
import 'package:raabta/core/design/app_text_styles.dart';
import 'package:share_plus/share_plus.dart';

class ExpatScoreScreen extends StatefulWidget {
  const ExpatScoreScreen({super.key});

  @override
  State<ExpatScoreScreen> createState() => _ExpatScoreScreenState();
}

class _ExpatScoreScreenState extends State<ExpatScoreScreen>
    with SingleTickerProviderStateMixin {
  static const int _score = 72;
  static const String _levelLabel = 'Growing Strong 📈';

  late AnimationController _arcController;
  late Animation<double> _arcAnimation;

  static const List<String> _levels = [
    'New Arrival',
    'Settling In',
    'Growing Strong',
    'Established',
    'Qatar Pro',
  ];

  static const List<_CategoryScore> _categories = [
    _CategoryScore(
      emoji: '💼',
      title: 'Career',
      score: 78,
      color: AppColors.primary,
      completed: [
        'Job profile complete',
        'Skills listed',
        'Experience added',
      ],
      pending: [
        'Post your first job review',
        'Add certifications',
      ],
    ),
    _CategoryScore(
      emoji: '🏠',
      title: 'Housing',
      score: 62,
      color: AppColors.info,
      completed: [
        'Current accommodation confirmed',
        'Area preference set',
      ],
      pending: [
        'Get verified housing listing',
        'Add housing review',
      ],
    ),
    _CategoryScore(
      emoji: '💰',
      title: 'Financial',
      score: 80,
      color: AppColors.success,
      completed: [
        'Money transfer preference set',
        'Exchange rate alerts active',
        'Salary range added',
      ],
      pending: [
        'Add emergency fund status',
      ],
    ),
    _CategoryScore(
      emoji: '👥',
      title: 'Community',
      score: 45,
      color: AppColors.secondary,
      completed: [
        'Joined 2 community groups',
      ],
      pending: [
        'Post in community (earn 10pts)',
        'Answer 3 questions',
        'Attend 1 event',
      ],
    ),
    _CategoryScore(
      emoji: '📋',
      title: 'Documentation',
      score: 65,
      color: AppColors.warning,
      completed: [
        'Iqama deadline set',
        'Passport expiry tracked',
      ],
      pending: [
        'Add QID information',
        'Set medical card reminder',
      ],
    ),
  ];

  static const List<_AiRecommendation> _recommendations = [
    _AiRecommendation(
      action: 'Post a community question',
      points: 15,
      duration: '2 minutes',
    ),
    _AiRecommendation(
      action: 'Add your driving license info',
      points: 10,
      duration: '1 minute',
    ),
    _AiRecommendation(
      action: 'Refer 1 friend',
      points: 50,
      duration: 'Share link',
    ),
  ];

  static const List<_Achievement> _achievements = [
    _Achievement(emoji: '🌟', name: 'Early Adopter', earned: true),
    _Achievement(emoji: '💼', name: 'Job Seeker', earned: true),
    _Achievement(emoji: '🏠', name: 'Home Hunter', earned: false),
    _Achievement(emoji: '🤝', name: 'Connector', earned: false),
    _Achievement(emoji: '🌍', name: 'Qatar Pro', earned: false),
  ];

  static const List<_GamificationLevel> _gamificationLevels = [
    _GamificationLevel(
      emoji: '🆕',
      name: 'New Arrival',
      range: '0–20',
      status: _LevelStatus.completed,
    ),
    _GamificationLevel(
      emoji: '🏠',
      name: 'Settling In',
      range: '21–40',
      status: _LevelStatus.completed,
    ),
    _GamificationLevel(
      emoji: '📈',
      name: 'Growing Strong',
      range: '41–60',
      status: _LevelStatus.current,
    ),
    _GamificationLevel(
      emoji: '🏆',
      name: 'Established Resident',
      range: '61–80',
      status: _LevelStatus.next,
    ),
    _GamificationLevel(
      emoji: '⭐',
      name: 'Qatar Pro',
      range: '81–100',
      status: _LevelStatus.future,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _arcController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _arcAnimation = Tween<double>(begin: 0, end: _score / 100).animate(
      CurvedAnimation(parent: _arcController, curve: Curves.easeOutCubic),
    );
    _arcController.forward();
  }

  @override
  void dispose() {
    _arcController.dispose();
    super.dispose();
  }

  void _shareScore() {
    Share.share(
      'My Raabta Expat Life Score is $_score — $_levelLabel. '
      'Track your Qatar journey on Raabta!',
      subject: 'My Expat Life Score',
    );
  }

  void _onDoIt(_AiRecommendation recommendation) {
    if (recommendation.action == 'Refer 1 friend') {
      _shareScore();
      return;
    }
    if (recommendation.action == 'Post a community question') {
      context.push('/community');
      return;
    }
    if (recommendation.action == 'Add your driving license info') {
      context.push('/visa');
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${recommendation.action} — Coming Soon'),
        backgroundColor: AppColors.surfaceElevated,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Expat Life Score', style: AppTextStyles.h2),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.share_outlined, color: AppColors.textPrimary),
            onPressed: _shareScore,
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl,
          0,
          AppSpacing.xl,
          AppSpacing.xxxl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeroSection(),
            const SizedBox(height: AppSpacing.xxl),
            _buildWeeklyTrend(),
            const SizedBox(height: AppSpacing.xxl),
            Text('📊 Score Breakdown', style: AppTextStyles.h2),
            const SizedBox(height: AppSpacing.md),
            ..._categories.map(_buildCategoryCard),
            const SizedBox(height: AppSpacing.xxl),
            Text(
              '🤖 AI Recommendations to Improve Score',
              style: AppTextStyles.h2,
            ),
            const SizedBox(height: AppSpacing.md),
            ..._recommendations.map(_buildRecommendationCard),
            const SizedBox(height: AppSpacing.xxl),
            Text('🏆 Your Achievements', style: AppTextStyles.h2),
            const SizedBox(height: AppSpacing.md),
            _buildAchievementsGrid(),
            const SizedBox(height: AppSpacing.xxl),
            Text('Level Journey', style: AppTextStyles.h2),
            const SizedBox(height: AppSpacing.md),
            _buildGamificationTimeline(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
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
                        '$_score',
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
          _levelLabel,
          style: const TextStyle(
            color: AppColors.warning,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        _buildLevelProgression(),
      ],
    );
  }

  Widget _buildLevelProgression() {
    const currentLevelIndex = 2;
    const completedLevels = 3;

    return Column(
      children: [
        Row(
          children: List.generate(_levels.length, (index) {
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
                            ? AppColors.primary
                            : AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  if (index < _levels.length - 1) const SizedBox(width: 4),
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
          children: List.generate(_levels.length, (index) {
            final isCurrent = index == currentLevelIndex;
            return Text(
              _levels[index],
              style: AppTextStyles.bodySmall.copyWith(
                color: isCurrent ? AppColors.primary : AppColors.textMuted,
                fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w400,
                fontSize: 10,
              ),
            );
          }),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Progress: $completedLevels/${_levels.length} levels complete',
          style: AppTextStyles.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildWeeklyTrend() {
    const weeklyScores = [64.0, 67.0, 69.0, 72.0];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Weekly Trend', style: AppTextStyles.h3),
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
                        const labels = ['Wk 1', 'Wk 2', 'Wk 3', 'Wk 4'];
                        final index = value.toInt();
                        if (index < 0 || index >= labels.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            labels[index],
                            style: AppTextStyles.bodySmall,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minY: 60,
                maxY: 75,
                lineBarsData: [
                  LineChartBarData(
                    spots: List.generate(
                      weeklyScores.length,
                      (i) => FlSpot(i.toDouble(), weeklyScores[i]),
                    ),
                    isCurved: true,
                    color: AppColors.primary,
                    barWidth: 3,
                    dotData: FlDotData(
                      getDotPainter: (spot, percent, bar, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: AppColors.primary,
                          strokeWidth: 2,
                          strokeColor: AppColors.background,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withValues(alpha: 0.25),
                          AppColors.primary.withValues(alpha: 0),
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
              _TrendChip(label: 'This week: +5 pts', color: AppColors.success),
              const SizedBox(width: AppSpacing.sm),
              _TrendChip(label: 'Last week: +3 pts', color: AppColors.success),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(_CategoryScore category) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${category.emoji} ${category.title}',
                  style: AppTextStyles.h3,
                ),
              ),
              Text(
                '${category.score}/100',
                style: AppTextStyles.labelLarge.copyWith(
                  color: category.color,
                ),
              ),
            ],
          ),
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
          const SizedBox(height: AppSpacing.md),
          ...category.completed.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, size: 16, color: AppColors.success),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(item, style: AppTextStyles.bodyMedium),
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
                      color: AppColors.textMuted,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      item,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textMuted,
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

  Widget _buildRecommendationCard(_AiRecommendation recommendation) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.borderPrimary),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(recommendation.action, style: AppTextStyles.bodyLarge),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '+${recommendation.points} points · ${recommendation.duration}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => _onDoIt(recommendation),
            style: TextButton.styleFrom(
              backgroundColor: AppColors.primary.withValues(alpha: 0.15),
              foregroundColor: AppColors.primary,
            ),
            child: const Text('Do It'),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
        childAspectRatio: 0.85,
      ),
      itemCount: _achievements.length,
      itemBuilder: (context, index) {
        final achievement = _achievements[index];
        return _AchievementBadge(achievement: achievement);
      },
    );
  }

  Widget _buildGamificationTimeline() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: List.generate(_gamificationLevels.length, (index) {
          final level = _gamificationLevels[index];
          final isLast = index == _gamificationLevels.length - 1;
          return _TimelineLevelItem(
            level: level,
            isLast: isLast,
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
        colors: [AppColors.primary, AppColors.accent, AppColors.primary],
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
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        label,
        style: AppTextStyles.bodySmall.copyWith(
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
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: achievement.earned
            ? AppColors.surfaceElevated
            : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: achievement.earned
              ? AppColors.gold.withValues(alpha: 0.4)
              : AppColors.border,
        ),
      ),
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
            style: AppTextStyles.bodySmall.copyWith(
              color: achievement.earned
                  ? AppColors.textPrimary
                  : AppColors.textMuted,
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
          const SizedBox(height: 2),
          Icon(
            achievement.earned ? Icons.lock_open : Icons.lock,
            size: 12,
            color: achievement.earned ? AppColors.success : AppColors.textMuted,
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
  });

  final _GamificationLevel level;
  final bool isLast;

  Color get _dotColor {
    switch (level.status) {
      case _LevelStatus.completed:
        return AppColors.success;
      case _LevelStatus.current:
        return AppColors.primary;
      case _LevelStatus.next:
        return AppColors.warning;
      case _LevelStatus.future:
        return AppColors.textMuted;
    }
  }

  String get _statusLabel {
    switch (level.status) {
      case _LevelStatus.completed:
        return 'completed';
      case _LevelStatus.current:
        return 'CURRENT';
      case _LevelStatus.next:
        return 'next';
      case _LevelStatus.future:
        return 'future';
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
                            color: AppColors.primary.withValues(alpha: 0.5),
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
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontSize: 14,
                            color: level.status == _LevelStatus.future
                                ? AppColors.textMuted
                                : AppColors.textPrimary,
                            fontWeight: level.status == _LevelStatus.current
                                ? FontWeight.w800
                                : FontWeight.w500,
                          ),
                        ),
                        Text(
                          _statusLabel,
                          style: AppTextStyles.bodySmall.copyWith(
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

class _CategoryScore {
  const _CategoryScore({
    required this.emoji,
    required this.title,
    required this.score,
    required this.color,
    required this.completed,
    required this.pending,
  });

  final String emoji;
  final String title;
  final int score;
  final Color color;
  final List<String> completed;
  final List<String> pending;
}

class _AiRecommendation {
  const _AiRecommendation({
    required this.action,
    required this.points,
    required this.duration,
  });

  final String action;
  final int points;
  final String duration;
}

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
