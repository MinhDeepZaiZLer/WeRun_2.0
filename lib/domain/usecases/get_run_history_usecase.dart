import 'package:dacs4_werun_2_0/domain/entities/run_activity.dart';
import 'package:dacs4_werun_2_0/domain/repositories/run_repository.dart';
import 'package:injectable/injectable.dart';

@lazySingleton // Đánh dấu để DI (Ngày 7)
class GetRunHistoryUsecase {
  final RunRepository _runRepository;

  GetRunHistoryUsecase(this._runRepository);

  Stream<List<RunActivity>> call() {
    // Lấy stream lịch sử từ repository
    return _runRepository.getRunHistory();
  }
}