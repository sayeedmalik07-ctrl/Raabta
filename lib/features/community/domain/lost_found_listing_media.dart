import 'package:raabta/features/community/domain/lost_found_attributes.dart';
import 'package:raabta/features/community/models/community_models.dart';

abstract final class LostFoundListingMedia {
  static bool shouldDisplayPhoto(LostFoundItem item) {
    if (LostFoundCategory.blocksPhoto(item.attributes?.category)) {
      return false;
    }
    final url = item.photoUrl;
    return url != null && url.trim().isNotEmpty;
  }
}
