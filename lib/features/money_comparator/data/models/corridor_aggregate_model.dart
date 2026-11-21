import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:raabta/features/money_comparator/domain/corridor_transfer_method.dart';

/// Rolling aggregate for one corridor + method + provider — `corridor_aggregates`.
class CorridorAggregate {
  const CorridorAggregate({
    required this.id,
    required this.destinationCountryCode,
    required this.destinationCurrencyCode,
    required this.destinationCountryName,
    required this.method,
    required this.providerName,
    required this.reportCount,
    required this.avgEffectiveRate,
    required this.avgFeePaidQar,
    required this.avgDeliveryHours,
    this.lastUpdated,
  });

  final String id;
  final String destinationCountryCode;
  final String destinationCurrencyCode;
  final String destinationCountryName;
  final CorridorTransferMethod method;
  final String providerName;
  final int reportCount;
  final double avgEffectiveRate;
  final double avgFeePaidQar;
  final double avgDeliveryHours;
  final DateTime? lastUpdated;

  static CorridorAggregate fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    return CorridorAggregate(
      id: doc.id,
      destinationCountryCode:
          data['destinationCountryCode'] as String? ?? '',
      destinationCurrencyCode:
          data['destinationCurrencyCode'] as String? ?? '',
      destinationCountryName: data['destinationCountryName'] as String? ?? '',
      method: CorridorTransferMethod.fromValue(data['method'] as String?),
      providerName: data['providerName'] as String? ?? '',
      reportCount: (data['reportCount'] as num?)?.toInt() ?? 0,
      avgEffectiveRate: (data['avgEffectiveRate'] as num?)?.toDouble() ?? 0,
      avgFeePaidQar: (data['avgFeePaidQar'] as num?)?.toDouble() ?? 0,
      avgDeliveryHours: (data['avgDeliveryHours'] as num?)?.toDouble() ?? 0,
      lastUpdated: (data['lastUpdated'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toCacheJson() => {
        'id': id,
        'destinationCountryCode': destinationCountryCode,
        'destinationCurrencyCode': destinationCurrencyCode,
        'destinationCountryName': destinationCountryName,
        'method': method.value,
        'providerName': providerName,
        'reportCount': reportCount,
        'avgEffectiveRate': avgEffectiveRate,
        'avgFeePaidQar': avgFeePaidQar,
        'avgDeliveryHours': avgDeliveryHours,
        'lastUpdated': lastUpdated?.toIso8601String(),
      };

  static CorridorAggregate fromCacheJson(Map<String, dynamic> json) {
    return CorridorAggregate(
      id: json['id'] as String? ?? '',
      destinationCountryCode: json['destinationCountryCode'] as String? ?? '',
      destinationCurrencyCode:
          json['destinationCurrencyCode'] as String? ?? '',
      destinationCountryName: json['destinationCountryName'] as String? ?? '',
      method: CorridorTransferMethod.fromValue(json['method'] as String?),
      providerName: json['providerName'] as String? ?? '',
      reportCount: (json['reportCount'] as num?)?.toInt() ?? 0,
      avgEffectiveRate: (json['avgEffectiveRate'] as num?)?.toDouble() ?? 0,
      avgFeePaidQar: (json['avgFeePaidQar'] as num?)?.toDouble() ?? 0,
      avgDeliveryHours: (json['avgDeliveryHours'] as num?)?.toDouble() ?? 0,
      lastUpdated: DateTime.tryParse(json['lastUpdated']?.toString() ?? ''),
    );
  }
}
