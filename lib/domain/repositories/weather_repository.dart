abstract class WeatherRepository {
  Future<Map<String, dynamic>> getCurrentWeather(double lat, double lng);
}