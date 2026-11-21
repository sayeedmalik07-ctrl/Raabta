import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/spacing/app_spacing.dart';
import 'package:raabta/core/typography/app_typography.dart';
import 'package:raabta/core/widgets/glass_progress_indicator.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/features/trip_planner/presentation/l10n/trip_strings.dart';
import 'package:raabta/features/trip_planner/providers/trip_planner_providers.dart';

class TripGeneratingScreen extends ConsumerStatefulWidget {
  const TripGeneratingScreen({super.key});

  @override
  ConsumerState<TripGeneratingScreen> createState() =>
      _TripGeneratingScreenState();
}

class _TripGeneratingScreenState extends ConsumerState<TripGeneratingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _run());
  }

  Future<void> _run() async {
    final plan = await ref.read(tripPlannerProvider.notifier).generateTrip();
    if (!mounted) return;
    if (plan != null) {
      context.replace('/trip-planner/itinerary/${plan.id}');
    } else {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(tripPlannerProvider).preferences.locale;
    return GlassScreenScaffold(
      title: TripStrings.t('trip_generate', locale),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const GlassProgressIndicator(),
            const SizedBox(height: AppSpacing.lg),
            Text(
              TripStrings.t('trip_generating', locale),
              style: AppTypography.body,
            ),
          ],
        ),
      ),
    );
  }
}
