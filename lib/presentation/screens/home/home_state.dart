
// ============================================================================
// lib/presentation/screens/home/home_state.dart
part of 'home_bloc.dart';
class HomeState {
  final bool isLoading;
  final User? user;
  final Stats stats;
  final WeatherState weatherState;
  final String motivationalMessage;
  final String? error;

  HomeState({
    this.isLoading = false,
    this.user,
    this.stats = const Stats(),
    this.weatherState = const WeatherState(),
    this.motivationalMessage = '',
    this.error,
  });

  HomeState copyWith({
    bool? isLoading,
    User? user,
    Stats? stats,
    WeatherState? weatherState,
    String? motivationalMessage,
    String? error,
  }) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      stats: stats ?? this.stats,
      weatherState: weatherState ?? this.weatherState,
      motivationalMessage: motivationalMessage ?? this.motivationalMessage,
      error: error,
    );
  }
}

class User {
  final String id;
  final String fullName;
  final String email;
  final double? lastRunLat;
  final double? lastRunLng;

  const User({
    required this.id,
    required this.fullName,
    required this.email,
    this.lastRunLat,
    this.lastRunLng,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      fullName: json['fullName'] ?? json['full_name'] ?? '',
      email: json['email'] ?? '',
      lastRunLat: json['lastRunLat']?.toDouble() ?? json['last_run_lat']?.toDouble(),
      lastRunLng: json['lastRunLng']?.toDouble() ?? json['last_run_lng']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'lastRunLat': lastRunLat,
      'lastRunLng': lastRunLng,
    };
  }
}

class Stats {
  final double todayGoal;
  final double goalProgress;
  final double totalDistance;
  final String bestPace;
  final int consecutiveDays;

  const Stats({
    this.todayGoal = 5000.0, // Default 5km in meters
    this.goalProgress = 0.0,
    this.totalDistance = 0.0,
    this.bestPace = '0:00',
    this.consecutiveDays = 0,
  });

  Stats copyWith({
    double? todayGoal,
    double? goalProgress,
    double? totalDistance,
    String? bestPace,
    int? consecutiveDays,
  }) {
    return Stats(
      todayGoal: todayGoal ?? this.todayGoal,
      goalProgress: goalProgress ?? this.goalProgress,
      totalDistance: totalDistance ?? this.totalDistance,
      bestPace: bestPace ?? this.bestPace,
      consecutiveDays: consecutiveDays ?? this.consecutiveDays,
    );
  }

  factory Stats.fromJson(Map<String, dynamic> json) {
    return Stats(
      todayGoal: (json['todayGoal'] ?? json['today_goal'] ?? 5000.0).toDouble(),
      goalProgress: (json['goalProgress'] ?? json['goal_progress'] ?? 0.0).toDouble(),
      totalDistance: (json['totalDistance'] ?? json['total_distance'] ?? 0.0).toDouble(),
      bestPace: json['bestPace'] ?? json['best_pace'] ?? '0:00',
      consecutiveDays: json['consecutiveDays'] ?? json['consecutive_days'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'todayGoal': todayGoal,
      'goalProgress': goalProgress,
      'totalDistance': totalDistance,
      'bestPace': bestPace,
      'consecutiveDays': consecutiveDays,
    };
  }
}

class WeatherState {
  final bool isLoading;
  final String temperature;
  final String condition;
  final int weatherCode;
  final String? error;

  const WeatherState({
    this.isLoading = false,
    this.temperature = '--°',
    this.condition = 'Loading...',
    this.weatherCode = 0,
    this.error,
  });

  WeatherState copyWith({
    bool? isLoading,
    String? temperature,
    String? condition,
    int? weatherCode,
    String? error,
  }) {
    return WeatherState(
      isLoading: isLoading ?? this.isLoading,
      temperature: temperature ?? this.temperature,
      condition: condition ?? this.condition,
      weatherCode: weatherCode ?? this.weatherCode,
      error: error,
    );
  }

  factory WeatherState.fromJson(Map<String, dynamic> json) {
    return WeatherState(
      isLoading: false,
      temperature: '${json['temperature']?.round() ?? 0}°C',
      condition: _getWeatherCondition(json['weatherCode'] ?? 0),
      weatherCode: json['weatherCode'] ?? 0,
    );
  }

  static String _getWeatherCondition(int code) {
    switch (code) {
      case 0:
        return 'Clear sky';
      case 1:
      case 2:
      case 3:
        return 'Partly cloudy';
      case 45:
      case 48:
        return 'Foggy';
      case 51:
      case 53:
      case 55:
        return 'Drizzle';
      case 61:
      case 63:
      case 65:
        return 'Rain';
      case 71:
      case 73:
      case 75:
        return 'Snow';
      case 95:
      case 96:
      case 99:
        return 'Thunderstorm';
      default:
        return 'Unknown';
    }
  }
}

