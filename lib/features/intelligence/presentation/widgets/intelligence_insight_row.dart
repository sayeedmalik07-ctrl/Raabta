import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/intelligence/capabilities.dart';
import 'package:raabta/core/glass/glass_card.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/models/intelligence/explanation.dart';
import 'package:raabta/models/intelligence/intelligence_source.dart';
import 'package:raabta/services/intelligence/opportunity_insight_adapter.dart';
import 'package:raabta/services/intelligence/risk_insight_adapter.dart';

/// List row for a scored Risk or Opportunity insight.
///
/// Mirrors [EosbBreakdownRow] layout: [GlassCard] row, caption subtitle,
/// trailing metric, and info icon opening a transparency bottom sheet.
class IntelligenceInsightRow extends StatelessWidget {
  const IntelligenceInsightRow({
    super.key,
    required this.title,
    required this.explanation,
    this.subtitle,
    this.onExpand,
  });

  final String title;
  final Explanation explanation;
  final String? subtitle;
  final VoidCallback? onExpand;

  @override
  Widget build(BuildContext context) {
    final caption = subtitle ?? explanation.why;
    final confidenceLabel =
        '${(explanation.confidence * 100).round()}%';

    return GlassCard(
      onTap: onExpand,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.title.copyWith(fontSize: 14),
                ),
                Text(
                  caption,
                  style: AppTypography.caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Text(
            confidenceLabel,
            style: AppTypography.title.copyWith(
              color: explanation.confidence >= 0.7
                  ? AppColors.successBright
                  : AppColors.textSecondary,
            ),
          ),
          if (onExpand != null) ...[
            const SizedBox(width: AppSpacing.xs),
            IconButton(
              icon: const Icon(Icons.info_outline, size: AppSpacing.iconSm),
              color: AppColors.info,
              onPressed: onExpand,
              visualDensity: VisualDensity.compact,
            ),
          ],
        ],
      ),
    );
  }
}

/// Bottom sheet for "why am I seeing this" — same structure as
/// [showEosbBreakdownSheet] (headline, metric, three labelled sections).
void showIntelligenceExplanationSheet(
  BuildContext context, {
  required String title,
  required Explanation explanation,
  Capability? actionCapability,
}) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusLg)),
    ),
    builder: (ctx) => Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTypography.headline2),
            const SizedBox(height: AppSpacing.md),
            Text(
              '${(explanation.confidence * 100).round()}% confidence',
              style: AppTypography.display.copyWith(
                color: AppColors.successBright,
                fontSize: 28,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Why you\'re seeing this', style: AppTypography.title),
            Text(explanation.why, style: AppTypography.body),
            const SizedBox(height: AppSpacing.md),
            Text('Source', style: AppTypography.title),
            Text(
              _formatSource(explanation.source),
              style: AppTypography.bodySmall,
            ),
            const SizedBox(height: AppSpacing.md),
            Text('Last updated', style: AppTypography.title),
            Text(
              _formatTimestamp(explanation.lastUpdated),
              style: AppTypography.bodySmall,
            ),
            if (actionCapability != null) ...[
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    ctx.push(actionCapability.route);
                  },
                  child: Text('Open ${actionCapability.name}'),
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    ),
  );
}

/// Renders a [ScoredRisk] using the EOSB breakdown row + sheet pattern.
class ScoredRiskInsightRow extends StatelessWidget {
  const ScoredRiskInsightRow({
    super.key,
    required this.scored,
  });

  final ScoredRisk scored;

  @override
  Widget build(BuildContext context) {
    return IntelligenceInsightRow(
      title: scored.insight.summary,
      explanation: scored.explanation,
      onExpand: () => showIntelligenceExplanationSheet(
        context,
        title: scored.insight.summary,
        explanation: scored.explanation,
      ),
    );
  }
}

/// Renders a [ScoredOpportunity] using the EOSB breakdown row + sheet pattern.
class ScoredOpportunityInsightRow extends StatelessWidget {
  const ScoredOpportunityInsightRow({
    super.key,
    required this.scored,
  });

  final ScoredOpportunity scored;

  @override
  Widget build(BuildContext context) {
    return IntelligenceInsightRow(
      title: scored.insight.summary,
      explanation: scored.explanation,
      onExpand: () => showIntelligenceExplanationSheet(
        context,
        title: scored.insight.summary,
        explanation: scored.explanation,
      ),
    );
  }
}

String _formatSource(IntelligenceSource source) {
  final ref = source.reference;
  if (ref != null && ref.isNotEmpty) {
    return '${source.type} · $ref · ${source.verificationStatus}';
  }
  return '${source.type} · ${source.verificationStatus}';
}

String _formatTimestamp(DateTime dt) =>
    '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
    '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
