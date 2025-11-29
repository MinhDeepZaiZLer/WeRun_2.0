import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'package:flutter/foundation.dart';
// Import Domain & Data
import '../../../../domain/repositories/user_repository.dart';
import '../../../../domain/repositories/weather_repository.dart';
import '../../../../domain/usecases/get_run_stats_usecase.dart';
import '../../../../data/services/firebase_auth_service.dart';
import '../../../../domain/entities/user.dart' as domain_user; // Alias để tránh trùng tên

part  'home_event.dart';
part 'home_state.dart';

@injectable
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final UserRepository _userRepository;
  final WeatherRepository _weatherRepository;
  final GetRunStatsUsecase _getRunStatsUsecase;
  final FirebaseAuthService _authService;

  HomeBloc(
    this._userRepository,
    this._weatherRepository,
    this._getRunStatsUsecase,
    this._authService,
  ) : super(HomeState()) {
    on<LoadHomeData>(_onLoadHomeData);
    on<RefreshWeather>(_onRefreshWeather);
    on<StartRun>(_onStartRun);
    on<OpenSettings>(_onOpenSettings);
    on<OpenMusic>(_onOpenMusic);
  }

  Future<void> _onLoadHomeData(
    LoadHomeData event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));
    
    try {
      final userId = _authService.currentUserId;
      if (userId == null) {
        emit(state.copyWith(isLoading: false, error: "User not found"));
        return;
      }

      // 1. Lấy thông tin User từ Firestore
      final userEntity = await _userRepository.getUser(userId);
      
      // Chuyển đổi Domain User -> HomeState User
      User? uiUser;
      if (userEntity != null) {
        uiUser = User(
          id: userEntity.id,
          fullName: userEntity.fullName,
          email: userEntity.email,
          lastRunLat: userEntity.lastRunLat,
          lastRunLng: userEntity.lastRunLng,
        );
      }

      // 2. Lấy thống kê chạy
      final stats = await _getRunStatsUsecase(userId);

      emit(state.copyWith(
        isLoading: false,
        user: uiUser,
        stats: stats,
        motivationalMessage: "Welcome back, runner!",
      ));

      // 3. Gọi Weather sau khi có tọa độ (nếu có)
      if (uiUser?.lastRunLat != null && uiUser?.lastRunLng != null) {
        add(RefreshWeather());
      } else {
        // Mặc định lấy thời tiết Đà Nẵng nếu chưa có location
        add(RefreshWeather()); 
      }

    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onRefreshWeather(
    RefreshWeather event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(
      weatherState: state.weatherState.copyWith(isLoading: true),
    ));

    try {
      // Lấy tọa độ từ user hiện tại hoặc mặc định (Đà Nẵng)
      final lat = state.user?.lastRunLat ?? 16.0471;
      final lng = state.user?.lastRunLng ?? 108.2068;

      final weatherData = await _weatherRepository.getCurrentWeather(lat, lng);
      
      final temp = weatherData['temperature'] as double;
      final code = weatherData['weathercode'] as int;

      // Logic map code sang chữ (đã có sẵn trong HomeState helper hoặc làm tại đây)
      // Tạm thời ta map đơn giản để hiển thị
      
      emit(state.copyWith(
        weatherState: WeatherState.fromJson({
          'temperature': temp,
          'weatherCode': code
        }), // Tận dụng factory fromJson đã có
      ));
    } catch (e) {
      emit(state.copyWith(
        weatherState: state.weatherState.copyWith(
          isLoading: false,
          error: "Weather Error",
          temperature: "--",
        ),
      ));
    }
  }

  void _onStartRun(StartRun event, Emitter<HomeState> emit) {
    debugPrint("Start Run Clicked");
  }
  void _onOpenSettings(OpenSettings event, Emitter<HomeState> emit) {}
  void _onOpenMusic(OpenMusic event, Emitter<HomeState> emit) {}
}