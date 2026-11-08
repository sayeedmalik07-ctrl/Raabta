import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:raabta/features/money_comparator/domain/corridor_transfer_method.dart';

/// One crowdsourced transfer report — written to `corridor_reports`.
class CorridorReport {
  const CorridorReport({
    required this.destinationCountryCode,
    required this.destinationCurrencyCode,
    required this.destinationCountryName,
    required this.amountSentQar,
    required this.method,
    required this.providerName,
    required this.feePaidQar,
    required this.amountRecipientGot,
    required this.deliveryHours,
    this.id,
    this.userId,
    this.createdAt,
  });

  final String? id;
  final String? userId;
  final String destinationCountryCode;
  final String destinationCurrencyCode;
  final String destinationCountryName;
  final double amountSentQar;
  final CorridorTransferMethod method;
  final String providerName;
  final double feePaidQar;
  final double amountRecipientGot;
  final double deliveryHours;
  final DateTime? createdAt;

  Map<String, dynamic> toFirestore() => {
        'destinationCountryCode': destinationCountryCode,
        'destinationCurrencyCode': destinationCurrencyCode,
        'destinationCountryName': destinationCountryName,
        'amountSentQar': amountSentQar,
        'method': method.value,
        'providerName': providerName.trim(),
        'providerSlug': _slugify(providerName),
        'feePaidQar': feePaidQar,
        'amountRecipientGot': amountRecipientGot,
        'deliveryHours': deliveryHours,
        'userId': userId,
        'createdAt': FieldValue.serverTimestamp(),
      };

  static CorridorReport fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    return CorridorReport(
      id: doc.id,
      userId: data['userId'] as String?,
      destinationCountryCode:
          data['destinationCountryCode'] as String? ?? '',
      destinationCurrencyCode:
          data['destinationCurrencyCode'] as String? ?? '',
      destinationCountryName: data['destinationCountryName'] as String? ?? '',
      amountSentQar: (data['amountSentQar'] as num?)?.toDouble() ?? 0,
      method: CorridorTransferMethod.fromValue(data['method'] as String?),
      providerName: data['providerName'] as String? ?? '',
      feePaidQar: (data['feePaidQar'] as num?)?.toDouble() ?? 0,
      amountRecipientGot:
          (data['amountRecipientGot'] as num?)?.toDouble() ?? 0,
      deliveryHours: (data['deliveryHours'] as num?)?.toDouble() ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  static String aggregateDocId({
    required String countryCode,
    required CorridorTransferMethod method,
    required String providerName,
  }) {
    return '${countryCode.toUpperCase()}_${method.value}_${_slugify(providerName)}';
  }

  static String _slugify(String name) {
    return name
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
  }
}
