enum BranchSortOption {
  nearest,
  highestRated,
  lowestWait,
  openNow,
}

class BranchFinderFilters {
  const BranchFinderFilters({
    this.searchQuery = '',
    this.area,
    this.city,
    this.openNowOnly = false,
    this.service,
    this.sort = BranchSortOption.highestRated,
    this.nearbyOnly = false,
  });

  final String searchQuery;
  final String? area;
  final String? city;
  final bool openNowOnly;
  final String? service;
  final BranchSortOption sort;
  final bool nearbyOnly;

  BranchFinderFilters copyWith({
    String? searchQuery,
    String? area,
    String? city,
    bool? openNowOnly,
    String? service,
    BranchSortOption? sort,
    bool? nearbyOnly,
    bool clearArea = false,
    bool clearCity = false,
    bool clearService = false,
  }) {
    return BranchFinderFilters(
      searchQuery: searchQuery ?? this.searchQuery,
      area: clearArea ? null : (area ?? this.area),
      city: clearCity ? null : (city ?? this.city),
      openNowOnly: openNowOnly ?? this.openNowOnly,
      service: clearService ? null : (service ?? this.service),
      sort: sort ?? this.sort,
      nearbyOnly: nearbyOnly ?? this.nearbyOnly,
    );
  }
}

/// Known exchange service names for filters and admin forms.
const kExchangeServiceNames = [
  'Money Transfer',
  'Cash Pickup',
  'Bank Transfer',
  'Currency Exchange',
  'Corporate Transfer',
  'Salary Transfer',
  'Western Union',
  'MoneyGram',
  'Mobile Wallet',
  'Bill Payment',
  'WPS',
  'International Remittance',
  'Demand Draft',
  'Foreign Currency Notes',
];
