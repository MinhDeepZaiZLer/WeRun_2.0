import 'package:dacs4_werun_2_0/domain/entities/run_activity.dart';
import 'package:dacs4_werun_2_0/domain/repositories/run_repository.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class SaveRunUsecase {
  final RunRepository _runRepository;
  SaveRunUsecase(this._runRepository);
  Future<void> call(RunActivity run) {
    return _runRepository.saveRun(run);
  }

}