// lib/data/models/run_activity_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/location_point.dart';
import '../../domain/entities/run_activity.dart';

class RunActivityModel extends RunActivity {
  RunActivityModel({
    required super.id,
    required super.userId,
    required super.route,
    required super.durationInSeconds,
    required super.distanceInMeters,
    required super.timestamp,
    required super.avgSpeedKmh,
    required super.caloriesBurned,
  });

  // Chuyển đổi từ Firestore Document (JSON) sang Model

  factory RunActivityModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    final List<LocationPoint> routePoints =
        (data['route'] as List<dynamic>?)?.map((item) {
          final map = item as Map<String, dynamic>;
          final geoPoint = map['location'] as GeoPoint;
          final timestamp =
              (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();

          return LocationPoint(
            latitude: geoPoint.latitude,
            longitude: geoPoint.longitude,
            timestamp: timestamp,
          );
        }).toList() ??
        [];

    return RunActivityModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      route: routePoints,
      durationInSeconds: data['durationInSeconds'] ?? 0,
      distanceInMeters: (data['distanceInMeters'] ?? 0.0).toDouble(),
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      avgSpeedKmh: (data['avgSpeedKmh'] ?? 0.0).toDouble(),
      caloriesBurned: (data['caloriesBurned'] ?? 0.0).toDouble(),
    );
  }

  // Chuyển đổi từ Model sang JSON (để ghi vào Firestore)
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'durationInSeconds': durationInSeconds,
      'distanceInMeters': distanceInMeters,
      'timestamp': Timestamp.fromDate(timestamp),
      'avgSpeedKmh': avgSpeedKmh,
      'caloriesBurned': caloriesBurned,
      // Lưu route dưới dạng List<GeoPoint>
      'route': route
          .map(
            (point) => {
              'location': GeoPoint(point.latitude, point.longitude),
              'timestamp': Timestamp.fromDate(point.timestamp),
            },
          )
          .toList(),
    };
  }
}
