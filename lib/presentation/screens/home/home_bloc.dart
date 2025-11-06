// lib/presentation/screens/home/home_bloc.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:meta/meta.dart';

// Import các lớp State/Event
// import 'home_state.dart'; 

// Khai báo 2 file "phụ"
part 'home_event.dart';
part 'home_state.dart';


// --- GIẢ ĐỊNH VỀ USECASE (Clean Architecture) ---
// Đây là các Usecase bạn sẽ cần tạo trong thư mục `domain/usecases/`
// và tiêm (inject) vào BLoC này.
// 
// 1. GetFullUserUsecase: Lấy thông tin chi tiết (từ Firestore)
// 2. GetRunStatsUsecase: Lấy các thống kê chạy (totalDistance, bestPace...)
// 3. GetWeatherUsecase: Lấy thời tiết từ API
// 4. GetAiMessageUsecase: Lấy tin nhắn truyền động lực (từ AI API)
// --------------------------------------------------


@injectable // <-- Đánh dấu để DI (GetIt) nhận diện
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  // === KHAI BÁO USECASES (Giả định) ===
  // (Bạn sẽ cần tạo và inject các usecase này)
  // final GetFullUserUsecase _getFullUserUsecase;
  // final GetRunStatsUsecase _getRunStatsUsecase;
  // final GetWeatherUsecase _getWeatherUsecase;
  // final GetAiMessageUsecase _getAiMessageUsecase;

  HomeBloc(
    // === NHẬN USECASES TỪ DI ===
    // this._getFullUserUsecase,
    // this._getRunStatsUsecase,
    // this._getWeatherUsecase,
    // this._getAiMessageUsecase,
  ) : super(HomeState()) { // Trạng thái ban đầu
    
    // Đăng ký các trình xử lý sự kiện
    on<LoadHomeData>(_onLoadHomeData);
    on<RefreshWeather>(_onRefreshWeather);
    on<StartRun>(_onStartRun);
    on<OpenSettings>(_onOpenSettings);
    on<OpenMusic>(_onOpenMusic);
  }

  // === XỬ LÝ SỰ KIỆN LOADHOME ===
  Future<void> _onLoadHomeData(
    LoadHomeData event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));
    
    // 1. Kích hoạt tải thời tiết (nhưng không chờ)
    add(RefreshWeather());

    try {
      // 2. Tải User, Stats, và AI Message song song
      // (Bạn cần implement các Usecase này)
      //
      // final (domainUser, domainStats, aiMessage) = await (
      //   _getFullUserUsecase(),
      //   _getRunStatsUsecase(),
      //   _getAiMessageUsecase(),
      // ).wait(); // Dart 3 record parallel fetch

      // --- PHẦN CODE GIẢ LẬP (Mockup) ---
      // (Xóa phần này khi bạn đã có Usecase thật)
      await Future.delayed(const Duration(seconds: 1));
      final domainUser = User(
        id: '123',
        fullName: 'Minh Deep',
        email: 'minh@example.com',
        lastRunLat: 10.7626,
        lastRunLng: 106.6601,
      );
      final domainStats = Stats(
        todayGoal: 5000.0,
        goalProgress: 0.3,
        totalDistance: 120000.0,
        bestPace: '5:30',
        consecutiveDays: 3,
      );
      const aiMessage = "Một hành trình vạn dặm bắt đầu từ một bước chân!";
      // --- KẾT THÚC CODE GIẢ LẬP ---

      emit(state.copyWith(
        isLoading: false,
        user: domainUser,
        stats: domainStats,
        motivationalMessage: aiMessage,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  // === XỬ LÝ SỰ KIỆN LÀM MỚI THỜI TIẾT ===
  Future<void> _onRefreshWeather(
    RefreshWeather event,
    Emitter<HomeState> emit,
  ) async {
    // 1. Chỉ cập nhật phần WeatherState, giữ nguyên phần còn lại
    emit(state.copyWith(weatherState: const WeatherState(isLoading: true)));

    try {
      // (Bạn cần implement Usecase này)
      // final domainWeather = await _getWeatherUsecase();

      // --- PHẦN CODE GIẢ LẬP (Mockup) ---
      await Future.delayed(const Duration(milliseconds: 500));
      // Giả lập dữ liệu thời tiết (trả về từ Usecase)
      const mockTemperature = 28.0;
      const mockWeatherCode = 1; // 1 = Partly cloudy
      // --- KẾT THÚC CODE GIẢ LẬP ---

      // 2. Lấy logic xử lý code từ file `home_state.dart`
      // (Đảm bảo `_getWeatherCondition` trong `home_state.dart` là public 
      // hoặc di chuyển logic đó ra ngoài)
      // *Giả sử bạn đã sửa `_getWeatherCondition` thành `getWeatherCondition`*
      
      // final condition = WeatherState.getWeatherCondition(mockWeatherCode);
      
      // (Vì hàm đó đang là private, tôi sẽ copy logic tạm vào đây)
      final condition = _mapWeatherCodeToCondition(mockWeatherCode);

      emit(state.copyWith(
        weatherState: WeatherState(
          isLoading: false,
          temperature: '${mockTemperature.round()}°C',
          condition: condition,
          weatherCode: mockWeatherCode,
        ),
      ));
    } catch (e) {
      emit(state.copyWith(
        weatherState: WeatherState(isLoading: false, error: e.toString()),
      ));
    }
  }

  // (Helper function - nên chuyển logic này vào file state/utils)
  String _mapWeatherCodeToCondition(int code) {
    switch (code) {
      case 0: return 'Clear sky';
      case 1: case 2: case 3: return 'Partly cloudy';
      case 45: case 48: return 'Foggy';
      case 51: case 53: case 55: return 'Drizzle';
      case 61: case 63: case 65: return 'Rain';
      case 71: case 73: case 75: return 'Snow';
      case 95: case 96: case 99: return 'Thunderstorm';
      default: return 'Unknown';
    }
  }

  // === CÁC SỰ KIỆN KHÁC (ĐỂ LOGGING HOẶC SIDE EFFECT) ===
  // UI của bạn đã xử lý điều hướng, BLoC chỉ cần biết sự kiện
  
  void _onStartRun(StartRun event, Emitter<HomeState> emit) {
    // TODO: Có thể thêm logic chuẩn bị cho lần chạy (ví dụ: tạo 1 run ID)
    debugPrint('StartRun event triggered');
  }

  void _onOpenSettings(OpenSettings event, Emitter<HomeState> emit) {
    debugPrint('OpenSettings event triggered');
  }

  void _onOpenMusic(OpenMusic event, Emitter<HomeState> emit) {
    // TODO: Có thể emit 1 state để mở overlay music player
    debugPrint('OpenMusic event triggered');
  }
}