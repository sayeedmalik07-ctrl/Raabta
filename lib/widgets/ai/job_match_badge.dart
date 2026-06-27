import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/core/design/app_colors.dart';
import 'package:raabta/core/design/app_radius.dart';
import 'package:raabta/core/design/app_spacing.dart';
import 'package:raabta/core/design/app_text_styles.dart';
import 'package:raabta/services/ai/claude_ai_service.dart';
import 'package:raabta/services/ai/job_match_service.dart';
import 'package:raabta/services/ai/user_profile_ai_service.dart';
import 'package:raabta/widgets/ai/ai_loading_skeleton.dart';
import 'package:raabta/widgets/ai/ai_match_indicator.dart';

class JobMatchBadge extends ConsumerStatefulWidget {
  const JobMatchBadge({
    super.key,
    required this.jobData,
    this.compact = false,
  });

  final Map<String, dynamic> jobData;
  final bool compact;

  @override
  ConsumerState<JobMatchBadge> createState() => _JobMatchBadgeState();
}

class _JobMatchBadgeState extends ConsumerState<JobMatchBadge> {
  JobMatchResult? _result;
  String? _aiExplanation;
  bool _loading = true;

  Color get _matchColor {
    final score = _result?.matchScore ?? 0;
    if (score >= 90) return AppColors.success;
    if (score >= 75) return AppColors.primary;
    if (score >= 60) return AppColors.info;
    if (score >= 45) return AppColors.warning;
    return AppColors.textMuted;
  }

  @override
  void initState() {
    super.initState();
    _calculate();
  }

  Future<void> _calculate() async {
    try {
      final profile =
          ref.read(userProfileAIServiceProvider).getCachedProfile() ??
              ref.read(userAIProfileProvider);

      if (profile == null) {
        if (mounted) setState(() => _loading = false);
        return;
      }

      final matchService = ref.read(jobMatchServiceProvider);
      final result = matchService.evaluateMatch(widget.jobData, profile);

      String? explanation;
      if (!widget.compact && result.matchScore >= 45) {
        final claudeService = ref.read(claudeAIServiceProvider);
        final aiResponse = await claudeService.generateJobExplanation(
          jobData: widget.jobData,
          matchScore: result.matchScore,
          profile: profile,
        );
        if (aiResponse.success) explanation = aiResponse.reply;
      }

      if (mounted) {
        setState(() {
          _result = result;
          _aiExplanation = explanation;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return widget.compact
          ? const AILoadingSkeleton(width: 80, height: 24, borderRadius: 20)
          : const AILoadingSkeleton(
              width: double.infinity,
              height: 64,
              borderRadius: AppRadius.md,
            );
    }

    if (_result == null) return const SizedBox.shrink();
    if (_result!.matchScore < 45) return const SizedBox.shrink();

    return widget.compact ? _buildCompact() : _buildFull();
  }

  Widget _buildCompact() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _matchColor.withValues(alpha: 0.12),
        border: Border.all(color: _matchColor.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🤖', style: TextStyle(fontSize: 10)),
          const SizedBox(width: 3),
          Text(
            '${_result!.matchScore}% Match',
            style: TextStyle(
              color: _matchColor,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFull() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: _matchColor.withValues(alpha: 0.06),
        border: Border(left: BorderSide(color: _matchColor, width: 3)),
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(AppRadius.md),
          bottomRight: Radius.circular(AppRadius.md),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AIMatchIndicator(matchScore: _result!.matchScore, size: 48),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '🤖 Raabta AI Analysis',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.primary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: _matchColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _result!.matchLevel,
                        style: TextStyle(
                          color: _matchColor,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${_result!.matchScore}% Profile Match',
                  style: AppTextStyles.h3.copyWith(color: _matchColor),
                ),
                if (_aiExplanation != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    _aiExplanation!,
                    style: AppTextStyles.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 6),
                _buildBreakdownChips(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownChips() {
    final breakdown = _result?.breakdown;
    if (breakdown == null) return const SizedBox.shrink();

    final chips = <Widget>[];
    for (final entry in breakdown.entries) {
      if (entry.value > 0) {
        chips.add(_chip(_labelFor(entry.key), entry.value));
        if (chips.length >= 3) break;
      }
    }

    return Wrap(spacing: 4, runSpacing: 4, children: chips);
  }

  Widget _chip(String label, int score) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$label +$score',
        style: TextStyle(
          fontSize: 9,
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _labelFor(String key) {
    const labels = {
      'skill': 'Skills',
      'experience': 'Experience',
      'location': 'Location',
      'salary': 'Salary',
      'industry': 'Industry',
    };
    return labels[key] ?? key;
  }
}
