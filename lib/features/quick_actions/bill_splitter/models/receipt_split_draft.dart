import 'package:raabta/features/quick_actions/bill_splitter/models/split_person.dart';
import 'package:raabta/services/ai/document_extraction_service.dart';

/// In-memory draft passed between receipt scan flow screens — not persisted.
class ReceiptSplitDraft {
  const ReceiptSplitDraft({
    required this.receipt,
    required this.people,
    this.billCurrency = 'QAR',
  });

  final ReceiptLineItemsExtractionResult receipt;
  final List<SplitPerson> people;
  final String billCurrency;

  ReceiptSplitDraft copyWith({
    ReceiptLineItemsExtractionResult? receipt,
    List<SplitPerson>? people,
    String? billCurrency,
  }) {
    return ReceiptSplitDraft(
      receipt: receipt ?? this.receipt,
      people: people ?? this.people,
      billCurrency: billCurrency ?? this.billCurrency,
    );
  }
}
