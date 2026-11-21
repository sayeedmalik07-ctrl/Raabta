import 'package:raabta/features/sponsorship_transfer/domain/models/sponsorship_transfer_enums.dart';

class TransferReadinessItem {
  const TransferReadinessItem({
    required this.id,
    required this.titleKey,
    required this.explanationKey,
    required this.actionKey,
    required this.status,
    this.ruleKey,
    this.citationKey,
    this.sortPriority = 100,
  });

  final String id;
  final String titleKey;
  final String explanationKey;
  final String actionKey;
  final TransferReadinessStatus status;
  final String? ruleKey;
  final String? citationKey;
  final int sortPriority;

  Map<String, dynamic> toJson() => {
        'id': id,
        'titleKey': titleKey,
        'explanationKey': explanationKey,
        'actionKey': actionKey,
        'status': status.name,
        'ruleKey': ruleKey,
        'citationKey': citationKey,
        'sortPriority': sortPriority,
      };

  factory TransferReadinessItem.fromJson(Map<String, dynamic> json) {
    return TransferReadinessItem(
      id: json['id'] as String? ?? '',
      titleKey: json['titleKey'] as String? ?? '',
      explanationKey: json['explanationKey'] as String? ?? '',
      actionKey: json['actionKey'] as String? ?? '',
      status: TransferReadinessStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => TransferReadinessStatus.informational,
      ),
      ruleKey: json['ruleKey'] as String?,
      citationKey: json['citationKey'] as String?,
      sortPriority: json['sortPriority'] as int? ?? 100,
    );
  }
}

class TransferReadinessResult {
  const TransferReadinessResult({
    required this.items,
    required this.checkedAt,
    required this.noticeMonths,
    required this.permitWindowStatus,
    this.daysSincePermitExpiry,
    this.monthsEmployed,
    this.probationNoticeApplies = false,
  });

  final List<TransferReadinessItem> items;
  final DateTime checkedAt;
  final int noticeMonths;
  final PermitWindowStatus permitWindowStatus;
  final int? daysSincePermitExpiry;
  final int? monthsEmployed;
  final bool probationNoticeApplies;

  bool get hasCriticalIssue =>
      items.any((i) => i.status == TransferReadinessStatus.critical);

  bool get hasWarning =>
      items.any((i) => i.status == TransferReadinessStatus.warning);

  Map<String, dynamic> toJson() => {
        'items': items.map((e) => e.toJson()).toList(),
        'checkedAt': checkedAt.toIso8601String(),
        'noticeMonths': noticeMonths,
        'permitWindowStatus': permitWindowStatus.name,
        'daysSincePermitExpiry': daysSincePermitExpiry,
        'monthsEmployed': monthsEmployed,
        'probationNoticeApplies': probationNoticeApplies,
      };

  factory TransferReadinessResult.fromJson(Map<String, dynamic> json) {
    final itemsRaw = json['items'] as List<dynamic>? ?? [];
    return TransferReadinessResult(
      items: itemsRaw
          .map((e) => TransferReadinessItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      checkedAt: DateTime.tryParse(json['checkedAt'] as String? ?? '') ??
          DateTime.now(),
      noticeMonths: json['noticeMonths'] as int? ?? 1,
      permitWindowStatus: PermitWindowStatus.values.firstWhere(
        (e) => e.name == json['permitWindowStatus'],
        orElse: () => PermitWindowStatus.unknown,
      ),
      daysSincePermitExpiry: json['daysSincePermitExpiry'] as int?,
      monthsEmployed: json['monthsEmployed'] as int?,
      probationNoticeApplies: json['probationNoticeApplies'] as bool? ?? false,
    );
  }
}
