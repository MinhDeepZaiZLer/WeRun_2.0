// lib/presentation/screens/history/bloc/history_bloc.dart
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:meta/meta.dart';

import '../../../../domain/entities/run_activity.dart';
import '../../../../domain/usecases/get_run_history_usecase.dart';

part 'history_event.dart';
part 'history_state.dart';

@injectable // <-- Đánh dấu để DI
class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final GetRunHistoryUsecase _getRunHistoryUsecase;
  StreamSubscription? _historySubscription;

  HistoryBloc(this._getRunHistoryUsecase) : super(HistoryLoading()) {
    on<LoadHistory>(_onLoadHistory);
    on<_HistoryUpdated>(_onHistoryUpdated);
  }

  void _onLoadHistory(LoadHistory event, Emitter<HistoryState> emit) {
    // Hủy stream cũ (nếu có)
    _historySubscription?.cancel();

    // Bắt đầu lắng nghe stream từ Usecase
    _historySubscription = _getRunHistoryUsecase.call().listen(
      (activities) {
        // Khi có dữ liệu mới, add event nội bộ
        add(_HistoryUpdated(activities));
      },
      onError: (error) {
        emit(HistoryError(error.toString()));
      },
    );
  }

  void _onHistoryUpdated(_HistoryUpdated event, Emitter<HistoryState> emit) {
    // Phát ra state mới với danh sách đã được cập nhật
    emit(HistoryLoaded(event.activities));
  }

  @override
  Future<void> close() {
    _historySubscription?.cancel();
    return super.close();
  }
}