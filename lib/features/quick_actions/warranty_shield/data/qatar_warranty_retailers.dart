import 'package:raabta/features/quick_actions/warranty_shield/models/warranty_item.dart';

/// A publicly listed contact or policy line — [verified] marks official-source confirmation.
class RetailerReferenceField {
  const RetailerReferenceField({
    required this.value,
    this.verified = false,
  });

  final String value;
  final bool verified;
}

/// Bundled Qatar electronics/appliance retailer reference (config-driven, not scattered in widgets).
class QatarWarrantyRetailer {
  const QatarWarrantyRetailer({
    required this.id,
    required this.displayName,
    required this.matchTokens,
    required this.policySummaryKey,
    this.phone,
    this.serviceCenterKey,
    this.websiteUrl,
  });

  final String id;
  final String displayName;

  /// Lowercase tokens matched as substrings against normalized retailer/brand text.
  final List<String> matchTokens;

  /// [WarrantyStrings] key for localized policy summary copy.
  final String policySummaryKey;
  final RetailerReferenceField? phone;
  final String? serviceCenterKey;
  final RetailerReferenceField? websiteUrl;
}

/// Lookup + normalization for warranty retailer intelligence (Part C).
abstract final class QatarWarrantyRetailerCatalog {
  static const retailers = <QatarWarrantyRetailer>[
    QatarWarrantyRetailer(
      id: 'jarir',
      displayName: 'Jarir Bookstore',
      matchTokens: ['jarir'],
      policySummaryKey: 'warr_retailer_jarir_policy',
      phone: RetailerReferenceField(
        value: '+974 800 0200',
        verified: false,
      ),
      serviceCenterKey: 'warr_retailer_jarir_service',
      websiteUrl: RetailerReferenceField(
        value: 'https://www.jarir.com/qa-en/',
        verified: true,
      ),
    ),
    QatarWarrantyRetailer(
      id: 'carrefour',
      displayName: 'Carrefour Qatar',
      matchTokens: ['carrefour', 'maf carrefour'],
      policySummaryKey: 'warr_retailer_carrefour_policy',
      phone: RetailerReferenceField(
        value: '800 7327',
        verified: false,
      ),
      serviceCenterKey: 'warr_retailer_carrefour_service',
      websiteUrl: RetailerReferenceField(
        value: 'https://www.carrefourqatar.com/',
        verified: true,
      ),
    ),
    QatarWarrantyRetailer(
      id: 'lulu',
      displayName: 'Lulu Hypermarket',
      matchTokens: ['lulu', 'lulu hypermarket'],
      policySummaryKey: 'warr_retailer_lulu_policy',
      phone: RetailerReferenceField(
        value: '800 5888',
        verified: false,
      ),
      serviceCenterKey: 'warr_retailer_lulu_service',
      websiteUrl: RetailerReferenceField(
        value: 'https://www.luluhypermarket.com/en-qa',
        verified: true,
      ),
    ),
    QatarWarrantyRetailer(
      id: 'sharaf_dg',
      displayName: 'Sharaf DG',
      matchTokens: ['sharaf', 'sharaf dg', 'sharafdg'],
      policySummaryKey: 'warr_retailer_sharaf_policy',
      phone: RetailerReferenceField(
        value: '+974 4036 6000',
        verified: false,
      ),
      serviceCenterKey: 'warr_retailer_sharaf_service',
      websiteUrl: RetailerReferenceField(
        value: 'https://www.sharafdg.com/qatar/',
        verified: true,
      ),
    ),
    QatarWarrantyRetailer(
      id: 'virgin',
      displayName: 'Virgin Megastore Qatar',
      matchTokens: ['virgin', 'virgin megastore'],
      policySummaryKey: 'warr_retailer_virgin_policy',
      phone: RetailerReferenceField(
        value: '+974 4411 8100',
        verified: false,
      ),
      serviceCenterKey: 'warr_retailer_virgin_service',
      websiteUrl: RetailerReferenceField(
        value: 'https://www.virginmegastore.qa/',
        verified: false,
      ),
    ),
  ];

  static String normalize(String raw) {
    return raw
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ');
  }

  /// Match saved [WarrantyItem] retailer/brand against bundled catalog.
  static QatarWarrantyRetailer? matchForItem(WarrantyItem item) {
    final haystack = normalize(
      '${item.retailer} ${item.brand}',
    );
    if (haystack.trim().isEmpty) return null;

    for (final retailer in retailers) {
      for (final token in retailer.matchTokens) {
        if (haystack.contains(token)) return retailer;
      }
    }
    return null;
  }

  /// Test helper — match free-text retailer name.
  static QatarWarrantyRetailer? matchName(String? retailerOrBrand) {
    final haystack = normalize(retailerOrBrand ?? '');
    if (haystack.isEmpty) return null;
    for (final retailer in retailers) {
      for (final token in retailer.matchTokens) {
        if (haystack.contains(token)) return retailer;
      }
    }
    return null;
  }
}
