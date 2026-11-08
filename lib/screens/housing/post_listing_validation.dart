import 'package:raabta/screens/housing/l10n/housing_strings.dart';

/// Step inputs for post-listing wizard validation (testable without widgets).
class PostListingStepInput {
  const PostListingStepInput({
    this.photoCount = 0,
    this.title = '',
    this.priceText = '',
    this.description = '',
    this.whatsapp = '',
    this.contactName = '',
  });

  final int photoCount;
  final String title;
  final String priceText;
  final String description;
  final String whatsapp;
  final String contactName;
}

/// Returns a localized error message, or null when the step is valid.
String? validatePostListingStep({
  required int step,
  required String locale,
  required PostListingStepInput input,
}) {
  switch (step) {
    case 0:
      if (input.photoCount <= 0) {
        return HousingStrings.t('error_photo_required', locale);
      }
      return null;
    case 1:
      if (input.title.trim().length < 5) {
        return HousingStrings.t('error_title_min', locale);
      }
      final price = int.tryParse(input.priceText.trim());
      if (price == null || price < 500 || price > 20000) {
        return HousingStrings.t('error_price_range', locale);
      }
      if (input.description.trim().length < 20) {
        return HousingStrings.t('error_description_min', locale);
      }
      return null;
    case 2:
      return null;
    case 3:
      if (input.whatsapp.trim().length < 8) {
        return HousingStrings.t('error_whatsapp_invalid', locale);
      }
      if (input.contactName.trim().isEmpty) {
        return HousingStrings.t('error_contact_name_required', locale);
      }
      return null;
    default:
      return null;
  }
}
