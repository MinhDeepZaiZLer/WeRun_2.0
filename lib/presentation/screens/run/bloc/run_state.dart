// lib/presentation/screens/run/bloc/run_state.dart
part of 'run_bloc.dart';

@immutable
abstract class RunState {
  const RunState();

  SuggestedRoute? get suggestedRoute => null;
}

// 1. Trạng thái ban đầu (Đã thêm suggestedRoute)
class RunInitial extends RunState {
  final SuggestedRoute? suggestedRoute; 

  const RunInitial({this.suggestedRoute});
}

// 2. Trạng thái đang chạy (Đã thêm suggestedRoute)
class RunInProgress extends RunState {
  final int elapsedSeconds; 
  final double distanceMeters; 
  final double currentSpeedKmh; 
  final List<LocationPoint> route; 
  final bool isPaused;
  final SuggestedRoute? suggestedRoute; // <-- Quan trọng: Giữ đường AI khi đang chạy

  const RunInProgress({
    this.elapsedSeconds = 0,
    this.distanceMeters = 0,
    this.currentSpeedKmh = 0,
    this.route = const [],
    this.isPaused = false,
    this.suggestedRoute,
  });

  RunInProgress copyWith({
    int? elapsedSeconds,
    double? distanceMeters,
    double? currentSpeedKmh,
    List<LocationPoint>? route,
    bool? isPaused,
    SuggestedRoute? suggestedRoute,
  }) {
    return RunInProgress(
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      currentSpeedKmh: currentSpeedKmh ?? this.currentSpeedKmh,
      route: route ?? this.route,
      isPaused: isPaused ?? this.isPaused,
      suggestedRoute: suggestedRoute ?? this.suggestedRoute,
    );
  }
}

// 3. Trạng thái đã hoàn thành
class RunFinished extends RunState {
  final RunActivity activity; 
  const RunFinished(this.activity);
}

// 4. Trạng thái lỗi
class RunFailure extends RunState {
  final String message;
  const RunFailure(this.message);
}