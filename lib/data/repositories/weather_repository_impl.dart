import 'package:injectable/injectable.dart';
import '../../domain/repositories/weather_repository.dart';
import '../services/weather_service.dart';

@LazySingleton(as: WeatherRepository)
class WeatherRepositoryImpl implements WeatherRepository {
  final WeatherService _service;

  WeatherRepositoryImpl(this._service);

  @override
  Future<Map<String, dynamic>> getCurrentWeather(double lat, double lng) {
    return _service.getWeather(lat, lng);
  }
}