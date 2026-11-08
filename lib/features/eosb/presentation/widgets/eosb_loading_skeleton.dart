import 'package:flutter/material.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/widgets/truth_engine_result_skeleton.dart';
import 'package:raabta/widgets/ai/ai_loading_skeleton.dart';

class EosbDashboardSkeleton extends StatelessWidget {
  const EosbDashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: const [
        AILoadingSkeleton(width: double.infinity, height: 14, borderRadius: 6),
        SizedBox(height: AppSpacing.md),
        AILoadingSkeleton(width: double.infinity, height: 72, borderRadius: 12),
        SizedBox(height: AppSpacing.lg),
        AILoadingSkeleton(width: double.infinity, height: 140, borderRadius: 16),
        SizedBox(height: AppSpacing.lg),
        AILoadingSkeleton(width: double.infinity, height: 48, borderRadius: 12),
        SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 88,
                child: AILoadingSkeleton(
                  width: double.infinity,
                  height: 88,
                  borderRadius: 12,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: SizedBox(
                height: 88,
                child: AILoadingSkeleton(
                  width: double.infinity,
                  height: 88,
                  borderRadius: 12,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class EosbResultSkeleton extends StatelessWidget {
  const EosbResultSkeleton({super.key});

  @override
  Widget build(BuildContext context) => const TruthEngineResultSkeleton();
}
