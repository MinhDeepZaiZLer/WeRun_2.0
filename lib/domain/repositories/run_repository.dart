import '/domain/entities/run_activity.dart';


abstract class RunRepository {
  
  Future<void> saveRun(RunActivity run);

  Stream<List<RunActivity>> getRunHistory();
}