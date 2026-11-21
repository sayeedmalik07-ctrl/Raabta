import 'package:flutter/material.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/widgets/ai/ai_loading_skeleton.dart';

/// Shared loading skeleton for Truth Engine result screens.
class TruthEngineResultSkeleton extends StatelessWidget {
  const TruthEngineResultSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: const [
        AILoadingSkeleton(width: double.infinity, height: 72, borderRadius: 12),
        SizedBox(height: AppSpacing.lg),
        AILoadingSkeleton(width: double.infinity, height: 160, borderRadius: 16),
        SizedBox(height: AppSpacing.lg),
        AILoadingSkeleton(width: double.infinity, height: 120, borderRadius: 12),
        SizedBox(height: AppSpacing.sm),
        AILoadingSkeleton(width: double.infinity, height: 56, borderRadius: 12),
        SizedBox(height: AppSpacing.sm),
        AILoadingSkeleton(width: double.infinity, height: 56, borderRadius: 12),
      ],
    );
  }
}
