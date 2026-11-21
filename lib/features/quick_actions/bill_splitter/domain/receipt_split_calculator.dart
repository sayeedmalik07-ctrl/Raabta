import 'package:raabta/features/quick_actions/bill_splitter/models/split_person.dart';
import 'package:raabta/services/ai/document_extraction_service.dart';

enum ReceiptChargeSplitMode { proportional, equalAmongAll }

class ReceiptSplitPersonTotal {
  const ReceiptSplitPersonTotal({
    required this.person,
    required this.itemsSubtotal,
    required this.chargesShare,
    required this.totalQar,
  });

  final SplitPerson person;
  final double itemsSubtotal;
  final double chargesShare;
  final double totalQar;
}

abstract final class ReceiptSplitCalculator {
  ReceiptSplitCalculator._();

  static double lineItemsSubtotal(List<ReceiptLineItemRow> items) {
    return items.fold(0.0, (sum, item) => sum + item.lineTotal);
  }

  static double chargesTotal({
    required double? tax,
    required double? serviceCharge,
    required double? tip,
  }) {
    return (tax ?? 0) + (serviceCharge ?? 0) + (tip ?? 0);
  }

  /// Assigns each line item equally among [assigneeIds]; empty assignees skipped.
  static Map<String, double> itemSharesByPerson({
    required List<ReceiptLineItemRow> items,
    required Map<int, Set<String>> assignmentsByItemIndex,
  }) {
    final totals = <String, double>{};
    for (var i = 0; i < items.length; i++) {
      final assignees = assignmentsByItemIndex[i] ?? {};
      if (assignees.isEmpty) continue;
      final share = items[i].lineTotal / assignees.length;
      for (final id in assignees) {
        totals[id] = (totals[id] ?? 0) + share;
      }
    }
    return totals;
  }

  static List<ReceiptSplitPersonTotal> compute({
    required List<SplitPerson> people,
    required List<ReceiptLineItemRow> items,
    required Map<int, Set<String>> assignmentsByItemIndex,
    required double? tax,
    required double? serviceCharge,
    required double? tip,
    ReceiptChargeSplitMode chargeMode = ReceiptChargeSplitMode.proportional,
  }) {
    if (people.isEmpty) return const [];

    final itemShares = itemSharesByPerson(
      items: items,
      assignmentsByItemIndex: assignmentsByItemIndex,
    );
    final subtotalAll = lineItemsSubtotal(items);
    final charges = chargesTotal(
      tax: tax,
      serviceCharge: serviceCharge,
      tip: tip,
    );

    return people.map((person) {
      final id = person.stableId;
      final itemsSubtotal = itemShares[id] ?? 0;
      final chargesShare = switch (chargeMode) {
        ReceiptChargeSplitMode.equalAmongAll => charges / people.length,
        ReceiptChargeSplitMode.proportional =>
          subtotalAll <= 0 ? charges / people.length : charges * (itemsSubtotal / subtotalAll),
      };
      return ReceiptSplitPersonTotal(
        person: person,
        itemsSubtotal: itemsSubtotal,
        chargesShare: chargesShare,
        totalQar: itemsSubtotal + chargesShare,
      );
    }).toList(growable: false);
  }
}
