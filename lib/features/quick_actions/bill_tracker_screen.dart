export 'package:raabta/features/quick_actions/bill_tracker/domain/bill_entry.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/core/widgets/glass_screen_scaffold.dart';
import 'package:raabta/features/bill_tracker/friends_family_loans/presentation/screens/loans_overview_screen.dart';
import 'package:raabta/features/quick_actions/bill_tracker/l10n/bill_tracker_strings.dart';
import 'package:raabta/features/quick_actions/bill_tracker/presentation/bill_tracker_bill_actions.dart';
import 'package:raabta/features/quick_actions/bill_tracker/widgets/add_bill_sheet.dart';
import 'package:raabta/features/quick_actions/bill_tracker/widgets/utility_bills_tab.dart';
import 'package:raabta/providers/visa_providers.dart';

enum _BillTrackerSection { utilityBills, friendsFamilyLoans }

class BillTrackerScreen extends ConsumerWidget {
  const BillTrackerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = AppLocale.normalize(ref.watch(userLanguageProvider));
    final isRtl = AppLocale.isRtl(locale);
    final section = ref.watch(_billTrackerSectionProvider);

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: GlassScreenScaffold(
        title: BillTrackerStrings.t('screen_title', locale),
        actions: [
          if (section == _BillTrackerSection.utilityBills)
            IconButton(
              onPressed: () => _showAddBillSheet(context, ref, locale),
              icon: const Icon(
                Icons.add_circle_outline_rounded,
                color: AppColors.amberGlow,
              ),
              tooltip: BillTrackerStrings.t('add_bill_tooltip', locale),
            )
          else
            IconButton(
              onPressed: () => context.push('/bill-tracker/loans/add'),
              icon: const Icon(
                Icons.add_circle_outline_rounded,
                color: AppColors.amberGlow,
              ),
              tooltip: BillTrackerStrings.t('add_loan_tooltip', locale),
            ),
        ],
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: SegmentedButton<_BillTrackerSection>(
                segments: [
                  ButtonSegment(
                    value: _BillTrackerSection.utilityBills,
                    label: Text(
                      BillTrackerStrings.t('tab_utility_bills', locale),
                    ),
                    icon: const Icon(Icons.receipt_long_rounded, size: 18),
                  ),
                  ButtonSegment(
                    value: _BillTrackerSection.friendsFamilyLoans,
                    label: Text(
                      BillTrackerStrings.t('tab_friends_family', locale),
                    ),
                    icon: const Icon(Icons.groups_rounded, size: 18),
                  ),
                ],
                selected: {section},
                onSelectionChanged: (value) => ref
                    .read(_billTrackerSectionProvider.notifier)
                    .state = value.first,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: section == _BillTrackerSection.utilityBills
                  ? const UtilityBillsTab()
                  : const LoansOverviewScreen(),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddBillSheet(
    BuildContext context,
    WidgetRef ref,
    String locale,
  ) {
    AddBillSheet.show(
      context,
      locale: locale,
      onSubmit: ({
        required String provider,
        required String category,
        required String emoji,
        required double amount,
        required DateTime dueDate,
        String accountNumber = '',
      }) =>
          BillTrackerBillActions.addBill(
            ref,
            context: context,
            provider: provider,
            category: category,
            emoji: emoji,
            amount: amount,
            dueDate: dueDate,
            accountNumber: accountNumber,
          ),
    );
  }
}

final _billTrackerSectionProvider =
    StateProvider<_BillTrackerSection>((ref) {
  return _BillTrackerSection.utilityBills;
});
