import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:raabta/core/colors/app_colors.dart';
import 'package:raabta/features/quick_actions/warranty_shield/l10n/warranty_strings.dart';
import 'package:raabta/providers/visa_providers.dart';

// ─── Repair shop data ─────────────────────────────────────

class RepairShop {
  final String id;
  final String name;
  final String area;
  final String phone;
  final String category;
  final double? rating;

  const RepairShop({
    required this.id,
    required this.name,
    required this.area,
    required this.phone,
    required this.category,
    this.rating,
  });

  factory RepairShop.fromFirestore(DocumentSnapshot doc, String locale) {
    final d = doc.data() as Map<String, dynamic>? ?? {};
    return RepairShop(
      id:       doc.id,
      name:     d['name']     as String? ?? WarrantyStrings.t('warr_repair_shop_fallback', locale),
      area:     d['area']     as String? ?? d['location'] as String? ?? WarrantyStrings.t('warr_area_qatar', locale),
      phone:    d['phone']    as String? ?? '',
      category: d['category'] as String? ?? 'repair',
      rating:   (d['rating']  as num?)?.toDouble(),
    );
  }
}

// ─── WIDGET ──────────────────────────────────────────────

class RepairShopSuggestions extends ConsumerWidget {
  final String productCategory;

  const RepairShopSuggestions({
    super.key,
    required this.productCategory,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(userLanguageProvider);
    return FutureBuilder<QuerySnapshot>(
      // NOTE: This query returns empty until repair shop
      // documents are added to the businesses collection
      // with category: 'repair'. The widget gracefully
      // returns SizedBox.shrink() when empty.
      // BusinessesScreen currently uses hardcoded listings;
      // seed Firestore `businesses` to populate suggestions.
      future: FirebaseFirestore.instance
          .collection('businesses')
          .where('category', isEqualTo: 'repair')
          .limit(3)
          .get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData ||
            snapshot.data!.docs.isEmpty) {
          return const SizedBox.shrink();
        }

        final shops = snapshot.data!.docs.map((doc) {
          try {
            return RepairShop.fromFirestore(doc, locale);
          } catch (_) {
            return null;
          }
        }).whereType<RepairShop>().toList();

        if (shops.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 14),
            Row(
              children: [
                const Icon(
                  Icons.build_rounded,
                  color: AppColors.accentGold,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  WarrantyStrings.t('warr_repair_shops_title', locale),
                  style: TextStyle(
                    color: AppColors.isLight
                        ? AppColors.textPrimary
                        : Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7, vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accentGold
                        .withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    WarrantyStrings.t('warr_repair_warranty_badge', locale),
                    style: const TextStyle(
                      color: AppColors.accentGold,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ...shops.map(
              (shop) => _RepairShopCard(shop: shop, locale: locale),
            ),
          ],
        );
      },
    );
  }
}

// ─── Single repair shop card ─────────────────────────────

class _RepairShopCard extends StatelessWidget {
  final RepairShop shop;
  final String locale;

  const _RepairShopCard({required this.shop, required this.locale});

  Future<void> _onView(BuildContext context) async {
    if (shop.phone.isNotEmpty) {
      final uri = Uri.parse('tel:${shop.phone}');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
        return;
      }
    }
    if (context.mounted) {
      context.push('/businesses');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.isLight
            ? AppColors.glassSurface
            : Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.isLight
              ? AppColors.glassBorder
              : Colors.white.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              color: AppColors.accentGold.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Text(
                '🔧',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  shop.name,
                  style: TextStyle(
                    color: AppColors.isLight
                        ? AppColors.textPrimary
                        : Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  shop.area,
                  style: TextStyle(
                    color: AppColors.isLight
                        ? AppColors.textOnGlassMuted
                        : Colors.white.withValues(alpha: 0.4),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          if (shop.rating != null) ...[
            const Icon(
              Icons.star_rounded,
              color: AppColors.accentGold,
              size: 13,
            ),
            const SizedBox(width: 3),
            Text(
              shop.rating!.toStringAsFixed(1),
              style: const TextStyle(
                color: AppColors.accentGold,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 8),
          ],
          OutlinedButton(
            onPressed: () => _onView(context),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 6,
              ),
              side: BorderSide(
                color: AppColors.accentGold.withValues(alpha: 0.4),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              WarrantyStrings.t('warr_repair_view', locale),
              style: const TextStyle(
                color: AppColors.accentGold,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
