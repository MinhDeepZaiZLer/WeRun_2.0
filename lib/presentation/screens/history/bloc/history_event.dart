part of 'history_bloc.dart';

@immutable
abstract class HistoryEvent {}

// Báo cho BLoC bắt đầu lắng nghe lịch sử từ Firestore
class LoadHistory extends HistoryEvent {}

// (Nội bộ) Cập nhật UI khi có dữ liệu mới từ Stream
class _HistoryUpdated extends HistoryEvent {
  final List<RunActivity> activities;
  _HistoryUpdated(this.activities);
}