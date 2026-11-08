import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/core/l10n/app_locale.dart';
import 'package:raabta/features/quick_actions/bill_tracker/l10n/bill_tracker_strings.dart';
import 'package:raabta/features/quick_actions/bill_tracker/presentation/providers/bill_tracker_providers.dart';
import 'package:raabta/features/quick_actions/bill_tracker/services/bill_anomaly_notification_service.dart';
import 'package:raabta/providers/visa_providers.dart';
import 'package:raabta/services/drafts/draft_box_keys.dart';
import 'package:raabta/services/drafts/draft_service.dart';
import 'package:raabta/services/smart_notification_engine.dart';

abstract final class BillTrackerBillActions {
  static Future<void> addBill(
    WidgetRef ref, {
    required BuildContext context,
    required String provider,
    required String category,
    required String emoji,
    required double amount,
    required DateTime dueDate,
    String accountNumber = '',
    String notes = '',
    DateTime? billingPeriodStart,
    DateTime? billingPeriodEnd,
    String currency = 'QAR',
  }) async {
    final locale = AppLocale.normalize(ref.read(userLanguageProvider));

    try {
      final userId = await ref.read(billTrackerUserIdProvider.future);
      final docId = await ref.read(billTrackerRepositoryProvider).addBill(
            userId: userId,
            provider: provider,
            category: category,
            emoji: emoji,
            amount: amount,
            dueDate: dueDate,
            accountNumber: accountNumber,
            notes: notes,
            billingPeriodStart: billingPeriodStart,
            billingPeriodEnd: billingPeriodEnd,
            currency: currency,
          );

      await SmartNotificationEngine.instance.scheduleBillDueReminders(
        billId: docId,
        provider: provider,
        dueDate: dueDate,
        amount: amount,
      );

      final allBills =
          await ref.read(billTrackerRepositoryProvider).fetchBills(userId);
      await BillAnomalyNotificationService.maybeNotifyForNewBill(
        billId: docId,
        allBills: allBills,
        locale: locale,
      );

      await DraftService.instance.clearDraft(DraftBoxKeys.billTrackerAdd);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            BillTrackerStrings.format('could_not_add_bill', locale, {
              'error': '$e',
            }),
          ),
          backgroundColor: AppColors.errorBright,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  static Future<void> markPaid(WidgetRef ref, String id, bool paid) async {
    await ref.read(billTrackerRepositoryProvider).markPaid(id, paid);
  }

  static Future<void> deleteBill(WidgetRef ref, String id) async {
    await SmartNotificationEngine.instance.cancelBillReminders(id);
    await ref.read(billTrackerRepositoryProvider).deleteBill(id);
  }
}
