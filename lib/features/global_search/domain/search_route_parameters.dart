/// Typed destination query parameters for Global Search FIND navigation (S4).
///
/// Distinct from [SearchAnalysis] — only fields intended for route propagation.
class SearchRouteParameters {
  const SearchRouteParameters({
    this.area,
    this.minPrice,
    this.maxPrice,
    this.minSalary,
    this.maxSalary,
    this.jobCategory,
    this.jobQuery,
    this.employmentType,
    this.serviceTrade,
    this.propertyType,
    this.bedrooms,
    this.businessTag,
    this.businessQuery,
    this.visaTopic,
  });

  final String? area;
  final int? minPrice;
  final int? maxPrice;
  final int? minSalary;
  final int? maxSalary;
  final String? jobCategory;
  final String? jobQuery;
  final String? employmentType;
  final String? serviceTrade;
  final String? propertyType;
  final int? bedrooms;
  final String? businessTag;
  final String? businessQuery;
  final String? visaTopic;

  bool get isEmpty =>
      area == null &&
      minPrice == null &&
      maxPrice == null &&
      minSalary == null &&
      maxSalary == null &&
      jobCategory == null &&
      (jobQuery == null || jobQuery!.isEmpty) &&
      employmentType == null &&
      serviceTrade == null &&
      propertyType == null &&
      bedrooms == null &&
      businessTag == null &&
      (businessQuery == null || businessQuery!.isEmpty) &&
      visaTopic == null;

  Map<String, String> toQueryMap() {
    final map = <String, String>{};
    void put(String key, String? value) {
      final trimmed = value?.trim();
      if (trimmed == null || trimmed.isEmpty) return;
      map[key] = trimmed;
    }

    put('area', area);
    put('jobCategory', jobCategory);
    put('jobQuery', jobQuery);
    put('employmentType', employmentType);
    put('trade', serviceTrade);
    put('propertyType', propertyType);
    put('businessTag', businessTag);
    put('businessQuery', businessQuery);
    put('topic', visaTopic);

    if (minPrice != null && minPrice! > 0) {
      map['minPrice'] = minPrice.toString();
    }
    if (maxPrice != null && maxPrice! > 0) {
      map['maxPrice'] = maxPrice.toString();
    }
    if (minSalary != null && minSalary! > 0) {
      map['minSalary'] = minSalary.toString();
    }
    if (maxSalary != null && maxSalary! > 0) {
      map['maxSalary'] = maxSalary.toString();
    }
    if (bedrooms != null && bedrooms! > 0) {
      map['bedrooms'] = bedrooms.toString();
    }

    return map;
  }

  factory SearchRouteParameters.fromQueryMap(Map<String, String> raw) {
    int? readInt(String? value) => int.tryParse(value ?? '');

    return SearchRouteParameters(
      area: raw['area'],
      minPrice: readInt(raw['minPrice']),
      maxPrice: readInt(raw['maxPrice']),
      minSalary: readInt(raw['minSalary']),
      maxSalary: readInt(raw['maxSalary']),
      jobCategory: raw['jobCategory'],
      jobQuery: raw['jobQuery'],
      employmentType: raw['employmentType'],
      serviceTrade: raw['trade'],
      propertyType: raw['propertyType'],
      bedrooms: readInt(raw['bedrooms']),
      businessTag: raw['businessTag'] ?? raw['tag'],
      businessQuery: raw['businessQuery'],
      visaTopic: raw['topic'],
    );
  }

  SearchRouteParameters copyWith({
    String? area,
    int? minPrice,
    int? maxPrice,
    int? minSalary,
    int? maxSalary,
    String? jobCategory,
    String? jobQuery,
    String? employmentType,
    String? serviceTrade,
    String? propertyType,
    int? bedrooms,
    String? businessTag,
    String? businessQuery,
    String? visaTopic,
  }) {
    return SearchRouteParameters(
      area: area ?? this.area,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      minSalary: minSalary ?? this.minSalary,
      maxSalary: maxSalary ?? this.maxSalary,
      jobCategory: jobCategory ?? this.jobCategory,
      jobQuery: jobQuery ?? this.jobQuery,
      employmentType: employmentType ?? this.employmentType,
      serviceTrade: serviceTrade ?? this.serviceTrade,
      propertyType: propertyType ?? this.propertyType,
      bedrooms: bedrooms ?? this.bedrooms,
      businessTag: businessTag ?? this.businessTag,
      businessQuery: businessQuery ?? this.businessQuery,
      visaTopic: visaTopic ?? this.visaTopic,
    );
  }
}
