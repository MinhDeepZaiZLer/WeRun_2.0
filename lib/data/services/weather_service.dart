import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class WeatherService {
  final Dio _dio = Dio();

  Future<Map<String, dynamic>> getWeather(double lat, double lng) async {
    try {
      final response = await _dio.get(
        'https://api.open-meteo.com/v1/forecast',
        queryParameters: {
          'latitude': lat,
          'longitude': lng,
          'current_weather': true,
        },
      );
      return response.data['current_weather'];
    } catch (e) {
      print("Lỗi Weather API: $e");
      throw Exception("Không thể lấy dữ liệu thời tiết");
    }
  }
}