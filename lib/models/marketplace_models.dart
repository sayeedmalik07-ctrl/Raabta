import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:raabta/features/post_engine/data/post_schema_persistence.dart';

enum ListingBoostBadge { featured, hot }

class MarketplaceCategory {
  const MarketplaceCategory({
    required this.id,
    required this.emoji,
    required this.name,
  });

  final String id;
  final String emoji;
  final String name;
}

class MarketplaceListing {
  const MarketplaceListing({
    required this.id,
    required this.categoryId,
    required this.emoji,
    required this.title,
    required this.price,
    required this.area,
    required this.posted,
    required this.condition,
    required this.sellerFlag,
    required this.views,
    required this.distanceKm,
    this.badge,
    this.trendingViews = 0,
    this.ownerUserId,
    this.relevantGroupIds = const [],
    this.description = '',
    this.photoUrls = const [],
    this.schemaFields = const {},
  });

  final String id;
  final String categoryId;
  final String emoji;
  final String title;
  final String price;
  final String area;
  final String posted;
  final String condition;
  final String sellerFlag;
  final int views;
  final double distanceKm;
  final ListingBoostBadge? badge;
  final int trendingViews;
  final String? ownerUserId;
  final List<String> relevantGroupIds;
  final String description;
  final List<String> photoUrls;
  final Map<String, dynamic> schemaFields;

  bool get hasSchemaAttributes => schemaFields.isNotEmpty;

  factory MarketplaceListing.fromJson(Map<String, dynamic> json) {
    final createdAtRaw = json['createdAt'];
    DateTime? createdAt;
    if (createdAtRaw is Timestamp) {
      createdAt = createdAtRaw.toDate();
    } else if (createdAtRaw is String) {
      createdAt = DateTime.tryParse(createdAtRaw);
    }

    final postedRaw = json['posted'] as String?;
    final posted = postedRaw != null && postedRaw.isNotEmpty
        ? postedRaw
        : (createdAt != null ? _formatPosted(createdAt) : 'Recently');

    final priceRaw = json['price'];
    final price = priceRaw is num
        ? '${priceRaw.toStringAsFixed(0)} QR'
        : (priceRaw as String? ?? '');

    return MarketplaceListing(
      id: json['id'] as String? ?? '',
      categoryId: json['categoryId'] as String? ?? '',
      emoji: json['emoji'] as String? ??
          marketplaceCategoryById(json['categoryId'] as String? ?? '').emoji,
      title: json['title'] as String? ?? '',
      price: price,
      area: json['area'] as String? ?? '',
      posted: posted,
      condition: json['condition'] as String? ?? '',
      sellerFlag: json['sellerFlag'] as String? ?? '🌍',
      views: (json['views'] as num?)?.toInt() ?? 0,
      distanceKm: (json['distanceKm'] as num?)?.toDouble() ?? 0,
      badge: _parseBadge(json['badge'] as String?),
      trendingViews: (json['trendingViews'] as num?)?.toInt() ?? 0,
      ownerUserId: json['ownerUserId'] as String? ??
          json['userId'] as String? ??
          json['sellerId'] as String?,
      relevantGroupIds: _parseRelevantGroupIds(json),
      description: json['description'] as String? ?? '',
      photoUrls: _parseStringList(json['photoUrls']),
      schemaFields:
          PostSchemaPersistence.parseSchemaFieldsForRead(json['schemaFields']),
    );
  }

  static List<String> _parseStringList(dynamic raw) {
    if (raw is List) {
      return raw.map((e) => e.toString()).where((e) => e.isNotEmpty).toList();
    }
    return const [];
  }

  static List<String> _parseRelevantGroupIds(Map<String, dynamic> json) {
    final raw = json['relevantGroupIds'];
    if (raw is List) {
      return raw.map((e) => e.toString()).where((id) => id.isNotEmpty).toList();
    }
    return const [];
  }

  static String _formatPosted(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.day}/${date.month}/${date.year}';
  }

  static ListingBoostBadge? _parseBadge(String? raw) {
    switch (raw) {
      case 'featured':
        return ListingBoostBadge.featured;
      case 'hot':
        return ListingBoostBadge.hot;
      default:
        return null;
    }
  }
}

const marketplaceCategories = [
  MarketplaceCategory(id: 'cars_bikes', emoji: '🚗', name: 'Cars & Bikes'),
  MarketplaceCategory(
    id: 'mobiles_tablets',
    emoji: '📱',
    name: 'Mobiles & Tablets',
  ),
  MarketplaceCategory(id: 'furniture', emoji: '🛋️', name: 'Furniture'),
  MarketplaceCategory(id: 'electronics', emoji: '💻', name: 'Electronics'),
  MarketplaceCategory(
    id: 'home_appliances',
    emoji: '🏠',
    name: 'Home Appliances',
  ),
  MarketplaceCategory(id: 'books_more', emoji: '📚', name: 'Books & More'),
];

MarketplaceCategory marketplaceCategoryById(String id) {
  return marketplaceCategories.firstWhere(
    (c) => c.id == id,
    orElse: () => marketplaceCategories.first,
  );
}

MarketplaceCategory? marketplaceCategoryByName(String name) {
  final normalized = name.trim().toLowerCase();
  for (final category in marketplaceCategories) {
    if (category.name.toLowerCase() == normalized) return category;
  }
  return null;
}

/// Payload for creating a marketplace listing in Firestore.
class MarketplaceListingSubmission {
  const MarketplaceListingSubmission({
    required this.ownerUserId,
    required this.categoryId,
    required this.title,
    required this.priceQar,
    required this.description,
    required this.condition,
    required this.area,
    this.sellerFlag = '🌍',
    this.relevantGroupIds = const [],
    this.schemaFields = const {},
  });

  final String ownerUserId;
  final String categoryId;
  final String title;
  final int priceQar;
  final String description;
  final String condition;
  final String area;
  final String sellerFlag;
  final List<String> relevantGroupIds;
  final Map<String, dynamic> schemaFields;

  Map<String, dynamic> toFirestore({List<String> photoUrls = const []}) {
    final category = marketplaceCategoryById(categoryId);
    return {
      'ownerUserId': ownerUserId,
      'categoryId': categoryId,
      'emoji': category.emoji,
      'title': title.trim(),
      'price': priceQar,
      'priceLabel': '$priceQar QR',
      'description': description.trim(),
      'condition': condition,
      'area': area.trim(),
      'sellerFlag': sellerFlag,
      'relevantGroupIds': relevantGroupIds,
      'views': 0,
      'trendingViews': 0,
      'distanceKm': 0.0,
      'status': 'active',
      'photoUrls': photoUrls,
      'photoCount': photoUrls.length,
      'createdAt': FieldValue.serverTimestamp(),
      if (schemaFields.isNotEmpty) 'schemaFields': schemaFields,
    };
  }
}

List<MarketplaceListing> fallbackMarketplaceListings() {
  return const [
    MarketplaceListing(
      id: 'listing-1',
      categoryId: 'mobiles_tablets',
      emoji: '📱',
      title: 'iPhone 14 Pro Max 256GB',
      price: '3,200 QR',
      area: 'Al Khor',
      posted: '2 hours ago',
      condition: 'Excellent',
      sellerFlag: '🇮🇳',
      views: 234,
      distanceKm: 2.3,
      badge: ListingBoostBadge.featured,
      trendingViews: 1240,
    ),
    MarketplaceListing(
      id: 'listing-2',
      categoryId: 'cars_bikes',
      emoji: '🚗',
      title: 'Toyota Corolla 2020',
      price: '42,000 QR',
      area: 'Doha',
      posted: '5 hours ago',
      condition: 'Good',
      sellerFlag: '🇵🇰',
      views: 891,
      distanceKm: 18.5,
      badge: ListingBoostBadge.hot,
      trendingViews: 2100,
    ),
    MarketplaceListing(
      id: 'listing-3',
      categoryId: 'furniture',
      emoji: '🛋️',
      title: 'IKEA Sofa Set',
      price: '800 QR',
      area: 'Lusail',
      posted: '1 day ago',
      condition: 'Like New',
      sellerFlag: '🇵🇭',
      views: 156,
      distanceKm: 12.1,
      badge: ListingBoostBadge.featured,
      trendingViews: 890,
    ),
    MarketplaceListing(
      id: 'listing-4',
      categoryId: 'electronics',
      emoji: '📺',
      title: 'Samsung TV 55"',
      price: '1,200 QR',
      area: 'Al Khor',
      posted: '3 hours ago',
      condition: 'Excellent',
      sellerFlag: '🇧🇩',
      views: 412,
      distanceKm: 1.8,
      badge: ListingBoostBadge.hot,
      trendingViews: 1560,
    ),
    MarketplaceListing(
      id: 'listing-5',
      categoryId: 'cars_bikes',
      emoji: '🏍️',
      title: 'Yamaha MT-07 2022',
      price: '28,500 QR',
      area: 'Al Rayyan',
      posted: '6 hours ago',
      condition: 'Excellent',
      sellerFlag: '🇳🇵',
      views: 312,
      distanceKm: 9.4,
    ),
    MarketplaceListing(
      id: 'listing-6',
      categoryId: 'mobiles_tablets',
      emoji: '📱',
      title: 'Samsung Galaxy S23 Ultra',
      price: '2,450 QR',
      area: 'Doha',
      posted: '8 hours ago',
      condition: 'Like New',
      sellerFlag: '🇱🇰',
      views: 178,
      distanceKm: 14.2,
    ),
    MarketplaceListing(
      id: 'listing-7',
      categoryId: 'furniture',
      emoji: '🪑',
      title: 'Office Desk + Chair Set',
      price: '450 QR',
      area: 'Al Wakrah',
      posted: '2 days ago',
      condition: 'Good',
      sellerFlag: '🇪🇬',
      views: 89,
      distanceKm: 22.0,
    ),
    MarketplaceListing(
      id: 'listing-8',
      categoryId: 'electronics',
      emoji: '💻',
      title: 'MacBook Air M2 512GB',
      price: '3,800 QR',
      area: 'Lusail',
      posted: '12 hours ago',
      condition: 'Excellent',
      sellerFlag: '🇮🇳',
      views: 521,
      distanceKm: 11.3,
    ),
    MarketplaceListing(
      id: 'listing-9',
      categoryId: 'home_appliances',
      emoji: '🧺',
      title: 'LG Front Load Washer 9kg',
      price: '950 QR',
      area: 'Al Khor',
      posted: '1 day ago',
      condition: 'Good',
      sellerFlag: '🇵🇰',
      views: 143,
      distanceKm: 3.1,
    ),
    MarketplaceListing(
      id: 'listing-10',
      categoryId: 'home_appliances',
      emoji: '❄️',
      title: 'Samsung Double Door Fridge',
      price: '1,600 QR',
      area: 'Doha',
      posted: '4 hours ago',
      condition: 'Like New',
      sellerFlag: '🇧🇩',
      views: 267,
      distanceKm: 16.8,
    ),
    MarketplaceListing(
      id: 'listing-11',
      categoryId: 'books_more',
      emoji: '📚',
      title: 'Engineering Textbooks (Set of 5)',
      price: '120 QR',
      area: 'Education City',
      posted: '3 days ago',
      condition: 'Good',
      sellerFlag: '🇮🇳',
      views: 64,
      distanceKm: 19.5,
    ),
    MarketplaceListing(
      id: 'listing-12',
      categoryId: 'books_more',
      emoji: '🎮',
      title: 'PS5 + 3 Games Bundle',
      price: '1,450 QR',
      area: 'Al Rayyan',
      posted: '7 hours ago',
      condition: 'Like New',
      sellerFlag: '🇵🇭',
      views: 388,
      distanceKm: 8.7,
    ),
  ];
}

int marketplaceCountForCategory(
  List<MarketplaceListing> listings,
  String categoryId,
) {
  return listings.where((l) => l.categoryId == categoryId).length;
}
