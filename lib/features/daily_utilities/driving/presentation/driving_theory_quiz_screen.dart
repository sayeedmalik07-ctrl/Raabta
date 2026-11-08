import 'package:flutter/material.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/features/daily_utilities/driving/data/theory_quiz_progress.dart';
import 'package:raabta/features/daily_utilities/driving/domain/driving_theory_questions.dart';
import 'package:raabta/features/daily_utilities/driving/widgets/unpaid_fines_banner.dart';

class DrivingTheoryQuizScreen extends StatefulWidget {
  const DrivingTheoryQuizScreen({super.key});

  @override
  State<DrivingTheoryQuizScreen> createState() => _DrivingTheoryQuizScreenState();
}

class _DrivingTheoryQuizScreenState extends State<DrivingTheoryQuizScreen> {
  TheoryQuizCategory? _category;
  List<TheoryQuestion> _questions = [];
  int _index = 0;
  int? _selected;
  bool _showExplanation = false;
  int _correct = 0;
  final _missed = <TheoryQuestion>[];
  bool _finished = false;

  void _start({TheoryQuizCategory? category, bool missedOnly = false}) {
    final pool = missedOnly
        ? List<TheoryQuestion>.from(_missed)
        : questionsForCategory(category);
    setState(() {
      _category = category;
      _questions = pool..shuffle();
      _index = 0;
      _selected = null;
      _showExplanation = false;
      _correct = 0;
      if (!missedOnly) _missed.clear();
      _finished = false;
    });
  }

  void _pick(int i) {
    if (_showExplanation || _finished) return;
    setState(() {
      _selected = i;
      _showExplanation = true;
      final q = _questions[_index];
      if (i == q.correctIndex) {
        _correct++;
      } else {
        _missed.add(q);
      }
    });
  }

  void _next() {
    if (_index + 1 >= _questions.length) {
      _finish();
      return;
    }
    setState(() {
      _index++;
      _selected = null;
      _showExplanation = false;
    });
  }

  Future<void> _finish() async {
    final mode = _category?.id ?? 'mixed';
    await TheoryQuizProgressService.recordAttempt(
      modeKey: mode,
      score: _correct,
      total: _questions.length,
    );
    setState(() => _finished = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty && !_finished) {
      return GlassScreenScaffold(
        title: 'Theory Quiz',
        body: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            const UnpaidFinesBanner(),
            GlassCard(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Text(
                'Unofficial practice only — not an MOI-certified test. '
                'Content verified against published guidance (Jul 2026); expand with licensed school material before marketing.',
                style: AppTypography.caption.copyWith(color: AppColors.accentGold),
              ),
            ),
            const SizedBox(height: 12),
            GlassCard(
              onTap: () => _start(),
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  const Text('🎯', style: TextStyle(fontSize: 28)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text('Full mixed test', style: AppTypography.title),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
            ),
            const SizedBox(height: 8),
            ...TheoryQuizCategory.values.map(
              (c) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: GlassCard(
                  onTap: () => _start(category: c),
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    children: [
                      Expanded(child: Text(c.label, style: AppTypography.title.copyWith(fontSize: 14))),
                      const Icon(Icons.chevron_right, size: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (_finished) {
      return GlassScreenScaffold(
        title: 'Results',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => setState(() {
            _questions = [];
            _finished = false;
          }),
        ),
        body: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            children: [
              Text(
                '$_correct / ${_questions.length}',
                style: AppTypography.headline2.copyWith(
                  fontSize: 48,
                  color: AppColors.accentGold,
                ),
              ),
              Text('correct', style: AppTypography.title),
              const SizedBox(height: 24),
              if (_missed.isNotEmpty)
                FilledButton(
                  onPressed: () => _start(missedOnly: true),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.sharePurple,
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  child: Text('Retry ${_missed.length} missed'),
                ),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: () => _start(category: _category),
                child: const Text('Try again'),
              ),
            ],
          ),
        ),
      );
    }

    final q = _questions[_index];
    return GlassScreenScaffold(
      title: q.category.label,
      leading: IconButton(
        icon: const Icon(Icons.close, color: Colors.white),
        onPressed: () => setState(() => _questions = []),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LinearProgressIndicator(
              value: (_index + 1) / _questions.length,
              color: AppColors.sharePurple,
              backgroundColor: Colors.white12,
            ),
            const SizedBox(height: 16),
            Text(
              'Question ${_index + 1} of ${_questions.length}',
              style: AppTypography.caption,
            ),
            const SizedBox(height: 8),
            Text(q.question, style: AppTypography.title.copyWith(fontSize: 16)),
            const SizedBox(height: 16),
            ...List.generate(q.options.length, (i) {
              final selected = _selected == i;
              final correct = i == q.correctIndex;
              Color? border;
              if (_showExplanation) {
                if (correct) border = AppColors.successBright;
                else if (selected) border = AppColors.errorBright;
              }
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: OutlinedButton(
                  onPressed: () => _pick(i),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(
                      color: border ?? Colors.white24,
                      width: border != null ? 2 : 1,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                    alignment: Alignment.centerLeft,
                  ),
                  child: Text(q.options[i]),
                ),
              );
            }),
            if (_showExplanation) ...[
              const SizedBox(height: 8),
              GlassCard(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Text(q.explanation, style: AppTypography.bodySmall),
              ),
              const Spacer(),
              FilledButton(
                onPressed: _next,
                style: FilledButton.styleFrom(backgroundColor: AppColors.sharePurple),
                child: Text(
                  _index + 1 >= _questions.length ? 'See results' : 'Next',
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
