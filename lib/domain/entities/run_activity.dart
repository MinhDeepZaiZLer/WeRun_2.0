import 'location_point.dart';

class RunActivity {
  final String id;
  final String userId;

  final List<LocationPoint> route; // luu lai toa do gps -> ve ra duong chay
  final int durationInSeconds; //tong thoi gian chay tinh bang giay
  final double distanceInMeters; // tong quang duong chay duoc tinh bang met
  final DateTime timestamp; // thoi diem bat dau chay
  final double avgSpeedKmh; // Tốc độ trung bình (km/h)
  final double caloriesBurned;
  RunActivity({
    required this.id,
    required this.userId,
    required this.route,
    required this.durationInSeconds,
    required this.distanceInMeters,
    required this.timestamp,
    required this.avgSpeedKmh,
    required this.caloriesBurned,
  });
}
