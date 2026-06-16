import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AreaMapPreview extends StatelessWidget {
  const AreaMapPreview({
    super.key,
    required this.area,
    required this.latitude,
    required this.longitude,
  });

  final String area;
  final double latitude;
  final double longitude;

  @override
  Widget build(BuildContext context) {
    final position = LatLng(latitude, longitude);

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: 200,
        child: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: position,
                zoom: 12,
              ),
              markers: {
                Marker(
                  markerId: MarkerId(area),
                  position: position,
                  infoWindow: InfoWindow(
                    title: area,
                    snippet:
                        'Approximate area — exact address hidden for safety',
                  ),
                ),
              },
              circles: {
                Circle(
                  circleId: CircleId('${area}_area'),
                  center: position,
                  radius: 800,
                  fillColor: const Color(0xFF22D3EE).withValues(alpha: 0.15),
                  strokeColor: const Color(0xFF22D3EE),
                  strokeWidth: 2,
                ),
              },
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              liteModeEnabled: true,
            ),
            Positioned(
              bottom: 8,
              left: 8,
              right: 8,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Approximate area only — exact address not shown for safety',
                  style: TextStyle(color: Colors.white, fontSize: 11),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
