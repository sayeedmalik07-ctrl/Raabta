/// Client-side search aliases keyed by category path suffix (Part 6).
///
/// Firestore schema nodes do not carry keyword metadata yet; these aliases
/// supplement localized labels so queries like "iphone" or "AC repair" resolve.
abstract final class PostCategorySearchAliases {
  static const _suffixKeywords = <String, List<String>>{
    'mobiles': [
      'phone',
      'mobile',
      'cell phone',
      'iphone',
      'smartphone',
      'android',
      'samsung',
      'huawei',
      'جوال',
      'موبايل',
      'هاتف',
      'ايفون',
    ],
    'cars': ['car', 'vehicle', 'auto', 'sedan', 'suv', 'toyota', 'nissan'],
    'motorcycles_bikes': ['motorcycle', 'bike', 'scooter'],
    'laptops': ['laptop', 'notebook', 'macbook', 'computer'],
    'televisions': ['tv', 'television', 'screen'],
    'air_conditioners': ['ac', 'air conditioner', 'aircon', 'cooling'],
    'refrigerators': ['fridge', 'refrigerator', 'freezer'],
    'room': ['room', 'bedroom', 'bed space', 'single room'],
    'flat': [
      'flat',
      'apartment',
      'bedroom',
      '2 bedroom',
      '3 bedroom',
      'villa',
      'lusail',
      'شقة',
      'غرفتين',
    ],
    'sharing': ['sharing', 'shared', 'roommate', 'partition'],
    'studio': ['studio', 'bachelor', 'studio apartment'],
    'it': ['developer', 'software', 'programmer', 'tech'],
    'healthcare': ['nurse', 'doctor', 'medical', 'clinic'],
    'driving': ['driver', 'delivery', 'chauffeur'],
    'cleaning': ['cleaner', 'maid', 'housekeeping'],
    'ac_repair': ['ac repair', 'air conditioner', 'hvac', 'ac service'],
    'plumbing': ['plumber', 'pipe', 'leak', 'water'],
    'electrical': ['electrician', 'wiring', 'power'],
  };

  static List<String> forPath(String categoryPath) {
    final normalized = categoryPath.toLowerCase();
    final segment = normalized.split('.').last;
    return _suffixKeywords[segment] ?? const [];
  }
}
