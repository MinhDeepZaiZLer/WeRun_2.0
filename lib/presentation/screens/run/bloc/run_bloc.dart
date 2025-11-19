// lib/presentation/screens/run/bloc/run_bloc.dart
import 'dart:async';
import 'package:flutter/foundation.dart'; // Cho debugPrint
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:location/location.dart';
// Helper để tính toán
import 'package:dacs4_werun_2_0/domain/utils/distance_calculator.dart'; 

// Import Domain
import '../../../../domain/entities/location_point.dart';
import '../../../../domain/entities/run_activity.dart';
import '../../../../domain/usecases/save_run_usecase.dart';
// Import Data
import '../../../../data/services/gps_service.dart';
import '../../../../domain/usecases/get_suggested_route_usecase.dart'; 
import '../../../../domain/entities/suggested_route.dart'; 
part 'run_event.dart';
part 'run_state.dart';

@injectable // <-- Đánh dấu để DI
class RunBloc extends Bloc<RunEvent, RunState> {
  final GpsService _gpsService;
  final GetSuggestedRouteUsecase _getSuggestedRouteUsecase;
  final SaveRunUsecase _saveRunUsecase;
  // (Chúng ta sẽ cần 1 Usecase để lấy ID của user hiện tại)
  // final GetCurrentUserIdUsecase _getCurrentUserIdUsecase;

  // Dùng để theo dõi Stream từ GPS
  StreamSubscription<LocationData>? _gpsSubscription;
  // Dùng để đếm giây
  Timer? _timer;
  RunBloc(
    this._gpsService,
    this._saveRunUsecase,
    this._getSuggestedRouteUsecase,
  ) : super(RunInitial()) {
    on<StartRun>(_onStartRun);
    on<PauseRun>(_onPauseRun);
    on<ResumeRun>(_onResumeRun);
    on<StopRun>(_onStopRun);
    on<DiscardRun>(_onDiscardRun); // <-- 1. ĐĂNG KÝ EVENT
    on<SuggestRouteRequested>(_onSuggestRouteRequested);
    on<_LocationChanged>(_onLocationChanged);
    on<_TimerTicked>(_onTimerTicked);
  }

  @override
  Future<void> close() {
    // Hủy mọi thứ khi BLoC bị đóng
    _gpsSubscription?.cancel();
    _timer?.cancel();
    return super.close();
  }

  // --- HÀM XỬ LÝ SỰ KIỆN ---

  void _onStartRun(StartRun event, Emitter<RunState> emit) {
    final currentSuggestedRoute = 
        (state is RunInitial) ? (state as RunInitial).suggestedRoute : null;
    // 1. Hủy mọi stream/timer cũ (nếu có)
    _gpsSubscription?.cancel();
    _timer?.cancel();

    // 2. Bắt đầu Timer: cứ 1 giây, add event _TimerTicked
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      add(_TimerTicked());
    });

    // 3. Bắt đầu GPS: cứ có vị trí mới, add event _LocationChanged
    _gpsSubscription = _gpsService.getLocationStream().listen(
      (locationData) {
        add(_LocationChanged(locationData));
      },
      onError: (error) {
        emit(RunFailure("Không thể lấy vị trí GPS: $error"));
      },
    );

    // 4. Đặt trạng thái ban đầu cho lần chạy
    emit(RunInProgress(
      elapsedSeconds: 0,
      distanceMeters: 0,
      currentSpeedKmh: 0,
      route: const [],
      isPaused: false,
      suggestedRoute: currentSuggestedRoute,
    ));
  }

  void _onPauseRun(PauseRun event, Emitter<RunState> emit) {
    if (state is RunInProgress) {
      // 1. Dừng Timer và GPS
      _timer?.cancel();
      _gpsSubscription?.pause();
      // 2. Cập nhật state
      emit((state as RunInProgress).copyWith(isPaused: true));
    }
  }

  void _onResumeRun(ResumeRun event, Emitter<RunState> emit) {
    if (state is RunInProgress) {
      // 1. Khởi động lại Timer
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        add(_TimerTicked());
      });
      // 2. Khởi động lại GPS
      _gpsSubscription?.resume();
      // 3. Cập nhật state
      emit((state as RunInProgress).copyWith(isPaused: false));
    }
  }

  void _onTimerTicked(_TimerTicked event, Emitter<RunState> emit) {
    if (state is RunInProgress) {
      final currentState = state as RunInProgress;
      // Cộng 1 giây vào thời gian
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
      // Chỉ tính quãng đường nếu có ít nhất 1 điểm cũ
      if (currentState.route.isNotEmpty) {
        final lastPoint = currentState.route.last;
        // (Bạn cần tạo hàm `calculateDistance` này)
        newDistance += calculateDistance(
          lastPoint.latitude, lastPoint.longitude,
          newPoint.latitude, newPoint.longitude,
        );
      }
      
      // Lấy tốc độ từ gói location (m/s) và chuyển sang (km/h)
      final double speedMs = event.locationData.speed ?? 0;
      final double speedKmh = speedMs * 3.6;

      // Cập nhật state với dữ liệu mới
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
      
      // 1. Dừng Timer và GPS
      _timer?.cancel();
      _gpsSubscription?.cancel();
      
      // (Giả sử bạn đã có user ID, tạm hard-code là 'user_123')
      // final userId = _getCurrentUserIdUsecase.call();
      const userId = 'user_123'; 

      // 2. Tính toán các chỉ số cuối cùng
      final double avgSpeedKmh = (currentState.distanceMeters / 1000) / 
                                (currentState.elapsedSeconds / 3600);
      final double calories = (currentState.distanceMeters / 1000) * 70; // Giả lập

      // 3. Tạo đối tượng RunActivity
      final RunActivity activity = RunActivity(
        id: DateTime.now().millisecondsSinceEpoch.toString(), // ID tạm
        userId: userId,
        route: currentState.route,
        durationInSeconds: currentState.elapsedSeconds,
        distanceInMeters: currentState.distanceMeters,
        timestamp: DateTime.now().subtract(Duration(seconds: currentState.elapsedSeconds)),
        avgSpeedKmh: avgSpeedKmh,
        caloriesBurned: calories,
      );

      try {
        // 4. Lưu vào CSDL
        await _saveRunUsecase.call(activity);
        // 5. Chuyển sang màn hình Hoàn thành
        emit(RunFinished(activity));
      } catch (e) {
        emit(RunFailure("Không thể lưu lần chạy: $e"));
      }
    }
  }
  Future<void> _onSuggestRouteRequested(
  SuggestRouteRequested event, Emitter<RunState> emit) async {

  try {
    debugPrint("[RunBloc] Đang lấy vị trí GPS hiện tại...");
    // 1. Lấy vị trí GPS hiện tại
    final locationData = await _gpsService.getCurrentLocation();
    if (locationData?.latitude == null || locationData?.longitude == null) {
      emit(const RunFailure("Không thể lấy vị trí GPS. Hãy thử lại."));
      return;
    }

    debugPrint("[RunBloc] Đang gọi AI Backend (Python)...");

    // 2. Gọi AI Backend
    final SuggestedRoute suggestedRoute = await _getSuggestedRouteUsecase.call(
      lat: locationData!.latitude!,
      lng: locationData.longitude!,
      distanceKm: event.distanceKm,
    );
    emit(RunInitial(suggestedRoute: suggestedRoute));

    debugPrint("[RunBloc] AI ĐÃ TRẢ VỀ: ${suggestedRoute.routePoints.length} ĐIỂM");

    // 3. TODO: Chúng ta sẽ vẽ đường này lên bản đồ
    // Tạm thời, chúng ta sẽ bắt đầu chạy (StartRun) VÀ
    // phát ra một state mới (ví dụ RunSuggestionSuccess) 
    // để MapScreen vẽ đường AI này.

    // (Tạm thời chỉ in ra console)

  } catch (e) {
    emit(RunFailure(e.toString()));
  }
}
  void _onDiscardRun(DiscardRun event, Emitter<RunState> emit) {
    // 1. Dừng Timer và GPS
    _timer?.cancel();
    _gpsSubscription?.cancel();
    
    // 2. Quay về trạng thái ban đầu
    emit(RunInitial());
    
    debugPrint("Run discarded. Returning to initial state.");
  }
  
}

