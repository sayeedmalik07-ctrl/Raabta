import '../models/eosb_employee_input.dart';
import '../models/eosb_result.dart';

/// Return / family ticket entitlement (contractual estimate).
class TicketCalculator {
  const TicketCalculator._();

  static const _economyTicketEstimate = 2500.0;
  static const _dependentTicketEstimate = 1800.0;

  static List<EntitlementBreakdownItem> calculate(EosbEmployeeInput input) {
    final items = <EntitlementBreakdownItem>[];

    if (input.returnTicketIncluded) {
      items.add(
        const EntitlementBreakdownItem(
          id: 'return_ticket',
          titleKey: 'eosb_return_ticket',
          amount: _economyTicketEstimate,
          formulaKey: 'eosb_ticket_formula',
          ruleKey: 'eosb_ticket_rule',
          exampleKey: 'eosb_ticket_example',
        ),
      );
    }

    if (input.familySponsored && input.dependentsCount > 0) {
      items.add(
        EntitlementBreakdownItem(
          id: 'family_ticket',
          titleKey: 'eosb_family_ticket',
          amount: _dependentTicketEstimate * input.dependentsCount,
          formulaKey: 'eosb_family_ticket_formula',
          ruleKey: 'eosb_family_ticket_rule',
          exampleKey: 'eosb_family_ticket_example',
        ),
      );
    }

    return items;
  }
}
