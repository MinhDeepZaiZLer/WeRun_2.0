import '../entities/suggested_route.dart';

abstract class AiRepository {
  // Hàm mà BLoC sẽ gọi
  Future<SuggestedRoute> getSuggestedRoute({
    required double lat, 
    required double lng, 
    required double distanceKm,
  });
}