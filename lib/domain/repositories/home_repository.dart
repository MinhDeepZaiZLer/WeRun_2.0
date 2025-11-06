
import 'package:dacs4_werun_2_0/domain/entities/user.dart';
import 'package:dacs4_werun_2_0/presentation/screens/home/home_bloc.dart' hide User;

class HomeRepository {
  // API base URL
  final String baseUrl;

  HomeRepository({required this.baseUrl});

  Future<User> getUserProfile(String userId) async {
    // TODO: Implement actual API call
    // Example:
    // final response = await http.get(Uri.parse('$baseUrl/users/$userId'));
    // if (response.statusCode == 200) {
    //   return User.fromJson(json.decode(response.body));
    // }
    throw UnimplementedError('API call not implemented');
  }

  Future<Stats> getUserStats(String userId) async {
    // TODO: Implement actual API call
    throw UnimplementedError('API call not implemented');
  }

  Future<Map<String, dynamic>> getWeather(double lat, double lng) async {
    // TODO: Implement weather API call
    // Example using OpenWeatherMap:
    // final response = await http.get(
    //   Uri.parse('$weatherApiUrl?lat=$lat&lon=$lng&appid=$apiKey')
    // );
    throw UnimplementedError('Weather API call not implemented');
  }

  Future<void> updateGoalProgress(String userId, double distance) async {
    // TODO: Implement API call to update progress
    throw UnimplementedError('API call not implemented');
  }
}
