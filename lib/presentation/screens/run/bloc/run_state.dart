part of 'run_bloc.dart';

@immutable
abstract class RunState {
  const RunState();
}

// 1. Trạng thái ban đầu (Nút "Start" đang chờ)
class RunInitial extends RunState {
   final SuggestedRoute? suggestedRoute;
   const RunInitial({this.suggestedRoute});
}

// 2. Trạng thái đang chạy hoặc đang tạm dừng
class RunInProgress extends RunState {
  final int elapsedSeconds; // Tổng thời gian chạy (giây)
  final double distanceMeters; // Tổng quãng đường (mét)
  final double currentSpeedKmh; // Tốc độ hiện tại (km/h)
  final List<LocationPoint> route; // Lộ trình đã chạy
  final bool isPaused; // Có đang tạm dừng không?
  final SuggestedRoute? suggestedRoute;

  const RunInProgress({
    this.elapsedSeconds = 0,
    this.distanceMeters = 0,
    this.currentSpeedKmh = 0,
    this.route = const [],
    this.isPaused = false,
    this.suggestedRoute,
    
  });

  // Hàm copyWith để dễ dàng cập nhật state
  RunInProgress copyWith({
    int? elapsedSeconds,
    double? distanceMeters,
    double? currentSpeedKmh,
    List<LocationPoint>? route,
    bool? isPaused,
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

// 3. Trạng thái đã hoàn thành (đã bấm "Stop")
class RunFinished extends RunState {
  final RunActivity activity; // Thông tin tóm tắt lần chạy
  const RunFinished(this.activity);
}

// 4. Trạng thái lỗi (ví dụ: mất quyền GPS)
class RunFailure extends RunState {
  final String message;
  const RunFailure(this.message);
}