import 'package:raabta/features/personal_budget/domain/personal_budget_models.dart';
import 'package:raabta/features/quick_actions/bill_tracker_screen.dart';

/// Maps Bill Tracker monthly totals into budget slider defaults.
abstract final class PersonalBudgetBillPrefillService {
  static PersonalBudgetInputs prefillFromBills(List<BillEntry> bills) {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month);
    final monthEnd = DateTime(now.year, now.month + 1);

    double utilities = 0;
    double rent = 0;
    double other = 0;

    for (final bill in bills) {
      if (bill.dueDate.isBefore(monthStart) || !bill.dueDate.isBefore(monthEnd)) {
        continue;
      }
      switch (bill.category) {
        case 'Electricity & Water':
        case 'District Cooling':
        case 'Gas':
        case 'Telecom':
          utilities += bill.amount;
        case 'Housing':
          rent += bill.amount;
        default:
          other += bill.amount;
      }
    }

    return PersonalBudgetInputs(
      utilities: utilities,
      rent: rent,
      other: other,
    );
  }
}
