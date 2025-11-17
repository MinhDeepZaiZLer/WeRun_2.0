// lib/presentation/screens/history/bloc/history_state.dart
part of 'history_bloc.dart';

@immutable
abstract class HistoryState {
  const HistoryState();
}

// Đang tải
class HistoryLoading extends HistoryState {}

// Đã tải thành công
class HistoryLoaded extends HistoryState {
  final List<RunActivity> activities;
  const HistoryLoaded(this.activities);
}

// Tải thất bại
class HistoryError extends HistoryState {
  final String message;
  const HistoryError(this.message);
}