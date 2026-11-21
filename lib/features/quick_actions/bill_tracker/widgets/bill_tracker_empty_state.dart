import 'package:flutter/material.dart';
import 'package:raabta/core/widgets/glass_empty_state.dart';
import 'package:raabta/features/quick_actions/bill_tracker/l10n/bill_tracker_strings.dart';

class BillTrackerEmptyState extends StatelessWidget {
  const BillTrackerEmptyState({
    super.key,
    required this.locale,
    required this.onAddBill,
  });

  final String locale;
  final VoidCallback onAddBill;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: GlassEmptyState(
          icon: Icons.receipt_long_outlined,
          title: BillTrackerStrings.t('empty_title', locale),
          description: BillTrackerStrings.t('empty_description', locale),
          actionLabel: BillTrackerStrings.t('empty_action', locale),
          onAction: onAddBill,
        ),
      ),
    );
  }
}
