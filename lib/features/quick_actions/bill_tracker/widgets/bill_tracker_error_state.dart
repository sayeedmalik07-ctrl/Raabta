import 'package:flutter/material.dart';
import 'package:raabta/core/l10n/common_action_strings.dart';
import 'package:raabta/core/widgets/glass_error_state.dart';
import 'package:raabta/features/quick_actions/bill_tracker/l10n/bill_tracker_strings.dart';

class BillTrackerErrorState extends StatelessWidget {
  const BillTrackerErrorState({
    super.key,
    required this.locale,
    required this.error,
    required this.onRetry,
  });

  final String locale;
  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: GlassErrorState(
          message:
              '${BillTrackerStrings.t('error_load_bills', locale)}\n$error',
          onRetry: onRetry,
          retryLabel: CommonActionStrings.t('action_retry', locale),
        ),
      ),
    );
  }
}
