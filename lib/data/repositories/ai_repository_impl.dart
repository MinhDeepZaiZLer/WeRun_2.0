import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart'; // Để kiểm tra Debug/Release
import 'package:injectable/injectable.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

import '../../domain/entities/suggested_route.dart';
import '../../domain/repositories/ai_repository.dart';

@LazySingleton(as: AiRepository) // <-- Đánh dấu cho DI
class AiRepositoryImpl implements AiRepository {
  final Dio _dio;

  // URL của backend Python
  // QUAN TRỌNG:
  // 10.0.2.2 là địa chỉ "localhost" đặc biệt của máy ảo Android
  static const String _androidBaseUrl = "http://10.0.2.2:8000/api/v1";
  // Nếu bạn test trên iOS Simulator, dùng:
  static const String _iosBaseUrl = "http://127.0.0.1:8000/api/v1";
  static const String _liveBaseUrl = "https://werun-backend.onrender.com/api/v1";
  AiRepositoryImpl() 
    : _dio = Dio(BaseOptions(
        // Tự động chọn URL đúng
       baseUrl: _liveBaseUrl,
        // Tăng thời gian chờ vì AI mất thời gian tính toán
        connectTimeout: const Duration(seconds: 90), // 90 giây
        receiveTimeout: const Duration(seconds: 90),
      ));

  @override
  Future<SuggestedRoute> getSuggestedRoute({
    required double lat, 
    required double lng, 
    required double distanceKm
  }) async {
    
    // Đảm bảo server Python (uvicorn) của bạn đang chạy!
    print("Đang gọi AI Backend để tìm đường chạy...");
    
    try {
      final response = await _dio.post(
        '/generate_route',
        data: {
          "lat": lat,
          "lng": lng,
          "distance_km": distanceKm,
        },
      );

      if (response.statusCode == 200) {
        // Lấy danh sách [[lng, lat], [lng, lat], ...] từ JSON
        final List<dynamic> pathCoords = response.data['path'];
        final double actualKm = response.data['actual_distance_km'];
        
        // "Dịch" nó sang [LatLng] của MapLibre
        final List<LatLng> routePoints = pathCoords
            .map((coord) => LatLng(
                  coord[1] as double, // [1] là lat
                  coord[0] as double   // [0] là lng
                ))
            .toList();
            
        print("Đã nhận ${routePoints.length} tọa độ từ AI.");
            
        return SuggestedRoute(
          routePoints: routePoints,
          actualDistanceKm: actualKm,
        );
      } else {
        throw Exception("Lỗi khi gọi AI: ${response.statusMessage}");
      }
    } on DioException catch (e) {
      // (Bắt lỗi nếu không kết nối được backend)
      debugPrint("Lỗi AiRepositoryImpl: $e");
      throw Exception("Không thể kết nối đến AI backend. Hãy đảm bảo server Python (uvicorn) đang chạy.");
    } catch (e) {
      throw Exception("Lỗi không xác định: $e");
    }
  }
}