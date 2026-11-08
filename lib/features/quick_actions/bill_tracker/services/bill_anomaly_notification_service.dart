import 'package:raabta/features/quick_actions/bill_tracker/domain/bill_anomaly_detector.dart';
import 'package:raabta/features/quick_actions/bill_tracker/domain/bill_anomaly_models.dart';
import 'package:raabta/features/quick_actions/bill_tracker/domain/bill_entry.dart';
import 'package:raabta/services/smart_notification_engine.dart';

/// Sends a one-shot alert when a newly saved bill exceeds the rolling average.
abstract final class BillAnomalyNotificationService {
  static Future<void> maybeNotifyForNewBill({
    required String billId,
    required List<BillEntry> allBills,
    required String locale,
  }) async {
    final anomaly = BillAnomalyDetector.forBillId(billId, allBills);
    if (anomaly == null) return;

    await _notify(anomaly, locale);
  }

  static Future<void> _notify(BillAnomaly anomaly, String locale) async {
    final periodKey = anomaly.billId;
    await SmartNotificationEngine.instance.maybeNotifyBillAmountAnomaly(
      billId: anomaly.billId,
      provider: anomaly.displayProvider,
      currentAmount: anomaly.currentAmount,
      averageAmount: anomaly.averageAmount,
      percentAbove: anomaly.roundedPercentAbove,
      currency: anomaly.currency,
      dedupKey: 'bill_anomaly_${anomaly.displayProvider}_$periodKey',
      locale: locale,
    );
  }
}
