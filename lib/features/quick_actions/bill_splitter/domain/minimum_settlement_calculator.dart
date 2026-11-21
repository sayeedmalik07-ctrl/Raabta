/// Greedy minimum-payment settlement for group bill splits.
abstract final class MinimumSettlementCalculator {
  MinimumSettlementCalculator._();

  static const epsilon = 0.009;

  /// Net balance per person: positive = should receive, negative = should pay.
  static Map<String, double> netBalances({
    required Map<String, double> sharesByPersonId,
    required double totalBill,
    required String payerId,
  }) {
    final balances = <String, double>{};
    for (final entry in sharesByPersonId.entries) {
      if (entry.key == payerId) {
        balances[entry.key] = totalBill - entry.value;
      } else {
        balances[entry.key] = -entry.value;
      }
    }
    return balances;
  }

  /// Fewest payments to zero all balances (largest creditor ↔ largest debtor).
  static List<SettlementPayment> simplify(Map<String, double> netBalances) {
    final creditors = <_Node>[];
    final debtors = <_Node>[];

    for (final entry in netBalances.entries) {
      final value = entry.value;
      if (value.abs() < epsilon) continue;
      if (value > 0) {
        creditors.add(_Node(entry.key, value));
      } else {
        debtors.add(_Node(entry.key, -value));
      }
    }

    creditors.sort((a, b) => b.amount.compareTo(a.amount));
    debtors.sort((a, b) => b.amount.compareTo(a.amount));

    final payments = <SettlementPayment>[];
    var ci = 0;
    var di = 0;

    while (ci < creditors.length && di < debtors.length) {
      final pay = creditors[ci].amount < debtors[di].amount
          ? creditors[ci].amount
          : debtors[di].amount;
      if (pay >= epsilon) {
        payments.add(
          SettlementPayment(
            fromPersonId: debtors[di].id,
            toPersonId: creditors[ci].id,
            amount: pay,
          ),
        );
      }

      creditors[ci] = _Node(creditors[ci].id, creditors[ci].amount - pay);
      debtors[di] = _Node(debtors[di].id, debtors[di].amount - pay);

      if (creditors[ci].amount < epsilon) ci++;
      if (debtors[di].amount < epsilon) di++;
    }

    return payments;
  }
}

class SettlementPayment {
  const SettlementPayment({
    required this.fromPersonId,
    required this.toPersonId,
    required this.amount,
  });

  final String fromPersonId;
  final String toPersonId;
  final double amount;
}

class _Node {
  const _Node(this.id, this.amount);

  final String id;
  final double amount;
}
