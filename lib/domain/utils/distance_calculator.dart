// lib/domain/utils/distance_calculator.dart
import 'dart:math' as math;

/// Tính khoảng cách (bằng mét) giữa 2 tọa độ GPS
double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
  const double earthRadius = 6371000; // mét
  
  final double dLat = _toRadians(lat2 - lat1);
  final double dLon = _toRadians(lon2 - lon1);

  final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
                   math.cos(_toRadians(lat1)) * math.cos(_toRadians(lat2)) *
                   math.sin(dLon / 2) * math.sin(dLon / 2);
  
  final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  
  return earthRadius * c;
}

double _toRadians(double degree) {
  return degree * math.pi / 180;
}