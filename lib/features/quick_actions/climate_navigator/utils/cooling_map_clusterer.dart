import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:raabta/features/quick_actions/climate_navigator/models/cooling_resource.dart';

/// Grid-based map clustering — same approach as [BranchMapClusterer] in
/// Exchange Locator Pro (`branch_map_clusterer.dart`).
class CoolingMapClusterer {
  const CoolingMapClusterer._();

  static Set<Marker> buildMarkers({
    required List<CoolingResource> resources,
    required double zoom,
    required void Function(CoolingResource resource) onResourceTap,
    required void Function(LatLng center, int count) onClusterTap,
  }) {
    if (resources.isEmpty) return {};

    final cellDegrees = _cellDegreesForZoom(zoom);
    if (cellDegrees <= 0) {
      return {
        for (final resource in resources)
          _resourceMarker(resource, onResourceTap),
      };
    }

    final buckets = <String, List<CoolingResource>>{};
    for (final resource in resources) {
      final key =
          _gridKey(resource.latitude, resource.longitude, cellDegrees);
      buckets.putIfAbsent(key, () => []).add(resource);
    }

    final markers = <Marker>{};
    var clusterIndex = 0;
    for (final group in buckets.values) {
      if (group.length == 1) {
        markers.add(_resourceMarker(group.first, onResourceTap));
        continue;
      }

      final center = _centroid(group);
      final id = 'cooling_cluster_$clusterIndex';
      clusterIndex++;
      markers.add(
        Marker(
          markerId: MarkerId(id),
          position: center,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          infoWindow: InfoWindow(title: '${group.length} cooling spots'),
          onTap: () => onClusterTap(center, group.length),
        ),
      );
    }
    return markers;
  }

  static double markerHueForType(String type, {required bool isVerified}) {
    if (!isVerified) return BitmapDescriptor.hueOrange;
    switch (type) {
      case 'mall':
        return BitmapDescriptor.hueRose;
      case 'metro':
        return BitmapDescriptor.hueAzure;
      case 'mosque':
        return BitmapDescriptor.hueGreen;
      case 'hospital':
        return BitmapDescriptor.hueRed;
      case 'library':
        return BitmapDescriptor.hueViolet;
      case 'shaded_area':
        return BitmapDescriptor.hueYellow;
      default:
        return BitmapDescriptor.hueCyan;
    }
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

  static LatLng _centroid(List<CoolingResource> resources) {
    var lat = 0.0;
    var lng = 0.0;
    for (final r in resources) {
      lat += r.latitude;
      lng += r.longitude;
    }
    final n = resources.length;
    return LatLng(lat / n, lng / n);
  }

  static Marker _resourceMarker(
    CoolingResource resource,
    void Function(CoolingResource resource) onResourceTap,
  ) {
    return Marker(
      markerId: MarkerId(resource.id),
      position: LatLng(resource.latitude, resource.longitude),
      icon: BitmapDescriptor.defaultMarkerWithHue(
        markerHueForType(resource.type, isVerified: resource.isVerified),
      ),
      infoWindow: InfoWindow(
        title: resource.name,
        snippet: resource.address,
      ),
      onTap: () => onResourceTap(resource),
    );
  }
}
