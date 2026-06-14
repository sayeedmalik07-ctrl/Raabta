import 'package:flutter/material.dart';

class HousingScreen extends StatefulWidget {
  const HousingScreen({super.key});

  @override
  State<HousingScreen> createState() => _HousingScreenState();
}

class _HousingScreenState extends State<HousingScreen> {
  static const Color _backgroundColor = Color(0xFF050A0F);
  static const Color _surfaceColor = Color(0xFF0D1520);
  static const Color _subtitleColor = Color(0xFF8A9BB0);
  static const Color _cyanColor = Color(0xFF22D3EE);

  final TextEditingController _searchController = TextEditingController();

  static const List<String> _filters = [
    'All',
    'Room',
    'Flat',
    'Sharing',
    'Studio',
  ];

  int _selectedFilter = 0;

  static const List<_HousingListing> _listings = [
    _HousingListing(
      title: '2BHK Flat for Rent',
      area: 'Al Khor',
      price: '2,500 QR/month',
      posted: '2 days ago',
      type: 'Flat',
    ),
    _HousingListing(
      title: '2BHK Flat for Rent',
      area: 'Doha',
      price: '3,200 QR/month',
      posted: '1 day ago',
      type: 'Flat',
    ),
    _HousingListing(
      title: '2BHK Flat for Rent',
      area: 'Lusail',
      price: '4,000 QR/month',
      posted: '3 days ago',
      type: 'Flat',
    ),
    _HousingListing(
      title: '2BHK Flat for Rent',
      area: 'Al Wakrah',
      price: '2,000 QR/month',
      posted: '4 days ago',
      type: 'Room',
    ),
    _HousingListing(
      title: '2BHK Flat for Rent',
      area: 'Mesaieed',
      price: '1,800 QR/month',
      posted: '5 days ago',
      type: 'Sharing',
    ),
  ];

  List<_HousingListing> get _filteredListings {
    if (_selectedFilter == 0) return _listings;
    final filter = _filters[_selectedFilter];
    return _listings.where((l) => l.type == filter).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final listings = _filteredListings;

    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back, color: Colors.white),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                decoration: InputDecoration(
                  hintText: 'Search rooms, flats in Qatar...',
                  hintStyle: const TextStyle(color: _subtitleColor),
                  prefixIcon: const Icon(Icons.search, color: _subtitleColor),
                  filled: true,
                  fillColor: _surfaceColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _filters.length,
                separatorBuilder: (context, index) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final isSelected = _selectedFilter == index;
                  return FilterChip(
                    label: Text(_filters[index]),
                    selected: isSelected,
                    onSelected: (_) => setState(() => _selectedFilter = index),
                    backgroundColor: _surfaceColor,
                    selectedColor: _cyanColor.withValues(alpha: 0.2),
                    labelStyle: TextStyle(
                      color: isSelected ? _cyanColor : _subtitleColor,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                    side: BorderSide(
                      color: isSelected ? _cyanColor : Colors.transparent,
                    ),
                    showCheckmark: false,
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                itemCount: listings.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  return _ListingCard(listing: listings[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HousingListing {
  const _HousingListing({
    required this.title,
    required this.area,
    required this.price,
    required this.posted,
    required this.type,
  });

  final String title;
  final String area;
  final String price;
  final String posted;
  final String type;
}

class _ListingCard extends StatelessWidget {
  const _ListingCard({required this.listing});

  final _HousingListing listing;

  static const Color _surfaceColor = Color(0xFF0D1520);
  static const Color _subtitleColor = Color(0xFF8A9BB0);
  static const Color _cyanColor = Color(0xFF22D3EE);
  static const Color _verifiedGreen = Color(0xFF22C55E);
  static const Color _whatsappGreen = Color(0xFF25D366);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      listing.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '📍 ${listing.area}',
                      style: const TextStyle(
                        color: _subtitleColor,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      listing.price,
                      style: const TextStyle(
                        color: _cyanColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _verifiedGreen.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  '✓ VERIFIED',
                  style: TextStyle(
                    color: _verifiedGreen,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                listing.posted,
                style: const TextStyle(color: _subtitleColor, fontSize: 13),
              ),
              SizedBox(
                height: 36,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.chat, size: 18),
                  label: const Text('WhatsApp'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _whatsappGreen,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
