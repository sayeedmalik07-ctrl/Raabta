import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:raabta/features/exchange_locator/domain/models/exchange_branch.dart';
import 'package:raabta/features/exchange_locator/presentation/widgets/queue_status_badge.dart';

/// Lightweight grid-based clustering — avoids google_maps_cluster_manager
/// which conflicts with google_maps_flutter_platform_interface Cluster types.
class BranchMapClusterer {
  const BranchMapClusterer._();

  static Set<Marker> buildMarkers({
    required List<ExchangeBranch> branches,
    required double zoom,
    required void Function(ExchangeBranch branch) onBranchTap,
    required void Function(LatLng center, int count) onClusterTap,
  }) {
    if (branches.isEmpty) return {};

    final cellDegrees = _cellDegreesForZoom(zoom);
    if (cellDegrees <= 0) {
      return {
        for (final branch in branches)
          _branchMarker(branch, onBranchTap),
      };
    }

    final buckets = <String, List<ExchangeBranch>>{};
    for (final branch in branches) {
      final key = _gridKey(branch.latitude, branch.longitude, cellDegrees);
      buckets.putIfAbsent(key, () => []).add(branch);
    }

    final markers = <Marker>{};
    var clusterIndex = 0;
    for (final group in buckets.values) {
      if (group.length == 1) {
        markers.add(_branchMarker(group.first, onBranchTap));
        continue;
      }

      final center = _centroid(group);
      final id = 'cluster_$clusterIndex';
      clusterIndex++;
      markers.add(
        Marker(
          markerId: MarkerId(id),
          position: center,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          infoWindow: InfoWindow(title: '${group.length} branches'),
          onTap: () => onClusterTap(center, group.length),
        ),
      );
    }
    return markers;
  }

  static double _cellDegreesForZoom(double zoom) {
    if (zoom >= 14) return 0;
    if (zoom >= 12) return 0.008;
    if (zoom >= 10) return 0.025;
    if (zoom >= 8) return 0.06;
    return 0.15;
  }

  static String _gridKey(double lat, double lng, double cell) {
    final latBucket = (lat / cell).floor();
    final lngBucket = (lng / cell).floor();
    return '$latBucket:$lngBucket';
  }

  static LatLng _centroid(List<ExchangeBranch> branches) {
    var lat = 0.0;
    var lng = 0.0;
    for (final b in branches) {
      lat += b.latitude;
      lng += b.longitude;
    }
    final n = branches.length;
    return LatLng(lat / n, lng / n);
  }

  static Marker _branchMarker(
    ExchangeBranch branch,
    void Function(ExchangeBranch branch) onBranchTap,
  ) {
    return Marker(
      markerId: MarkerId(branch.id),
      position: LatLng(branch.latitude, branch.longitude),
      icon: BitmapDescriptor.defaultMarkerWithHue(markerHueForBranch(branch)),
      infoWindow: InfoWindow(
        title: branch.branchName,
        snippet: branch.displayLocation,
      ),
      onTap: () => onBranchTap(branch),
    );
  }
}
