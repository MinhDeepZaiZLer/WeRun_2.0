import 'package:maplibre_gl/maplibre_gl.dart'; // Import LatLng

class SuggestedRoute {
  // Chúng ta sẽ lưu route dưới dạng [LatLng] của MapLibre
  final List<LatLng> routePoints; 
  final double actualDistanceKm;

  SuggestedRoute({
    required this.routePoints,
    required this.actualDistanceKm,
  });
}