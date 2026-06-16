import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:raabta/models/housing_models.dart';
import 'package:raabta/providers/housing_providers.dart';
import 'package:raabta/screens/housing/listing_card.dart';
import 'package:raabta/screens/housing/post_listing_screen.dart';

class HousingListScreen extends ConsumerStatefulWidget {
  const HousingListScreen({super.key});

  @override
  ConsumerState<HousingListScreen> createState() => _HousingListScreenState();
}

class _HousingListScreenState extends ConsumerState<HousingListScreen> {
  static const Color _backgroundColor = Color(0xFF050A0F);
  static const Color _surfaceColor = Color(0xFF0D1520);
  static const Color _subtitleColor = Color(0xFF8A9BB0);
  static const Color _cyanColor = Color(0xFF22D3EE);

  final TextEditingController _searchController = TextEditingController();
  bool _showAdvancedFilters = false;

  static const List<({String label, ListingType type})> _typeFilters = [
    (label: 'All', type: ListingType.all),
    (label: 'Room', type: ListingType.room),
    (label: 'Flat', type: ListingType.flat),
    (label: 'Sharing', type: ListingType.sharing),
    (label: 'Studio', type: ListingType.studio),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applySearch(String value) {
    ref.read(housingFiltersProvider.notifier).state =
        ref.read(housingFiltersProvider).copyWith(searchQuery: value);
  }

  void _selectType(ListingType type) {
    ref.read(housingFiltersProvider.notifier).state =
        ref.read(housingFiltersProvider).copyWith(type: type);
  }

  void _selectArea(String? area) {
    ref.read(housingFiltersProvider.notifier).state =
        ref.read(housingFiltersProvider).copyWith(
              area: area,
              clearArea: area == null,
            );
  }

  void _updatePriceRange(RangeValues range) {
    ref.read(housingFiltersProvider.notifier).state =
        ref.read(housingFiltersProvider).copyWith(
              minPrice: range.start,
              maxPrice: range.end,
            );
  }

  void _selectGender(GenderPreference gender) {
    ref.read(housingFiltersProvider.notifier).state =
        ref.read(housingFiltersProvider).copyWith(gender: gender);
  }

  void _selectNationality(NationalityPreference nationality) {
    ref.read(housingFiltersProvider.notifier).state =
        ref.read(housingFiltersProvider).copyWith(nationality: nationality);
  }

  @override
  Widget build(BuildContext context) {
    final filters = ref.watch(housingFiltersProvider);
    final listingsAsync = ref.watch(housingListingsProvider);

    return Scaffold(
      backgroundColor: _backgroundColor,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const PostListingScreen()),
          );
        },
        backgroundColor: _cyanColor,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add),
        label: const Text('Post Listing', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                ),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Housing',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Find rooms & flats across Qatar',
                        style: TextStyle(color: _subtitleColor, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () =>
                      setState(() => _showAdvancedFilters = !_showAdvancedFilters),
                  icon: Icon(
                    _showAdvancedFilters
                        ? Icons.filter_alt
                        : Icons.filter_alt_outlined,
                    color: _cyanColor,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                onChanged: _applySearch,
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
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: qatarAreas.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final area = qatarAreas[index];
                  final selected = filters.area == area;
                  return FilterChip(
                    label: Text(area),
                    selected: selected,
                    onSelected: (_) => _selectArea(selected ? null : area),
                    backgroundColor: _surfaceColor,
                    selectedColor: _cyanColor.withValues(alpha: 0.2),
                    labelStyle: TextStyle(
                      color: selected ? _cyanColor : _subtitleColor,
                      fontSize: 12,
                    ),
                    showCheckmark: false,
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _typeFilters.length,
                separatorBuilder: (context, index) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final item = _typeFilters[index];
                  final selected = filters.type == item.type;
                  return FilterChip(
                    label: Text(item.label),
                    selected: selected,
                    onSelected: (_) => _selectType(item.type),
                    backgroundColor: _surfaceColor,
                    selectedColor: _cyanColor.withValues(alpha: 0.2),
                    labelStyle: TextStyle(
                      color: selected ? _cyanColor : _subtitleColor,
                      fontWeight:
                          selected ? FontWeight.w600 : FontWeight.normal,
                    ),
                    side: BorderSide(
                      color: selected ? _cyanColor : Colors.transparent,
                    ),
                    showCheckmark: false,
                  );
                },
              ),
            ),
            if (_showAdvancedFilters) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _surfaceColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Price: ${filters.minPrice.round()} – ${filters.maxPrice.round()} QR/month',
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                      ),
                      RangeSlider(
                        values: RangeValues(filters.minPrice, filters.maxPrice),
                        min: 500,
                        max: 5000,
                        divisions: 45,
                        activeColor: _cyanColor,
                        inactiveColor: const Color(0xFF1A2535),
                        labels: RangeLabels(
                          '${filters.minPrice.round()}',
                          '${filters.maxPrice.round()}',
                        ),
                        onChanged: _updatePriceRange,
                      ),
                      const Text(
                        'Gender preference',
                        style: TextStyle(color: _subtitleColor, fontSize: 13),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: GenderPreference.values.map((g) {
                          final selected = filters.gender == g;
                          return ChoiceChip(
                            label: Text(genderLabel(g)),
                            selected: selected,
                            onSelected: (_) => _selectGender(g),
                            backgroundColor: _backgroundColor,
                            selectedColor: _cyanColor.withValues(alpha: 0.2),
                            labelStyle: TextStyle(
                              color: selected ? _cyanColor : _subtitleColor,
                              fontSize: 12,
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Nationality preference',
                        style: TextStyle(color: _subtitleColor, fontSize: 13),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: NationalityPreference.values.map((n) {
                          final selected = filters.nationality == n;
                          return ChoiceChip(
                            label: Text(nationalityLabel(n)),
                            selected: selected,
                            onSelected: (_) => _selectNationality(n),
                            backgroundColor: _backgroundColor,
                            selectedColor: _cyanColor.withValues(alpha: 0.2),
                            labelStyle: TextStyle(
                              color: selected ? _cyanColor : _subtitleColor,
                              fontSize: 12,
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 12),
            Expanded(
              child: listingsAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: _cyanColor),
                ),
                error: (error, _) => _EmptyState(
                  icon: Icons.error_outline,
                  title: 'Could not load listings',
                  subtitle: error.toString(),
                  actionLabel: 'Retry',
                  onAction: () => ref.invalidate(housingListingsProvider),
                ),
                data: (listings) {
                  if (listings.isEmpty) {
                    return _EmptyState(
                      icon: Icons.home_outlined,
                      title: 'No listings found',
                      subtitle:
                          'Try adjusting your filters or post a new listing.',
                      actionLabel: 'Post Listing',
                      onAction: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const PostListingScreen(),
                          ),
                        );
                      },
                    );
                  }

                  return RefreshIndicator(
                    color: _cyanColor,
                    onRefresh: () async {
                      ref.invalidate(housingListingsProvider);
                      await ref.read(housingListingsProvider.future);
                    },
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 88),
                      itemCount: listings.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        return ListingCard(listing: listings[index]);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onAction,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFF8A9BB0), size: 56),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(color: Color(0xFF8A9BB0), fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: onAction,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF22D3EE),
                foregroundColor: Colors.black,
              ),
              child: Text(actionLabel),
            ),
          ],
        ),
      ),
    );
  }
}
