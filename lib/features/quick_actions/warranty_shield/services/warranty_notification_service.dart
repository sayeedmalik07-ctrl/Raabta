import 'package:raabta/features/quick_actions/warranty_shield/models/warranty_item.dart';
import 'package:raabta/services/smart_notification_engine.dart';

abstract final class WarrantyNotificationService {
  static Future<void> scheduleFor(WarrantyItem item) async {
    await SmartNotificationEngine.instance.scheduleWarrantyReminders(
      warrantyId: item.id,
      productName: item.productName,
      brand: item.brand,
      expiryDate: item.expiryDate,
    );
  }

  static Future<void> cancelFor(String warrantyId) async {
    await SmartNotificationEngine.instance.cancelWarrantyReminders(warrantyId);
  }
}
