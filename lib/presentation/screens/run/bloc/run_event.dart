part of 'run_bloc.dart';

@immutable
abstract class RunEvent {}

class StartRun extends RunEvent {}
class PauseRun extends RunEvent {}
class ResumeRun extends RunEvent {}
class StopRun extends RunEvent {} // Nút "Save"
class DiscardRun extends RunEvent {} // <-- THÊM DÒNG NÀY

class _LocationChanged extends RunEvent {
  final LocationData locationData;
  _LocationChanged(this.locationData);
}

class _TimerTicked extends RunEvent {}