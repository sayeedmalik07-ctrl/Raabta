import 'package:raabta/features/housing/domain/housing_viewing_request.dart';

/// When in-app housing chat may be offered on listing detail (compliance + viewing state).
bool housingInAppMessageEnabled({
  required bool viewingsEnabled,
  required bool isOwner,
  required String? viewerUid,
  required List<HousingViewingRequest> viewingRequests,
}) {
  if (viewingsEnabled) return true;
  if (isOwner) return viewingRequests.isNotEmpty;
  if (viewerUid == null || viewerUid.isEmpty) return false;
  return viewingRequests.any((r) => r.viewerId == viewerUid);
}
