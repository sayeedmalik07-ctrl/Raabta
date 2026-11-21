class WarrantyItem {
  const WarrantyItem({
    required this.id,
    required this.productName,
    required this.brand,
    required this.category,
    required this.purchaseDate,
    required this.expiryDate,
    required this.purchasePriceQar,
    required this.receiptImagePath,
    this.retailer = '',
    this.currency = 'QAR',
  });

  final String id;
  final String productName;
  final String brand;
  final String category;
  final DateTime purchaseDate;
  final DateTime expiryDate;
  final double purchasePriceQar;
  final String receiptImagePath;
  final String retailer;
  final String currency;

  int get daysLeft => expiryDate.difference(DateTime.now()).inDays;
  bool get isExpired => daysLeft < 0;
  bool get expiringsSoon => daysLeft <= 30 && daysLeft >= 0;

  WarrantyItem copyWith({
    String? id,
    String? productName,
    String? brand,
    String? category,
    DateTime? purchaseDate,
    DateTime? expiryDate,
    double? purchasePriceQar,
    String? receiptImagePath,
    String? retailer,
    String? currency,
  }) {
    return WarrantyItem(
      id: id ?? this.id,
      productName: productName ?? this.productName,
      brand: brand ?? this.brand,
      category: category ?? this.category,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      expiryDate: expiryDate ?? this.expiryDate,
      purchasePriceQar: purchasePriceQar ?? this.purchasePriceQar,
      receiptImagePath: receiptImagePath ?? this.receiptImagePath,
      retailer: retailer ?? this.retailer,
      currency: currency ?? this.currency,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'productName': productName,
        'brand': brand,
        'category': category,
        'purchaseDate': purchaseDate.toIso8601String(),
        'expiryDate': expiryDate.toIso8601String(),
        'purchasePriceQar': purchasePriceQar,
        'receiptImagePath': receiptImagePath,
        'retailer': retailer,
        'currency': currency,
      };

  factory WarrantyItem.fromJson(Map<String, dynamic> json) {
    return WarrantyItem(
      id: json['id'] as String? ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      productName: json['productName'] as String? ?? 'Unknown Product',
      brand: json['brand'] as String? ?? 'N/A',
      category: json['category'] as String? ?? 'General',
      purchaseDate: DateTime.tryParse(json['purchaseDate'] as String? ?? '') ??
          DateTime.now(),
      expiryDate: DateTime.tryParse(json['expiryDate'] as String? ?? '') ??
          DateTime.now().add(const Duration(days: 365)),
      purchasePriceQar: (json['purchasePriceQar'] as num?)?.toDouble() ?? 0,
      receiptImagePath: json['receiptImagePath'] as String? ?? '',
      retailer: json['retailer'] as String? ?? '',
      currency: json['currency'] as String? ?? 'QAR',
    );
  }
}
