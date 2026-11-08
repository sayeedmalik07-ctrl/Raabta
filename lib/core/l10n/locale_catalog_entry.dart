/// Builds a 9-locale catalog row; unset locales fall back to [english].
///
/// Use `// TODO-TRANSLATE-REVIEW` on keys in [keysNeedingReview] until native review.
Map<String, String> l10nEntry({
  required String english,
  String? arabic,
  String? hindi,
  String? urdu,
  String? malayalam,
  String? nepali,
  String? bengali,
  String? tamil,
  String? filipino,
}) {
  return {
    'English': english,
    'Arabic': arabic ?? english,
    'Hindi': hindi ?? english,
    'Urdu': urdu ?? hindi ?? english,
    'Malayalam': malayalam ?? english,
    'Nepali': nepali ?? english,
    'Bengali': bengali ?? hindi ?? english,
    'Tamil': tamil ?? english,
    'Filipino': filipino ?? english,
  };
}
