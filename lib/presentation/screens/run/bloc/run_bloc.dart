// lib/presentation/screens/run/bloc/run_bloc.dart
import 'dart:async';
import 'package:dacs4_werun_2_0/data/services/firebase_auth_service.dart';
import 'package:dacs4_werun_2_0/domain/repositories/weather_repository.dart';
import 'package:flutter/foundation.dart'; 
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:location/location.dart';
import 'package:dacs4_werun_2_0/domain/utils/distance_calculator.dart'; 

import '../../../../domain/entities/location_point.dart';
import '../../../../domain/entities/run_activity.dart';
import '../../../../domain/entities/suggested_route.dart'; // <-- Import này
import '../../../../domain/usecases/save_run_usecase.dart';
import '../../../../domain/usecases/get_suggested_route_usecase.dart'; // <-- Import này
import '../../../../data/services/gps_service.dart';

part 'run_event.dart';
part 'run_state.dart';

@injectable 
class RunBloc extends Bloc<RunEvent, RunState> {
  final GpsService _gpsService;
  final SaveRunUsecase _saveRunUsecase;
  final GetSuggestedRouteUsecase _getSuggestedRouteUsecase;
  final WeatherRepository _weatherRepository;
  StreamSubscription<LocationData>? _gpsSubscription;
  Timer? _timer;
  final FirebaseAuthService _authService;
  RunBloc(
    this._gpsService,
    this._saveRunUsecase,
    this._getSuggestedRouteUsecase,
    this._weatherRepository,
    this._authService,
  ) : super(const RunInitial()) { // Thêm const
    on<StartRun>(_onStartRun);
    on<PauseRun>(_onPauseRun);
    on<ResumeRun>(_onResumeRun);
    on<StopRun>(_onStopRun);
    on<DiscardRun>(_onDiscardRun);
    on<SuggestRouteRequested>(_onSuggestRouteRequested);
    on<_LocationChanged>(_onLocationChanged);
    on<_TimerTicked>(_onTimerTicked);
  }

  @override
  Future<void> close() {
    _gpsSubscription?.cancel();
    _timer?.cancel();
    return super.close();
  }

  // --- CẬP NHẬT HÀM NÀY ---
 Future<void> _onSuggestRouteRequested(
      SuggestRouteRequested event, Emitter<RunState> emit) async {
    
    emit(RunInitial(isLoadingAi: true, suggestedRoute: state.suggestedRoute)); 

    try {
      print("📍 [BLoC] Đang gọi GPS..."); 
      
      // Gọi hàm GPS (đã có timeout 5s)
      LocationData? locationData = await _gpsService.getCurrentLocation();
      
      // === THÊM LOGIC DỰ PHÒNG (FALLBACK) ===
      if (locationData?.latitude == null) {
         print("⚠️ [BLoC] Không lấy được GPS thật -> Dùng tọa độ giả lập (Đà Nẵng) để test.");
         // Tự tạo một LocationData giả (Khu vực FPT Đà Nẵng)
         locationData = LocationData.fromMap({
            'latitude': 16.0610, 
           'longitude': 108.2209,
         });
      }
      // =======================================

      print("✅ [BLoC] Chốt tọa độ: ${locationData!.latitude}, ${locationData.longitude}");
      print("🌐 [BLoC] Đang gọi API...");

      final SuggestedRoute suggestedRoute = await _getSuggestedRouteUsecase.call(
        lat: locationData.latitude!,
        lng: locationData.longitude!,
        distanceKm: event.distanceKm,
      );
      
      print("✅ [BLoC] API Xong! Có ${suggestedRoute.routePoints.length} điểm");

      emit(RunInitial(isLoadingAi: false, suggestedRoute: suggestedRoute)); 
      
    } catch (e) {
      print("❌ [BLoC] Lỗi Exception: $e");
      emit(RunInitial(isLoadingAi: false, suggestedRoute: state.suggestedRoute)); 
      emit(RunFailure(e.toString()));
    }
  }

  // --- CẬP NHẬT HÀM NÀY ---
  void _onStartRun(StartRun event, Emitter<RunState> emit) {
    // Lấy đường chạy AI hiện tại (nếu có) để mang theo
    final currentSuggestedRoute = (state is RunInitial) 
        ? (state as RunInitial).suggestedRoute 
        : null;

    _gpsSubscription?.cancel();
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      add(_TimerTicked());
    });

    _gpsSubscription = _gpsService.getLocationStream().listen(
      (locationData) {
        add(_LocationChanged(locationData));
      },
      onError: (error) {
        emit(RunFailure("Không thể lấy vị trí GPS: $error"));
      },
    );

    emit(RunInProgress(
      elapsedSeconds: 0,
      distanceMeters: 0,
      currentSpeedKmh: 0,
      route: [],
      isPaused: false,
      suggestedRoute: currentSuggestedRoute, // <-- Mang theo đường AI
    ));
  }

  // ... (Các hàm _onPauseRun, _onResumeRun, _onTimerTicked, 
  //     _onLocationChanged, _onStopRun, _onDiscardRun GIỮ NGUYÊN) ...
  
  void _onPauseRun(PauseRun event, Emitter<RunState> emit) {
    if (state is RunInProgress) {
      _timer?.cancel();
      _gpsSubscription?.pause();
      emit((state as RunInProgress).copyWith(isPaused: true));
    }
  }

  void _onResumeRun(ResumeRun event, Emitter<RunState> emit) {
    if (state is RunInProgress) {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        add(_TimerTicked());
      });
      _gpsSubscription?.resume();
      emit((state as RunInProgress).copyWith(isPaused: false));
    }
  }

  void _onTimerTicked(_TimerTicked event, Emitter<RunState> emit) {
    if (state is RunInProgress) {
      final currentState = state as RunInProgress;
      emit(currentState.copyWith(elapsedSeconds: currentState.elapsedSeconds + 1));
    }
  }

  void _onLocationChanged(_LocationChanged event, Emitter<RunState> emit) {
    if (state is RunInProgress) {
      final currentState = state as RunInProgress;
      
      final newPoint = LocationPoint(
        latitude: event.locationData.latitude!,
        longitude: event.locationData.longitude!,
        timestamp: DateTime.now(),
      );

      double newDistance = currentState.distanceMeters;
      if (currentState.route.isNotEmpty) {
        final lastPoint = currentState.route.last;
        newDistance += calculateDistance(
          lastPoint.latitude, lastPoint.longitude,
          newPoint.latitude, newPoint.longitude,
        );
      }
      
      final double speedMs = event.locationData.speed ?? 0;
      final double speedKmh = speedMs * 3.6;

      emit(currentState.copyWith(
        distanceMeters: newDistance,
        currentSpeedKmh: speedKmh,
        route: List.from(currentState.route)..add(newPoint),
      ));
    }
  }

  Future<void> _onStopRun(StopRun event, Emitter<RunState> emit) async {
    if (state is RunInProgress) {
      final currentState = state as RunInProgress;
      _timer?.cancel();
      _gpsSubscription?.cancel();
      
      final userId = _authService.currentUserId ?? 'anonymous';

      final double avgSpeedKmh = (currentState.distanceMeters / 1000) / 
                                (currentState.elapsedSeconds / 3600);
      final double calories = (currentState.distanceMeters / 1000) * 70;

      final RunActivity activity = RunActivity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        route: currentState.route,
        durationInSeconds: currentState.elapsedSeconds,
        distanceInMeters: currentState.distanceMeters,
        timestamp: DateTime.now().subtract(Duration(seconds: currentState.elapsedSeconds)),
        avgSpeedKmh: avgSpeedKmh.isNaN ? 0.0 : avgSpeedKmh,
        caloriesBurned: calories,
      );

      try {
        await _saveRunUsecase.call(activity);
        emit(RunFinished(activity));
      } catch (e) {
        emit(RunFailure("Không thể lưu lần chạy: $e"));
      }
    }
  }

  void _onDiscardRun(DiscardRun event, Emitter<RunState> emit) {
    _timer?.cancel();
    _gpsSubscription?.cancel();
    emit(const RunInitial());
    debugPrint("Run discarded. Returning to initial state.");
  }
}