part of 'run_bloc.dart';

@immutable
abstract class RunEvent {}

class StartRun extends RunEvent {}
class PauseRun extends RunEvent {}
class ResumeRun extends RunEvent {}
class StopRun extends RunEvent {} // Nút "Save"
class DiscardRun extends RunEvent {} // <-- THÊM DÒNG NÀY
class SuggestRouteRequested extends RunEvent {
  final double distanceKm;
  SuggestRouteRequested({this.distanceKm = 5.0}); // Mặc định 5km
}
class _LocationChanged extends RunEvent {
  final LocationData locationData;
  _LocationChanged(this.locationData);
}

class _TimerTicked extends RunEvent {}